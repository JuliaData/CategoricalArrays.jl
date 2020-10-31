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

function cat_promote_type(::Type{S}, ::Type{T}) where {S, T}
    U = promote_type(S, T)
    U <: Union{SupportedTypes, Missing} ?
        U : typeintersect(Union{SupportedTypes, Missing}, Union{S, T})
end

cat_promote_eltype() = Union{}
cat_promote_eltype(v1, vs...) = cat_promote_type(eltype(v1), cat_promote_eltype(vs...))

Base.promote_rule(::Type{C}, ::Type{T}) where {C <: CategoricalValue, T} =
    promote_type(leveltype(C), T)

Base.promote_rule(::Type{C}, ::Type{T}) where {C <: CategoricalValue, T >: Missing} =
    Union{promote_rule(C, nonmissingtype(T)), Missing}

# To fix ambiguities with definitions from Base
Base.promote_rule(::Type{C}, ::Type{Missing}) where {C <: CategoricalValue} = Union{C, Missing}
Base.promote_rule(::Type{C}, ::Type{Any}) where {C <: CategoricalValue} = Any

Base.promote_rule(::Type{C1}, ::Type{C2}) where
    {R1<:Integer, R2<:Integer,
     C1<:CategoricalValue{<: SupportedTypes, R1},
     C2<:CategoricalValue{<: SupportedTypes, R2}} =
    CategoricalValue{cat_promote_type(leveltype(C1), leveltype(C2)), promote_type(R1, R2)}
Base.promote_rule(::Type{C1}, ::Type{C2}) where {C1<:CategoricalValue, C2<:CategoricalValue} =
    CategoricalValue{cat_promote_type(leveltype(C1), leveltype(C2))}

# General fallbacks
Base.convert(::Type{S}, x::CategoricalValue) where {S <: SupportedTypes} =
    convert(S, get(x))
Base.convert(::Type{Union{S, Missing}}, x::CategoricalValue) where {S <: SupportedTypes} =
    convert(Union{S, Missing}, get(x))
Base.convert(::Type{Union{S, Nothing}}, x::CategoricalValue) where {S <: SupportedTypes} =
    convert(Union{S, Nothing}, get(x))

(::Type{T})(x::T) where {T <: CategoricalValue} = x

Base.Broadcast.broadcastable(x::CategoricalValue) = Ref(x)

function Base.show(io::IO, x::CategoricalValue)
    if nonmissingtype(get(io, :typeinfo, Any)) === nonmissingtype(typeof(x))
        show(io, get(x))
    else
        print(io, typeof(x))
        print(io, ' ')
        show(io, get(x))
        if isordered(pool(x))
            @printf(io, " (%i/%i)", levelcode(x), length(pool(x)))
        end
    end
end

Base.print(io::IO, x::CategoricalValue) = print(io, get(x))
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

Base.:(==)(x::CategoricalValue, y::SupportedTypes) = get(x) == y
Base.:(==)(x::SupportedTypes, y::CategoricalValue) = x == get(y)

@inline function Base.isequal(x::CategoricalValue, y::CategoricalValue)
    if pool(x) === pool(y)
        return level(x) == level(y)
    else
        return isequal(get(x), get(y))
    end
end

Base.isequal(x::CategoricalValue, y::SupportedTypes) = isequal(get(x), y)
Base.isequal(x::SupportedTypes, y::CategoricalValue) = isequal(x, get(y))

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

Base.isless(x::CategoricalValue, y::SupportedTypes) = levelcode(x) < levelcode(x.pool[get(x.pool, y)])
Base.isless(y::SupportedTypes, x::CategoricalValue) = levelcode(x.pool[get(x.pool, y)]) < levelcode(x)

function Base.:<(x::CategoricalValue, y::CategoricalValue)
    if pool(x) !== pool(y)
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    elseif !isordered(pool(x)) # !isordered(pool(y)) is implied by pool(x) === pool(y)
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return levelcode(x) < levelcode(y)
    end
end

function Base.:<(x::CategoricalValue, y::SupportedTypes)
    if !isordered(pool(x))
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return levelcode(x) < levelcode(x.pool[get(x.pool, y)])
    end
end

function Base.:<(y::SupportedTypes, x::CategoricalValue)
    if !isordered(pool(x))
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return levelcode(x.pool[get(x.pool, y)]) < levelcode(x)
    end
end

# JSON of CategoricalValue is JSON of the value it refers to
JSON.lower(x::CategoricalValue) = JSON.lower(get(x))
DataAPI.defaultarray(::Type{CategoricalValue{T, R}}, N) where {T, R} =
  CategoricalArray{T, N, R}
DataAPI.defaultarray(::Type{Union{CategoricalValue{T, R}, Missing}}, N) where {T, R} =
  CategoricalArray{Union{T, Missing}, N, R}

# define appropriate handlers for JSON3 interface
StructTypes.StructType(x::CategoricalValue) = StructTypes.StructType(get(x))
StructTypes.StructType(::Type{<:CategoricalValue{T}}) where {T} = StructTypes.StructType(T)
StructTypes.numbertype(::Type{<:CategoricalValue{T}}) where {T <: Number} = T
StructTypes.construct(::Type{T}, x::CategoricalValue{T}) where {T} = T(get(x))
