function updateorder!{S, T}(
    order::Array{RefType},
    invindex::Dict{S, RefType},
    ordered::Vector{T},
)
    for (i, v) in enumerate(ordered)
        order[invindex[convert(S, v)]] = i
    end
    return
end
