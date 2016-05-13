function OrdinalValue(level::Integer, pool::OrdinalPool)
    return OrdinalValue(convert(RefType, level), pool)
end

Base.convert{T}(::Type{OrdinalValue{T}}, x::OrdinalValue{T}) = x

function Base.convert{S, T}(::Type{S}, x::OrdinalValue{T})
    return convert(S, x.opool.pool.index[x.level])
end

function Base.show{T}(io::IO, x::OrdinalValue{T})
    if limit_output(io)
        print(io, repr(x.opool.pool.index[x.level]))
    else
        @printf(io, "OrdinalValue{%s} %s (%i/%i)",
                T, repr(x.opool.pool.index[x.level]), x.opool.order[x.level], length(x.opool))
    end
end

Base.:(==)(x::OrdinalValue, y::OrdinalValue) =
    x.opool.pool.index[x.level] == y.opool.pool.index[y.level]
Base.:(==)(x::OrdinalValue, y::Any) = x.opool.pool.index[x.level] == y
Base.:(==)(x::Any, y::OrdinalValue) = y == x

Base.isequal(x::OrdinalValue, y::OrdinalValue) =
    isequal(x.opool.pool.index[x.level], y.opool.pool.index[y.level])
Base.isequal(x::OrdinalValue, y::Any) = isequal(x.opool.pool.index[x.level], y)
Base.isequal(x::Any, y::OrdinalValue) = isequal(y, x)

function Base.isless{S, T}(x::OrdinalValue{S}, y::OrdinalValue{T})
    error("OrdinalValue objects with different pools cannot be compared")
end

function Base.isless{T}(x::OrdinalValue{T}, y::OrdinalValue{T})
    if !(x.opool === y.opool)
        error("OrdinalValue objects with different pools cannot be compared")
    else
        return isless(x.opool.order[x.level], y.opool.order[y.level])
    end
end
