function Base.convert{S, T}(::Type{CategoricalPool{S}}, opool::OrdinalPool{T})
    return convert(CategoricalPool{S}, opool.pool)
end

Base.convert{T}(::Type{CategoricalPool}, opool::OrdinalPool{T}) = opool.pool

function Base.convert{S, T}(::Type{OrdinalPool{S}}, opool::OrdinalPool{T})
    poolS = convert(CategoricalPool{S}, opool.pool)
    return OrdinalPool(poolS, opool.order)
end

Base.convert{T}(::Type{OrdinalPool}, opool::OrdinalPool{T}) = opool
