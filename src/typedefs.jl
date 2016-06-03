## Pools

abstract CategoricalPool{T, V}

# V is always set to NominalValue{T} or OrdinalValue{T}
# This workaround is needed since this type not defined yet
# See JuliaLang/julia#269
for P in (:NominalPool, :OrdinalPool)
    @eval begin
        immutable $P{T, V} <: CategoricalPool{T, V}
            index::Vector{T}
            invindex::Dict{T, RefType}
            order::Vector{RefType}
            valindex::Vector{V}

            function $P{T}(index::Vector{T},
                           invindex::Dict{T, RefType},
                           order::Vector{RefType})
                pool = new(index, invindex, order, V[])
                buildvalues!(pool)
            end
        end
    end
end


## Values

abstract CategoricalValue{T}

immutable NominalValue{T} <: CategoricalValue{T}
    level::RefType
    pool::NominalPool{T, NominalValue{T}}
end

immutable OrdinalValue{T} <: CategoricalValue{T}
    level::RefType
    pool::OrdinalPool{T, OrdinalValue{T}}
end


## Arrays

type NominalArray{T, N} <: AbstractArray{NominalValue{T}, N}
    pool::NominalPool{T, NominalValue{T}}
    values::Array{RefType, N}
end
typealias NominalVector{T} NominalArray{T, 1}
typealias NominalMatrix{T} NominalArray{T, 2}

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

type NullableNominalArray{T, N} <: AbstractArray{Nullable{NominalValue{T}}, N}
    pool::NominalPool{T, NominalValue{T}}
    values::Array{RefType, N}
end
typealias NullableNominalVector{T} NullableNominalArray{T, 1}
typealias NullableNominalMatrix{T} NullableNominalArray{T, 2}

type NullableOrdinalArray{T, N} <: AbstractArray{Nullable{OrdinalValue{T}}, N}
    pool::OrdinalPool{T, OrdinalValue{T}}
    values::Array{RefType, N}
end
typealias NullableOrdinalVector{T} NullableOrdinalArray{T, 1}
typealias NullableOrdinalMatrix{T} NullableOrdinalArray{T, 2}
