function buildindex{S, T <: Integer}(invindex::Dict{S, T})
    index = Array(S, length(invindex))
    for (v, i) in invindex
        index[i] = v
    end
    return index
end

function buildinvindex{T}(index::Vector{T})
    invindex = Dict{T, RefType}()
    for (i, v) in enumerate(index)
        invindex[v] = i
    end
    return invindex
end

function buildvalues!{T, V}(pool::CategoricalPool{T, V})
    n = length(levels(pool))
    resize!(pool.valindex, n)
    for i in 1:n
        pool.valindex[i] = V(i, pool)
    end
    pool
end

# TODO: Try to make this faster by avoiding need to call convert
function buildorder{T}(index::Vector{T})
    return convert(Vector{RefType}, sortperm(index))
end

function buildorder{S, T}(invindex::Dict{S, RefType}, ordered::Vector{T})
    order = Array(RefType, length(invindex))
    updateorder!(order, invindex, ordered)
    return order
end
