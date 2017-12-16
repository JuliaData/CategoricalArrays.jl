@deprecate ordered isordered

@deprecate compact compress
@deprecate uncompact decompress

@deprecate CategoricalArray(::Type{T}, dims::NTuple{N,Int}; ordered=false) where {T, N} CategoricalArray{T}(dims, ordered=ordered)
@deprecate CategoricalArray(::Type{T}, dims::Int...; ordered=false) where {T} CategoricalArray{T}(dims, ordered=ordered)

@deprecate CategoricalVector(::Type{T}, m::Integer; ordered=false) where {T} CategoricalVector{T}(m, ordered=ordered)

@deprecate CategoricalMatrix(::Type{T}, m::Int, n::Int; ordered=false) where {T} CategoricalMatrix{T}(m, n, ordered=ordered)

# Only define methods for Nullables while they're in Base, otherwise we don't care
if VERSION < v"0.7.0-DEV.3017"
    Base.convert(::Type{Nullable{S}}, x::CategoricalValue{Nullable}) where {S} =
        convert(Nullable{S}, get(x))
    Base.convert(::Type{Nullable}, x::CategoricalValue{S}) where {S} = convert(Nullable{S}, x)
    Base.convert(::Type{Nullable{CategoricalValue{Nullable{T}}}},
                 x::CategoricalValue{Nullable{T}}) where {T} =
        Nullable(x)
end
