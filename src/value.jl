# checks whether the type is categorical value
iscatvalue(::Type) = false
iscatvalue(::Type{Union{}}) = false # prevent incorrect dispatch to Type{<:CatValue} method
iscatvalue(::Type{<:CatValue}) = true
iscatvalue(x::Any) = iscatvalue(typeof(x))

leveltype(::Type{<:CategoricalValue{T}}) where {T} = T
leveltype(::Type{<:CategoricalString}) = String
leveltype(::Type) = throw(ArgumentError("Not a categorical value type"))
leveltype(x::Any) = leveltype(typeof(x))

# integer type of category reference codes used by categorical value
reftype(::Type{<:CatValue{R}}) where {R} = R
reftype(x::Any) = reftype(typeof(x))

pool(x::CatValue) = x.pool
level(x::CatValue) = x.level

# extract the type of the original value from array eltype `T`
unwrap_catvaluetype(::Type{T}) where {T} = T
unwrap_catvaluetype(::Type{T}) where {T >: Missing} =
    Union{unwrap_catvaluetype(nonmissingtype(T)), Missing}
unwrap_catvaluetype(::Type{Union{}}) = Union{} # prevent incorrect dispatch to T<:CatValue method
unwrap_catvaluetype(::Type{Any}) = Any # prevent recursion in T>:Missing method
unwrap_catvaluetype(::Type{T}) where {T <: CatValue} = leveltype(T)

# get the categorical value type given value type `T` and reference type `R`
catvaluetype(::Type{T}, ::Type{R}) where {T >: Missing, R} =
    catvaluetype(nonmissingtype(T), R)
catvaluetype(::Type{T}, ::Type{R}) where {T <: CatValue, R} =
    catvaluetype(leveltype(T), R)
catvaluetype(::Type{Any}, ::Type{R}) where {R} =
    CategoricalValue{Any, R}  # prevent recursion in T>:Missing method
catvaluetype(::Type{T}, ::Type{R}) where {T, R} =
    CategoricalValue{T, R}
catvaluetype(::Type{<:AbstractString}, ::Type{R}) where {R} =
    CategoricalString{R}
# to prevent incorrect dispatch to T<:CatValue method
catvaluetype(::Type{Union{}}, ::Type{R}) where {R} = CategoricalValue{Union{}, R}

# get the categorical value type given value type `T`
catvaluetype(::Type{T}) where {T >: Missing} = catvaluetype(nonmissingtype(T))
catvaluetype(::Type{T}) where {T <: CatValue} = catvaluetype(leveltype(T))
catvaluetype(::Type{Any}) = CategoricalValue{Any}  # prevent recursion in T>:Missing method
catvaluetype(::Type{T}) where {T} = CategoricalValue{T}
catvaluetype(::Type{<:AbstractString}) = CategoricalString
# to prevent incorrect dispatch to T<:CatValue method
catvaluetype(::Type{Union{}}) where {R} = CategoricalValue{Union{}}

Base.get(x::CatValue) = index(pool(x))[level(x)]

"""
    levelcode(x::Union{CategoricalValue, CategoricalString})

Get the code of categorical value `x`, i.e. its index in the set
of possible values returned by [`levels(x)`](@ref).
"""
levelcode(x::CatValue) = Signed(widen(order(pool(x))[level(x)]))

"""
    levelcode(x::Missing)

Return `missing`.
"""
levelcode(x::Missing) = missing

DataAPI.levels(x::CatValue) = levels(pool(x))

# creates categorical value for `level` from the `pool`
# The result is of type `C` that has "categorical value" trait
catvalue(level::Integer, pool::CategoricalPool{T, R, C}) where {T, R, C} =
    C(convert(R, level), pool)

Base.promote_rule(::Type{C}, ::Type{T}) where {C <: CatValue, T} = promote_type(leveltype(C), T)
Base.promote_rule(::Type{C1}, ::Type{Union{C2, Missing}}) where {C1 <: CatValue, C2 <: CatValue} =
    Union{promote_type(C1, C2), Missing}
# To fix ambiguities with definitions from Base
Base.promote_rule(::Type{C}, ::Type{Missing}) where {C <: CatValue} = Union{C, Missing}
Base.promote_rule(::Type{C}, ::Type{Any}) where {C <: CatValue} = Any

Base.promote_rule(::Type{CategoricalValue{S, R1}},
                  ::Type{CategoricalValue{T, R2}}) where {S, T, R1<:Integer, R2<:Integer} =
    CategoricalValue{promote_type(S, T), promote_type(R1, R2)}
Base.promote_rule(::Type{CategoricalString{R1}},
                  ::Type{CategoricalString{R2}}) where {R1<:Integer, R2<:Integer} =
    CategoricalString{promote_type(R1, R2)}
Base.promote_rule(::Type{C1}, ::Type{C2}) where
    {R1<:Integer, R2<:Integer, C1<:CatValue{R1}, C2<:CatValue{R2}} =
    catvaluetype(promote_type(leveltype(C1), leveltype(C2)), promote_type(R1, R2))
Base.promote_rule(::Type{C1}, ::Type{C2}) where {C1<:CatValue, C2<:CatValue} =
    catvaluetype(promote_type(leveltype(C1), leveltype(C2)))

Base.convert(::Type{Ref}, x::CatValue) = RefValue{leveltype(x)}(x)
Base.convert(::Type{String}, x::CatValue) = convert(String, get(x))
Base.convert(::Type{Any}, x::CatValue) = x

# Defined separately to avoid ambiguities
Base.convert(::Type{AbstractString}, x::CategoricalString) = x
Base.convert(::Type{T}, x::T) where {T <: CatValue} = x
Base.convert(::Type{Union{T, Missing}}, x::T) where {T <: CatValue} = x
Base.convert(::Type{Union{T, Nothing}}, x::T) where {T <: CatValue} = x
# General fallbacks
Base.convert(::Type{S}, x::T) where {S, T <: CatValue} =
    T <: S ? x : convert(S, get(x))
