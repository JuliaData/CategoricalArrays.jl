# TODO: Ensure that index and invindex are one-to-one in constructor?
function CategoricalPool{T}(index::Vector{T}, invindex::Dict{T, RefType})
    CategoricalPool{T, CategoricalValue{T}}(index, invindex)
end

function CategoricalPool{T}(index::Vector{T})
    CategoricalPool(index, buildinvindex(index))
end

function CategoricalPool{S, T <: Integer}(invindex::Dict{S, T})
    invindex = convert(Dict{S, RefType}, invindex)
    CategoricalPool(buildindex(invindex), invindex)
end

function Base.convert{S, T}(::Type{CategoricalPool{S}}, pool::CategoricalPool{T})
    indexS = convert(Vector{S}, pool.index)
    invindexS = convert(Dict{S, RefType}, pool.invindex)
    CategoricalPool(indexS, invindexS)
end

Base.convert{T}(::Type{CategoricalPool}, pool::CategoricalPool{T}) = pool
Base.convert{T}(::Type{CategoricalPool{T}}, pool::CategoricalPool{T}) = pool

function Base.show{T}(io::IO, pool::CategoricalPool{T})
    @printf(io, "CategoricalPool{%s}([%s])", T, join(map(repr, pool.index), ","))
    return
end

Base.length(pool::CategoricalPool) = length(pool.index)
levels(pool::CategoricalPool) = pool.index

function Base.push!{S}(pool::CategoricalPool{S}, level)
    levelS = convert(S, level)
    if !haskey(pool.invindex, levelS)
        j = length(pool.index) + 1
        pool.invindex[levelS] = j
        push!(pool.index, levelS)
        push!(pool.valindex, CategoricalValue(j, pool))
    end
    return pool
end

function Base.append!(pool::CategoricalPool, levels)
    for level in levels
        push!(pool, level)
    end
    return pool
end

function Base.delete!{S}(pool::CategoricalPool{S}, level)
    levelS = convert(S, level)
    if haskey(pool.invindex, levelS)
        ind = pool.invindex[levelS]
        delete!(pool.invindex, levelS)
        splice!(pool.index, ind)
        splice!(pool.valindex, ind)
        for i in ind:length(pool)
            pool.invindex[pool.index[i]] -= 1
        end
    end
    return pool
end

function Base.delete!(pool::CategoricalPool, levels...)
    for level in levels
        delete!(pool, level)
    end
    return pool
end

function levels!{S, T}(pool::CategoricalPool{S}, newlevels::Vector{T})
    for (k, v) in pool.invindex
        delete!(pool.invindex, k)
    end
    n = length(newlevels)
    resize!(pool.index, n)
    resize!(pool.valindex, n)
    for i in 1:n
        v = newlevels[i]
        pool.index[i] = v
        pool.valindex[i] = CategoricalValue(i, pool)
        pool.invindex[v] = i
    end
    return newlevels
end

invget(pool::CategoricalPool, x::Any) = pool.invindex[x]
