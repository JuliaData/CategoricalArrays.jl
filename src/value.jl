CategoricalValue(pool::CategoricalPool{T, R}, level::Integer) where {T, R} =
    CategoricalValue(pool, convert(R, level))

"""
    CategoricalValue(value, source::Union{CategoricalValue, CategoricalArray})

Return a `CategoricalValue` object wrapping `value` and attached to
the `CategoricalPool` of `source`.
"""
function CategoricalValue(value, source::Union{CategoricalValue, CatArrOrSub})
    p = pool(source)
    i = get(p, value, nothing)
    i === nothing && throw(ArgumentError("level $value not found in source pool"))
    return CategoricalValue(p, i)
end

leveltype(::Type{<:CategoricalValue{T}}) where {T} = T
leveltype(::Type{T}) where {T} = T
leveltype(x::Any) = leveltype(typeof(x))
# to fix ambiguity
leveltype(x::Type{Union{}}) = Union{}

# integer type of category reference codes used by categorical value
reftype(::Type{<:CategoricalValue{<:Any, R}}) where {R} = R
reftype(x::Any) = reftype(typeof(x))

pool(x::CategoricalValue) = x.pool
refcode(x::CategoricalValue) = x.ref
isordered(x::CategoricalValue) = isordered(x.pool)

# extract the type of the original value from array eltype `T`
unwrap_catvaluetype(::Type{T}) where {T} = T
unwrap_catvaluetype(::Type{T}) where {T >: Missing} =
    Union{unwrap_catvaluetype(nonmissingtype(T)), Missing}
unwrap_catvaluetype(::Type{Union{}}) = Union{} # prevent incorrect dispatch to T<:CategoricalValue method
unwrap_catvaluetype(::Type{Any}) = Any # prevent recursion in T>:Missing method
unwrap_catvaluetype(::Type{T}) where {T <: CategoricalValue} = leveltype(T)

"""
    unwrap(x::CategoricalValue)
    unwrap(x::Missing)

Get the value wrapped by categorical value `x`. If `x` is `Missing` return `missing`.
"""
DataAPI.unwrap(x::CategoricalValue) = levels(x)[refcode(x)]

"""
    levelcode(x::CategoricalValue)

Get the code of categorical value `x`, i.e. its index in the set
of possible values returned by [`levels(x)`](@ref DataAPI.levels).
"""
levelcode(x::CategoricalValue) = Signed(widen(refcode(x)))

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

# General fallback
Base.convert(::Type{S}, x::CategoricalValue) where {S <: SupportedTypes} =
    convert(S, unwrap(x))

(::Type{T})(x::T) where {T <: CategoricalValue} = x

Base.Broadcast.broadcastable(x::CategoricalValue) = Ref(x)

function Base.show(io::IO, x::CategoricalValue)
    if get(io, :compact, false) ||
        nonmissingtype(get(io, :typeinfo, Any)) === nonmissingtype(typeof(x))
        show(io, unwrap(x))
    else
        print(io, typeof(x))
        print(io, ' ')
        show(io, unwrap(x))
        if isordered(pool(x))
            @printf(io, " (%i/%i)", levelcode(x), length(pool(x)))
        end
    end
end

Base.print(io::IO, x::CategoricalValue) = print(io, unwrap(x))
Base.string(x::CategoricalValue) = string(unwrap(x))
Base.write(io::IO, x::CategoricalValue) = write(io, unwrap(x))
Base.String(x::CategoricalValue{<:AbstractString}) = String(unwrap(x))

@inline function Base.:(==)(x::CategoricalValue, y::CategoricalValue)
    if pool(x) === pool(y) || pool(x) == pool(y)
        return refcode(x) == refcode(y)
    else
        return unwrap(x) == unwrap(y)
    end
end

Base.:(==)(x::CategoricalValue, y::SupportedTypes) = unwrap(x) == y
Base.:(==)(x::SupportedTypes, y::CategoricalValue) = x == unwrap(y)

@inline function Base.isequal(x::CategoricalValue, y::CategoricalValue)
    if pool(x) === pool(y) || pool(x) == pool(y)
        return refcode(x) == refcode(y)
    else
        return isequal(unwrap(x), unwrap(y))
    end
end

Base.isequal(x::CategoricalValue, y::SupportedTypes) = isequal(unwrap(x), y)
Base.isequal(x::SupportedTypes, y::CategoricalValue) = isequal(x, unwrap(y))

Base.in(x::CategoricalValue, y::AbstractRange{T}) where {T<:Integer} = unwrap(x) in y

Base.hash(x::CategoricalValue, h::UInt) = hash(unwrap(x), h)

# Method defined even on unordered values so that sort() works
function Base.isless(x::CategoricalValue, y::CategoricalValue)
    if pool(x) === pool(y) || pool(x) == pool(y)
        return levelcode(x) < levelcode(y)
    else
        throw(ArgumentError("CategoricalValue objects from unequal pools cannot be tested for order"))
    end
end

Base.isless(x::CategoricalValue, y::SupportedTypes) =
    throw(ArgumentError("cannot compare a `CategoricalValue` to value `v` of type " *
                        "`$(typeof(y))`: wrap `v` using `CategoricalValue(v, catvalue)` " *
                        "or `CategoricalValue(v, catarray)` first"))
Base.isless(y::SupportedTypes, x::CategoricalValue) = isless(x, y)

function Base.:<(x::CategoricalValue, y::CategoricalValue)
    poolx = pool(x)
    pooly = pool(y)
    if poolx === pooly || poolx == pooly
        if isordered(poolx) && isordered(pooly)
            return levelcode(x) < levelcode(y)
        else
            throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
        end
    else
        throw(ArgumentError("CategoricalValue objects from unequal pools cannot be tested for order"))
    end
end

Base.:<(x::CategoricalValue, y::SupportedTypes) =
    throw(ArgumentError("cannot compare a `CategoricalValue` to value `v` of type " *
                        "`$(typeof(y))`: wrap `v` using `CategoricalValue(v, catvalue)` " *
                        "or `CategoricalValue(v, catarray)` first"))
Base.:<(y::SupportedTypes, x::CategoricalValue) = x < y

DataAPI.defaultarray(::Type{CategoricalValue{T, R}}, N) where {T, R} =
    CategoricalArray{T, N, R}
DataAPI.defaultarray(::Type{Union{CategoricalValue{T, R}, Missing}}, N) where {T, R} =
    CategoricalArray{Union{T, Missing}, N, R}