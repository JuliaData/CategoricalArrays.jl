## Code common to NullableNominalArray and NullableOrdinalArray

import Base: convert, getindex, setindex!, similar

## Constructors and converters
## (special methods for AbstractArray{Nullable}, to avoid wrapping Nullable inside Nullable)

for (A, V, M, P, S) in ((:NullableNominalArray, :NullableNominalVector,
                         :NullableNominalMatrix, :NominalPool, :NominalValue),
                        (:NullableOrdinalArray, :NullableOrdinalVector,
                         :NullableOrdinalMatrix, :OrdinalPool, :OrdinalValue))
    @eval begin
        $A{T, N}(::Type{Nullable{T}}, dims::NTuple{N,Int}) =
            $A{T, N}($P(), zeros(DefaultRefType, dims))
        $A{T}(::Type{Nullable{T}}, dims::Int...) = $A(T, dims)

        (::Type{$A{Nullable{T}, N, R}}){T, N, R}(dims::NTuple{N,Int}) =
            $A($P{T, R}(), zeros(R, dims))
        (::Type{$A{Nullable{T}, N}}){T, N}(dims::NTuple{N,Int}) = $A{T}(dims)
        (::Type{$A{Nullable{T}}}){T}(m::Int) = $A{T}((m,))
        (::Type{$A{Nullable{T}}}){T}(m::Int, n::Int) = $A{T}((m, n))
        (::Type{$A{Nullable{T}}}){T}(m::Int, n::Int, o::Int) = $A{T}((m, n, o))

        (::Type{$A{Nullable{$S{T, R}}, N, R}}){T, N, R}(dims::NTuple{N,Int}) = $A{T, N, R}(dims)
        (::Type{$A{Nullable{$S{T}}, N, R}}){T, N, R}(dims::NTuple{N,Int}) = $A{T, N, R}(dims)
        (::Type{$A{Nullable{$S{T, R}}, N}}){T, N, R}(dims::NTuple{N,Int}) = $A{T, N, R}(dims)
        (::Type{$A{Nullable{$S{T}}, N}}){T, N}(dims::NTuple{N,Int}) = $A{T, N}(dims)
        (::Type{$A{Nullable{$S}, N}}){N}(dims::NTuple{N,Int}) = $A{String, N}(dims)
        (::Type{$A{Nullable{$S}}}){N}(dims::NTuple{N,Int}) = $A{String, N}(dims)

        $V{T}(::Type{Nullable{T}}, m::Integer) = $A{T}((m,))
        (::Type{$V{Nullable{T}}}){T}(m::Int) = $A{T}((n,))

        $M{T}(::Type{Nullable{T}}, m::Int, n::Int) = $A{T}((m, n))
        (::Type{$M{Nullable{T}}}){T}(m::Int, n::Int) = $A{T}((m, n))

        convert{T, N, R}(::Type{$A{T, N, R}}, A::AbstractArray{Nullable{T}}) = convert($A{T, N, R}, A)
        convert{T, N}(::Type{$A{T}}, A::AbstractArray{Nullable{T}, N}) = convert($A{T, N}, A)
        convert{T, N}(::Type{$A}, A::AbstractArray{Nullable{T}, N}) = convert($A{T, N}, A)
        convert{T}(::Type{$V}, A::AbstractVector{Nullable{T}}) = convert($V{T}, A)
        convert{T}(::Type{$M}, A::AbstractMatrix{Nullable{T}}) = convert($M{T}, A)

        convert{T, N, R}(::Type{$A{Nullable{$S{T, R}}, N}}, A::AbstractArray{T, N}) =
            convert($A{T, N, R}, A)
        convert{T, N}(::Type{$A{Nullable{$S{T}}, N}}, A::AbstractArray{T, N}) =
            convert($A{T, N}, A)

        function getindex(A::$A, i::Int)
            j = A.values[i]
            S = eltype(eltype(A))
            j > 0 ? Nullable{S}(A.pool[j]) : Nullable{S}()
        end

        function setindex!(A::$A, v::Nullable, i::Int)
            if isnull(v)
                A.values[i] = 0
            else
                A[i] = get(v)
            end
        end

        levels!(A::$A, newlevels::Vector; nullok=false) = _levels!(A, newlevels, nullok=nullok)
    end
end
