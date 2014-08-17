# TODO: Ensure that index and invindex are one-to-one in constructor?
immutable CategoricalPool{T}
    index::Vector{T}
    invindex::Dict{T, RefType}
end
