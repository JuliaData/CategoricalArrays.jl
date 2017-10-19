# categorical value concept
iscatvalue(::Type) = false
iscatvalue(x::Any) = iscatvalue(typeof(x))

# categorical value concept implementation for CategoricalValue and CategoricalString
iscatvalue(::Type{<:CategoricalString}) = true
iscatvalue(::Type{<:CategoricalValue}) = true
valtype(::Type{<:CategoricalValue{T}}) where T = T
valtype(::Type{<:CategoricalString}) = String
# integer type of category reference codes for given type
reftype(::Type) = DefaultRefType
reftype(::Type{<:CategoricalValue{T, R}}) where {T,R} = R
reftype(::Type{<:CategoricalString{R}}) where R = R

pool(x::CatValue) = x.pool
level(x::CatValue) = x.level

# extract the type of original value from categorical value type
unwrap_catvalue_type(::Type{T}) where {T<:CatValue} = valtype(T)
unwrap_catvalue_type(::Type{Union{T, Null}}) where {T<:CatValue} = Union{valtype(T), Null}
unwrap_catvalue_type(::Type{T}) where {T} = T

# default categorical value type for given non-null value type `T` and reference type `R`
catvalue_type(::Type{T}, refType::Type{R}) where {T<:CatValue, R} =
    reftype(T) === R ? T : catvalue_type(valtype(T), refType)
catvalue_type(::Type{Any}, refType::Type{R}) where {R} = # to avoid recursion within Union{T,Null}
    CategoricalValue{Any, R}
catvalue_type(::Type{Union{T, Null}}, refType::Type{R}) where {T, R} =
    catvalue_type(T, R)
catvalue_type(::Type{T}, refType::Type{R}) where {T, R} =
    CategoricalValue{T, R}
catvalue_type(::Type{String}, refType::Type{R}) where {R} =
    CategoricalString{R}

#= type-unstable by more generic version
function catvalue_type(::Type{T}, refType::Type) where {T, R} =
    if iscatvalue(T) # generic categorical value type not included in CatValue
        if reftype(T) === R
            return T
        else
            return catvalue_type(valtype(T), R)
        end
    else
        return CategoricalValue{T, R}
    end
end
=#

# these functions use the "categorical value" concept,
# but are defined only for CatValue union
Base.get(x::CatValue) = index(pool(x))[level(x)]
order(x::CatValue) = order(pool(x))[level(x)]

# creates categorical value for `level` from the `pool`
# The result type is of type `C`, which may be different from `CategoricalValue{T,R}`
function catvalue(level::Integer, pool::CategoricalPool{T, R, C}) where {T, R, C}
    return C(convert(R, level), pool)
end

Base.convert(::Type{CategoricalValue{T, R}}, x::CategoricalValue{T, R}) where {T, R <: Integer} = x
Base.convert(::Type{CategoricalValue{T}}, x::CategoricalValue{T}) where {T} = x
Base.convert(::Type{CategoricalValue}, x::CategoricalValue) = x

Base.convert(::Type{CategoricalString{R}}, x::CategoricalString{R}) where {R <: Integer} = x
Base.convert(::Type{CategoricalString}, x::CategoricalString) = x

Base.convert(::Type{Union{CategoricalValue{T, R}, Null}}, x::CategoricalValue{T, R}) where {T, R <: Integer} = x
Base.convert(::Type{Union{CategoricalValue{T}, Null}}, x::CategoricalValue{T}) where {T} = x
Base.convert(::Type{Union{CategoricalValue, Null}}, x::CategoricalValue) = x

# To fix ambiguities with definitions from Base
Base.promote_rule(::Type{CategoricalValue{S, R}}, ::Type{T}) where {S, T, R} = promote_type(S, T)
Base.promote_rule(::Type{CategoricalValue{S}}, ::Type{T}) where {S, T} = promote_type(S, T)
Base.promote_rule(::Type{CategoricalValue}, ::Type{T}) where {T} = T

# FIXME is that right?
Base.promote_rule(::Type{<:CategoricalString}, ::Type{T}) where {T <: AbstractString} = T

