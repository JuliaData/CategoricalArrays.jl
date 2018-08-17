function buildindex(invindex::Dict{S, R}) where {S, R <: Integer}
    index = Vector{S}(undef, length(invindex))
    for (v, i) in invindex
        index[i] = v
    end
    return index
end

function buildinvindex(index::Vector{T}, ::Type{R}=DefaultRefType) where {T, R}
    if length(index) > typemax(R)
        throw(LevelsException{T, R}(index[typemax(R)+1:end]))
    end

    invindex = Dict{T, R}()
    for (i, v) in enumerate(index)
        invindex[v] = i
    end
    return invindex
end

function buildvalues!(pool::CategoricalPool)
    resize!(pool.valindex, length(levels(pool)))
    for i in eachindex(pool.valindex)
        v = catvalue(i, pool)
        @inbounds pool.valindex[i] = v
    end
    return pool.valindex
end

function buildorder!(order::Array{R},
                     invindex::Dict{S, R},
                     levels::Vector{S}) where {S, R <: Integer}
    for (i, v) in enumerate(levels)
        order[invindex[convert(S, v)]] = i
    end
    return order
end

function buildorder(invindex::Dict{S, R}, levels::Vector) where {S, R <: Integer}
    order = Vector{R}(undef, length(invindex))
    return buildorder!(order, invindex, levels)
end
