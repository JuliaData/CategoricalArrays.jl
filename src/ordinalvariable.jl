function OrdinalVariable(level::Integer, pool::OrdinalPool)
    return OrdinalVariable(convert(RefType, level), pool)
end

function Base.convert{S, T}(::Type{S}, x::OrdinalVariable{T})
    return convert(S, x.opool.pool.index[x.level])
end

function Base.show{T}(io::IO, x::OrdinalVariable{T})
    @printf(io, "Ordinal '%s'", convert(T, x))
    return
end

function Base.isless{S, T}(x::OrdinalVariable{S}, y::OrdinalVariable{T})
    error("OrdinalVariable objects with different pools cannot be compared")
end

function Base.isless{T}(x::OrdinalVariable{T}, y::OrdinalVariable{T})
    if !(x.opool === y.opool)
        error("OrdinalVariable objects with different pools cannot be compared")
    else
        return isless(x.opool.order[x.level], y.opool.order[y.level])
    end
end
