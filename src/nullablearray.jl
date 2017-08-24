import Base: convert, getindex, setindex!, similar, in
using Nulls

## Constructors and converters
## (special methods for AbstractArray{Union{T, Null}}, to avoid wrapping nulls inside CategoricalValues)

CategoricalArray{Union{T, Null}, N, R}(dims::NTuple{N,Int}; ordered=false) where {T, N, R} =
    CategoricalArray{Union{T, Null}, N, R}(zeros(R, dims), CategoricalPool{T, R}(ordered))

CategoricalArray{Union{CategoricalValue{T, R}, Null}, N, R}(dims::NTuple{N,Int};
                                                                      ordered=false) where {T, N, R} =
    CategoricalArray{Union{T, Null}, N, R}(dims; ordered=ordered)
CategoricalArray{Union{CategoricalValue{T}, Null}, N, R}(dims::NTuple{N,Int};
                                                                   ordered=false) where {T, N, R} =
    CategoricalArray{Union{T, Null}, N, R}(dims; ordered=ordered)
CategoricalArray{Union{CategoricalValue{T, R}, Null}, N}(dims::NTuple{N,Int};
                                                                   ordered=false) where {T, N, R} =
    CategoricalArray{Union{T, Null}, N, R}(dims; ordered=ordered)
CategoricalArray{Union{CategoricalValue{T}, Null}, N}(dims::NTuple{N,Int};
                                                                ordered=false) where {T, N} =
    CategoricalArray{Union{T, Null}, N}(dims; ordered=ordered)
# CategoricalArray{Union{CategoricalValue, Null}, N}}){N}(dims::NTuple{N,Int};
#                                                                 ordered=false) =
#     CategoricalArray{Union{String, Null}, N}(dims; ordered=ordered)
# CategoricalArray{Union{CategoricalValue, Null}}}){N}(dims::NTuple{N,Int};
#                                                              ordered=false) =
#     CategoricalArray{Union{String, Null}, N}(dims; ordered=ordered)

CategoricalVector{T}(m::Int; ordered=false) where {T>:Null} =
    CategoricalArray{T}((m,); ordered=ordered)
CategoricalMatrix{T}(m::Int, n::Int; ordered=false) where {T>:Null} =
    CategoricalArray{T}((m, n); ordered=ordered)

CategoricalArray(A::AbstractArray{T}; ordered=_isordered(A)) where {T>:Null} =
    CategoricalArray{T}(A, ordered=ordered)
CategoricalVector(A::AbstractVector{T}; ordered=_isordered(A)) where {T>:Null} =
    CategoricalVector{T}(A, ordered=ordered)
CategoricalMatrix(A::AbstractMatrix{T}; ordered=_isordered(A)) where {T>:Null} =
    CategoricalMatrix{T}(A, ordered=ordered)

function convert(::Type{CategoricalArray{T, N, R}}, A::AbstractArray{S, N}) where {S, T>:Null, N, R}
    res = CategoricalArray{T, N, R}(size(A))
    copy!(res, A)

    if method_exists(isless, Tuple{Nulls.T(T), Nulls.T(T)})
        levels!(res, sort(levels(res)))
    end

    res
end

@inline function getindex(A::CategoricalArray{T}, I...) where {T>:Null}
    @boundscheck checkbounds(A, I...)
    # Let Array indexing code handle everything
    @inbounds r = A.refs[I...]

    if isa(r, Array)
        ret = CategoricalArray{T, ndims(r), eltype(r)}(r, deepcopy(A.pool))
        return ordered!(ret, isordered(A))
    else
        if r > 0
            @inbounds return A.pool[r]
        else
            return null
        end
    end
end

@inline function setindex!(A::CategoricalArray{>:Null}, v::Null, I::Real...)
    @boundscheck checkbounds(A, I...)
    @inbounds A.refs[I...] = 0
end

in(x::Null, y::CategoricalArray) = false
in(x::Null, y::CategoricalArray{>:Null}) = !all(v -> v > 0, y.refs)
