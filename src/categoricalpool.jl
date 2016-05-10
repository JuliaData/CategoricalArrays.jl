# TODO: Ensure that index and invindex are one-to-one in constructor?
function CategoricalPool{T}(index::Vector{T})
    return CategoricalPool(index, buildinvindex(index))
end

function CategoricalPool{S, T <: Integer}(invindex::Dict{S, T})
    invindex = convert(Dict{S, RefType}, invindex)
    return CategoricalPool(buildindex(invindex), invindex)
end

function Base.convert{S, T}(::Type{CategoricalPool{S}}, pool::CategoricalPool{T})
    indexS = convert(Vector{S}, pool.index)
    invindexS = convert(Dict{S, RefType}, pool.invindex)
    return CategoricalPool(indexS, invindexS)
end

Base.convert{T}(::Type{CategoricalPool}, pool::CategoricalPool{T}) = pool

function Base.show{T}(io::IO, pool::CategoricalPool{T})
    @printf(io, "CategoricalPool{%s}", T)
    return
end

Base.length(pool::CategoricalPool) = length(pool.index)
levels(pool::CategoricalPool) = pool.index

function add!{S, T}(pool::CategoricalPool{S}, level::T)
    levelS = convert(S, level)
    if !haskey(pool.invindex, levelS)
        pool.invindex[levelS] = length(pool.index) + 1
        push!(pool.index, levelS)
    end
    return level
end

function add!{S, T}(pool::CategoricalPool{S}, levels::T...)
    for level in levels
        add!(pool, level)
    end
    return levels
end

function Base.delete!{S, T}(pool::CategoricalPool{S}, level::T)
    levelS = convert(S, level)
    if haskey(pool.invindex, levelS)
        ind = pool.invindex[levelS]
        delete!(pool.invindex, levelS)
        splice!(pool.index, ind)
        for i in ind:length(pool)
            pool.invindex[pool.index[i]] -= 1
        end
    end
    return levelS
end

function Base.delete!{S, T}(pool::CategoricalPool{S}, levels::T...)
    for level in levels
        delete!(pool, level)
    end
    return levels
end

function levels!{S, T}(pool::CategoricalPool{S}, newlevels::Vector{T})
    for (k, v) in pool.invindex
        delete!(pool.invindex, k)
    end
    n = length(newlevels)
    resize!(pool.index, n)
    for i in 1:n
        v = newlevels[i]
        pool.index[i] = v
        pool.invindex[v] = i
    end
    return newlevels
end
