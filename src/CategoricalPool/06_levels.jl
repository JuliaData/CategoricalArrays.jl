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
