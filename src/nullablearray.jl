import Base: convert, getindex, setindex!, similar, in
using Nulls

## Constructors and converters
## (special methods for AbstractArray{Union{T, Null}}, to avoid wrapping nulls inside CategoricalValues)

(::Type{CategoricalArray{Union{T, Null}, N, R}}){T, N, R}(dims::NTuple{N,Int}; ordered=false) =
    CategoricalArray{?T, N, R}(zeros(R, dims), CategoricalPool{T, R}(ordered))

(::Type{CategoricalArray{Union{CategoricalValue{T, R}, Null}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                               ordered=false) =
    CategoricalArray{?T, N, R}(dims; ordered=ordered)
(::Type{CategoricalArray{Union{CategoricalValue{T}, Null}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                            ordered=false) =
    CategoricalArray{?T, N, R}(dims; ordered=ordered)
(::Type{CategoricalArray{Union{CategoricalValue{T, R}, Null}, N}}){T, N, R}(dims::NTuple{N,Int};
                                                                            ordered=false) =
    CategoricalArray{?T, N, R}(dims; ordered=ordered)
(::Type{CategoricalArray{Union{CategoricalValue{T}, Null}, N}}){T, N}(dims::NTuple{N,Int};
                                                                      ordered=false) =
    CategoricalArray{?T, N}(dims; ordered=ordered)
# (::Type{CategoricalArray{Union{CategoricalValue, Null}, N}}){N}(dims::NTuple{N,Int};
#                                                                 ordered=false) =
#     CategoricalArray{?String, N}(dims; ordered=ordered)
# (::Type{CategoricalArray{Union{CategoricalValue, Null}}}){N}(dims::NTuple{N,Int};
#                                                              ordered=false) =
#     CategoricalArray{?String, N}(dims; ordered=ordered)

(::Type{CategoricalVector{Union{T, Null}}}){T}(m::Int; ordered=false) =
    CategoricalArray{?T}((m,); ordered=ordered)
(::Type{CategoricalMatrix{Union{T, Null}}}){T}(m::Int, n::Int; ordered=false) =
    CategoricalArray{?T}((m, n); ordered=ordered)

(::Type{CategoricalArray}){T}(A::AbstractArray{Union{T, Null}}; ordered=_isordered(A)) =
    CategoricalArray{?T}(A, ordered=ordered)
(::Type{CategoricalVector}){T}(A::AbstractVector{Union{T, Null}}; ordered=_isordered(A)) =
    CategoricalVector{?T}(A, ordered=ordered)
(::Type{CategoricalMatrix}){T}(A::AbstractMatrix{Union{T, Null}}; ordered=_isordered(A)) =
    CategoricalMatrix{?T}(A, ordered=ordered)

function convert{S, T, N, R}(::Type{CategoricalArray{Union{T, Null}, N, R}}, A::AbstractArray{S, N})
    res = CategoricalArray{?T, N, R}(size(A))
    copy!(res, A)

    if method_exists(isless, (T, T))
        levels!(res, sort(levels(res)))
    end

    res
end

@inline function getindex{T>:Null}(A::CategoricalArray{T}, I...)
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