Base.promote_rule(::Type{CategoricalValue}, ::Type{Null}) = Union{CategoricalValue, Null}
Base.promote_rule(::Type{CategoricalValue{T}}, ::Type{Null}) where T = Union{CategoricalValue{T}, Null}
Base.promote_rule(::Type{CategoricalValue{T,R}}, ::Type{Null}) where {T,R} = Union{CategoricalValue{T,R}, Null}

Base.promote_rule(::Type{CategoricalString}, ::Type{Null}) = Union{CategoricalString, Null}
Base.promote_rule(::Type{CategoricalString{R}}, ::Type{Null}) where {R} = Union{CategoricalString{R}, Null}

# Nullable support
Base.convert(::Type{Nullable{S}}, x::CategoricalValue{Nullable}) where {S} =
    convert(Nullable{S}, get(x))
Base.convert(::Type{Nullable}, x::CategoricalValue{S}) where {S} = convert(Nullable{S}, x)
Base.convert(::Type{Nullable{CategoricalValue{Nullable{T}}}},
             x::CategoricalValue{Nullable{T}}) where {T} =
    Nullable(x)
Base.convert(::Type{Ref}, x::CatValue) = RefValue{valtype(x)}(x)
Base.convert(::Type{String}, x::CatValue) = convert(String, get(x))
Base.convert(::Type{Any}, x::CatValue) = x

# fallback
Base.convert(::Type{S}, x::CatValue) where {S} = convert(S, get(x))
# Null support
Base.convert(::Type{Union{S, Null}}, x::CatValue) where {S} = convert(S, get(x))

function Base.show(io::IO, x::CatValue)
    if get(io, :compact, false)
        print(io, repr(x))
    elseif isordered(pool(x))
        @printf(io, "%s %s (%i/%i)",
                typeof(x), repr(x),
                order(x), length(pool(x)))
    else
        @printf(io, "%s %s", typeof(x), repr(x))
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

Base.:(==)(::CatValue, ::Null) = null
Base.:(==)(::Null, ::CatValue) = null

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

Base.isequal(::CatValue, ::Null) = false
Base.isequal(::Null, ::CatValue) = false

Base.in(x::CatValue, y::Any) = get(x) in y
Base.in(x::CatValue, y::Set) = get(x) in y
Base.in(x::CatValue, y::Range{T}) where {T<:Integer} = get(x) in y

Base.hash(x::CatValue, h::UInt) = hash(get(x), h)

# Method defined even on unordered values so that sort() works
function Base.isless(x::CatValue, y::CatValue)
    if pool(x) !== pool(y)
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    else
        return order(x) < order(y)
    end
end

function Base.:<(x::CatValue, y::CatValue)
    if pool(x) !== pool(y)
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    elseif !isordered(pool(x)) # !isordered(pool(y)) is implied by pool(x) === pool(y)
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return order(x) < order(y)
    end
end

# AbstractString interface for CategoricalString
Base.string(x::CategoricalString) = get(x)
Base.length(x::CategoricalString) = length(get(x))
Base.endof(x::CategoricalString) = endof(get(x))
Base.sizeof(x::CategoricalString) = sizeof(get(x))
Base.nextind(x::CategoricalString, i::Integer) = nextind(get(x), i)
Base.prevind(x::CategoricalString, i::Integer) = prevind(get(x), i)
Base.next(x::CategoricalString, i::Int) = next(get(x), i)
Base.getindex(x::CategoricalString, i::Int) = getindex(get(x), i)
Base.codeunit(x::CategoricalString, i::Integer) = codeunit(get(x), i)
Base.ascii(x::CategoricalString) = ascii(get(x))
Base.isvalid(x::CategoricalString) = isvalid(get(x))
Base.isvalid(x::CategoricalString, i::Integer) = isvalid(get(x), i)
Base.match(r::Regex, s::CategoricalString,
           idx::Integer=start(s), add_opts::UInt32=UInt32(0)) =
    match(r, get(s), idx, add_opts)
Base.matchall(r::Regex, s::CategoricalString, overlap::Bool=false) =
    matchall(r, get(s), overlap)
Base.collect(x::CategoricalString) = collect(get(x))
