CategoricalValue(level::Integer, pool::CategoricalPool{T, R}) where {T, R} =
    CategoricalValue(convert(R, level), pool)

leveltype(::Type{<:CategoricalValue{T}}) where {T} = T
leveltype(::Type{T}) where {T} = T
leveltype(x::Any) = leveltype(typeof(x))
# to fix ambiguity
leveltype(x::Type{Union{}}) = Union{}

# integer type of category reference codes used by categorical value
reftype(::Type{<:CategoricalValue{<:Any, R}}) where {R} = R
reftype(x::Any) = reftype(typeof(x))

pool(x::CategoricalValue) = x.pool
level(x::CategoricalValue) = x.level
isordered(x::CategoricalValue) = isordered(x.pool)

# extract the type of the original value from array eltype `T`
unwrap_catvaluetype(::Type{T}) where {T} = T
unwrap_catvaluetype(::Type{T}) where {T >: Missing} =
    Union{unwrap_catvaluetype(nonmissingtype(T)), Missing}
unwrap_catvaluetype(::Type{Union{}}) = Union{} # prevent incorrect dispatch to T<:CategoricalValue method
unwrap_catvaluetype(::Type{Any}) = Any # prevent recursion in T>:Missing method
unwrap_catvaluetype(::Type{T}) where {T <: CategoricalValue} = leveltype(T)

Base.get(x::CategoricalValue) = levels(x)[level(x)]

"""
    levelcode(x::CategoricalValue)

Get the code of categorical value `x`, i.e. its index in the set
of possible values returned by [`levels(x)`](@ref DataAPI.levels).
"""
levelcode(x::CategoricalValue) = Signed(widen(level(x)))

"""
    levelcode(x::Missing)

Return `missing`.
"""
levelcode(x::Missing) = missing

DataAPI.levels(x::CategoricalValue) = levels(pool(x))

Base.promote_rule(::Type{C}, ::Type{T}) where {C <: CategoricalValue, T} = promote_type(leveltype(C), T)
Base.promote_rule(::Type{C1}, ::Type{Union{C2, Missing}}) where {C1 <: CategoricalValue, C2 <: CategoricalValue} =
    Union{promote_type(C1, C2), Missing}
# To fix ambiguities with definitions from Base
Base.promote_rule(::Type{C}, ::Type{Missing}) where {C <: CategoricalValue} = Union{C, Missing}
Base.promote_rule(::Type{C}, ::Type{Any}) where {C <: CategoricalValue} = Any


Base.promote_rule(::Type{C1}, ::Type{C2}) where
    {R1<:Integer, R2<:Integer, C1<:CategoricalValue{<:Any, R1}, C2<:CategoricalValue{<:Any, R2}} =
    CategoricalValue{promote_type(leveltype(C1), leveltype(C2)), promote_type(R1, R2)}
Base.promote_rule(::Type{C1}, ::Type{C2}) where {C1<:CategoricalValue, C2<:CategoricalValue} =
    CategoricalValue{promote_type(leveltype(C1), leveltype(C2))}

Base.convert(::Type{Ref}, x::CategoricalValue) = RefValue{leveltype(x)}(x)
Base.convert(::Type{String}, x::CategoricalValue) = convert(String, get(x))
Base.convert(::Type{Any}, x::CategoricalValue) = x

# Defined separately to avoid ambiguities
Base.convert(::Type{T}, x::T) where {T <: CategoricalValue} = x
Base.convert(::Type{Union{T, Missing}}, x::T) where {T <: CategoricalValue} = x
Base.convert(::Type{Union{T, Nothing}}, x::T) where {T <: CategoricalValue} = x
# General fallbacks
Base.convert(::Type{S}, x::T) where {S, T <: CategoricalValue} =
    T <: S ? x : convert(S, get(x))
Base.convert(::Type{Union{S, Missing}}, x::T) where {S, T <: CategoricalValue} =
    T <: Union{S, Missing} ? x : convert(Union{S, Missing}, get(x))
Base.convert(::Type{Union{S, Nothing}}, x::T) where {S, T <: CategoricalValue} =
    T <: Union{S, Nothing} ? x : convert(Union{S, Nothing}, get(x))

(::Type{T})(x::T) where {T <: CategoricalValue} = x

