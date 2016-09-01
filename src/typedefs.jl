typealias DefaultRefType UInt32

## Pools

# V is always set to NominalValue{T} or OrdinalValue{T}
# This workaround is needed since this type not defined yet
# See JuliaLang/julia#269
immutable CategoricalPool{T, R <: Integer, V, O}
    index::Vector{T}
    invindex::Dict{T, R}
    order::Vector{R}
    ordered::Vector{T}
    valindex::Vector{V}

    function CategoricalPool{T, R, V, O}(index::Vector{T},
                        invindex::Dict{T, R},
                        order::Vector{R})
        pool = new(index, invindex, order, index[order], V[])
        buildvalues!(pool)
        return pool
    end
end

## Values

immutable CategoricalValue{T, R <: Integer, O}
    level::R
    pool::CategoricalPool{T, R, CategoricalValue{T, R, O}, O}
end

## Arrays

abstract AbstractCategoricalArray{T, N, R, O} <: AbstractArray{CategoricalValue{T, R, O}, N}

type CategoricalArray{T, N, R <: Integer, O} <: AbstractCategoricalArray{T, N, R, O}
    refs::Array{R, N}
    pool::CategoricalPool{T, R, CategoricalValue{T, R, O}, O}
end
typealias CategoricalVector{T, R, O} CategoricalArray{T, 1, R, O}
typealias CategoricalMatrix{T, R, O} CategoricalArray{T, 2, R, O}

## Nullable Arrays

abstract AbstractNullableCategoricalArray{T, N, R, O} <: AbstractArray{Nullable{CategoricalValue{T, R, O}}, N}

type NullableCategoricalArray{T, N, R <: Integer, O} <: AbstractNullableCategoricalArray{T, N, R, O}
    refs::Array{R, N}
    pool::CategoricalPool{T, R, CategoricalValue{T, R, O}, O}
end
typealias NullableCategoricalVector{T, R, O} NullableCategoricalArray{T, 1, R, O}
typealias NullableCategoricalMatrix{T, R, O} NullableCategoricalArray{T, 2, R, O}

## Type Aliases

typealias CategoricalArrays Union{CategoricalArray, NullableCategoricalArray}
