import Base: convert, getindex, setindex!, similar, in
using NullableArrays: NullableArray

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

@compat (::Type{NullableCategoricalVector{Nullable{T}}}){T}(m::Int; ordered=false) =
    NullableCategoricalArray{T}((n,); ordered=ordered)
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

@inline function getindex(A::NullableCategoricalArray, I...)
    @boundscheck checkbounds(A, I...)
    # Let Array indexing code handle everything
    @inbounds r = A.refs[I...]

    if isa(r, Array)
        return ordered!(arraytype(A)(r, deepcopy(A.pool)),
                        isordered(A))
    else
        S = eltype(eltype(A))
        if r > 0
            @inbounds return Nullable{S}(A.pool[r])
        else
            return Nullable{S}()
        end
    end
end

@inline function setindex!(A::NullableCategoricalArray, v::Nullable, I::Real...)
    @boundscheck checkbounds(A, I...)
    if isnull(v)
        @inbounds A.refs[I...] = 0
    else
        @inbounds A[I...] = get(v)
    end
end

levels!(A::NullableCategoricalArray, newlevels::Vector; nullok=false) = _levels!(A, newlevels, nullok=nullok)

droplevels!(A::NullableCategoricalArray) = levels!(A, _unique(Array, A.refs, A.pool))

unique{T}(A::NullableCategoricalArray{T}) = _unique(NullableArray{T}, A.refs, A.pool)

function in{T, N, R}(x::Nullable, y::NullableCategoricalArray{T, N, R})
    ref = get(y.pool, get(x), zero(R))
    ref != 0 ? ref in y.refs : false
end

function in{S<:CategoricalValue, T, N, R}(x::Nullable{S}, y::NullableCategoricalArray{T, N, R})
    v = get(x)
    if v.pool === y.pool
        return v.level in y.refs
    else
        ref = get(y.pool, index(v.pool)[v.level], zero(R))
        return ref != 0 ? ref in y.refs : false
    end
end

in{T, N, R}(x::Any, y::NullableCategoricalArray{T, N, R}) = false
in{T, N, R}(x::CategoricalValue, y::NullableCategoricalArray{T, N, R}) = false
