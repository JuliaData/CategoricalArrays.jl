function OrdinalValue(level::Integer, pool::OrdinalPool)
    return OrdinalValue(convert(RefType, level), pool)
end

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
