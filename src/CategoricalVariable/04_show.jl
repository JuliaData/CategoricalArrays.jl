function Base.show{T}(io::IO, x::CategoricalVariable{T})
    @printf(io, "Categorical '%s'", convert(T, x))
    return
end
