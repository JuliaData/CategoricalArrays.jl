function Base.show{T}(io::IO, pool::CategoricalPool{T})
    @printf(io, "CategoricalPool{%s}", T)
    return
end
