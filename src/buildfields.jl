function buildindex{S, R <: Integer}(invindex::Dict{S, R})
    index = Array(S, length(invindex))
    for (v, i) in invindex
        index[i] = v
    end
    return index
end

function buildinvindex{T, R}(index::Vector{T}, ::Type{R}=DefaultRefType)
    if length(index) > typemax(R)
        throw(LevelsException{T, R}(index[typemax(R)+1:end]))
    end

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
                                      levels::Vector{S})
    for (i, v) in enumerate(levels)
        order[invindex[convert(S, v)]] = i
    end
    return order
end

function buildorder{S, R <: Integer}(invindex::Dict{S, R}, levels::Vector)
    order = Array(R, length(invindex))
    return buildorder!(order, invindex, levels)
end
