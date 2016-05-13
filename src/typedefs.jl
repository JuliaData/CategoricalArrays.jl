## Pools

# V is always set to CategoricalValue{T}
# This workaround is needed since this type not defined yet
# See JuliaLang/julia#269
immutable CategoricalPool{T, V}
    index::Vector{T}
    invindex::Dict{T, RefType}
    valindex::Vector{V}

    function CategoricalPool{T}(index::Vector{T}, invindex::Dict{T, RefType})
        pool = new{T, CategoricalValue{T}}(index, invindex, V[])
        buildvalues!(pool, CategoricalValue)
    end
end

# V is always set to OrdinalValue{T}
immutable OrdinalPool{T, V}
    pool::CategoricalPool{T}
    order::Vector{RefType}
    valindex::Vector{V}

    function OrdinalPool{T}(pool::CategoricalPool{T}, order::Vector{RefType})
        pool = new{T, OrdinalValue{T}}(pool, order, V[])
        buildvalues!(pool, OrdinalValue)
    end
end

typealias CatOrdPool Union{CategoricalPool, OrdinalPool}


## Values

immutable CategoricalValue{T}
    level::RefType
    pool::CategoricalPool{T}
end

immutable OrdinalValue{T}
    level::RefType
    opool::OrdinalPool{T}
end


## Arrays

type CategoricalArray{T, N} <: AbstractArray{CategoricalValue{T}, N}
    pool::CategoricalPool{T, CategoricalValue{T}}
    values::Array{RefType, N}
end
typealias CategoricalVector{T} CategoricalArray{T, 1}
typealias CategoricalMatrix{T} CategoricalArray{T, 2}

abstract AbstractOrdinalArray{T, N} <: AbstractArray{OrdinalValue{T}, N}
typealias AbstractOrdinalVector{T} AbstractOrdinalArray{T, 1}
typealias AbstractOrdinalMatrix{T} AbstractOrdinalArray{T, 2}

type OrdinalArray{T, N} <: AbstractOrdinalArray{T, N}
    pool::OrdinalPool{T, OrdinalValue{T}}
    values::Array{RefType, N}
end
typealias OrdinalVector{T} OrdinalArray{T, 1}
typealias OrdinalMatrix{T} OrdinalArray{T, 2}


## Nullable Arrays

type NullableCategoricalArray{T, N} <: AbstractArray{Nullable{CategoricalValue{T}}, N}
    pool::CategoricalPool{T, CategoricalValue{T}}
    values::Array{RefType, N}
end
typealias NullableCategoricalVector{T} NullableCategoricalArray{T, 1}
typealias NullableCategoricalMatrix{T} NullableCategoricalArray{T, 2}

type NullableOrdinalArray{T, N} <: AbstractArray{Nullable{OrdinalValue{T}}, N}
    pool::OrdinalPool{T, OrdinalValue{T}}
    values::Array{RefType, N}
end
typealias NullableOrdinalVector{T} NullableOrdinalArray{T, 1}
typealias NullableOrdinalMatrix{T} NullableOrdinalArray{T, 2}
