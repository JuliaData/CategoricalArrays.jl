## Common code for NominalArray, OrdinalArray,
## NullableNominalArray and NullableOrdinalArray

import Base: convert, getindex, setindex!, similar, size, linearindexing

typealias CatOrdArray Union{NominalArray, OrdinalArray,
                            NullableNominalArray, NullableOrdinalArray}

for (A, V, M, P, S) in ((:NominalArray, :NominalVector,
                         :NominalMatrix, :CategoricalPool, :NominalValue),
                        (:OrdinalArray, :OrdinalVector,
                         :OrdinalMatrix, :CategoricalPool, :OrdinalValue),
                        (:NullableNominalArray, :NullableNominalVector, 
                         :NullableNominalMatrix, :CategoricalPool, :NominalValue),
                        (:NullableOrdinalArray, :NullableOrdinalVector,
                         :NullableOrdinalMatrix, :CategoricalPool, :OrdinalValue))
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

        convert{S, T, N}(::Type{$A{T, N}}, A::AbstractArray{S, N}) = copy!($A{T, N}(size(A)), A)
    end
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


## Categorical-specific methods

levels(A::CatOrdArray) = levels(A.pool)

function _levels!(A::CatOrdArray, newlevels::Vector; nullok=false)
    if !allunique(newlevels)
        throw(ArgumentError(string("duplicated levels found: ",
                                   join(unique(filter(x->sum(newlevels.==x)>1, newlevels)), ", "))))
    end

    # findfirst returns 0 when not found, which maps to a missing value
    levelsmap = [findfirst(newlevels, l) for l in levels(A)]

    if levelsmap != collect(1:length(levels(A)))
        # first pass to check whether changes can be applied without error
        # TODO: save original levels and undo changes in case of error to skip this step
        @inbounds for (i, x) in enumerate(A.values)
            j = levelsmap[x]

            if (isa(A, NominalArray) || isa(A, OrdinalArray)) && j == 0
                throw(ArgumentError("cannot remove level $(repr(levels(A)[x])) as it is used at position $i. Convert array to a Nullable$(typeof(A).name.name) if you want to transform some levels to missing values."))
            elseif (isa(A, NullableNominalArray) || isa(A, NullableOrdinalArray)) && !nullok && j == 0
                throw(ArgumentError("cannot remove level $(repr(levels(A)[x])) as it is used at position $i and nullok=false."))
            end
        end

        # actually apply changes
        @inbounds for (i, x) in enumerate(A.values)
            j = levelsmap[x]
            x > 0 && (A.values[i] = j)
        end
    end
    levels!(A.pool, newlevels)
end

function droplevels!(A::CatOrdArray)
    found = fill(false, length(levels(A)))
    @inbounds for i in A.values
        i > 0 && (found[i] = true)
    end
    levels!(A, levels(A)[found])
end


## Code specific to NominalArray and OrdinalArray

function getindex(A::CatOrdArray, i::Int)
    j = A.values[i]
    j > 0 || throw(UndefRefError())
    A.pool[j]
end

levels!(A::CatOrdArray, newlevels::Vector) = _levels!(A, newlevels)
