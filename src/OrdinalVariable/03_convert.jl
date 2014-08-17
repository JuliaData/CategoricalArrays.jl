function Base.convert{S, T}(::Type{S}, x::OrdinalVariable{T})
    return convert(S, x.opool.pool.index[x.level])
end
