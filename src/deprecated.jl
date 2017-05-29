@deprecate ordered isordered

@deprecate compact compress
@deprecate uncompact decompress

@deprecate CategoricalArray{T, N}(::Type{T}, dims::NTuple{N,Int}; ordered=false) CategoricalArray{T}(dims, ordered=ordered)
@deprecate CategoricalArray{T}(::Type{T}, dims::Int...; ordered=false) CategoricalArray{T}(dims, ordered=ordered)

@deprecate CategoricalVector{T}(::Type{T}, m::Integer; ordered=false) CategoricalVector{T}(m, ordered=ordered)

@deprecate CategoricalMatrix{T}(::Type{T}, m::Int, n::Int; ordered=false) CategoricalMatrix{T}(m, n, ordered=ordered)
