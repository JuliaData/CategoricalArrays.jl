const DefaultRefType = UInt32

## Pools

# Type params:
# * `T` type of categorized values
# * `R` integer type for referencing category levels
# * `V` categorical value type
mutable struct CategoricalPool{T, R <: Integer, V}
    levels::Vector{T}       # category levels ordered by their reference codes
    invindex::Dict{T, R}    # map from category levels to their reference codes
    valindex::Vector{V}     # "category value" objects 1-to-1 matching `index`
    ordered::Bool

    function CategoricalPool{T, R, V}(levels::Vector{T},
                                      ordered::Bool) where {T, R, V}
        if length(levels) > typemax(R)
            throw(LevelsException{T, R}(levels[Int(typemax(R))+1:end]))
        end
        invindex = Dict{T, R}(v => i for (i, v) in enumerate(levels))
        if length(invindex) != length(levels)
            throw(ArgumentError("Duplicate entries are not allowed in levels"))
        end
        CategoricalPool{T, R, V}(levels, invindex, ordered)
    end
    function CategoricalPool{T, R, V}(invindex::Dict{T, R},
                                      ordered::Bool) where {T, R, V}
        levels = Vector{T}(undef, length(invindex))
        # If invindex contains non consecutive values, a BoundsError will be thrown
        try
            for (k, v) in invindex
                levels[v] = k
            end
        catch BoundsError
            throw(ArgumentError("Reference codes must be in 1:length(invindex)"))
        end
        if length(invindex) > typemax(R)
            throw(LevelsException{T, R}(levels[typemax(R)+1:end]))
        end
        CategoricalPool{T, R, V}(levels, invindex, ordered)
    end
    function CategoricalPool{T, R, V}(levels::Vector{T},
                                      invindex::Dict{T, R},
                                      ordered::Bool) where {T, R, V}
        if T <: CategoricalValue && T !== Union{}
            throw(ArgumentError("Level type $T cannot be a categorical value type"))
        end
        if !(V <: CategoricalValue)
            throw(ArgumentError("Type $V is not a categorical value type"))
        end
        if V !== CategoricalValue{T, R}
            throw(ArgumentError("V must be CategoricalValue{T, R}"))
        end
        valindex = Vector{V}(undef, length(levels))
        pool = new(levels, invindex, valindex, ordered)
        pool.valindex .= CategoricalValue.(1:length(levels), Ref(pool))
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
    CategoricalValue{T, R <: Integer}

A wrapper around a value of type `T` corresponding to a level
in a `CategoricalPool`.

`CategoricalValue` objects are considered as equal to the value of type `T`
they wrap by `==` and `isequal`.
However, order comparisons like `<` and `isless` are only possible
if [`isordered`](@ref) is `true` for the value's pool, and in that case
the order of the pool's [`levels`](@ref DataAPI.levels) is used rather than the standard
ordering of values of type `T`.
"""
struct CategoricalValue{T, R <: Integer}
    level::R
    pool::CategoricalPool{T, R, CategoricalValue{T, R}}
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

mutable struct CategoricalArray{T, N, R <: Integer, V, C, U} <: AbstractCategoricalArray{T, N, R, V, C, U}
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
const CategoricalVector{T, R <: Integer, V, C, U} = CategoricalArray{T, 1, R, V, C, U}
const CategoricalMatrix{T, R <: Integer, V, C, U} = CategoricalArray{T, 2, R, V, C, U}

CatArrOrSub{T, N, R} = Union{CategoricalArray{T, N, R},
                             SubArray{<:Any, N, <:CategoricalArray{T, <:Any, R}}} where
                             {T, N, R<:Integer}