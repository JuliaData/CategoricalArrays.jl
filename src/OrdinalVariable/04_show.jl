function Base.show{T}(io::IO, x::OrdinalVariable{T})
    @printf(io, "Ordinal '%s'", convert(T, x))
    return
end
