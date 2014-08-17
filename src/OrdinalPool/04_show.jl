function Base.show{T}(io::IO, opool::OrdinalPool{T})
    @printf(io, "OrdinalPool{%s}", T)
    return
end
