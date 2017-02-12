typealias DefaultRefType UInt32

## Pools

# V is always set to CategoricalValue{T}
# This workaround is needed since this type not defined yet
# See JuliaLang/julia#269
type CategoricalPool{T, R <: Integer, V}
    index::Vector{T}
    invindex::Dict{T, R}
    order::Vector{R}
    levels::Vector{T}
    valindex::Vector{V}
    ordered::Bool

    function CategoricalPool{T, R}(index::Vector{T},
                                   invindex::Dict{T, R},
                                   order::Vector{R},
                                   ordered::Bool)
        pool = new(index, invindex, order, index[order], V[], ordered)
        buildvalues!(pool)
        return pool
    end
end

immutable LevelsException{T, R} <: Exception
    levels::Vector{T}
end

## Values

immutable CategoricalValue{T, R <: Integer}
    level::R
    pool::CategoricalPool{T, R, CategoricalValue{T, R}}
end

## Arrays

@compat abstract type AbstractCategoricalArray{T, N, R} <: AbstractArray{CategoricalValue{T, R}, N} end
typealias AbstractCategoricalVector{T, R} AbstractCategoricalArray{T, 1, R}
typealias AbstractCategoricalMatrix{T, R} AbstractCategoricalArray{T, 2, R}

type CategoricalArray{T, N, R <: Integer} <: AbstractCategoricalArray{T, N, R}
    refs::Array{R, N}
    pool::CategoricalPool{T, R, CategoricalValue{T, R}}
end
typealias CategoricalVector{T, R} CategoricalArray{T, 1, R}
typealias CategoricalMatrix{T, R} CategoricalArray{T, 2, R}

## Nullable Arrays

@compat abstract type AbstractNullableCategoricalArray{T, N, R} <: AbstractArray{Nullable{CategoricalValue{T, R}}, N} end
typealias AbstractNullableCategoricalVector{T, R} AbstractNullableCategoricalArray{T, 1, R}
typealias AbstractNullableCategoricalMatrix{T, R} AbstractNullableCategoricalArray{T, 2, R}

type NullableCategoricalArray{T, N, R <: Integer} <: AbstractNullableCategoricalArray{T, N, R}
    refs::Array{R, N}
    pool::CategoricalPool{T, R, CategoricalValue{T, R}}
end
typealias NullableCategoricalVector{T, R} NullableCategoricalArray{T, 1, R}
typealias NullableCategoricalMatrix{T, R} NullableCategoricalArray{T, 2, R}

## Type Aliases

typealias CatArray{T, N, R} Union{CategoricalArray{T, N, R}, NullableCategoricalArray{T, N, R}}
