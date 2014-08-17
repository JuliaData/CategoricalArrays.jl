function OrdinalPool{T}(index::Vector{T})
    pool = CategoricalPool(index)
    order = buildorder(pool.index)
    return OrdinalPool(pool, order)
end

function OrdinalPool{S, T <: Integer}(invindex::Dict{S, T})
    invindex = convert(Dict{S, RefType}, invindex)
    pool = CategoricalPool(invindex)
    order = buildorder(pool.index)
    return OrdinalPool(pool, order)
end

# TODO: Add tests for this
function OrdinalPool{S, T <: Integer}(index::Vector{S}, invindex::Dict{S, T})
    invindex = convert(Dict{S, RefType}, invindex)
    pool = CategoricalPool(index, invindex)
    order = buildorder(pool.index)
    return OrdinalPool(pool, order)
end

function OrdinalPool{T}(index::Vector{T}, ordered::Vector{T})
    pool = CategoricalPool(index)
    order = buildorder(pool.invindex, ordered)
    return OrdinalPool(pool, order)
end

function OrdinalPool{S, T <: Integer}(invindex::Dict{S, T}, ordered::Vector{S})
    invindex = convert(Dict{S, RefType}, invindex)
    pool = CategoricalPool(invindex)
    order = buildorder(pool.invindex, ordered)
    return OrdinalPool(pool, order)
end

# TODO: Add tests for this
function OrdinalPool{S, T <: Integer}(
    index::Vector{S},
    invindex::Dict{S, T},
    ordered::Vector{S},
)
    invindex = convert(Dict{S, RefType}, invindex)
    pool = CategoricalPool(index, invindex)
    order = buildorder(pool.invindex, ordered)
    return OrdinalPool(pool, order)
end
