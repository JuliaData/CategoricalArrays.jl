function OrdinalPool{T}(pool::CategoricalPool{T}, order::Vector{RefType})
    OrdinalPool{T, OrdinalValue{T}}(pool, order)
end

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
Base.convert{T}(::Type{OrdinalPool{T}}, opool::OrdinalPool{T}) = opool

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
    @printf(io, "OrdinalPool{%s}([%s])", T,
            join(map(repr, levels(opool)[opool.order]), ","))
end

Base.length(opool::OrdinalPool) = length(opool.pool)

Base.getindex(opool::OrdinalPool, i::Integer) = opool.valindex[i]
Base.get(opool::OrdinalPool, level::Any) = get(opool.pool, level)

levels(opool::OrdinalPool) = levels(opool.pool)

function Base.get!(f, opool::OrdinalPool, level)
    get!(opool.pool, level) do
        f()
        i = length(opool) + 1
        push!(opool.order, i)
        push!(opool.valindex, OrdinalValue(i, opool))
    end
end
Base.get!(opool::OrdinalPool, level) = get!(Void, opool, level)

Base.push!(opool::OrdinalPool, level) = (get!(opool, level); opool)

function Base.append!(opool::OrdinalPool, levels)
    for level in levels
        push!(opool, level)
    end
    return opool
end

function Base.delete!{S}(opool::OrdinalPool{S}, level)
    levelS = convert(S, level)
    if haskey(opool.invindex, levelS)
        delete!(opool.pool, levelS)
        ind = opool.pool.invindex[levelS]
        splice!(pool.order, ind)
        splice!(pool.valindex, ind)
    end
    return opool
end

function Base.delete!(pool::OrdinalPool, levels...)
    for level in levels
        delete!(opool, level)
    end
    return opool
end

function levels!{S, T}(opool::OrdinalPool{S}, newlevels::Vector{T})
    levels!(opool.pool, newlevels)
    order = buildorder(newlevels)
    n = length(newlevels)
    resize!(order, n)
    for i in 1:n
        opool.order[i] = order[i]
    end
    buildvalues!(opool, OrdinalValue)
    return newlevels
end

function levels!{S, T}(opool::OrdinalPool{S},
                       newlevels::Vector{T},
                       ordered::Vector{T})
    if !allunique(newlevels)
        throw(ArgumentError(string("duplicated levels found: ",
                                   join(unique(filter(x->sum(newlevels.==x)>1, newlevels)), ", "))))
    end

    levels!(opool.pool, newlevels)
    order = buildorder(opool.pool.invindex, ordered)
    n = length(newlevels)
    resize!(order, n)
    for i in 1:n
        opool.order[i] = order[i]
    end
    buildvalues!(opool, OrdinalValue)
    return newlevels
end

order{T}(opool::OrdinalPool{T}) = opool.order

function order!{S, T}(opool::OrdinalPool{S}, ordered::Vector{T})
    if !allunique(ordered)
        throw(ArgumentError(string("duplicated levels found: ",
                                   join(unique(filter(x->sum(ordered.==x)>1, ordered)), ", "))))
    end
    d = symdiff(ordered, levels(opool))
    if length(d) > 0
        throw(ArgumentError(string("found levels not in existing levels or vice-versa: ",
                                   join(d, ", "))))
    end
    updateorder!(opool.order, opool.pool.invindex, ordered)
    return ordered
end
