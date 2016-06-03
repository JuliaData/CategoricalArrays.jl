function OrdinalPool{S, T <: Integer}(index::Vector{S}, invindex::Dict{S, T}, order::Vector{RefType})
    invindex = convert(Dict{S, RefType}, invindex)
    OrdinalPool{S, OrdinalValue{S}}(index, invindex, order)
end

function OrdinalPool{T}(index::Vector{T})
    invindex = buildinvindex(index)
    order = buildorder(index)
    return OrdinalPool(index, invindex, order)
end

function OrdinalPool{S, T <: Integer}(invindex::Dict{S, T})
    invindex = convert(Dict{S, RefType}, invindex)
    index = buildindex(invindex)
    order = buildorder(index)
    return OrdinalPool(index, invindex, order)
end

# TODO: Add tests for this
function OrdinalPool{S, T <: Integer}(index::Vector{S}, invindex::Dict{S, T})
    invindex = convert(Dict{S, RefType}, invindex)
    order = buildorder(index)
    return OrdinalPool(index, invindex, order)
end

function OrdinalPool{T}(index::Vector{T}, ordered::Vector{T})
    invindex = buildinvindex(index)
    order = buildorder(invindex, ordered)
    return OrdinalPool(index, invindex, order)
end

function OrdinalPool{S, T <: Integer}(invindex::Dict{S, T}, ordered::Vector{S})
    invindex = convert(Dict{S, RefType}, invindex)
    index = buildindex(invindex)
    order = buildorder(invindex, ordered)
    return OrdinalPool(index, invindex, order)
end

# TODO: Add tests for this
function OrdinalPool{S, T <: Integer}(index::Vector{S},
                                      invindex::Dict{S, T},
                                      ordered::Vector{S})
    invindex = convert(Dict{S, RefType}, invindex)
    index = buildindex(invindex)
    order = buildorder(invindex, ordered)
    return OrdinalPool(index, invindex, order)
end

function Base.convert{S, T}(::Type{OrdinalPool{S}}, opool::OrdinalPool{T})
    indexS = convert(Vector{S}, opool.index)
    invindexS = convert(Dict{S, RefType}, opool.invindex)
    return OrdinalPool(indexS, invindexS, opool.order)
end

Base.convert{T}(::Type{OrdinalPool}, opool::OrdinalPool{T}) = opool
Base.convert{T}(::Type{OrdinalPool{T}}, opool::OrdinalPool{T}) = opool

function Base.show{T}(io::IO, opool::OrdinalPool{T})
    @printf(io, "OrdinalPool{%s}([%s])", T,
            join(map(repr, levels(opool)[opool.order]), ","))
end

Base.length(opool::OrdinalPool) = length(opool.index)

Base.getindex(opool::OrdinalPool, i::Integer) = opool.valindex[i]
Base.get(opool::OrdinalPool, level::Any) = opool.invindex[level]

levels(opool::OrdinalPool) = opool.index

function Base.get!(f, opool::OrdinalPool, level)
    get!(opool.invindex, level) do
        f()
        i = length(opool) + 1
        push!(opool.index, level)
        push!(opool.order, i)
        push!(opool.valindex, OrdinalValue(i, opool))
        i
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
        ind = opool.invindex[levelS]
        delete!(opool.invindex, levelS)
        deleteat!(opool.index, ind)
        deleteat!(opool.order, ind)
        deleteat!(opool.valindex, ind)
        for i in ind:length(opool)
            opool.invindex[opool.index[i]] -= 1
        end
    end
    return opool
end

function Base.delete!(opool::OrdinalPool, levels...)
    for level in levels
        delete!(opool, level)
    end
    return opool
end

function levels!{S, T}(opool::OrdinalPool{S}, newlevels::Vector{T})
    for (k, v) in opool.invindex
        delete!(opool.invindex, k)
    end
    n = length(newlevels)
    resize!(opool.index, n)
    resize!(opool.valindex, n)
    order = buildorder(newlevels)
    resize!(order, n)
    for i in 1:n
        v = newlevels[i]
        opool.index[i] = v
        opool.valindex[i] = OrdinalValue(i, opool)
        opool.invindex[v] = i
        opool.order[i] = order[i]
    end
    return newlevels
end

function levels!{S, T}(opool::OrdinalPool{S},
                       newlevels::Vector{T},
                       ordered::Vector{T})
    if !allunique(newlevels)
        throw(ArgumentError(string("duplicated levels found: ",
                                   join(unique(filter(x->sum(newlevels.==x)>1, newlevels)), ", "))))
    end

    order = buildorder(opool.invindex, ordered)
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
    updateorder!(opool.order, opool.invindex, ordered)
    return ordered
end
