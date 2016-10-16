## Common code for CategoricalArray and NullableCategoricalArray

import Base: convert, copy, getindex, setindex!, similar, size, linearindexing, unique, vcat

# Used for keyword argument default value
_isordered(x::AbstractCategoricalArray) = isordered(x)
_isordered(x::AbstractNullableCategoricalArray) = isordered(x)
_isordered(x::Any) = false

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
        As = $(string(A))
        Vs = $(string(V))
        Ms = $(string(M))

        @doc """
            $As{T}(dims::Dims; ordered::Bool=false)
            $As{T}(dims::Int...; ordered::Bool=false)

        Construct an uninitialized `$As` with levels of type `T` and dimensions `dim`.
        The `ordered` keyword argument determines whether the array values can be compared
        according to the ordering of levels or not (see [`isordered`](@ref)).

            $As{T, N, R}(dims::Dims; ordered::Bool=false)
            $As{T, N, R}(dims::Int...; ordered::Bool=false)

        Similar to definition above, but uses reference type `R` instead of the default type
        (`$DefaultRefType`).

            $As(A::AbstractArray; ordered::Bool=false)

        Construct a `$As` with the values from `A` and the same element type.

        If the element type supports it, levels are sorted in ascending order;
        else, they are kept in their order of appearance in `A`. The `ordered` keyword
        argument determines whether the array values can be compared according to the
        ordering of levels or not (see [`isordered`](@ref)).

            $As(A::CategoricalArray; ordered::Bool=false)
            $As(A::NullableCategoricalArray; ordered::Bool=false)

        If `A` is already a `CategoricalArray` or a `NullableCategoricalArray`, its levels
        and their order are preserved. The reference type is also preserved unless `compact`
        is provided. On the contrary, the `ordered` keyword argument takes precedence over
        the corresponding property of the input array, even when not provided.
        
        In all cases, a copy of `A` is made: use `convert` to avoid making copies when
        unnecessary.
        """ ->
        function $A end

        @doc """
            $Vs{T}(m::Int; ordered::Bool=false)

        Construct an uninitialized `$Vs` with levels of type `T` and dimensions `dim`.
        The `ordered` keyword argument determines whether the array values can be compared
        according to the ordering of levels or not (see [`isordered`](@ref)).

            $Vs{T, R}(m::Int; ordered::Bool=false)

        Similar to definition above, but uses reference type `R` instead of the default type
        (`$DefaultRefType`).

            $Vs(A::AbstractVector; ordered::Bool=false)

        Construct a `$Vs` with the values from `A` and the same element type.

        If the element type supports it, levels are sorted in ascending order;
        else, they are kept in their order of appearance in `A`. The `ordered` keyword
        argument determines whether the array values can be compared according to the
        ordering of levels or not (see [`isordered`](@ref)).

            $Vs(A::CategoricalVector; ordered::Bool=false)
            $Vs(A::NullableCategoricalVector; ordered::Bool=false)

        If `A` is already a `CategoricalVector` or a `NullableCategoricalVector`, its levels
        and their order are preserved. The reference type is also preserved unless `compact`
        is provided. On the contrary, the `ordered` keyword argument takes precedence over
        the corresponding property of the input array, even when not provided.
        
        In all cases, a copy of `A` is made: use `convert` to avoid making copies when
        unnecessary.
        """ ->
        function $V end

        @doc """
            $Ms{T}(m::Int, n::Int; ordered::Bool=false)

        Construct an uninitialized `$Ms` with levels of type `T` and dimensions `dim`.
        The `ordered` keyword argument determines whether the array values can be compared
        according to the ordering of levels or not (see [`isordered`](@ref)).

            $Ms{T, R}(m::Int, n::Int; ordered::Bool=false)

        Similar to definition above, but uses reference type `R` instead of the default type
        (`$DefaultRefType`).

            $Ms(A::AbstractVector; ordered::Bool=false)

        Construct a `$Ms` with the values from `A` and the same element type.

        If the element type supports it, levels are sorted in ascending order;
        else, they are kept in their order of appearance in `A`. The `ordered` keyword
        argument determines whether the array values can be compared according to the
        ordering of levels or not (see [`isordered`](@ref)).

            $Ms(A::CategoricalMatrix; ordered::Bool=false)
            $Ms(A::NullableCategoricalMatrix; ordered::Bool=false)

        If `A` is already a `CategoricalMatrix` or a `NullableCategoricalMatrix`, its levels
        and their order are preserved. The reference type is also preserved unless `compact`
        is provided. On the contrary, the `ordered` keyword argument takes precedence over
        the corresponding property of the input array, even when not provided.
        
        In all cases, a copy of `A` is made: use `convert` to avoid making copies when
        unnecessary.
        """ ->
        function $M end

        # Uninitialized array constructors

        $A{T, N}(::Type{T}, dims::NTuple{N,Int}; ordered=false) =
            $A(zeros(DefaultRefType, dims), CategoricalPool{T}(ordered))
        $A{T}(::Type{T}, dims::Int...; ordered=false) = ordered!($A{T}(dims), ordered)
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
        @compat (::Type{$A{T, N, R}}){T, N, R}(A::$A{T, N, R}; ordered=_isordered(A)) =
            ordered!(copy(A), ordered)

        # Note this method is also used for CategoricalArrays when T, N or R don't match
        @compat (::Type{$A{T, N, R}}){T, N, R}(A::AbstractArray; ordered=_isordered(A)) =
            ordered!(convert($A{T, N, R}, A), ordered)

        @compat (::Type{$A{T, N, R}}){T<:CategoricalValue, N, R}(A::AbstractArray;
                                                                 ordered=_isordered(A)) =
            $A{T.parameters[1], N, R}(A, ordered=ordered)

        # From AbstractArray
        @compat (::Type{$A{T, N}}){S, T, N}(A::AbstractArray{S, N}; ordered=_isordered(A)) =
            $A{T, N, DefaultRefType}(A, ordered=ordered)
        @compat (::Type{$A{T}}){S, T, N}(A::AbstractArray{S, N}; ordered=_isordered(A)) =
            $A{T, N}(A, ordered=ordered)
        @compat (::Type{$A}){T, N}(A::AbstractArray{T, N}; ordered=_isordered(A)) =
            $A{T, N}(A, ordered=ordered)

        @compat (::Type{$V{T}}){S, T}(A::AbstractVector{S}; ordered=_isordered(A)) =
            $A{T, 1}(A, ordered=ordered)
        @compat (::Type{$V}){T}(A::AbstractVector{T}; ordered=_isordered(A)) =
            $A{T, 1}(A, ordered=ordered)

        @compat (::Type{$M{T}}){S, T}(A::AbstractMatrix{S}; ordered=_isordered(A)) =
            $A{T, 2}(A, ordered=ordered)
        @compat (::Type{$M}){T}(A::AbstractMatrix{T}; ordered=_isordered(A)) =
            $A{T, 2}(A, ordered=ordered)

        # From CategoricalArray (preserve R)
        @compat (::Type{$A{T, N}}){S, T, N, R}(A::$A{S, N, R}; ordered=_isordered(A)) =
            $A{T, N, R}(A, ordered=ordered)
        @compat (::Type{$A{T}}){S, T, N, R}(A::$A{S, N, R}; ordered=_isordered(A)) =
            $A{T, N, R}(A, ordered=ordered)
        @compat (::Type{$A}){T, N, R}(A::$A{T, N, R}; ordered=_isordered(A)) =
            $A{T, N, R}(A, ordered=ordered)

        @compat (::Type{$V{T}}){S, T, R}(A::$V{S, R}; ordered=_isordered(A)) =
            $A{T, 1, R}(A, ordered=ordered)
        @compat (::Type{$V}){T, R}(A::$V{T, R}; ordered=_isordered(A)) =
            $A{T, 1, R}(A, ordered=ordered)

        @compat (::Type{$M{T}}){S, T, R}(A::$M{S, R}; ordered=_isordered(A)) =
            $A{T, 2, R}(A, ordered=ordered)
        @compat (::Type{$M}){T, R}(A::$M{T, R}; ordered=_isordered(A)) =
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
            ordered!($A(refs, pool), isordered(A))
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

