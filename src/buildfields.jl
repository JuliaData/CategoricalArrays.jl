function buildindex{S, R <: Integer}(invindex::Dict{S, R})
    index = Array(S, length(invindex))
    for (v, i) in invindex
        index[i] = v
    end
    return index
end

function buildinvindex{T}(index::Vector{T}, R=DefaultRefType)
    invindex = Dict{T, R}()
    for (i, v) in enumerate(index)
        invindex[v] = i
    end
    return invindex
end

function buildvalues!{T, R, V}(pool::CategoricalPool{T, R, V})
    n = length(levels(pool))
    resize!(pool.valindex, n)
    for i in 1:n
        pool.valindex[i] = V(i, pool)
    end
    return pool.valindex
end

function buildorder!{S, R <: Integer}(order::Array{R},
                                      invindex::Dict{S, R},
                                      ordered::Vector{S})
    for (i, v) in enumerate(ordered)
        order[invindex[convert(S, v)]] = i
    end
    return order
end

function buildorder{S, R <: Integer}(invindex::Dict{S, R}, ordered::Vector)
    order = Array(R, length(invindex))
    return buildorder!(order, invindex, ordered)
end
