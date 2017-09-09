function CategoricalValue(level::Integer, pool::CategoricalPool{T, R}) where {T, R}
    return CategoricalValue(convert(R, level), pool)
end

Base.convert(::Type{CategoricalValue{T, R}}, x::CategoricalValue{T, R}) where {T, R <: Integer} = x
Base.convert(::Type{CategoricalValue{T}}, x::CategoricalValue{T}) where {T} = x
Base.convert(::Type{CategoricalValue}, x::CategoricalValue) = x

Base.convert(::Type{Union{CategoricalValue{T, R}, Null}}, x::CategoricalValue{T, R}) where {T, R <: Integer} = x
Base.convert(::Type{Union{CategoricalValue{T}, Null}}, x::CategoricalValue{T}) where {T} = x
Base.convert(::Type{Union{CategoricalValue, Null}}, x::CategoricalValue) = x

Base.promote_rule(::Type{CategoricalValue{S, R}}, ::Type{T}) where {S, T, R} = promote_type(S, T)
Base.promote_rule(::Type{CategoricalValue{S}}, ::Type{T}) where {S, T} = promote_type(S, T)
Base.promote_rule(::Type{CategoricalValue}, ::Type{T}) where {T} = T

# To fix ambiguities with definitions from Base
Base.convert(::Type{Nullable{S}}, x::CategoricalValue{Nullable}) where {S} =
    convert(Nullable{S}, index(x.pool)[x.level])
Base.convert(::Type{Nullable}, x::CategoricalValue{S}) where {S} = convert(Nullable{S}, x)
Base.convert(::Type{Nullable{CategoricalValue{Nullable{T}}}},
             x::CategoricalValue{Nullable{T}}) where {T} =
    Nullable(x)
Base.convert(::Type{Ref}, x::CategoricalValue{T}) where {T} = RefValue{T}(x)
Base.convert(::Type{Any}, x::CategoricalArrays.CategoricalValue) = x

Base.convert(::Type{S}, x::CategoricalValue) where {S} = convert(S, index(x.pool)[x.level])
Base.convert(::Type{Union{S, Null}}, x::CategoricalValue) where {S} = convert(S, index(x.pool)[x.level])

function Base.show(io::IO, x::CategoricalValue{T}) where {T}
    if get(io, :compact, false)
        print(io, repr(index(x.pool)[x.level]))
    elseif isordered(x.pool)
        @printf(io, "%s %s (%i/%i)",
                typeof(x),
                repr(index(x.pool)[x.level]),
                order(x.pool)[x.level], length(x.pool))
    else
        @printf(io, "%s %s",
                typeof(x),
                repr(index(x.pool)[x.level]))
    end
end

@inline function Base.:(==)(x::CategoricalValue, y::CategoricalValue)
    if x.pool === y.pool
        return x.level == y.level
    else
        return index(x.pool)[x.level] == index(y.pool)[y.level]
    end
end

# To fix ambiguities with Base
Base.:(==)(x::CategoricalValue, y::WeakRef) = index(x.pool)[x.level] == y
Base.:(==)(x::WeakRef, y::CategoricalValue) = y == x

Base.:(==)(x::CategoricalValue, y::Any) = index(x.pool)[x.level] == y
Base.:(==)(x::Any, y::CategoricalValue) = y == x

@inline function Base.isequal(x::CategoricalValue, y::CategoricalValue)
    if x.pool === y.pool
        return x.level == y.level
    else
        return isequal(index(x.pool)[x.level], index(y.pool)[y.level])
    end
end

Base.isequal(x::CategoricalValue, y::Any) = isequal(index(x.pool)[x.level], y)
Base.isequal(x::Any, y::CategoricalValue) = isequal(y, x)

Base.in(x::CategoricalValue, y::Any) = index(x.pool)[x.level] in y
Base.in(x::CategoricalValue, y::Range{T}) where {T<:Integer} = index(x.pool)[x.level] in y

Base.hash(x::CategoricalValue, h::UInt) = hash(index(x.pool)[x.level], h)

function Base.isless(x::CategoricalValue{S}, y::CategoricalValue{T}) where {S, T}
    throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
end

# Method defined even on unordered values so that sort() works
function Base.isless(x::CategoricalValue{T}, y::CategoricalValue{T}) where {T}
    if x.pool !== y.pool
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    else
        return order(x.pool)[x.level] < order(y.pool)[y.level]
    end
end

function Base.:<(x::CategoricalValue{T}, y::CategoricalValue{T}) where {T}
    if x.pool !== y.pool
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    elseif !isordered(x.pool) # !isordered(y.pool) is implied by x.pool === y.pool
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return order(x.pool)[x.level] < order(y.pool)[y.level]
    end
end

Base.get(x::CategoricalValue{T,R}) where {T,R} = convert(T,x)