arraytype{T<:CategoricalArray}(::Type{T}) = CategoricalArray
arraytype{T<:NullableCategoricalArray}(::Type{T}) = NullableCategoricalArray

"""
    similar(A::CategoricalArray, element_type=eltype(A), dims=size(A))
    similar(A::NullableCategoricalArray,element_type=eltype(A), dims=size(A))

For `CategoricalArray` and `NullableCategoricalArray`, preserves the ordered property
of `A` (see [`isordered`](@ref)).
"""
similar{S, T, M, N, R}(A::CatArray{S, M, R}, ::Type{T}, dims::NTuple{N, Int}) =
    arraytype(typeof(A)){T, N, R}(dims; ordered=isordered(A))

"""
    compact(A::CategoricalArray)
    compact(A::NullableCategoricalArray)

Return a copy of categorical array `A` using the smallest reference type able to hold the
number of [`levels`](@ref) of `A`.

While this will reduce memory use, this function is type-unstable, which can affect
performance inside the function where the call is made. Therefore, use it with caution.
"""
function compact{T, N}(A::CatArray{T, N})
    R = reftype(length(index(A.pool)))
    convert(arraytype(typeof(A)){T, N, R}, A)
end

arraytype(A::CategoricalArray...) = CategoricalArray
arraytype(A::CatArray...) = NullableCategoricalArray

function vcat(A::CatArray...)
    newlevels, ordered = mergelevels(map(levels, A)...)
    ordered &= any(isordered, A)
    ordered &= all(a->isordered(a) || isempty(levels(a)), A)

    refs = map(A) do a
        ii = indexin(index(a.pool), newlevels)
        [x==0 ? 0 : ii[x] for x in a.refs]
    end

    T = arraytype(A...)
    T(DefaultRefType[refs...;], CategoricalPool(newlevels, ordered))
