order{T}(opool::OrdinalPool{T}) = opool.order

# TODO: Check that order doesn't specify anything that's not present
# TODO: Check that order specifies everything that's present
function order!{S, T}(opool::OrdinalPool{S}, ordered::Vector{T})
    updateorder!(opool.order, opool.pool.invindex, ordered)
    return ordered
end
