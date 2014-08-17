function Base.convert{S, T}(
    ::Type{CategoricalPool{S}},
    pool::CategoricalPool{T},
)
    indexS = convert(Vector{S}, pool.index)
    invindexS = convert(Dict{S, RefType}, pool.invindex)
    return CategoricalPool(indexS, invindexS)
end

Base.convert{T}(::Type{CategoricalPool}, pool::CategoricalPool{T}) = pool

function Base.convert{S, T}(::Type{OrdinalPool{S}}, pool::CategoricalPool{T})
    poolS = convert(CategoricalPool{S}, pool)
    order = buildorder(poolS.index)
    return OrdinalPool(poolS, order)
end

function Base.convert{T}(::Type{OrdinalPool}, pool::CategoricalPool{T})
    order = buildorder(pool.index)
    return OrdinalPool(pool, order)
end
