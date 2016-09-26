## Common code for CategoricalArray and NullableCategoricalArray

import Base: convert, copy, getindex, setindex!, similar, size, linearindexing, vcat

# Used for keyword argument default value
_ordered(x::AbstractCategoricalArray) = ordered(x)
_ordered(x::AbstractNullableCategoricalArray) = ordered(x)
_ordered(x::Any) = false

function reftype(sz::Int)
    if sz <= typemax(UInt8)
        return UInt8
    elseif sz <= typemax(UInt16)
        return UInt16
    elseif sz <= typemax(UInt32)
        return UInt32
    else
        return UInt64
    end
end

for (A, V, M) in ((:CategoricalArray, :CategoricalVector, :CategoricalMatrix),
                  (:NullableCategoricalArray, :NullableCategoricalVector, :NullableCategoricalMatrix))
    @eval begin
        # Uninitialized array constructors

        $A{T, N}(::Type{T}, dims::NTuple{N,Int}; ordered=false) =
            $A(zeros(DefaultRefType, dims), CategoricalPool{T}(ordered))
        function $A{T}(::Type{T}, dims::Int...; ordered=false)
            A = $A{T}(dims)
            ordered!(A, ordered)
            A
        end
        $A(dims::Int...; ordered=false) = $A{String}(dims, ordered=ordered)

        $A{T, N, R}(::Type{CategoricalValue{T, R}}, dims::NTuple{N,Int}) = $A{T, N, R}(dims)
        $A{T, N}(::Type{CategoricalValue{T}}, dims::NTuple{N,Int}) = $A{T, N}(dims)
