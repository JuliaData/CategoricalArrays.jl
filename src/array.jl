## Common code for CategoricalArray and NullableCategoricalArray

import Base: convert, copy, copy!, getindex, setindex!, similar, size,
             linearindexing, unique, vcat

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
        and their order are preserved. The reference type is also preserved unless `compress`
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
        and their order are preserved. The reference type is also preserved unless `compress`
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
        and their order are preserved. The reference type is also preserved unless `compress`
        is provided. On the contrary, the `ordered` keyword argument takes precedence over
        the corresponding property of the input array, even when not provided.
        
        In all cases, a copy of `A` is made: use `convert` to avoid making copies when
        unnecessary.
        """ ->
        function $M end

        # Uninitialized array constructors

        $A(dims::Int...; ordered=false) = $A{String}(dims, ordered=ordered)

        @compat (::Type{$A{T, N, R}}){T, N, R}(dims::NTuple{N,Int}; ordered=false) =
            $A{T, N, R}(zeros(R, dims), CategoricalPool{T, R}(ordered))
        @compat (::Type{$A{T, N}}){T, N}(dims::NTuple{N,Int}; ordered=false) =
            $A{T, N, DefaultRefType}(dims, ordered=ordered)
        @compat (::Type{$A{T}}){T, N}(dims::NTuple{N,Int}; ordered=false) =
            $A{T, N}(dims, ordered=ordered)
        @compat (::Type{$A{T, 1}}){T}(m::Int; ordered=false) =
            $A{T, 1}((m,), ordered=ordered)
        @compat (::Type{$A{T, 2}}){T}(m::Int, n::Int; ordered=false) =
            $A{T, 2}((m, n), ordered=ordered)
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

        $V(m::Integer; ordered=false) = $A(m, ordered=ordered)
        @compat (::Type{$V{T}}){T}(m::Int; ordered=false) = $A{T}((m,), ordered=ordered)

        $M(m::Int, n::Int; ordered=false) = $A(m, n, ordered=ordered)
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
        convert{S, T, N}(::Type{$A{T, N}}, A::AbstractArray{S, N}) =
            convert($A{T, N, DefaultRefType}, A)
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
        function convert{S, T, N, R}(::Type{$A{T, N, R}}, A::$A{S, N})
            if length(A.pool) > typemax(R)
                throw(LevelsException{T, R}(levels(A)[typemax(R)+1:end]))
            end

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
@compat Base.IndexStyle(::Type{<:CatArray}) = IndexLinear()

@inline function setindex!(A::CatArray, v::Any, I::Real...)
    @boundscheck checkbounds(A, I...)
    @inbounds A.refs[I...] = get!(A.pool, v)
end

@inline function setindex!{T}(A::CatArray, v::CategoricalValue{T}, I::Real...)
    @boundscheck checkbounds(A, I...)
    @inbounds A.refs[I...] = get!(A.pool, convert(T, v))
end

function mergelevels(ordered, levels...)
    T = Base.promote_eltype(levels...)
    res = Array{T}(0)

    # Fast path in case all levels are equal
    if all(l -> l == levels[1], levels[2:end])
        return copy(levels[1]), ordered
    elseif sum(l -> !isempty(l), levels) == 1
        return copy(levels[findfirst(l -> !isempty(l), levels)]), ordered
    end

    for l in levels
        levelsmap = indexin(l, res)

        i = length(res)+1
        for j = length(l):-1:1
            if levelsmap[j] == 0
                insert!(res, i, l[j])
            else
                i = levelsmap[j]
            end
        end
    end

    # Check that result is ordered
    if ordered
        levelsmaps = [indexin(res, l) for l in levels]

        # Check that each original order is preserved
        for m in levelsmaps
            issorted(m[m .!= 0]) || return res, false
        end

        # Check that all order relations between pairs of subsequent elements
        # are defined in at least one set of original levels
        pairs = fill(false, length(res)-1)
        for m in levelsmaps
            @inbounds for i in eachindex(pairs)
                pairs[i] |= (m[i] != 0) & (m[i+1] != 0)
            end
            all(pairs) && return res, true
        end
    end

    res, false
end

# Methods preserving levels and more efficient than AbstractArray fallbacks
copy(A::CatArray) = deepcopy(A)

function copy!{T, N}(dest::CatArray{T, N}, dstart::Integer,
                     src::CatArray{T, N}, sstart::Integer, n::Integer=length(src)-sstart+1)
    destinds, srcinds = linearindices(dest), linearindices(src)
    (dstart ∈ destinds && dstart+n-1 ∈ destinds) || throw(BoundsError(dest, dstart:dstart+n-1))
    (sstart ∈ srcinds  && sstart+n-1 ∈ srcinds)  || throw(BoundsError(src,  sstart:sstart+n-1))
    n == 0 && return dest
    n < 0 && throw(ArgumentError(string("tried to copy n=", n, " elements, but n should be nonnegative")))

    drefs = dest.refs
    srefs = src.refs

    newlevels, ordered = mergelevels(isordered(dest), levels(dest), levels(src))
    # Orderedness cannot be preserved if the source was unordered and new levels
    # need to be added: new comparisons would only be based on the source's order
    # (this is consistent with what happens when adding a new level via setindex!)
    ordered &= isordered(src) | (length(newlevels) == length(levels(dest)))
    ordered!(dest, ordered)

    # Simple case: replace all values
    if dstart == dstart == 1 && n == length(dest) == length(src)
        # Set index to reflect refs
        levels!(dest.pool, T[]) # Needed in case src and dest share some levels
        levels!(dest.pool, index(src.pool))

        # Set final levels in their visible order
        levels!(dest.pool, newlevels)

        copy!(drefs, srefs)
    else # More work to do: preserve some values (and therefore index)
        levels!(dest.pool, newlevels)

        indexmap = indexin(index(src.pool), index(dest.pool))

        @inbounds for i = 0:(n-1)
            x = srefs[sstart+i]
            drefs[dstart+i] = x > 0 ? indexmap[x] : 0
        end

    end

    dest
end

copy!{T,N}(dest::CatArray{T, N}, src::CatArray{T, N}) =
    copy!(dest, 1, src, 1, length(src))

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
    compress(A::CategoricalArray)
    compress(A::NullableCategoricalArray)

Return a copy of categorical array `A` using the smallest reference type able to hold the
number of [`levels`](@ref) of `A`.

While this will reduce memory use, this function is type-unstable, which can affect
performance inside the function where the call is made. Therefore, use it with caution.
"""
function compress{T, N}(A::CatArray{T, N})
    R = reftype(length(index(A.pool)))
    convert(arraytype(typeof(A)){T, N, R}, A)
