const DefaultRefType = UInt32

## Pools

# V is always set to CategoricalValue{T}
# This workaround is needed since this type not defined yet
# See JuliaLang/julia#269
mutable struct CategoricalPool{T, R <: Integer, V}
    index::Vector{T}        # category levels ordered by their reference codes
    invindex::Dict{T, R}    # map from category levels to their reference codes
    order::Vector{R}        # 1-to-1 map from `index` to `level` (position of i-th category in `levels`)
    levels::Vector{T}       # category levels ordered by externally specified order
    valindex::Vector{V}     # "category value" objects 1-to-1 matching `index`
    ordered::Bool

    function CategoricalPool{T, R, V}(index::Vector{T},
                                      invindex::Dict{T, R},
                                      order::Vector{R},
                                      ordered::Bool) where {T, R, V}
        pool = new(index, invindex, order, index[order], V[], ordered)
        buildvalues!(pool)
        return pool
    end
end

struct LevelsException{T, R} <: Exception
    levels::Vector{T}
end

## Values

struct CategoricalValue{T, R <: Integer} <: AbstractString
    level::R
    pool::CategoricalPool{T, R, CategoricalValue{T, R}}
end

## Arrays

abstract type AbstractCategoricalArray{T, N, R, V, U} <: AbstractArray{Union{CategoricalValue{V, R}, U}, N} end
AbstractCategoricalVector{T, R, V, U} = AbstractCategoricalArray{T, 1, R, V, U}
AbstractCategoricalMatrix{T, R, V, U} = AbstractCategoricalArray{T, 2, R, V, U}

struct CategoricalArray{T, N, R <: Integer, V, U} <: AbstractCategoricalArray{T, N, R, V, U}
    refs::Array{R, N}
    pool::CategoricalPool{V, R, CategoricalValue{V, R}}

    function CategoricalArray{T, N, R}(refs::Array{R, N},
                                       pool::CategoricalPool{V, R, CategoricalValue{V, R}}) where
                                                 {T, N, R <: Integer, V}
        T === V || T == Union{V, Null} || throw(ArgumentError("T ($T) must be equal to $V or Union{$V, Null}"))
        U = T >: Null ? Null : Union{}
        new{T, N, R, V, U}(refs, pool)
    end
end
CategoricalVector{T, R, V, U} = CategoricalArray{T, 1, V, U}
CategoricalMatrix{T, R, V, U} = CategoricalArray{T, 2, V, U}