end


## Categorical-specific methods

"""
    levels(A::CategoricalArray)
    levels(A::NullableCategoricalArray)

Return the levels of categorical array `A`. This may include levels which do not actually appear
in the data (see [`droplevels!`](@ref)).
"""
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
            elseif isa(A, NullableCategoricalArray) && !nullok && x > 0 && deleted[x]
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

    A
end

function _unique{S<:AbstractArray, T<:Integer}(::Type{S},
                                               refs::AbstractArray{T},
                                               pool::CategoricalPool)
    seen = fill(false, length(index(pool))+1)
    tracknulls = eltype(S) <: Nullable
    # If we don't track nulls, short-circuit even if none has been seen
    seen[1] = !tracknulls
    batch = 0
    @inbounds for i in refs
        seen[i + 1] = true
        # Only do a costly short-circuit check periodically
        batch += 1
        if batch > 1000
            all(seen) && break
            batch = 0
        end
    end
    seennull = shift!(seen)
    res = S(index(pool)[seen][sortperm(pool.order[seen])])
    if tracknulls && seennull
        push!(res, Nullable{eltype(index(pool))}())
    end
    res
end

"""
    unique(A::CategoricalArray)
    unique(A::NullableCategoricalArray)

Return levels which appear in `A`, in the same order as [`levels`](@ref)
(and not in their order of appearance). This function is significantly slower than
[`levels`](@ref) since it needs to check whether levels are used or not.
"""
function unique end

"""
    droplevels!(A::CategoricalArray)
    droplevels!(A::NullableCategoricalArray)

Drop levels which do not appear in categorical array `A` (so that they will no longer be
returned by [`levels`](@ref)).
"""
function droplevels end

"""
    isordered(A::CategoricalArray)
    isordered(A::NullableCategoricalArray)

Test whether entries in `A` can be compared using `<`, `>` and similar operators,
using the ordering of levels.
"""
isordered(A::CatArray) = isordered(A.pool)

"""
    ordered!(A::CategoricalArray, ordered::Bool)
    ordered!(A::NullableCategoricalArray, ordered::Bool)

Set whether entries in `A` can be compared using `<`, `>` and similar operators,
using the ordering of levels. Return the modified `A`.
"""
ordered!(A::CatArray, ordered) = (ordered!(A.pool, ordered); return A)

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

"""
    categorical{T}(A::AbstractArray{T}[, compact::Bool]; ordered::Bool=false)

Construct a categorical array with the values from `A`. If `T<:Nullable`, return a
`NullableCategoricalArray{T}`; else, return a `CategoricalArray{T}`.

If the element type supports it, levels are sorted in ascending order;
else, they are kept in their order of appearance in `A`. The `ordered` keyword
argument determines whether the array values can be compared according to the
ordering of levels or not (see [`isordered`](@ref)).

If `compact` is provided and set to `true`, the smallest reference type able to hold the
number of unique values in `A` will be used. While this will reduce memory use, passing
this parameter will also introduce a type instability which can affect performance inside
the function where the call is made. Therefore, use this option with caution (the
one-argument version does not suffer from this problem).

    categorical{T}(A::CategoricalArray{T}[, compact::Bool]; ordered::Bool=false)
    categorical{T}(A::NullableCategoricalArray{T}[, compact::Bool]; ordered::Bool=false)

If `A` is already a `CategoricalArray` or a `NullableCategoricalArray`, its levels
are preserved. The reference type is also preserved unless `compact` is provided.
On the contrary, the `ordered` keyword argument takes precedence over the
corresponding property of the input array, even when not provided.

In all cases, a copy of `A` is made: use `convert` to avoid making copies when
unnecessary.
"""
function categorical end

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

"""
    levels!(A::CategoricalArray, newlevels::Vector)
    levels!(A::NullableCategoricalArray, newlevels::Vector; nullok::Bool=false)

Set the levels categorical array `A`. The order of appearance of levels will be respected
by [`levels`](@ref), which may affect display of results in some operations; if `A` is
ordered (see [`isordered`](@ref)), it will also be used for order comparisons
using `<`, `>` and similar operators. Reordering levels will never affect the values
of entries in the array.

If `A` is a `CategoricalArray`, `newlevels` must include all levels which appear in the data.
The same applies if `A` is a `NullableCategoricalArray`, unless `nullok=false` is passed: in
that case, entries corresponding to missing levels will be set to null.
"""
function levels! end

levels!(A::CategoricalArray, newlevels::Vector) = _levels!(A, newlevels)

droplevels!(A::CategoricalArray) = levels!(A, unique(A))

function mergelevels(levels...)
    T = Base.promote_eltype(levels...)
    res = Array{T}(0)
    ordered = true

    for l in levels
        levelsmap = indexin(l, res)

        ordered &= issorted(levelsmap[levelsmap.!=0])
        if !ordered
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

    res, ordered
end

unique(A::CategoricalArray) = _unique(Array, A.refs, A.pool)
