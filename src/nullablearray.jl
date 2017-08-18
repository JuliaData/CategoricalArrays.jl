import Base: convert, getindex, setindex!, similar, in
using Nulls

## Constructors and converters
## (special methods for AbstractArray{Union{T, Null}}, to avoid wrapping nulls inside CategoricalValues)

(::Type{CategoricalArray{Union{T, Null}, N, R}})(dims::NTuple{N,Int}; ordered=false) where {T, N, R} =
    CategoricalArray{Union{T, Null}, N, R}(zeros(R, dims), CategoricalPool{T, R}(ordered))

(::Type{CategoricalArray{Union{CategoricalValue{T, R}, Null}, N, R}})(dims::NTuple{N,Int};
                                                                      ordered=false) where {T, N, R} =
    CategoricalArray{Union{T, Null}, N, R}(dims; ordered=ordered)
(::Type{CategoricalArray{Union{CategoricalValue{T}, Null}, N, R}})(dims::NTuple{N,Int};
                                                                   ordered=false) where {T, N, R} =
    CategoricalArray{Union{T, Null}, N, R}(dims; ordered=ordered)
(::Type{CategoricalArray{Union{CategoricalValue{T, R}, Null}, N}})(dims::NTuple{N,Int};
                                                                   ordered=false) where {T, N, R} =
    CategoricalArray{Union{T, Null}, N, R}(dims; ordered=ordered)
(::Type{CategoricalArray{Union{CategoricalValue{T}, Null}, N}})(dims::NTuple{N,Int};
                                                                ordered=false) where {T, N} =
    CategoricalArray{Union{T, Null}, N}(dims; ordered=ordered)
# (::Type{CategoricalArray{Union{CategoricalValue, Null}, N}}){N}(dims::NTuple{N,Int};
#                                                                 ordered=false) =
#     CategoricalArray{Union{String, Null}, N}(dims; ordered=ordered)
# (::Type{CategoricalArray{Union{CategoricalValue, Null}}}){N}(dims::NTuple{N,Int};
#                                                              ordered=false) =
#     CategoricalArray{Union{String, Null}, N}(dims; ordered=ordered)

(::Type{CategoricalVector{Union{T, Null}}})(m::Int; ordered=false) where {T} =
    CategoricalArray{Union{T, Null}}((m,); ordered=ordered)
(::Type{CategoricalMatrix{Union{T, Null}}})(m::Int, n::Int; ordered=false) where {T} =
    CategoricalArray{Union{T, Null}}((m, n); ordered=ordered)

(::Type{CategoricalArray})(A::AbstractArray{Union{T, Null}}; ordered=_isordered(A)) where {T} =
    CategoricalArray{Union{T, Null}}(A, ordered=ordered)
(::Type{CategoricalVector})(A::AbstractVector{Union{T, Null}}; ordered=_isordered(A)) where {T} =
    CategoricalVector{Union{T, Null}}(A, ordered=ordered)
(::Type{CategoricalMatrix})(A::AbstractMatrix{Union{T, Null}}; ordered=_isordered(A)) where {T} =
    CategoricalMatrix{Union{T, Null}}(A, ordered=ordered)

function convert(::Type{CategoricalArray{Union{T, Null}, N, R}}, A::AbstractArray{S, N}) where {S, T, N, R}
    res = CategoricalArray{Union{T, Null}, N, R}(size(A))
    copy!(res, A)

    if method_exists(isless, (T, T))
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
in(x::Null, y::CategoricalArray{<:Null}) = !all(v -> v > 0, y.refs)