Base.convert(::Type{Union{S, Missing}}, x::T) where {S, T <: CatValue} =
    T <: Union{S, Missing} ? x : convert(Union{S, Missing}, get(x))
Base.convert(::Type{Union{S, Nothing}}, x::T) where {S, T <: CatValue} =
    T <: Union{S, Nothing} ? x : convert(Union{S, Nothing}, get(x))

(::Type{T})(x::T) where {T <: CatValue} = x

Base.Broadcast.broadcastable(x::CatValue) = Ref(x)

if VERSION >= v"0.7.0-DEV.2797"
    function Base.show(io::IO, x::CatValue)
        if nonmissingtype(get(io, :typeinfo, Any)) === nonmissingtype(typeof(x))
            print(io, repr(x))
        elseif isordered(pool(x))
            @printf(io, "%s %s (%i/%i)",
                    typeof(x), repr(x),
                    levelcode(x), length(pool(x)))
        else
            @printf(io, "%s %s", typeof(x), repr(x))
        end
    end
else
    function Base.show(io::IO, x::CatValue)
        if get(io, :compact, false)
            print(io, repr(x))
        elseif isordered(pool(x))
            @printf(io, "%s %s (%i/%i)",
                    typeof(x), repr(x),
                    levelcode(x), length(pool(x)))
        else
            @printf(io, "%s %s", typeof(x), repr(x))
        end
    end
end

Base.print(io::IO, x::CatValue) = print(io, get(x))
Base.repr(x::CatValue) = repr(get(x))

@inline function Base.:(==)(x::CatValue, y::CatValue)
    if pool(x) === pool(y)
        return level(x) == level(y)
    else
        return get(x) == get(y)
    end
end

Base.:(==)(::CatValue, ::Missing) = missing
Base.:(==)(::Missing, ::CatValue) = missing

# To fix ambiguities with Base
Base.:(==)(x::CatValue, y::WeakRef) = get(x) == y
Base.:(==)(x::WeakRef, y::CatValue) = y == x

Base.:(==)(x::CatValue, y::AbstractString) = get(x) == y
Base.:(==)(x::AbstractString, y::CatValue) = y == x

Base.:(==)(x::CatValue, y::Any) = get(x) == y
Base.:(==)(x::Any, y::CatValue) = y == x

@inline function Base.isequal(x::CatValue, y::CatValue)
    if pool(x) === pool(y)
        return level(x) == level(y)
    else
        return isequal(get(x), get(y))
    end
end

Base.isequal(x::CatValue, y::Any) = isequal(get(x), y)
Base.isequal(x::Any, y::CatValue) = isequal(y, x)

Base.isequal(::CatValue, ::Missing) = false
Base.isequal(::Missing, ::CatValue) = false

Base.in(x::CatValue, y::AbstractRange{T}) where {T<:Integer} = get(x) in y

Base.hash(x::CatValue, h::UInt) = hash(get(x), h)

# Method defined even on unordered values so that sort() works
function Base.isless(x::CatValue, y::CatValue)
    if pool(x) !== pool(y)
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    else
        return levelcode(x) < levelcode(y)
    end
end

Base.isless(x::CatValue, y) = levelcode(x) < levelcode(x.pool[get(x.pool, y)])
Base.isless(x::CatValue, y::AbstractString) = levelcode(x) < levelcode(x.pool[get(x.pool, y)])
Base.isless(::CatValue, ::Missing) = true
Base.isless(y, x::CatValue) = levelcode(x.pool[get(x.pool, y)]) < levelcode(x)
Base.isless(y::AbstractString, x::CatValue) = levelcode(x.pool[get(x.pool, y)]) < levelcode(x)
Base.isless(::Missing, ::CatValue) = false

function Base.:<(x::CatValue, y::CatValue)
    if pool(x) !== pool(y)
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    elseif !isordered(pool(x)) # !isordered(pool(y)) is implied by pool(x) === pool(y)
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return levelcode(x) < levelcode(y)
    end
end

function Base.:<(x::CatValue, y)
    if !isordered(pool(x))
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return levelcode(x) < levelcode(x.pool[get(x.pool, y)])
    end
end

Base.:<(x::CatValue, y::AbstractString) = invoke(<, Tuple{CatValue, Any}, x, y)
Base.:<(::CatValue, ::Missing) = missing

function Base.:<(y, x::CatValue)
    if !isordered(pool(x))
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return levelcode(x.pool[get(x.pool, y)]) < levelcode(x)
    end
end

Base.:<(y::AbstractString, x::CatValue) = invoke(<, Tuple{Any, CatValue}, y, x)
Base.:<(::Missing, ::CatValue) = missing

# JSON of CatValue is JSON of the value it refers to
JSON.lower(x::CatValue) = JSON.lower(get(x))
DataAPI.defaultarray(::Type{CategoricalString{R}}, N) where {R} =
  CategoricalArray{String, N, R}
DataAPI.defaultarray(::Type{Union{CategoricalString{R}, Missing}}, N) where {R} =
  CategoricalArray{Union{String, Missing}, N, R}
DataAPI.defaultarray(::Type{CategoricalValue{T, R}}, N) where {T, R} =
  CategoricalArray{T, N, R}
DataAPI.defaultarray(::Type{Union{CategoricalValue{T, R}, Missing}}, N) where {T, R} =
  CategoricalArray{Union{T, Missing}, N, R}

# Efficient method equivalent to the fallback
Base.string(x::CategoricalString) = get(x)
Base.String(x::CategoricalString) = get(x)