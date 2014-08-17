levels(opool::OrdinalPool) = opool.pool.index

function levels!{S, T}(
    opool::OrdinalPool{S},
    newlevels::Vector{T},
)
    levels!(opool.pool, newlevels)
    order = buildorder(newlevels)
    n = length(newlevels)
    resize!(order, n)
    for i in 1:n
        opool.order[i] = order[i]
    end
    return newlevels
end

function levels!{S, T}(
    opool::OrdinalPool{S},
    newlevels::Vector{T},
    ordered::Vector{T},
)
    levels!(opool.pool, newlevels)
    order = buildorder(opool.pool.invindex, ordered)
    n = length(newlevels)
    resize!(order, n)
    for i in 1:n
        opool.order[i] = order[i]
    end
    return newlevels
end
