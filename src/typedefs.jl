const DefaultRefType = UInt32

## Pools

# Type params:
# * `T` type of categorized values
# * `R` integer type for referencing category levels
# * `V` categorical value type
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
        if iscatvalue(T)
            throw(ArgumentError("Level type $T cannot be a categorical value type"))
        end
        if !iscatvalue(V)
            throw(ArgumentError("Type $V is not a categorical value type"))
        end
        if leveltype(V) !== T
            throw(ArgumentError("Level type of the categorical value ($(leveltype(V))) and of the pool ($T) do not match"))
        end
        if reftype(V) !== R
            throw(ArgumentError("Reference type of the categorical value ($(reftype(V))) and of the pool ($R) do not match"))
        end
        levels = similar(index)
        levels[order] = index
        pool = new(index, invindex, order, levels, V[], ordered)
        buildvalues!(pool)
        return pool
    end
end

struct LevelsException{T, R} <: Exception
    levels::Vector{T}
end

struct OrderedLevelsException{T, S} <: Exception
    newlevel::S
    levels::Vector{T}
end

## Values

"""
Default categorical value type for
referencing values of type `T`.
"""
struct CategoricalValue{T, R <: Integer}
    level::R
    pool::CategoricalPool{T, R, CategoricalValue{T, R}}
end

"""
`String` categorical value.
Provides `AbstractString` interoperability.
"""
struct CategoricalString{R <: Integer} <: AbstractString
    level::R
    pool::CategoricalPool{String, R, CategoricalString{R}}
end

## Arrays

# Type params:
# * `T` original type of elements before categorization, could be Union{T, Missing}
# * `N` array dimension
# * `R` integer type for referencing category levels
# * `V` original type of elements (excluding Missing) before categorization
# * `C` categorical value type
# * `U` type of missing value, `Union{}` if missing values are not accepted
abstract type AbstractCategoricalArray{T, N, R, V, C, U} <: AbstractArray{Union{C, U}, N} end
const AbstractCategoricalVector{T, R, V, C, U} = AbstractCategoricalArray{T, 1, R, V, C, U}
const AbstractCategoricalMatrix{T, R, V, C, U} = AbstractCategoricalArray{T, 2, R, V, C, U}

struct CategoricalArray{T, N, R <: Integer, V, C, U} <: AbstractCategoricalArray{T, N, R, V, C, U}
    refs::Array{R, N}
    pool::CategoricalPool{V, R, C}

    function CategoricalArray{T, N}(refs::Array{R, N},
                                    pool::CategoricalPool{V, R, C}) where
                                                 {T, N, R <: Integer, V, C}
        T === V || T == Union{V, Missing} || throw(ArgumentError("T ($T) must be equal to $V or Union{$V, Missing}"))
        U = T >: Missing ? Missing : Union{}
        new{T, N, R, V, C, U}(refs, pool)
    end
end
const CategoricalVector{T, R, V, C, U} = CategoricalArray{T, 1, V, C, U}
const CategoricalMatrix{T, R, V, C, U} = CategoricalArray{T, 2, V, C, U}
