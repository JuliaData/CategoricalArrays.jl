# union of all categorical value types
const CatValue{R} = Union{CategoricalValue{T, R} where T,
                          CategoricalString{R}}

# checks whether the type is categorical value
iscatvalue(::Type) = false
iscatvalue(::Type{Union{}}) = false # prevent incorrect dispatch to Type{<:CatValue} method
iscatvalue(::Type{<:CatValue}) = true
iscatvalue(x::Any) = iscatvalue(typeof(x))

leveltype(::Type{<:CategoricalValue{T}}) where {T} = T
leveltype(::Type{<:CategoricalString}) = String
leveltype(::Type) = throw(ArgumentError("Not a categorical value type"))
leveltype(x::Any) = leveltype(typeof(x))
# eltype() is a synonym of leveltype() for categorical values
Base.eltype(::Type{T}) where {T <: CatValue} = leveltype(T)
Base.eltype(x::CatValue) = eltype(typeof(x))

# integer type of category reference codes used by categorical value
reftype(::Type{<:CatValue{R}}) where {R} = R
reftype(x::Any) = reftype(typeof(x))

pool(x::CatValue) = x.pool
level(x::CatValue) = x.level

# extract the type of the original value from array eltype `T`
unwrap_catvaluetype(::Type{T}) where {T} = T
unwrap_catvaluetype(::Type{T}) where {T >: Missing} =
    Union{unwrap_catvaluetype(Missings.T(T)), Missing}
unwrap_catvaluetype(::Type{Union{}}) = Union{} # prevent incorrect dispatch to T<:CatValue method
unwrap_catvaluetype(::Type{Any}) = Any # prevent recursion in T>:Missing method
unwrap_catvaluetype(::Type{T}) where {T <: CatValue} = leveltype(T)

# get the categorical value type given value type `T` and reference type `R`
catvaluetype(::Type{T}, ::Type{R}) where {T >: Missing, R} =
    catvaluetype(Missings.T(T), R)
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

Base.get(x::CatValue) = index(pool(x))[level(x)]
order(x::CatValue) = order(pool(x))[level(x)]

# creates categorical value for `level` from the `pool`
# The result is of type `C` that has "categorical value" trait
catvalue(level::Integer, pool::CategoricalPool{T, R, C}) where {T, R, C} =
    C(convert(R, level), pool)

Base.promote_rule(::Type{C}, ::Type{T}) where {C <: CatValue, T} = promote_type(leveltype(C), T)

# To fix ambiguities with definitions from Base
Base.promote_rule(::Type{C}, ::Type{T}) where {C <: CategoricalString, T <: AbstractString} =
    promote_type(leveltype(C), T)
Base.promote_rule(::Type{C}, ::Type{Missing}) where {C <: CatValue} = Union{C, Missing}

Base.convert(::Type{Nullable{S}}, x::CategoricalValue{Nullable}) where {S} =
    convert(Nullable{S}, get(x))
Base.convert(::Type{Nullable}, x::CategoricalValue{S}) where {S} = convert(Nullable{S}, x)
Base.convert(::Type{Nullable{CategoricalValue{Nullable{T}}}},
             x::CategoricalValue{Nullable{T}}) where {T} =
    Nullable(x)
Base.convert(::Type{Ref}, x::CatValue) = RefValue{leveltype(x)}(x)
Base.convert(::Type{String}, x::CatValue) = convert(String, get(x))
Base.convert(::Type{Any}, x::CatValue) = x

Base.convert(::Type{T}, x::T) where {T <: CatValue} = x
Base.convert(::Type{Union{T, Missing}}, x::T) where {T <: CatValue} = x # override the convert() below
Base.convert(::Type{S}, x::CatValue) where {S} = convert(S, get(x)) # fallback

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

Base.in(x::CatValue, y::Any) = get(x) in y
Base.in(x::CatValue, y::Set) = get(x) in y
Base.in(x::CatValue, y::AbstractRange{T}) where {T<:Integer} = get(x) in y

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
