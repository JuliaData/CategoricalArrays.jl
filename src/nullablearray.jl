## Code common to NullableCategoricalArray and NullableOrdinalArray

import Base: convert, getindex, setindex!, similar

## Constructors and converters
## (special methods for AbstractArray{Nullable}, to avoid wrapping Nullable inside Nullable)

for (A, V, M, P, S) in ((:NullableCategoricalArray, :NullableCategoricalVector,
                         :NullableCategoricalMatrix, :CategoricalPool, :CategoricalValue),
                        (:NullableOrdinalArray, :NullableOrdinalVector,
                         :NullableOrdinalMatrix, :OrdinalPool, :OrdinalValue))
    @eval begin
        $A{T, N}(::Type{Nullable{T}}, dims::NTuple{N,Int}) =
            $A{T, N}($P(T[]), zeros(RefType, dims))
        $A{T}(::Type{Nullable{T}}, dims::Int...) = $A(T, dims)

        (::Type{$A{Nullable{T}, N}}){T, N}(dims::NTuple{N,Int}) = $A(T, dims)
        (::Type{$A{Nullable{T}}}){T}(m::Int) = $A{T, 1}(m)
        (::Type{$A{Nullable{T}}}){T}(m::Int, n::Int) = $A{T, 2}(m, n)
        (::Type{$A{Nullable{T}}}){T}(m::Int, n::Int, o::Int) = $A{T, 3}(m, n, o)

        $V{T}(::Type{Nullable{T}}, m::Integer) = $A(T, m)
        (::Type{$V{Nullable{T}}}){T}(m::Int) = $A(T, m)

        $M{T}(::Type{Nullable{T}}, m::Int) = $A(T, m)
        (::Type{$M{Nullable{T}}}){T}(m::Int, n::Int) = $A(T, m)

        convert{T, N}(::Type{$A{T}}, A::AbstractArray{Nullable{T}, N}) = convert($A{T, N}, A)
        convert{T, N}(::Type{$A}, A::AbstractArray{Nullable{T}, N}) = convert($A{T, N}, A)
        convert{T}(::Type{$V}, A::AbstractVector{Nullable{T}}) = convert($V{T}, A)
        convert{T}(::Type{$M}, A::AbstractMatrix{Nullable{T}}) = convert($M{T}, A)

        similar{T}(A::$A, ::Type{Nullable{$S{T}}}, dims::Dims) = $A(T, dims)

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
    end
end
