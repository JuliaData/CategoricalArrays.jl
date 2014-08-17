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
