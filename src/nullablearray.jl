import Base: convert, getindex, setindex!, similar, in
using Nulls

## Constructors and converters
## (special methods for AbstractArray{Union{T, Null}}, to avoid wrapping nulls inside CategoricalValues)

NullableCategoricalArray{T, N}(::Type{Union{T, Null}}, dims::NTuple{N,Int}; ordered=false) =
    NullableCategoricalArray{T, N}(zeros(DefaultRefType, dims), CategoricalPool(ordered))
NullableCategoricalArray{T}(::Type{Union{T, Null}}, dims::Int...; ordered=false) =
    NullableCategoricalArray(T, dims; ordered=ordered)

@compat (::Type{NullableCategoricalArray{Union{T, Null}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                          ordered=false) =
    NullableCategoricalArray(zeros(R, dims), CategoricalPool{T, R}(ordered))
@compat (::Type{NullableCategoricalArray{Union{T, Null}, N}}){T, N}(dims::NTuple{N,Int};
                                                                    ordered=false) =
    NullableCategoricalArray{T}(dims; ordered=ordered)
@compat (::Type{NullableCategoricalArray{Union{T, Null}}}){T}(m::Int;
                                                              ordered=false) =
    NullableCategoricalArray{T}((m,); ordered=ordered)
@compat (::Type{NullableCategoricalArray{Union{T, Null}}}){T}(m::Int, n::Int;
                                                              ordered=false) =
    NullableCategoricalArray{T}((m, n); ordered=ordered)
@compat (::Type{NullableCategoricalArray{Union{T, Null}}}){T}(m::Int, n::Int, o::Int;
                                                              ordered=false) =
    NullableCategoricalArray{T}((m, n, o); ordered=ordered)

@compat (::Type{NullableCategoricalArray{Union{CategoricalValue{T, R}, Null}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                                               ordered=false) =
    NullableCategoricalArray{T, N, R}(dims; ordered=ordered)
@compat (::Type{NullableCategoricalArray{Union{CategoricalValue{T}, Null}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                                            ordered=false) =
    NullableCategoricalArray{T, N, R}(dims; ordered=ordered)
@compat (::Type{NullableCategoricalArray{Union{CategoricalValue{T, R}, Null}, N}}){T, N, R}(dims::NTuple{N,Int};
                                                                                            ordered=false) =
    NullableCategoricalArray{T, N, R}(dims; ordered=ordered)
@compat (::Type{NullableCategoricalArray{Union{CategoricalValue{T}, Null}, N}}){T, N}(dims::NTuple{N,Int};
                                                                                      ordered=false) =
    NullableCategoricalArray{T, N}(dims; ordered=ordered)
# @compat (::Type{NullableCategoricalArray{Union{CategoricalValue, Null}, N}}){N}(dims::NTuple{N,Int};
#                                                                                 ordered=false) =
#     NullableCategoricalArray{String, N}(dims; ordered=ordered)
# @compat (::Type{NullableCategoricalArray{Union{CategoricalValue, Null}}}){N}(dims::NTuple{N,Int};
#                                                                              ordered=false) =
#     NullableCategoricalArray{String, N}(dims; ordered=ordered)

@compat (::Type{NullableCategoricalVector{Union{T, Null}}}){T}(m::Int; ordered=false) =
    NullableCategoricalArray{T}((n,); ordered=ordered)
@compat (::Type{NullableCategoricalMatrix{Union{T, Null}}}){T}(m::Int, n::Int; ordered=false) =
    NullableCategoricalArray{T}((m, n); ordered=ordered)

@compat (::Type{NullableCategoricalArray}){T}(A::AbstractArray{Union{T, Null}};
                                              ordered=_isordered(A)) =
    NullableCategoricalArray{T}(A, ordered=ordered)
@compat (::Type{NullableCategoricalVector}){T}(A::AbstractVector{Union{T, Null}};
                                                         ordered=_isordered(A)) =
    NullableCategoricalVector{T}(A, ordered=ordered)
@compat (::Type{NullableCategoricalMatrix}){T}(A::AbstractMatrix{Union{T, Null}};
                                               ordered=_isordered(A)) =
    NullableCategoricalMatrix{T}(A, ordered=ordered)

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
        res[i] = ifelse(m, null, x)
    end

    if method_exists(isless, (T, T))
        levels!(res, sort(levels(res)))
    end

    res
end

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

function convert{S, T, N, R}(::Type{NullableCategoricalArray{Union{T, Null}, N, R}}, A::AbstractArray{S, N})
    res = NullableCategoricalArray{T, N, R}(size(A))
    copy!(res, A)

    if method_exists(isless, (T, T))
        levels!(res, sort(levels(res)))
    end

    res
end

@inline function getindex(A::NullableCategoricalArray, I...)
    @boundscheck checkbounds(A, I...)
    # Let Array indexing code handle everything
    @inbounds r = A.refs[I...]

    if isa(r, Array)
        return ordered!(arraytype(A)(r, deepcopy(A.pool)),
                        isordered(A))
    else
        if r > 0
            @inbounds return A.pool[r]
        else
            return null
        end
    end
end

@inline function setindex!(A::NullableCategoricalArray, v::Null, I::Real...)
    @boundscheck checkbounds(A, I...)
    @inbounds A.refs[I...] = 0
end

levels!(A::NullableCategoricalArray, newlevels::Vector; nullok=false) = _levels!(A, newlevels, nullok=nullok)

droplevels!{T}(A::NullableCategoricalArray{T}) = levels!(A, _unique(T, A.refs, A.pool))

unique{T}(A::NullableCategoricalArray{T}) = _unique(Union{T, Null}, A.refs, A.pool)

in(x::Null, y::NullableCategoricalArray) = !all(v -> v > 0, y.refs)