Base.Broadcast.broadcastable(x::CategoricalValue) = Ref(x)

function Base.show(io::IO, x::CategoricalValue)
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

Base.print(io::IO, x::CategoricalValue) = print(io, get(x))
Base.repr(x::CategoricalValue) = repr(get(x))
Base.string(x::CategoricalValue) = string(get(x))
Base.write(io::IO, x::CategoricalValue) = write(io, get(x))
Base.String(x::CategoricalValue{<:AbstractString}) = String(get(x))

@inline function Base.:(==)(x::CategoricalValue, y::CategoricalValue)
    if pool(x) === pool(y)
        return level(x) == level(y)
    else
        return get(x) == get(y)
    end
end

Base.:(==)(::CategoricalValue, ::Missing) = missing
Base.:(==)(::Missing, ::CategoricalValue) = missing

# To fix ambiguities with Base
Base.:(==)(x::CategoricalValue, y::WeakRef) = get(x) == y
Base.:(==)(x::WeakRef, y::CategoricalValue) = y == x

Base.:(==)(x::CategoricalValue, y::Any) = get(x) == y
Base.:(==)(x::Any, y::CategoricalValue) = y == x

@inline function Base.isequal(x::CategoricalValue, y::CategoricalValue)
    if pool(x) === pool(y)
        return level(x) == level(y)
    else
        return isequal(get(x), get(y))
    end
end

Base.isequal(x::CategoricalValue, y::Any) = isequal(get(x), y)
Base.isequal(x::Any, y::CategoricalValue) = isequal(y, x)

Base.isequal(::CategoricalValue, ::Missing) = false
Base.isequal(::Missing, ::CategoricalValue) = false

Base.in(x::CategoricalValue, y::AbstractRange{T}) where {T<:Integer} = get(x) in y

Base.hash(x::CategoricalValue, h::UInt) = hash(get(x), h)

# Method defined even on unordered values so that sort() works
function Base.isless(x::CategoricalValue, y::CategoricalValue)
    if pool(x) !== pool(y)
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    else
        return levelcode(x) < levelcode(y)
    end
end

Base.isless(x::CategoricalValue, y) = levelcode(x) < levelcode(x.pool[get(x.pool, y)])
Base.isless(::CategoricalValue, ::Missing) = true
Base.isless(y, x::CategoricalValue) = levelcode(x.pool[get(x.pool, y)]) < levelcode(x)
Base.isless(::Missing, ::CategoricalValue) = false

function Base.:<(x::CategoricalValue, y::CategoricalValue)
    if pool(x) !== pool(y)
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    elseif !isordered(pool(x)) # !isordered(pool(y)) is implied by pool(x) === pool(y)
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return levelcode(x) < levelcode(y)
    end
end

function Base.:<(x::CategoricalValue, y)
    if !isordered(pool(x))
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return levelcode(x) < levelcode(x.pool[get(x.pool, y)])
    end
end

function Base.:<(y, x::CategoricalValue)
    if !isordered(pool(x))
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return levelcode(x.pool[get(x.pool, y)]) < levelcode(x)
    end
end

Base.:<(::CategoricalValue, ::Missing) = missing
Base.:<(::Missing, ::CategoricalValue) = missing

# JSON of CategoricalValue is JSON of the value it refers to
JSON.lower(x::CategoricalValue) = JSON.lower(get(x))
DataAPI.defaultarray(::Type{CategoricalValue{T, R}}, N) where {T, R} =
  CategoricalArray{T, N, R}
DataAPI.defaultarray(::Type{Union{CategoricalValue{T, R}, Missing}}, N) where {T, R} =
  CategoricalArray{Union{T, Missing}, N, R}

# define appropriate handlers for JSON3 interface
StructTypes.StructType(::Type{<:CategoricalValue{<:String}}) = StructTypes.StringType()
StructTypes.StructType(::Type{<:CategoricalValue{<:Symbol}}) = StructTypes.StringType()
StructTypes.StructType(::Type{<:CategoricalValue{<:Number}}) = StructTypes.NumberType()
StructTypes.numbertype(::Type{CategoricalValue{T}}) where {T <: Number} = T

(::Type{T})(x::CategoricalValue{<:Number}) where {T <: Number} = T(get(x))