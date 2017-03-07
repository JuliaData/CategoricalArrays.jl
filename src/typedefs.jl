@compat const DefaultRefType = UInt32

## Pools

# V is always set to CategoricalValue{T}
# This workaround is needed since this type not defined yet
# See JuliaLang/julia#269
if VERSION >= v"0.6.0-dev.2643"
    include_string("""
        type CategoricalPool{T, R <: Integer, V}
            index::Vector{T}
            invindex::Dict{T, R}
            order::Vector{R}
            levels::Vector{T}
            valindex::Vector{V}
            hashindex::Vector{UInt}
            ordered::Bool

            function CategoricalPool{T, R, V}(index::Vector{T},
                                              invindex::Dict{T, R},
                                              order::Vector{R},
                                              ordered::Bool) where {T, R, V}
                pool = new(index, invindex, order, index[order], V[], UInt[], ordered)
                buildcaches!(pool)
                return pool
            end
        end
    """)
else
    @eval begin
        type CategoricalPool{T, R <: Integer, V}
            index::Vector{T}
            invindex::Dict{T, R}
            order::Vector{R}
            levels::Vector{T}
            valindex::Vector{V}
            hashindex::Vector{UInt}
            ordered::Bool

            function CategoricalPool{T, R}(index::Vector{T},
                                           invindex::Dict{T, R},
                                           order::Vector{R},
                                           ordered::Bool)
                pool = new(index, invindex, order, index[order], V[], UInt[], ordered)
                buildcaches!(pool)
                return pool
            end
        end
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
@compat AbstractCategoricalVector{T, R} = AbstractCategoricalArray{T, 1, R}
@compat AbstractCategoricalMatrix{T, R} = AbstractCategoricalArray{T, 2, R}

immutable CategoricalArray{T, N, R <: Integer} <: AbstractCategoricalArray{T, N, R}
    refs::Array{R, N}
    pool::CategoricalPool{T, R, CategoricalValue{T, R}}
end
@compat CategoricalVector{T, R} = CategoricalArray{T, 1, R}
@compat CategoricalMatrix{T, R} = CategoricalArray{T, 2, R}

## Nullable Arrays

@compat abstract type AbstractNullableCategoricalArray{T, N, R} <: AbstractArray{Nullable{CategoricalValue{T, R}}, N} end
@compat AbstractNullableCategoricalVector{T, R} = AbstractNullableCategoricalArray{T, 1, R}
@compat AbstractNullableCategoricalMatrix{T, R} = AbstractNullableCategoricalArray{T, 2, R}

immutable NullableCategoricalArray{T, N, R <: Integer} <: AbstractNullableCategoricalArray{T, N, R}
    refs::Array{R, N}
    pool::CategoricalPool{T, R, CategoricalValue{T, R}}
end
@compat NullableCategoricalVector{T, R} = NullableCategoricalArray{T, 1, R}
@compat NullableCategoricalMatrix{T, R} = NullableCategoricalArray{T, 2, R}

## Type Aliases

@compat CatArray{T, N, R} = Union{CategoricalArray{T, N, R}, NullableCategoricalArray{T, N, R}}
@compat CatVector{T, R} = Union{CategoricalVector{T, R}, NullableCategoricalVector{T, R}}
