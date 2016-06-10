## Common code for NominalArray, OrdinalArray,
## NullableNominalArray and NullableOrdinalArray

import Base: convert, getindex, setindex!, similar, size, linearindexing

typealias CatOrdArray Union{NominalArray, OrdinalArray,
                            NullableNominalArray, NullableOrdinalArray}

for (A, V, M, P, S) in ((:NominalArray, :NominalVector,
                         :NominalMatrix, :NominalPool, :NominalValue),
                        (:OrdinalArray, :OrdinalVector,
                         :OrdinalMatrix, :OrdinalPool, :OrdinalValue),
                        (:NullableNominalArray, :NullableNominalVector, 
                         :NullableNominalMatrix, :NominalPool, :NominalValue),
                        (:NullableOrdinalArray, :NullableOrdinalVector,
                         :NullableOrdinalMatrix, :OrdinalPool, :OrdinalValue))
    @eval begin
        $A{T, N}(::Type{T}, dims::NTuple{N,Int}) =
            $A($P{T}(), zeros(DefaultRefType, dims))
        $A{T}(::Type{T}, dims::Int...) = $A{T}(dims)
        $A(dims::Int...) = $A{String}(dims)

        $A{T, N, R}(::Type{$S{T, R}}, dims::NTuple{N,Int}) = $A{T, N, R}(dims)
        $A{T, N}(::Type{$S{T}}, dims::NTuple{N,Int}) = $A{T, N}(dims)
        $A{N}(::Type{$S}, dims::NTuple{N,Int}) = $A{String, N}(dims)

        (::Type{$A{T, N, R}}){T, N, R}(dims::NTuple{N,Int}) =
            $A{T, N, R}($P{T, R}(), zeros(R, dims))
        (::Type{$A{T, N}}){T, N}(dims::NTuple{N,Int}) = $A{T, N, DefaultRefType}(dims)
        (::Type{$A{T}}){T, N}(dims::NTuple{N,Int}) = $A{T, N}(dims)
        (::Type{$A{T, 1, R}}){T, R}(m::Int) = $A{T, 1, R}((m,))
        # R <: Integer is required to prevent default constructor from being called instead
        (::Type{$A{T, 2, R}}){T, R <: Integer}(m::Int, n::Int) = $A{T, 2, R}((m, n))
        (::Type{$A{T, 3, R}}){T, R}(m::Int, n::Int, o::Int) = $A{T, 3, R}((m, n, o))
        (::Type{$A{T}}){T}(m::Int) = $A{T}((m,))
        (::Type{$A{T}}){T}(m::Int, n::Int) = $A{T}((m, n))
        (::Type{$A{T}}){T}(m::Int, n::Int, o::Int) = $A{T}((m, n, o))

        (::Type{$A{$S{T, R}, N, R}}){T, N, R}(dims::NTuple{N,Int}) = $A{T, N, R}(dims)
        (::Type{$A{$S{T}, N, R}}){T, N, R}(dims::NTuple{N,Int}) = $A{T, N, R}(dims)
        (::Type{$A{$S{T, R}, N}}){T, N, R}(dims::NTuple{N,Int}) = $A{T, N, R}(dims)
        (::Type{$A{$S{T}, N}}){T, N}(dims::NTuple{N,Int}) = $A{T, N}(dims)
        (::Type{$A{$S, N}}){N}(dims::NTuple{N,Int}) = $A{String, N}(dims)
        (::Type{$A{$S}}){N}(dims::NTuple{N,Int}) = $A{String, N}(dims)

        $V{T}(::Type{T}, m::Integer) = $A{T}((m,))
        $V(m::Integer) = $A(m)
        (::Type{$V{T}}){T}(m::Int) = $A{T}((m,))

        $M{T}(::Type{T}, m::Int, n::Int) = $A{T}((m, n))
        $M(m::Int, n::Int) = $A(m, n)
        (::Type{$M{T}}){T}(m::Int, n::Int) = $A{T}((m, n))

        convert{T, N, R}(::Type{$A{T, N, R}}, A::$A{T, N, R}) = A
        convert{T, N}(::Type{$A{T, N}}, A::$A{T, N}) = A
        convert{T}(::Type{$A{T}}, A::$A{T}) = A
        convert(::Type{$A}, A::$A) = A

        convert{T, N}(::Type{$A{T, N}}, A::AbstractArray{T, N}) =
            convert($A{T, N, DefaultRefType}, A)
        convert{T, N}(::Type{$A{T}}, A::AbstractArray{T, N}) = convert($A{T, N}, A)
        convert{S, T, N}(::Type{$A{T}}, A::AbstractArray{S, N}) = convert($A{T, N}, A)
        convert{T, N}(::Type{$A}, A::AbstractArray{T, N}) = convert($A{T, N}, A)

        convert{T, N, R}(::Type{$A{$S{T, R}, N}}, A::AbstractArray{T, N}) =
            convert($A{T, N, R}, A)
        convert{T, N}(::Type{$A{$S{T}, N}}, A::AbstractArray{T, N}) = convert($A{T, N}, A)

        convert{T}(::Type{$V{T}}, A::AbstractVector) = convert($V{T, DefaultRefType}, A)
        convert{T}(::Type{$V}, A::AbstractVector{T}) = convert($V{T}, A)
        convert{T}(::Type{$V{T}}, A::$V{T}) = A
        convert(::Type{$V}, A::$V) = A

        convert{T}(::Type{$M{T}}, A::AbstractMatrix) = convert($M{T, DefaultRefType}, A)
        convert{T}(::Type{$M}, A::AbstractMatrix{T}) = convert($M{T}, A)
        convert{T}(::Type{$M{T}}, A::$M{T}) = A
        convert(::Type{$M}, A::$M) = A

        similar{S, T, M, N, R}(A::$A{S, M, R}, ::Type{T}, dims::NTuple{N, Int}) = $A{T, N, R}(dims)

        convert{S, T, N, R}(::Type{$A{T, N, R}}, A::AbstractArray{S, N}) =
            copy!($A{T, N, R}(size(A)), A)
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

    # first pass to check whether changes can be applied without error
    # TODO: save original levels and undo changes in case of error to skip this step
    if !all(l->l in newlevels, index(A.pool))
        deleted = [!(l in newlevels) for l in index(A.pool)]
        @inbounds for (i, x) in enumerate(A.values)
            if (isa(A, NominalArray) || isa(A, OrdinalArray)) && deleted[x]
                throw(ArgumentError("cannot remove level $(repr(index(A.pool)[x])) as it is used at position $i. Convert array to a Nullable$(typeof(A).name.name) if you want to transform some levels to missing values."))
            elseif (isa(A, NullableNominalArray) || isa(A, NullableOrdinalArray)) && !nullok && deleted[x]
                throw(ArgumentError("cannot remove level $(repr(index(A.pool)[x])) as it is used at position $i and nullok=false."))
            end
        end
    end

    # actually apply changes
    oldindex = copy(index(A.pool))
    levels!(A.pool, newlevels)

    if index(A.pool) != oldindex
        # indexin returns 0 when not found, which maps to a missing value
        levelsmap = indexin(oldindex, index(A.pool))

        @inbounds for (i, x) in enumerate(A.values)
            j = levelsmap[x]
            x > 0 && (A.values[i] = j)
        end
    end

    levels(A.pool)
end

function droplevels!(A::CatOrdArray)
    found = fill(false, length(index(A.pool)))
    @inbounds for i in A.values
        i > 0 && (found[i] = true)
    end
    levels!(A, intersect(levels(A.pool), index(A.pool)[found]))
end


## Code specific to NominalArray and OrdinalArray

function getindex(A::CatOrdArray, i::Int)
    j = A.values[i]
    j > 0 || throw(UndefRefError())
    A.pool[j]
end

levels!(A::CatOrdArray, newlevels::Vector) = _levels!(A, newlevels)
