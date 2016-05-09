immutable CategoricalPool{T}
    index::Vector{T}
    invindex::Dict{T, RefType}
end

immutable OrdinalPool{T}
    pool::CategoricalPool{T}
    order::Vector{RefType}
end

immutable CategoricalValue{T}
    level::RefType
    pool::CategoricalPool{T}
end

immutable OrdinalValue{T}
    level::RefType
    opool::OrdinalPool{T}
end
