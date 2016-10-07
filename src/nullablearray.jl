import Base: convert, getindex, setindex!, similar

## Constructors and converters
## (special methods for AbstractArray{Nullable}, to avoid wrapping Nullable inside Nullable)

NullableCategoricalArray{T, N}(::Type{Nullable{T}}, dims::NTuple{N,Int}; ordered=false) =
    NullableCategoricalArray{T, N}(zeros(DefaultRefType, dims), CategoricalPool(ordered))
NullableCategoricalArray{T}(::Type{Nullable{T}}, dims::Int...; ordered=false) =
    NullableCategoricalArray(T, dims; ordered=ordered)

@compat (::Type{NullableCategoricalArray{Nullable{T}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                       ordered=false) =
    NullableCategoricalArray(zeros(R, dims), CategoricalPool{T, R}(ordered))
@compat (::Type{NullableCategoricalArray{Nullable{T}, N}}){T, N}(dims::NTuple{N,Int};
                                                                 ordered=false) =
    NullableCategoricalArray{T}(dims; ordered=ordered)
@compat (::Type{NullableCategoricalArray{Nullable{T}}}){T}(m::Int;
                                                           ordered=false) =
    NullableCategoricalArray{T}((m,); ordered=ordered)
@compat (::Type{NullableCategoricalArray{Nullable{T}}}){T}(m::Int, n::Int;
                                                           ordered=false) =
    NullableCategoricalArray{T}((m, n); ordered=ordered)
@compat (::Type{NullableCategoricalArray{Nullable{T}}}){T}(m::Int, n::Int, o::Int;
                                                           ordered=false) =
    NullableCategoricalArray{T}((m, n, o); ordered=ordered)

@compat (::Type{NullableCategoricalArray{Nullable{CategoricalValue{T, R}}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                                            ordered=false) =
    NullableCategoricalArray{T, N, R}(dims; ordered=ordered)
@compat (::Type{NullableCategoricalArray{Nullable{CategoricalValue{T}}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                                         ordered=false) =
    NullableCategoricalArray{T, N, R}(dims; ordered=ordered)
@compat (::Type{NullableCategoricalArray{Nullable{CategoricalValue{T, R}}, N}}){T, N, R}(dims::NTuple{N,Int};
                                                                                         ordered=false) =
    NullableCategoricalArray{T, N, R}(dims; ordered=ordered)
@compat (::Type{NullableCategoricalArray{Nullable{CategoricalValue{T}}, N}}){T, N}(dims::NTuple{N,Int};
                                                                                   ordered=false) =
    NullableCategoricalArray{T, N}(dims; ordered=ordered)
# @compat (::Type{NullableCategoricalArray{Nullable{CategoricalValue}, N}}){N}(dims::NTuple{N,Int};
#                                                                               ordered=false) =
#     NullableCategoricalArray{String, N}(dims; ordered=ordered)
# @compat (::Type{NullableCategoricalArray{Nullable{CategoricalValue}}}){N}(dims::NTuple{N,Int};
#                                                                            ordered=false) =
#     NullableCategoricalArray{String, N}(dims; ordered=ordered)

if VERSION >= v"0.5.0-dev"
    NullableCategoricalVector{T}(::Type{Nullable{T}}, m::Integer; ordered=false) =
      NullableCategoricalArray{T}((m,); ordered=ordered)
end
@compat (::Type{NullableCategoricalVector{Nullable{T}}}){T}(m::Int; ordered=false) =
    NullableCategoricalArray{T}((n,); ordered=ordered)

if VERSION >= v"0.5.0-dev"
    NullableCategoricalMatrix{T}(::Type{Nullable{T}}, m::Int, n::Int; ordered=false) =
      NullableCategoricalArray{T}((m, n); ordered=ordered)
end
@compat (::Type{NullableCategoricalMatrix{Nullable{T}}}){T}(m::Int, n::Int; ordered=false) =
    NullableCategoricalArray{T}((m, n); ordered=ordered)

@compat (::Type{NullableCategoricalArray}){T<:Nullable}(A::AbstractArray{T};
                                                        ordered=_isordered(A)) =
    NullableCategoricalArray{eltype(T)}(A, ordered=ordered)
@compat (::Type{NullableCategoricalVector}){T<:Nullable}(A::AbstractVector{T};
                                                         ordered=_isordered(A)) =
    NullableCategoricalVector{eltype(T)}(A, ordered=ordered)
@compat (::Type{NullableCategoricalMatrix}){T<:Nullable}(A::AbstractMatrix{T};
                                                         ordered=_isordered(A)) =
    NullableCategoricalMatrix{eltype(T)}(A, ordered=ordered)

"""
    NullableCategoricalArray(A::AbstractArray, missing::AbstractArray{Bool};
                             ordered::Bool=false)

Similar to definition above, but marks as null entries for which the corresponding entry
in `missing` is `true`.
"""
function NullableCategoricalArray{T, N}(A::AbstractArray{T, N},
                                        missing::AbstractArray{Bool, N};
                                        ordered=false)
    res = NullableCategoricalArray{T, N}(size(A); ordered=ordered)
    @inbounds for (i, x, m) in zip(eachindex(res), A, missing)
        res[i] = ifelse(m, Nullable{T}(), x)
    end

    if method_exists(isless, (T, T))
        levels!(res, sort(levels(res)))
    end

    res
end

if VERSION >= v"0.5.0-dev"
    """
        NullableCategoricalVector(A::AbstractVector, missing::AbstractVector{Bool};
                                  ordered::Bool=false)

    Similar to definition above, but marks as null entries for which the corresponding entry
    in `missing` is `true`.
    """
    NullableCategoricalVector{T}(A::AbstractVector{T},
                                 missing::AbstractVector{Bool};
                                 ordered=false) =
        NullableCategoricalArray(A, missing; ordered=ordered)

    """
        NullableCategoricalMatrix(A::AbstractMatrix, missing::AbstractMatrix{Bool};
                                  ordered::Bool=false)

    Similar to definition above, but marks as null entries for which the corresponding entry
    in `missing` is `true`.
    """
    NullableCategoricalMatrix{T}(A::AbstractMatrix{T},
                                 missing::AbstractMatrix{Bool};
                                 ordered=false) =
        NullableCategoricalArray(A, missing; ordered=ordered)
end

function getindex(A::NullableCategoricalArray, i::Int)
    j = A.refs[i]
    S = eltype(eltype(A))
    j > 0 ? Nullable{S}(A.pool[j]) : Nullable{S}()
end

function setindex!(A::NullableCategoricalArray, v::Nullable, i::Int)
    if isnull(v)
        A.refs[i] = 0
    else
        A[i] = get(v)
    end
end

levels!(A::NullableCategoricalArray, newlevels::Vector; nullok=false) = _levels!(A, newlevels, nullok=nullok)
