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

if VERSION < v"0.7.0-DEV.2581"
    CategoricalArray(dims::Int...; ordered=false) =
        CategoricalArray{String}(dims, ordered=ordered)

    function CategoricalArray{T, N, R}(dims::NTuple{N,Int};
                                    ordered=false) where {T, N, R}
        C = catvaluetype(T, R)
        V = leveltype(C)
        S = T >: Missing ? Union{V, Missing} : V
        CategoricalArray{S, N}(zeros(R, dims), CategoricalPool{V, R, C}(ordered))
    end

    CategoricalArray{T, N}(dims::NTuple{N,Int}; ordered=false) where {T, N} =
        CategoricalArray{T, N, DefaultRefType}(dims, ordered=ordered)
    CategoricalArray{T}(dims::NTuple{N,Int}; ordered=false) where {T, N} =
        CategoricalArray{T, N}(dims, ordered=ordered)
    CategoricalArray{T, 1}(m::Int; ordered=false) where {T} =
        CategoricalArray{T, 1}((m,), ordered=ordered)
    CategoricalArray{T, 2}(m::Int, n::Int; ordered=false) where {T} =
        CategoricalArray{T, 2}((m, n), ordered=ordered)
    CategoricalArray{T, 1, R}(m::Int; ordered=false) where {T, R} =
        CategoricalArray{T, 1, R}((m,), ordered=ordered)
    # R <: Integer is required to prevent default constructor from being called instead
    CategoricalArray{T, 2, R}(m::Int, n::Int; ordered=false) where {T, R <: Integer} =
        CategoricalArray{T, 2, R}((m, n), ordered=ordered)
    CategoricalArray{T, 3, R}(m::Int, n::Int, o::Int; ordered=false) where {T, R} =
        CategoricalArray{T, 3, R}((m, n, o), ordered=ordered)
    CategoricalArray{T}(m::Int; ordered=false) where {T} =
        CategoricalArray{T}((m,), ordered=ordered)
    CategoricalArray{T}(m::Int, n::Int; ordered=false) where {T} =
        CategoricalArray{T}((m, n), ordered=ordered)
    CategoricalArray{T}(m::Int, n::Int, o::Int; ordered=false) where {T} =
        CategoricalArray{T}((m, n, o), ordered=ordered)

    CategoricalVector(m::Integer; ordered=false) = CategoricalArray(m, ordered=ordered)
    CategoricalVector{T}(m::Int; ordered=false) where {T} =
        CategoricalArray{T}((m,), ordered=ordered)

    CategoricalMatrix(m::Int, n::Int; ordered=false) = CategoricalArray(m, n, ordered=ordered)
    CategoricalMatrix{T}(m::Int, n::Int; ordered=false) where {T} =
        CategoricalArray{T}((m, n), ordered=ordered)
else
    @deprecate CategoricalArray(dims::Int...; ordered=false) CategoricalArray(uninitialized, dims...; ordered=ordered)

    @deprecate CategoricalArray{T, N, R}(dims::NTuple{N,Int}; ordered=false) where {T, N, R} CategoricalArray{T, N, R}(uninitialized, dims; ordered=ordered)

    @deprecate CategoricalArray{T, N}(dims::NTuple{N,Int}; ordered=false) where {T, N} CategoricalArray{T, N}(uninitialized, dims; ordered=ordered)
    @deprecate CategoricalArray{T}(dims::NTuple{N,Int}; ordered=false) where {T, N} CategoricalArray{T}(uninitialized, dims; ordered=ordered)
    @deprecate CategoricalArray{T, 1}(m::Int; ordered=false) where {T} CategoricalArray{T, 1}(uninitialized, m; ordered=ordered)
    @deprecate CategoricalArray{T, 2}(m::Int, n::Int; ordered=false) where {T} CategoricalArray{T, 2}(uninitialized, m, n; ordered=ordered)
    @deprecate CategoricalArray{T, 1, R}(m::Int; ordered=false) where {T, R} CategoricalArray{T, 1, R}(uninitialized, m; ordered=ordered)
    # R <: Integer is required to prevent default constructor from being called instead
    @deprecate CategoricalArray{T, 2, R}(m::Int, n::Int; ordered=false) where {T, R <: Integer} CategoricalArray{T, 2, R}(uninitialized, m, n; ordered=ordered)
    @deprecate CategoricalArray{T, 3, R}(m::Int, n::Int, o::Int; ordered=false) where {T, R} CategoricalArray{T, 3, R}(uninitialized, m, n, o; ordered=ordered)
    @deprecate CategoricalArray{T}(m::Int; ordered=false) where {T} CategoricalArray{T}(uninitialized, m; ordered=ordered)
    @deprecate CategoricalArray{T}(m::Int, n::Int; ordered=false) where {T} CategoricalArray{T}(uninitialized, m, n; ordered=ordered)
    @deprecate CategoricalArray{T}(m::Int, n::Int, o::Int; ordered=false) where {T} CategoricalArray{T}(uninitialized, m, n, o; ordered=ordered)

    @deprecate CategoricalVector(m::Integer; ordered=false) CategoricalVector(uninitialized, m; ordered=ordered)
    @deprecate CategoricalVector{T}(m::Int; ordered=false) where {T} CategoricalVector{T}(uninitialized, m; ordered=ordered)

    @deprecate CategoricalMatrix(m::Int, n::Int; ordered=false) CategoricalMatrix(uninitialized, m, n; ordered=ordered)
    @deprecate CategoricalMatrix{T}(m::Int, n::Int; ordered=false) where {T} CategoricalMatrix{T}(uninitialized, m::Int, n::Int; ordered=ordered)
end