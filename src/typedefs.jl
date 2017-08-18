using Nulls

@compat const DefaultRefType = UInt32

## Pools

# V is always set to CategoricalValue{T}
# This workaround is needed since this type not defined yet
# See JuliaLang/julia#269
mutable struct CategoricalPool{T, R <: Integer, V}
    index::Vector{T}
    invindex::Dict{T, R}
    order::Vector{R}
    levels::Vector{T}
    valindex::Vector{V}
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

struct CategoricalValue{T, R <: Integer}
    level::R
    pool::CategoricalPool{T, R, CategoricalValue{T, R}}
end

## Arrays

@compat abstract type AbstractCategoricalArray{T, N, R, V, U} <: AbstractArray{Union{CategoricalValue{V, R}, U}, N} end
@compat AbstractCategoricalVector{T, R, V, U} = AbstractCategoricalArray{T, 1, R, V, U}
@compat AbstractCategoricalMatrix{T, R, V, U} = AbstractCategoricalArray{T, 2, R, V, U}

struct CategoricalArray{T, N, R <: Integer, V, U} <: AbstractCategoricalArray{T, N, R, V, U}
    refs::Array{R, N}
    pool::CategoricalPool{V, R, CategoricalValue{V, R}}

    function (::Type{CategoricalArray{T, N, R}})(refs::Array{R, N},
                                                 pool::CategoricalPool{V, R, CategoricalValue{V, R}}) where
                                                 {T, N, R <: Integer, V}
        T === V || T == Union{V, Null} || throw(ArgumentError("T ($T) must be equal to $V or Union{$V, Null}"))
        U = T >: Null ? Null : Union{}
        new{T, N, R, V, U}(refs, pool)
    end
end
@compat CategoricalVector{T, R, V, U} = CategoricalArray{T, 1, V, U}
@compat CategoricalMatrix{T, R, V, U} = CategoricalArray{T, 2, V, U}
