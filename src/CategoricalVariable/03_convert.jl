function Base.convert{S, T}(::Type{S}, x::CategoricalVariable{T})
    return convert(S, x.pool.index[x.level])
end