#        $A{N}(::Type{CategoricalValue}, dims::NTuple{N,Int}) = $A{String, N}(dims)

        @compat (::Type{$A{T, N, R}}){T, N, R}(dims::NTuple{N,Int}; ordered=false) =
            $A{T, N, R}(zeros(R, dims), CategoricalPool{T, R}(ordered))
        @compat (::Type{$A{T, N}}){T, N}(dims::NTuple{N,Int}; ordered=false) =
            $A{T, N, DefaultRefType}(dims, ordered=ordered)
        @compat (::Type{$A{T}}){T, N}(dims::NTuple{N,Int}; ordered=false) =
            $A{T, N}(dims, ordered=ordered)
        @compat (::Type{$A{T, 1, R}}){T, R}(m::Int; ordered=false) =
            $A{T, 1, R}((m,), ordered=ordered)
        # R <: Integer is required to prevent default constructor from being called instead
        @compat (::Type{$A{T, 2, R}}){T, R <: Integer}(m::Int, n::Int; ordered=false) =
            $A{T, 2, R}((m, n), ordered=ordered)
        @compat (::Type{$A{T, 3, R}}){T, R}(m::Int, n::Int, o::Int; ordered=false) =
            $A{T, 3, R}((m, n, o), ordered=ordered)
        @compat (::Type{$A{T}}){T}(m::Int; ordered=false) =
            $A{T}((m,), ordered=ordered)
        @compat (::Type{$A{T}}){T}(m::Int, n::Int; ordered=false) =
            $A{T}((m, n), ordered=ordered)
        @compat (::Type{$A{T}}){T}(m::Int, n::Int, o::Int; ordered=false) =
            $A{T}((m, n, o), ordered=ordered)

        @compat (::Type{$A{CategoricalValue{T, R}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                    ordered=false) =
            $A{T, N, R}(dims, ordered=ordered)
        @compat (::Type{$A{CategoricalValue{T}, N, R}}){T, N, R}(dims::NTuple{N,Int};
                                                                 ordered=false) =
            $A{T, N, R}(dims, ordered=ordered)
        @compat (::Type{$A{CategoricalValue{T, R}, N}}){T, N, R}(dims::NTuple{N,Int};
                                                                 ordered=false) =
            $A{T, N, R}(dims, ordered=ordered)
        @compat (::Type{$A{CategoricalValue{T}, N}}){T, N}(dims::NTuple{N,Int};
                                                           ordered=false) =
            $A{T, N}(dims, ordered=ordered)
#        @compat (::Type{$A{CategoricalValue, N}}){N}(dims::NTuple{N,Int};
#                                                     ordered=false) =
#            $A{String, N}(dims, ordered=ordered)
#        @compat (::Type{$A{CategoricalValue}}){N}(dims::NTuple{N,Int};
#                                                  ordered=false) =
#            $A{String, N}(dims, ordered=ordered)

if VERSION >= v"0.5.0-dev"
        $V{T}(::Type{T}, m::Integer; ordered=false) = $A{T}((m,), ordered=ordered)
        $V(m::Integer; ordered=false) = $A(m, ordered=ordered)
end
        @compat (::Type{$V{T}}){T}(m::Int; ordered=false) = $A{T}((m,), ordered=ordered)

if VERSION >= v"0.5.0-dev"
        $M{T}(::Type{T}, m::Int, n::Int; ordered=false) = $A{T}((m, n), ordered=ordered)
        $M(m::Int, n::Int; ordered=false) = $A(m, n, ordered=ordered)
end
        @compat (::Type{$M{T}}){T}(m::Int, n::Int; ordered=false) = $A{T}((m, n), ordered=ordered)


        ## Constructors from arrays

        # This method is needed to ensure ordered!() only mutates a copy of A
        @compat function (::Type{$A{T, N, R}}){T, N, R}(A::$A{T, N, R};
                                                        ordered=_ordered(A))
            ret = copy(A)
            ordered!(ret, ordered)
            ret
        end

        # Note this method is also used for CategoricalArrays when T, N or R don't match
        @compat function (::Type{$A{T, N, R}}){T, N, R}(A::AbstractArray;
                                                        ordered=_ordered(A))
            ret = convert($A{T, N, R}, A)
            ordered!(ret, ordered)
            ret
        end

        @compat (::Type{$A{T, N, R}}){T<:CategoricalValue, N, R}(A::AbstractArray;
                                                                 ordered=_ordered(A)) =
            $A{T.parameters[1], N, R}(A, ordered=ordered)

        # From AbstractArray
        @compat (::Type{$A{T, N}}){S, T, N}(A::AbstractArray{S, N}; ordered=_ordered(A)) =
            $A{T, N, DefaultRefType}(A, ordered=ordered)
        @compat (::Type{$A{T}}){S, T, N}(A::AbstractArray{S, N}; ordered=_ordered(A)) =
            $A{T, N}(A, ordered=ordered)
        @compat (::Type{$A}){T, N}(A::AbstractArray{T, N}; ordered=_ordered(A)) =
            $A{T, N}(A, ordered=ordered)

        @compat (::Type{$V{T}}){S, T}(A::AbstractVector{S}; ordered=_ordered(A)) =
            $A{T, 1}(A, ordered=ordered)
        @compat (::Type{$V}){T}(A::AbstractVector{T}; ordered=_ordered(A)) =
            $A{T, 1}(A, ordered=ordered)

        @compat (::Type{$M{T}}){S, T}(A::AbstractMatrix{S}; ordered=_ordered(A)) =
            $A{T, 2}(A, ordered=ordered)
        @compat (::Type{$M}){T}(A::AbstractMatrix{T}; ordered=_ordered(A)) =
            $A{T, 2}(A, ordered=ordered)

        # From CategoricalArray (preserve R)
        @compat (::Type{$A{T, N}}){S, T, N, R}(A::$A{S, N, R}; ordered=_ordered(A)) =
            $A{T, N, R}(A, ordered=ordered)
        @compat (::Type{$A{T}}){S, T, N, R}(A::$A{S, N, R}; ordered=_ordered(A)) =
            $A{T, N, R}(A, ordered=ordered)
        @compat (::Type{$A}){T, N, R}(A::$A{T, N, R}; ordered=_ordered(A)) =
            $A{T, N, R}(A, ordered=ordered)

        @compat (::Type{$V{T}}){S, T, R}(A::$V{S, R}; ordered=_ordered(A)) =
            $A{T, 1, R}(A, ordered=ordered)
        @compat (::Type{$V}){T, R}(A::$V{T, R}; ordered=_ordered(A)) =
            $A{T, 1, R}(A, ordered=ordered)

        @compat (::Type{$M{T}}){S, T, R}(A::$M{S, R}; ordered=_ordered(A)) =
            $A{T, 2, R}(A, ordered=ordered)
        @compat (::Type{$M}){T, R}(A::$M{T, R}; ordered=_ordered(A)) =
            $A{T, 2, R}(A, ordered=ordered)


        ## Conversion methods

        # From AbstractArray
        convert{T, N}(::Type{$A{T, N}}, A::AbstractArray{T, N}) =
            convert($A{T, N, DefaultRefType}, A)
        convert{T, N}(::Type{$A{T}}, A::AbstractArray{T, N}) = convert($A{T, N}, A)
        convert{S, T, N}(::Type{$A{T}}, A::AbstractArray{S, N}) = convert($A{T, N}, A)
        convert{T, N}(::Type{$A}, A::AbstractArray{T, N}) = convert($A{T, N}, A)

        convert{T, N, R}(::Type{$A{CategoricalValue{T, R}, N}}, A::AbstractArray{T, N}) =
            convert($A{T, N, R}, A)
        convert{T, N}(::Type{$A{CategoricalValue{T}, N}}, A::AbstractArray{T, N}) =
            convert($A{T, N}, A)

        convert{T}(::Type{$V{T}}, A::AbstractVector) = convert($V{T, DefaultRefType}, A)
        convert{T}(::Type{$V}, A::AbstractVector{T}) = convert($V{T}, A)
        convert{T}(::Type{$V{T}}, A::$V{T}) = A
        convert(::Type{$V}, A::$V) = A

        convert{T}(::Type{$M{T}}, A::AbstractMatrix) = convert($M{T, DefaultRefType}, A)
        convert{T}(::Type{$M}, A::AbstractMatrix{T}) = convert($M{T}, A)
        convert{T}(::Type{$M{T}}, A::$M{T}) = A
        convert(::Type{$M}, A::$M) = A

        function convert{S, T, N, R}(::Type{$A{T, N, R}}, A::AbstractArray{S, N})
            res = $A{T, N, R}(size(A))
            copy!(res, A)

            if method_exists(isless, (T, T))
                levels!(res, sort(levels(res)))
            end

            res
        end

        # From CategoricalArray (preserve R)
        function convert{T, N, R}(::Type{$A{T, N, R}}, A::$A)
            refs = convert(Array{R, N}, A.refs)
            pool = convert(CategoricalPool{T, R}, A.pool)
            ret = $A(refs, pool)
            ordered!(ret, ordered(A))
            ret
        end
        convert{S, T, N, R}(::Type{$A{T, N}}, A::$A{S, N, R}) =
            convert($A{T, N, R}, A)
        convert{S, T, N, R}(::Type{$A{T}}, A::$A{S, N, R}) =
            convert($A{T, N, R}, A)
        convert{T, N, R}(::Type{$A}, A::$A{T, N, R}) =
            convert($A{T, N, R}, A)

        # R<:Integer is needed for this method to be considered more specific
        # than the generic one above (JuliaLang/julia#18443)
        convert{T, N, R<:Integer}(::Type{$A{T, N, R}}, A::$A{T, N, R}) = A
        convert{T, N}(::Type{$A{T, N}}, A::$A{T, N}) = A
        convert{T}(::Type{$A{T}}, A::$A{T}) = A
        convert(::Type{$A}, A::$A) = A


        ## Other methods

        similar{S, T, M, N, R}(A::$A{S, M, R}, ::Type{T}, dims::NTuple{N, Int}) =
            $A{T, N, R}(dims; ordered=ordered(A))

        function compact{T, N}(A::$A{T, N})
            R = reftype(length(index(A.pool)))
            convert($A{T, N, R}, A)
        end

        function vcat(A::$A...)
            newlevels, isordered = mergelevels(map(levels, A)...)

            refs = [indexin(index(a.pool), newlevels)[a.refs] for a in A]
            $A(DefaultRefType[refs...;],
               CategoricalPool(newlevels, isordered && all(ordered, A)))
        end
    end
end

function @compat(Base.:(==))(A::CatArray, B::CatArray)
    if size(A) != size(B)
        return false
    end
    if A.pool === B.pool
        for (a, b) in zip(A.refs, B.refs)
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

size(A::CatArray) = size(A.refs)
linearindexing{T <: CatArray}(::Type{T}) = Base.LinearFast()

setindex!(A::CatArray, v::Any, i::Int) = A.refs[i] = get!(A.pool, v)
setindex!{T}(A::CatArray, v::CategoricalValue{T}, i::Int) =
    A.refs[i] = get!(A.pool, convert(T, v))

# Method preserving levels and more efficient than AbstractArray one
copy(A::CatArray) = deepcopy(A)


## Categorical-specific methods

levels(A::CatArray) = levels(A.pool)

function _levels!(A::CatArray, newlevels::Vector; nullok=false)
    if !allunique(newlevels)
        throw(ArgumentError(string("duplicated levels found: ",
                                   join(unique(filter(x->sum(newlevels.==x)>1, newlevels)), ", "))))
    end

    # first pass to check whether changes can be applied without error
    # TODO: save original levels and undo changes in case of error to skip this step
    if !all(l->l in newlevels, index(A.pool))
        deleted = [!(l in newlevels) for l in index(A.pool)]
        @inbounds for (i, x) in enumerate(A.refs)
            if isa(A, CategoricalArray) && deleted[x]
                throw(ArgumentError("cannot remove level $(repr(index(A.pool)[x])) as it is used at position $i. Convert array to a Nullable$(typeof(A).name.name) if you want to transform some levels to missing values."))
            elseif isa(A, NullableCategoricalArray) && !nullok && deleted[x]
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

        @inbounds for (i, x) in enumerate(A.refs)
            x > 0 && (A.refs[i] = levelsmap[x])
        end
    end

    levels(A.pool)
end

function droplevels!(A::CatArray)
    found = fill(false, length(index(A.pool)))
    @inbounds for i in A.refs
        i > 0 && (found[i] = true)
    end
    levels!(A, intersect(levels(A.pool), index(A.pool)[found]))
end

ordered(A::CatArray) = ordered(A.pool)
ordered!(A::CatArray, ordered) = ordered!(A.pool, ordered)

function Base.push!(A::CatArray, item)
    resize!(A.refs, length(A.refs) + 1)
    A[end] = item
    return A
end

function Base.append!(A::CatArray, B::CatArray)
    levels!(A, union(levels(A), levels(B)))
    len = length(A.refs)
    len2 = length(B.refs)
    resize!(A.refs, len + length(B.refs))
    for i = 1:len2
        A[len + i] = B[i]
    end
    return A
end

Base.empty!(A::CatArray) = (empty!(A.refs); return A)

categorical(A::AbstractArray; ordered=false) = CategoricalArray(A, ordered=ordered)
categorical{T<:Nullable}(A::AbstractArray{T}; ordered=false) =
    NullableCategoricalArray(A, ordered=ordered)

# Type-unstable methods
function categorical{T, N}(A::AbstractArray{T, N}, compact; ordered=false)
    RefType = compact ? reftype(length(unique(A))) : DefaultRefType
    CategoricalArray{T, N, RefType}(A, ordered=ordered)
end
function categorical{T<:Nullable, N}(A::AbstractArray{T, N}, compact; ordered=false)
    RefType = compact ? reftype(length(unique(A))) : DefaultRefType
    NullableCategoricalArray{T, N, RefType}(A, ordered=ordered)
end
function categorical{T, N, R}(A::CategoricalArray{T, N, R}, compact; ordered=false)
    RefType = compact ? reftype(length(levels(A))) : R
    CategoricalArray{T, N, RefType}(A, ordered=ordered)
end
function categorical{T, N, R}(A::NullableCategoricalArray{T, N, R}, compact; ordered=false)
    RefType = compact ? reftype(length(levels(A))) : R
    NullableCategoricalArray{T, N, RefType}(A, ordered=ordered)
end



## Code specific to CategoricalArray

function getindex(A::CategoricalArray, i::Int)
    j = A.refs[i]
    j > 0 || throw(UndefRefError())
    A.pool[j]
end

levels!(A::CategoricalArray, newlevels::Vector) = _levels!(A, newlevels)

function mergelevels(levels...)
    T = Base.promote_eltype(levels...)
    res = Array{T}(0)
    isordered = true

    for l in levels
        levelsmap = indexin(l, res)

        isordered &= issorted(levelsmap[levelsmap.!=0])
        if !isordered
            # Give up attempt to order res
            append!(res, l[levelsmap.==0])
        else
            i = length(res)+1
            for j = length(l):-1:1
                if levelsmap[j] == 0
                    insert!(res, i, l[j])
                else
                    i = levelsmap[j]
                end
            end
        end
    end

    res, isordered
end
