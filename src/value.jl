function CategoricalValue{T, R}(level::Integer, pool::CategoricalPool{T, R})
    return CategoricalValue(convert(R, level), pool)
end

Base.convert{T, R}(::Type{CategoricalValue{T, R}}, x::CategoricalValue{T, R}) = x
Base.convert{T}(::Type{CategoricalValue{T}}, x::CategoricalValue{T}) = x
Base.convert(::Type{CategoricalValue}, x::CategoricalValue) = x

Base.promote_rule{S, T, R}(::Type{CategoricalValue{S, R}}, ::Type{T}) = promote_type(S, T)
Base.promote_rule{S, T}(::Type{CategoricalValue{S}}, ::Type{T}) = promote_type(S, T)
Base.promote_rule{T}(::Type{CategoricalValue}, ::Type{T}) = T

# To fix ambiguities with definitions from Base
Base.convert{S}(::Type{Nullable{S}}, x::CategoricalValue{Nullable}) =
    convert(Nullable{S}, index(x.pool)[x.level])
Base.convert{S}(::Type{Nullable}, x::CategoricalValue{S}) = convert(Nullable{S}, x)
Base.convert{T}(::Type{Nullable{CategoricalValue{Nullable{T}}}},
                x::CategoricalValue{Nullable{T}}) =
    Nullable(x)
Base.convert{T}(::Type{Ref}, x::CategoricalValue{T}) = RefValue{T}(x)

Base.convert{S, T, R}(::Type{S}, x::CategoricalValue{T, R}) = convert(S, index(x.pool)[x.level])

function Base.show{T}(io::IO, x::CategoricalValue{T})
    if @compat(get(io, :compact, false))
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
@compat Base.:(==)(x::CategoricalValue, y::WeakRef) = index(x.pool)[x.level] == y
@compat Base.:(==)(x::WeakRef, y::CategoricalValue) = y == x

@compat Base.:(==)(x::CategoricalValue, y::Any) = index(x.pool)[x.level] == y
@compat Base.:(==)(x::Any, y::CategoricalValue) = y == x

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
Base.in{T<:Integer}(x::CategoricalValue, y::Range{T}) = index(x.pool)[x.level] in y

Base.hash(x::CategoricalValue, h::UInt) = hash(index(x.pool)[x.level], h)

function Base.isless{S, T}(x::CategoricalValue{S}, y::CategoricalValue{T})
    throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
end

# Method defined even on unordered values so that sort() works
function Base.isless{T}(x::CategoricalValue{T}, y::CategoricalValue{T})
    if x.pool !== y.pool
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    else
        return order(x.pool)[x.level] < order(y.pool)[y.level]
    end
end

function Base.:<{T}(x::CategoricalValue{T}, y::CategoricalValue{T})
    if x.pool !== y.pool
        throw(ArgumentError("CategoricalValue objects with different pools cannot be tested for order"))
    elseif !isordered(x.pool) # !isordered(y.pool) is implied by x.pool === y.pool
        throw(ArgumentError("Unordered CategoricalValue objects cannot be tested for order using <. Use isless instead, or call the ordered! function on the parent array to change this"))
    else
        return order(x.pool)[x.level] < order(y.pool)[y.level]
    end
end

Base.get{T,R}(x::CategoricalValue{T,R}) = convert(T,x)
