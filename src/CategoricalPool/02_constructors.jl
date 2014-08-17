function CategoricalPool{T}(index::Vector{T})
    return CategoricalPool(index, buildinvindex(index))
end

function CategoricalPool{S, T <: Integer}(invindex::Dict{S, T})
    invindex = convert(Dict{S, RefType}, invindex)
    return CategoricalPool(buildindex(invindex), invindex)
end