end

"""
    decompress(A::CategoricalArray)
    decompress(A::NullableCategoricalArray)

Return a copy of categorical array `A` using the default reference type ($DefaultRefType).
If `A` is using a small reference type (such as `UInt8` or `UInt16`) the decompressed array
will have room for more levels.

To avoid the need to call decompress, ensure [`compress`](@ref) is not called when creating
the categorical array.
"""
decompress{T, N}(A::CatArray{T, N}) =
    convert(arraytype(typeof(A)){T, N, DefaultRefType}, A)

arraytype(A::CategoricalArray...) = CategoricalArray
arraytype(A::CatArray...) = NullableCategoricalArray

function vcat(A::CatArray...)
    ordered = any(isordered, A) && all(a->isordered(a) || isempty(levels(a)), A)
    newlevels, ordered = mergelevels(ordered, map(levels, A)...)

    refs = map(A) do a
        ii = indexin(index(a.pool), newlevels)
        [x==0 ? 0 : ii[x] for x in a.refs]
    end

    T = arraytype(A...)
    T(DefaultRefType[refs...;], CategoricalPool(newlevels, ordered))
end


## Categorical-specific methods

@inline function getindex(A::CatArray, I...)
    @boundscheck checkbounds(A, I...)
    # Let Array indexing code handle everything
    @inbounds r = A.refs[I...]

    if isa(r, Array)
        res = arraytype(A)(r, deepcopy(A.pool))
        return ordered!(res, isordered(A))
    else
        r > 0 || throw(UndefRefError())
        @inbounds res = A.pool[r]
        return res
    end
end

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

function Base.resize!(A::CatVector, n::Integer)
    n_orig = length(A)
    resize!(A.refs, n)
    if n > n_orig
        A.refs[n_orig+1:end] = 0
    end
    A
end

function Base.push!(A::CatVector, item)
    resize!(A.refs, length(A.refs) + 1)
    A[end] = item
    return A
end

function Base.append!(A::CatVector, B::CatArray)
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

function Base.reshape{T, N, R}(A::CatArray{T, N, R}, dims::Dims)
    x = reshape(A.refs, dims)
    res = arraytype(A){T, ndims(x), R}(x, A.pool)
    ordered!(res, isordered(res))
end

"""
    categorical{T}(A::AbstractArray{T}[, compress::Bool]; ordered::Bool=false)

Construct a categorical array with the values from `A`. If `T<:Nullable`, return a
`NullableCategoricalArray{T}`; else, return a `CategoricalArray{T}`.

If the element type supports it, levels are sorted in ascending order;
else, they are kept in their order of appearance in `A`. The `ordered` keyword
argument determines whether the array values can be compared according to the
ordering of levels or not (see [`isordered`](@ref)).

If `compress` is provided and set to `true`, the smallest reference type able to hold the
number of unique values in `A` will be used. While this will reduce memory use, passing
this parameter will also introduce a type instability which can affect performance inside
the function where the call is made. Therefore, use this option with caution (the
one-argument version does not suffer from this problem).

    categorical{T}(A::CategoricalArray{T}[, compress::Bool]; ordered::Bool=false)
    categorical{T}(A::NullableCategoricalArray{T}[, compress::Bool]; ordered::Bool=false)

If `A` is already a `CategoricalArray` or a `NullableCategoricalArray`, its levels
are preserved. The reference type is also preserved unless `compress` is provided.
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
function categorical{T, N}(A::AbstractArray{T, N}, compress; ordered=false)
    RefType = compress ? reftype(length(unique(A))) : DefaultRefType
    CategoricalArray{T, N, RefType}(A, ordered=ordered)
end
function categorical{T<:Nullable, N}(A::AbstractArray{T, N}, compress; ordered=false)
    RefType = compress ? reftype(length(unique(A))) : DefaultRefType
    NullableCategoricalArray{T, N, RefType}(A, ordered=ordered)
end
function categorical{T, N, R}(A::CategoricalArray{T, N, R}, compress; ordered=false)
    RefType = compress ? reftype(length(levels(A))) : R
    CategoricalArray{T, N, RefType}(A, ordered=ordered)
end
function categorical{T, N, R}(A::NullableCategoricalArray{T, N, R}, compress; ordered=false)
    RefType = compress ? reftype(length(levels(A))) : R
    NullableCategoricalArray{T, N, RefType}(A, ordered=ordered)
end



## Code specific to CategoricalArray

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

"""
    droplevels!(A::CategoricalArray)
    droplevels!(A::NullableCategoricalArray)

Drop levels which do not appear in categorical array `A` (so that they will no longer be
returned by [`levels`](@ref)).
"""

droplevels!(A::CategoricalArray) = levels!(A, unique(A))

unique(A::CategoricalArray) = _unique(Array, A.refs, A.pool)
