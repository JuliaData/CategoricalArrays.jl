function OrdinalPool{T}(index::Vector{T})
    pool = CategoricalPool(index)
    order = buildorder(pool.index)
    return OrdinalPool(pool, order)
end

function OrdinalPool{S, T <: Integer}(invindex::Dict{S, T})
    invindex = convert(Dict{S, RefType}, invindex)
    pool = CategoricalPool(invindex)
    order = buildorder(pool.index)
    return OrdinalPool(pool, order)
end

# TODO: Add tests for this
function OrdinalPool{S, T <: Integer}(index::Vector{S}, invindex::Dict{S, T})
    invindex = convert(Dict{S, RefType}, invindex)
    pool = CategoricalPool(index, invindex)
    order = buildorder(pool.index)
    return OrdinalPool(pool, order)
end

function OrdinalPool{T}(index::Vector{T}, ordered::Vector{T})
    pool = CategoricalPool(index)
    order = buildorder(pool.invindex, ordered)
    return OrdinalPool(pool, order)
end

function OrdinalPool{S, T <: Integer}(invindex::Dict{S, T}, ordered::Vector{S})
    invindex = convert(Dict{S, RefType}, invindex)
    pool = CategoricalPool(invindex)
    order = buildorder(pool.invindex, ordered)
    return OrdinalPool(pool, order)
end

# TODO: Add tests for this
function OrdinalPool{S, T <: Integer}(index::Vector{S},
                                      invindex::Dict{S, T},
                                      ordered::Vector{S})
    invindex = convert(Dict{S, RefType}, invindex)
    pool = CategoricalPool(index, invindex)
    order = buildorder(pool.invindex, ordered)
    return OrdinalPool(pool, order)
end

function Base.convert{S, T}(::Type{CategoricalPool{S}}, opool::OrdinalPool{T})
    return convert(CategoricalPool{S}, opool.pool)
end

Base.convert{T}(::Type{CategoricalPool}, opool::OrdinalPool{T}) = opool.pool

function Base.convert{S, T}(::Type{OrdinalPool{S}}, opool::OrdinalPool{T})
    poolS = convert(CategoricalPool{S}, opool.pool)
    return OrdinalPool(poolS, opool.order)
end

Base.convert{T}(::Type{OrdinalPool}, opool::OrdinalPool{T}) = opool

function Base.convert{S, T}(::Type{OrdinalPool{S}}, pool::CategoricalPool{T})
    poolS = convert(CategoricalPool{S}, pool)
    order = buildorder(poolS.index)
    return OrdinalPool(poolS, order)
end

function Base.convert{T}(::Type{OrdinalPool}, pool::CategoricalPool{T})
    order = buildorder(pool.index)
    return OrdinalPool(pool, order)
end

function Base.show{T}(io::IO, opool::OrdinalPool{T})
    @printf(io, "OrdinalPool{%s}", T)
    return
end

Base.length(opool::OrdinalPool) = length(opool.pool.index)
levels(opool::OrdinalPool) = opool.pool.index

function levels!{S, T}(opool::OrdinalPool{S}, newlevels::Vector{T})
    levels!(opool.pool, newlevels)
    order = buildorder(newlevels)
    n = length(newlevels)
    resize!(order, n)
    for i in 1:n
        opool.order[i] = order[i]
    end
    return newlevels
end

function levels!{S, T}(opool::OrdinalPool{S},
                       newlevels::Vector{T},
                       ordered::Vector{T})
    levels!(opool.pool, newlevels)
    order = buildorder(opool.pool.invindex, ordered)
    n = length(newlevels)
    resize!(order, n)
    for i in 1:n
        opool.order[i] = order[i]
    end
    return newlevels
end

order{T}(opool::OrdinalPool{T}) = opool.order

# TODO: Check that order doesn't specify anything that's not present
# TODO: Check that order specifies everything that's present
function order!{S, T}(opool::OrdinalPool{S}, ordered::Vector{T})
    updateorder!(opool.order, opool.pool.invindex, ordered)
    return ordered
end
