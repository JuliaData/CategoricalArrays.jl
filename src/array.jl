## Common code for CategoricalArray, OrdinalArray,
## NullableCategoricalArray and NullableOrdinalArray

import Base: convert, getindex, setindex!, similar, size, linearindexing

typealias CatOrdArray Union{CategoricalArray, OrdinalArray,
                            NullableCategoricalArray, NullableOrdinalArray}

for (A, V, M, P, S) in ((:CategoricalArray, :CategoricalVector,
                         :CategoricalMatrix, :CategoricalPool, :CategoricalValue),
                        (:OrdinalArray, :OrdinalVector,
                         :OrdinalMatrix, :OrdinalPool, :OrdinalValue),
                        (:NullableCategoricalArray, :NullableCategoricalVector, 
                         :NullableCategoricalMatrix, :CategoricalPool, :CategoricalValue),
                        (:NullableOrdinalArray, :NullableOrdinalVector,
                         :NullableOrdinalMatrix, :OrdinalPool, :OrdinalValue))
    @eval begin
        $A{T, N}(::Type{T}, dims::NTuple{N,Int}) =
            $A{T, N}($P(T[]), zeros(RefType, dims))
        $A{T}(::Type{T}, dims::Int...) = $A(T, dims)
        $A(dims::Int...) = $A(String, dims)

        (::Type{$A{T, N}}){T, N}(dims::NTuple{N,Int}) = $A(T, dims)
        (::Type{$A{T}}){T}(m::Int) = $A{T, 1}(m)
        (::Type{$A{T}}){T}(m::Int, n::Int) = $A{T, 2}(m, n)
        (::Type{$A{T}}){T}(m::Int, n::Int, o::Int) = $A{T, 3}(m, n, o)

        $V{T}(::Type{T}, m::Integer) = $A(T, m)
        $V(m::Integer) = $A(m)
        (::Type{$V{T}}){T}(m::Int) = $A(T, m)

        $M{T}(::Type{T}, m::Int) = $A(T, m)
        $M(m::Int, n::Int) = $A(m, n)
        (::Type{$M{T}}){T}(m::Int, n::Int) = $A(T, m)

        convert{T, N}(::Type{$A{T, N}}, A::$A{T, N}) = A
        convert{T}(::Type{$A{T}}, A::$A{T}) = A
        convert(::Type{$A}, A::$A) = A
        convert{T, N}(::Type{$A{T}}, A::AbstractArray{T, N}) = convert($A{T, N}, A)
        convert{S, T, N}(::Type{$A{T}}, A::AbstractArray{S, N}) = convert($A{T, N}, A)
        convert{T, N}(::Type{$A}, A::AbstractArray{T, N}) = convert($A{T, N}, A)
        convert{T}(::Type{$V}, A::AbstractVector{T}) = convert($V{T}, A)
        convert{T}(::Type{$V{T}}, A::$V{T}) = A
        convert(::Type{$V}, A::$V) = A
        convert{T}(::Type{$M}, A::AbstractMatrix{T}) = convert($M{T}, A)
        convert{T}(::Type{$M{T}}, A::$M{T}) = A
        convert(::Type{$M}, A::$M) = A

        similar{T}(A::$A, ::Type{$S{T}}, dims::Dims) = $A(T, dims)
        similar{T}(A::$A, ::Type{T}, dims::Dims) = $A(T, dims)

        levelstype{T, N}(::Type{$A{T, N}}) = T

        convert{S, T, N}(::Type{$A{T, N}}, A::AbstractArray{S, N}) =
            _convert($A{T, N}, $P, A)
    end
end

function _convert{S, T<:CatOrdArray, P<:CatOrdPool}(::Type{T}, ::Type{P}, A::AbstractArray{S})
    pool = P([convert(levelstype(T), x) for x in unique(A)])
    values = Array(RefType, size(A))
    for (i, x) in enumerate(A)
        @inbounds values[i] = get(pool, x)
    end
    T(pool, values)
end

function Base.:(==)(A::CatOrdArray, B::CatOrdArray)
    if size(A) != size(B)
        return false
    end
    if A.pool === B.pool
        for (a, b) in zip(A.values, B.values)
            if a != b
                return false
            end
        end
    else
        for (a, b) in zip(A, B)
            if a != b
                return false
            end
        end
    end
    return true
end

size(A::CatOrdArray) = size(A.values)
linearindexing{T <: CatOrdArray}(::Type{T}) = Base.LinearFast()

setindex!(A::CatOrdArray, v::Any, i::Int) = A.values[i] = get!(A.pool, v)


## Code specific to CategoricalArray and OrdinalArray

for T in (CategoricalArray, OrdinalArray)
    @eval begin
        function getindex(A::$T, i::Int)
            j = A.values[i]
            j > 0 || throw(UndefRefError())
            A.pool[j]
        end
    end
end


## Categorical-specific methods

levels(A::CatOrdArray) = levels(A.pool)
levels!(pool::CatOrdArray, newlevels::Vector) = levels!(A.pool)
