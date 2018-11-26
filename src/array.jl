## Code for CategoricalArray

import Base: Array, convert, collect, copy, getindex, setindex!, similar, size,
             unique, vcat, in, summary, float, complex
import Compat: copyto!

# Used for keyword argument default value
_isordered(x::AbstractCategoricalArray) = isordered(x)
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

"""
    CategoricalArray{T}(undef, dims::Dims; ordered::Bool=false)
    CategoricalArray{T}(undef, dims::Int...; ordered::Bool=false)

Construct an uninitialized `CategoricalArray` with levels of type `T` and dimensions `dim`.
The `ordered` keyword argument determines whether the array values can be compared
according to the ordering of levels or not (see [`isordered`](@ref)).

    CategoricalArray{T, N, R}(undef, dims::Dims; ordered::Bool=false)
    CategoricalArray{T, N, R}(undef, dims::Int...; ordered::Bool=false)

Similar to definition above, but uses reference type `R` instead of the default type
(`$DefaultRefType`).

    CategoricalArray(A::AbstractArray; ordered::Bool=false)

Construct a new `CategoricalArray` with the values from `A` and the same element type.

If the element type supports it, levels are sorted in ascending order;
else, they are kept in their order of appearance in `A`. The `ordered` keyword
argument determines whether the array values can be compared according to the
ordering of levels or not (see [`isordered`](@ref)).

    CategoricalArray(A::CategoricalArray; ordered::Bool=false)

If `A` is already a `CategoricalArray`, its levels are preserved;
the same applies to the ordered property and the reference type unless
explicitly overriden.
"""
function CategoricalArray end

"""
    CategoricalVector{T}(undef, m::Int; ordered::Bool=false)

Construct an uninitialized `CategoricalVector` with levels of type `T` and dimensions `dim`.
The `ordered` keyword argument determines whether the array values can be compared
according to the ordering of levels or not (see [`isordered`](@ref)).

    CategoricalVector{T, R}(undef, m::Int; ordered::Bool=false)

Similar to definition above, but uses reference type `R` instead of the default type
(`$DefaultRefType`).

    CategoricalVector(A::AbstractVector; ordered::Bool=false)

Construct a `CategoricalVector` with the values from `A` and the same element type.

If the element type supports it, levels are sorted in ascending order;
else, they are kept in their order of appearance in `A`. The `ordered` keyword
argument determines whether the array values can be compared according to the
ordering of levels or not (see [`isordered`](@ref)).

    CategoricalVector(A::CategoricalVector; ordered::Bool=false)

If `A` is already a `CategoricalVector`, its levels are preserved;
the same applies to the ordered property and the reference type unless
explicitly overriden.
"""
function CategoricalVector end

"""
    CategoricalMatrix{T}(undef, m::Int, n::Int; ordered::Bool=false)

Construct an uninitialized `CategoricalMatrix` with levels of type `T` and dimensions `dim`.
The `ordered` keyword argument determines whether the array values can be compared
according to the ordering of levels or not (see [`isordered`](@ref)).

    CategoricalMatrix{T, R}(undef, m::Int, n::Int; ordered::Bool=false)

Similar to definition above, but uses reference type `R` instead of the default type
(`$DefaultRefType`).

    CategoricalMatrix(A::AbstractVector; ordered::Bool=false)

Construct a `CategoricalMatrix` with the values from `A` and the same element type.

If the element type supports it, levels are sorted in ascending order;
else, they are kept in their order of appearance in `A`. The `ordered` keyword
argument determines whether the array values can be compared according to the
ordering of levels or not (see [`isordered`](@ref)).

    CategoricalMatrix(A::CategoricalMatrix; ordered::Bool=isordered(A))

If `A` is already a `CategoricalMatrix`, its levels are preserved;
the same applies to the ordered property and the reference type unless
explicitly overriden.
"""
function CategoricalMatrix end

# UndefInitializer array constructors

CategoricalArray(::UndefInitializer, dims::Int...; ordered=false) =
    CategoricalArray{String}(undef, dims, ordered=ordered)

function CategoricalArray{T, N, R}(::UndefInitializer, dims::NTuple{N,Int};
                                   ordered=false) where {T, N, R}
    C = catvaluetype(T, R)
    V = leveltype(C)
    S = T >: Missing ? Union{V, Missing} : V
    CategoricalArray{S, N}(zeros(R, dims), CategoricalPool{V, R, C}(ordered))
end

CategoricalArray{T, N}(::UndefInitializer, dims::NTuple{N,Int}; ordered=false) where {T, N} =
    CategoricalArray{T, N, DefaultRefType}(undef, dims, ordered=ordered)
CategoricalArray{T}(::UndefInitializer, dims::NTuple{N,Int}; ordered=false) where {T, N} =
    CategoricalArray{T, N}(undef, dims, ordered=ordered)
CategoricalArray{T, 1}(::UndefInitializer, m::Int; ordered=false) where {T} =
    CategoricalArray{T, 1}(undef, (m,), ordered=ordered)
CategoricalArray{T, 2}(::UndefInitializer, m::Int, n::Int; ordered=false) where {T} =
    CategoricalArray{T, 2}(undef, (m, n), ordered=ordered)
CategoricalArray{T, 1, R}(::UndefInitializer, m::Int; ordered=false) where {T, R} =
    CategoricalArray{T, 1, R}(undef, (m,), ordered=ordered)
# R <: Integer is required to prevent default constructor from being called instead
CategoricalArray{T, 2, R}(::UndefInitializer, m::Int, n::Int; ordered=false) where {T, R <: Integer} =
    CategoricalArray{T, 2, R}(undef, (m, n), ordered=ordered)
CategoricalArray{T, 3, R}(::UndefInitializer, m::Int, n::Int, o::Int; ordered=false) where {T, R} =
    CategoricalArray{T, 3, R}(undef, (m, n, o), ordered=ordered)
CategoricalArray{T}(::UndefInitializer, m::Int; ordered=false) where {T} =
    CategoricalArray{T}(undef, (m,), ordered=ordered)
CategoricalArray{T}(::UndefInitializer, m::Int, n::Int; ordered=false) where {T} =
    CategoricalArray{T}(undef, (m, n), ordered=ordered)
CategoricalArray{T}(::UndefInitializer, m::Int, n::Int, o::Int; ordered=false) where {T} =
    CategoricalArray{T}(undef, (m, n, o), ordered=ordered)

CategoricalVector(::UndefInitializer, m::Integer; ordered=false) =
    CategoricalArray(undef, m, ordered=ordered)
CategoricalVector{T}(::UndefInitializer, m::Int; ordered=false) where {T} =
    CategoricalArray{T}(undef, (m,), ordered=ordered)

CategoricalMatrix(::UndefInitializer, m::Int, n::Int; ordered=false) =
    CategoricalArray(undef, m, n, ordered=ordered)
CategoricalMatrix{T}(::UndefInitializer, m::Int, n::Int; ordered=false) where {T} =
    CategoricalArray{T}(undef, (m, n), ordered=ordered)


## Constructors from arrays

function CategoricalArray{T, N, R}(A::CategoricalArray{S, N, Q};
                                   ordered=_isordered(A)) where {S, T, N, Q, R}
    V = unwrap_catvaluetype(T)
    res = convert(CategoricalArray{V, N, R}, A)
    refs = res.refs === A.refs ? deepcopy(res.refs) : res.refs
    pool = res.pool === A.pool ? deepcopy(res.pool) : res.pool
    ordered!(CategoricalArray{V, N}(refs, pool), ordered)
end

function CategoricalArray{T, N, R}(A::AbstractArray; ordered=_isordered(A)) where {T, N, R}
    V = unwrap_catvaluetype(T)
    ordered!(convert(CategoricalArray{V, N, R}, A), ordered)
end

# From AbstractArray
CategoricalArray{T, N}(A::AbstractArray{S, N}; ordered=_isordered(A)) where {S, T, N} =
    CategoricalArray{T, N, DefaultRefType}(A, ordered=ordered)
CategoricalArray{T}(A::AbstractArray{S, N}; ordered=_isordered(A)) where {S, T, N} =
    CategoricalArray{T, N}(A, ordered=ordered)
CategoricalArray(A::AbstractArray{T, N}; ordered=_isordered(A)) where {T, N} =
    CategoricalArray{T, N}(A, ordered=ordered)

CategoricalVector{T}(A::AbstractVector{S}; ordered=_isordered(A)) where {S, T} =
    CategoricalArray{T, 1}(A, ordered=ordered)
CategoricalVector(A::AbstractVector{T}; ordered=_isordered(A)) where {T} =
    CategoricalArray{T, 1}(A, ordered=ordered)

CategoricalMatrix{T}(A::AbstractMatrix{S}; ordered=_isordered(A)) where {S, T} =
    CategoricalArray{T, 2}(A, ordered=ordered)
CategoricalMatrix(A::AbstractMatrix{T}; ordered=_isordered(A)) where {T} =
    CategoricalArray{T, 2}(A, ordered=ordered)

# From CategoricalArray (preserve R)
CategoricalArray{T, N}(A::CategoricalArray{S, N, R};
                       ordered=_isordered(A)) where {S, T, N, R} =
    CategoricalArray{T, N, R}(A, ordered=ordered)
CategoricalArray{T}(A::CategoricalArray{S, N, R};
                    ordered=_isordered(A)) where {S, T, N, R} =
    CategoricalArray{T, N, R}(A, ordered=ordered)
CategoricalArray(A::CategoricalArray{T, N, R};
                 ordered=_isordered(A)) where {T, N, R} =
    CategoricalArray{T, N, R}(A, ordered=ordered)

CategoricalVector{T}(A::CategoricalArray{S, 1, R};
                     ordered=_isordered(A)) where {S, T, R} =
    CategoricalArray{T, 1, R}(A, ordered=ordered)
CategoricalVector(A::CategoricalArray{T, 1, R};
                  ordered=_isordered(A)) where {T, R} =
    CategoricalArray{T, 1, R}(A, ordered=ordered)

CategoricalMatrix{T}(A::CategoricalArray{S, 2, R};
                     ordered=_isordered(A)) where {S, T, R} =
    CategoricalArray{T, 2, R}(A, ordered=ordered)
CategoricalMatrix(A::CategoricalArray{T, 2, R};
                  ordered=_isordered(A)) where {T, R} =
    CategoricalArray{T, 2, R}(A, ordered=ordered)


## Conversion methods

# From AbstractArray
convert(::Type{CategoricalArray{T, N}}, A::AbstractArray{S, N}) where {S, T, N} =
    convert(CategoricalArray{T, N, DefaultRefType}, A)
convert(::Type{CategoricalArray{T}}, A::AbstractArray{S, N}) where {S, T, N} =
    convert(CategoricalArray{T, N}, A)
convert(::Type{CategoricalArray}, A::AbstractArray{T, N}) where {T, N} =
    convert(CategoricalArray{T, N}, A)

convert(::Type{CategoricalVector{T}}, A::AbstractVector) where {T} =
    convert(CategoricalVector{T, DefaultRefType}, A)
convert(::Type{CategoricalVector}, A::AbstractVector{T}) where {T} =
    convert(CategoricalVector{T}, A)
convert(::Type{CategoricalVector{T}}, A::CategoricalVector{T}) where {T} = A
convert(::Type{CategoricalVector}, A::CategoricalVector) = A

convert(::Type{CategoricalMatrix{T}}, A::AbstractMatrix) where {T} =
    convert(CategoricalMatrix{T, DefaultRefType}, A)
convert(::Type{CategoricalMatrix}, A::AbstractMatrix{T}) where {T} =
    convert(CategoricalMatrix{T}, A)
convert(::Type{CategoricalMatrix{T}}, A::CategoricalMatrix{T}) where {T} = A
convert(::Type{CategoricalMatrix}, A::CategoricalMatrix) = A

function convert(::Type{CategoricalArray{T, N, R}}, A::AbstractArray{S, N}) where {S, T, N, R}
    res = CategoricalArray{T, N, R}(undef, size(A))
    copyto!(res, A)

    # if order is defined for level type, automatically apply it
    L = leveltype(res)
    if hasmethod(isless, Tuple{L, L})
        levels!(res.pool, sort(levels(res.pool)))
    end

    res
end

# From CategoricalArray (preserve levels, ordering and R)
function convert(::Type{CategoricalArray{T, N, R}}, A::CategoricalArray{S, N}) where {S, T, N, R}
    if length(A.pool) > typemax(R)
        throw(LevelsException{T, R}(levels(A)[typemax(R)+1:end]))
    end

    if T >: Missing
        U = Missings.T(T)
    else
        U = T
        S >: Missing && any(iszero, A.refs) &&
            throw(MissingException("cannot convert CategoricalArray with missing values to a CategoricalArray{$T}"))
    end

    pool = convert(CategoricalPool{unwrap_catvaluetype(U), R}, A.pool)
    refs = convert(Array{R, N}, A.refs)
    CategoricalArray{unwrap_catvaluetype(T), N}(refs, pool)
end
convert(::Type{CategoricalArray{T, N}}, A::CategoricalArray{S, N, R}) where {S, T, N, R} =
    convert(CategoricalArray{T, N, R}, A)
convert(::Type{CategoricalArray{T}}, A::CategoricalArray{S, N, R}) where {S, T, N, R} =
    convert(CategoricalArray{T, N, R}, A)
convert(::Type{CategoricalArray}, A::CategoricalArray{T, N, R}) where {T, N, R} =
    convert(CategoricalArray{T, N, R}, A)

# R<:Integer is needed for this method to be considered more specific
# than the generic one above (JuliaLang/julia#18443)
convert(::Type{CategoricalArray{T, N, R}}, A::CategoricalArray{T, N, R}) where {T, N, R<:Integer} = A
convert(::Type{CategoricalArray{T, N}}, A::CategoricalArray{T, N}) where {T, N} = A
convert(::Type{CategoricalArray{T}}, A::CategoricalArray{T}) where {T} = A
convert(::Type{CategoricalArray}, A::CategoricalArray) = A

function Base.:(==)(A::CategoricalArray{S}, B::CategoricalArray{T}) where {S, T}
    if size(A) != size(B)
        return false
    end
    anymissing = false
    if A.pool === B.pool
        @inbounds for (a, b) in zip(A.refs, B.refs)
            if a == 0 || b == 0
                (S >: Missing || T >: Missing) && (anymissing = true)
            elseif a != b
                return false
            end
        end
    else
        @inbounds for (a, b) in zip(A, B)
            eq = (a == b)
            if eq === false
                return false
            elseif S >: Missing || T >: Missing
                anymissing |= ismissing(eq)
            end
        end
    end
    return anymissing ? missing : true
end

function Base.isequal(A::CategoricalArray, B::CategoricalArray)
    if size(A) != size(B)
        return false
    end
    if A.pool === B.pool
        @inbounds for (a, b) in zip(A.refs, B.refs)
            if a != b
                return false
            end
        end
    else
        @inbounds for (a, b) in zip(A, B)
            if !isequal(a, b)
                return false
            end
        end
    end
    return true
end

size(A::CategoricalArray) = size(A.refs)
Base.IndexStyle(::Type{<:CategoricalArray}) = IndexLinear()

@inline function setindex!(A::CategoricalArray, v::Any, I::Real...)
    @boundscheck checkbounds(A, I...)
    @inbounds A.refs[I...] = get!(A.pool, v)
end

Base.fill!(A::CategoricalArray, v::Any) =
    (fill!(A.refs, get!(A.pool, convert(leveltype(A), v))); A)

function mergelevels(ordered, levels...)
    T = Base.promote_eltype(levels...)
    res = Vector{T}(undef, 0)

    nonempty_lv = Compat.findfirst(!isempty, levels)
    if nonempty_lv === nothing
        # no levels
        return res, ordered
    elseif all(l -> isempty(l) || l == levels[nonempty_lv], levels)
        # Fast path if all non-empty levels are equal
        append!(res, levels[nonempty_lv])
        return res, ordered
    end

    for l in levels
        levelsmap = indexin(l, res)

        i = length(res)+1
        for j = length(l):-1:1
            @static if VERSION >= v"0.7.0-DEV.3627"
                if levelsmap[j] === nothing
                    insert!(res, i, l[j])
                else
                    i = levelsmap[j]
                end
            else
                if levelsmap[j] == 0
                    insert!(res, i, l[j])
                else
                    i = levelsmap[j]
                end
            end
        end
    end

    # Check that result is ordered
    if ordered
        levelsmaps = [Compat.indexin(res, l) for l in levels]

        # Check that each original order is preserved
        for m in levelsmaps
            issorted(Iterators.filter(x -> x != nothing, m)) || return res, false
        end

        # Check that all order relations between pairs of subsequent elements
        # are defined in at least one set of original levels
        pairs = fill(false, length(res)-1)
        for m in levelsmaps
            @inbounds for i in eachindex(pairs)
                pairs[i] |= (m[i] != nothing) & (m[i+1] != nothing)
            end
            all(pairs) && return res, true
        end
    end

    res, false
end

# Methods preserving levels and more efficient than AbstractArray fallbacks
copy(A::CategoricalArray) = deepcopy(A)

CatArrOrSub{T, N} = Union{CategoricalArray{T, N},
                          SubArray{<:Any, N, <:CategoricalArray{T}}} where {T, N}

function copyto!(dest::CatArrOrSub{T, N}, dstart::Integer,
                 src::CatArrOrSub{<:Any, N}, sstart::Integer,
                 n::Integer) where {T, N}
    n == 0 && return dest
    n < 0 && throw(ArgumentError(string("tried to copy n=", n, " elements, but n should be nonnegative")))
    destinds, srcinds = LinearIndices(dest), LinearIndices(src)
    (dstart ∈ destinds && dstart+n-1 ∈ destinds) || throw(BoundsError(dest, dstart:dstart+n-1))
    (sstart ∈ srcinds  && sstart+n-1 ∈ srcinds)  || throw(BoundsError(src,  sstart:sstart+n-1))

    drefs = refs(dest)
    srefs = refs(src)
    dpool = pool(dest)
    spool = pool(src)

    # try converting src to dest type to avoid partial copy corruption of dest
    # in the event that the src cannot be copied into dest
    slevs = convert(Vector{T}, levels(src))
    if eltype(src) >: Missing && !(eltype(dest) >: Missing) && !all(x -> x > 0, srefs)
        throw(MissingException("cannot copy array with missing values to an array with element type $T"))
    end

    newlevels, ordered = mergelevels(isordered(dest), levels(dest), slevs)
    # Orderedness cannot be preserved if the source was unordered and new levels
    # need to be added: new comparisons would only be based on the source's order
    # (this is consistent with what happens when adding a new level via setindex!)
    ordered &= isordered(src) | (length(newlevels) == length(levels(dest)))
    if ordered != isordered(dest)
        isa(dest, SubArray) && throw(ArgumentError("cannot set ordered=$ordered on dest SubArray as it would affect the parent. Found when trying to set levels to $newlevels."))
        ordered!(dest, ordered)
    end

    # Simple case: replace all values
    if !isa(dest, SubArray) && dstart == dstart == 1 && n == length(dest) == length(src)
        # Set index to reflect refs
        levels!(dpool, T[]) # Needed in case src and dest share some levels
        levels!(dpool, index(spool))

        # Set final levels in their visible order
        levels!(dpool, newlevels)

        copyto!(drefs, srefs)
    else # More work to do: preserve some values (and therefore index)
        levels!(dpool, newlevels)

        indexmap = indexin(index(spool), index(dpool))

        @inbounds for i = 0:(n-1)
            x = srefs[sstart+i]
            drefs[dstart+i] = x > 0 ? indexmap[x] : 0
        end

    end

    dest
end

copyto!(dest::CatArrOrSub, src::CatArrOrSub) =
    copyto!(dest, 1, src, 1, length(src))

copyto!(dest::CatArrOrSub, dstart::Integer, src::CatArrOrSub) =
    copyto!(dest, dstart, src, 1, length(src))

@static if VERSION >= v"0.7.0-DEV.3208"
    using Future
    Future.copy!(dest::CatArrOrSub, src::CatArrOrSub) =
        copyto!(dest, 1, src, 1, length(src))
end

similar(A::CategoricalArray{S, M, R}, ::Type{T},
        dims::NTuple{N, Int}) where {T, N, S, M, R} =
    Array{T, N}(undef, dims)
similar(A::CategoricalArray{S, M, R}, ::Type{Missing},
        dims::NTuple{N, Int}) where {N, S, M, R} =
    Array{Missing, N}(missing, dims)
similar(A::CategoricalArray{S, M, Q}, ::Type{T},
        dims::NTuple{N, Int}) where {R, T<:CatValue{R}, N, S, M, Q} =
    CategoricalArray{T, N, R}(undef, dims)
similar(A::CategoricalArray{S, M, R}, ::Type{T},
        dims::NTuple{N, Int}) where {S, T<:CatValue, M, N, R} =
    CategoricalArray{T, N, R}(undef, dims)
# Union{T, Missing} is repeated even if theoretically redundant because of JuliaLang/julia#26405
# Once that bug is fixed, Union{T, Missing} can be replaced with T and the two definitions above can be removed
similar(A::CategoricalArray{S, M, Q}, ::Type{T},
        dims::NTuple{N, Int}) where {R, T<:Union{CatValue{R}, Missing}, N, S, M, Q} =
    CategoricalArray{Union{T, Missing}, N, R}(undef, dims)
similar(A::CategoricalArray{S, M, R}, ::Type{T},
        dims::NTuple{N, Int}) where {S, T<:Union{CatValue, Missing}, M, N, R} =
    CategoricalArray{Union{T, Missing}, N, R}(undef, dims)

"""
    compress(A::CategoricalArray)

Return a copy of categorical array `A` using the smallest reference type able to hold the
number of [`levels`](@ref) of `A`.

While this will reduce memory use, this function is type-unstable, which can affect
performance inside the function where the call is made. Therefore, use it with caution.
"""
function compress(A::CategoricalArray{T, N}) where {T, N}
    R = reftype(length(index(A.pool)))
    convert(CategoricalArray{T, N, R}, A)
end

"""
    decompress(A::CategoricalArray)

Return a copy of categorical array `A` using the default reference type ($DefaultRefType).
If `A` is using a small reference type (such as `UInt8` or `UInt16`) the decompressed array
will have room for more levels.

To avoid the need to call decompress, ensure [`compress`](@ref) is not called when creating
the categorical array.
"""
decompress(A::CategoricalArray{T, N}) where {T, N} =
    convert(CategoricalArray{T, N, DefaultRefType}, A)

function vcat(A::CategoricalArray...)
    ordered = any(isordered, A) && all(a->isordered(a) || isempty(levels(a)), A)
    newlevels, ordered = mergelevels(ordered, map(levels, A)...)

    refsvec = map(A) do a
        ii = convert(Vector{Int}, indexin(index(a.pool), newlevels))
        [x==0 ? 0 : ii[x] for x in a.refs]::Array{Int,ndims(a)}
    end

    T = Base.promote_eltype(A...) >: Missing ?
        Union{eltype(newlevels), Missing} : eltype(newlevels)
    refs = DefaultRefType[refsvec...;]
    pool = CategoricalPool(newlevels, ordered)
    CategoricalArray{T, ndims(refs)}(refs, pool)
end

@inline function getindex(A::CategoricalArray{T}, I...) where {T}
    @boundscheck checkbounds(A, I...)
    # Let Array indexing code handle everything
    @inbounds r = A.refs[I...]

    if isa(r, Array)
        res = CategoricalArray{T, ndims(r)}(r, deepcopy(A.pool))
        return ordered!(res, isordered(A))
    else
        r > 0 || throw(UndefRefError())
        @inbounds res = A.pool[r]
        return res
    end
end

catvaluetype(::Type{T}) where {T <: CategoricalArray} = Missings.T(eltype(T))
catvaluetype(A::CategoricalArray) = catvaluetype(typeof(A))

leveltype(::Type{T}) where {T <: CategoricalArray} = leveltype(catvaluetype(T))

"""
    levels(A::CategoricalArray)

Return the levels of categorical array `A`. This may include levels which do not actually appear
in the data (see [`droplevels!`](@ref)).
"""
Missings.levels(A::CategoricalArray) = levels(A.pool)

"""
    levels!(A::CategoricalArray, newlevels::Vector; allow_missing::Bool=false)

Set the levels categorical array `A`. The order of appearance of levels will be respected
by [`levels`](@ref), which may affect display of results in some operations; if `A` is
ordered (see [`isordered`](@ref)), it will also be used for order comparisons
using `<`, `>` and similar operators. Reordering levels will never affect the values
of entries in the array.

If `A` accepts missing values (i.e. `eltype(A) >: Missing`) and `allow_missing=true`,
entries corresponding to omitted levels will be set to `missing`.
Else, `newlevels` must include all levels which appear in the data.
"""
function levels!(A::CategoricalArray{T}, newlevels::Vector; allow_missing=false) where {T}
    if !allunique(newlevels)
        throw(ArgumentError(string("duplicated levels found: ",
                                   join(unique(filter(x->sum(newlevels.==x)>1, newlevels)), ", "))))
    end

    # first pass to check whether, if some levels are removed, changes can be applied without error
    # TODO: save original levels and undo changes in case of error to skip this step
    # equivalent to issubset but faster due to JuliaLang/julia#24624
    if !isempty(setdiff(index(A.pool), newlevels))
        deleted = [!(l in newlevels) for l in index(A.pool)]
        @inbounds for (i, x) in enumerate(A.refs)
            if T >: Missing
                !allow_missing && x > 0 && deleted[x] &&
                    throw(ArgumentError("cannot remove level $(repr(index(A.pool)[x])) as it is used at position $i and allow_missing=false."))
            else
                deleted[x] &&
                    throw(ArgumentError("cannot remove level $(repr(index(A.pool)[x])) as it is used at position $i. " *
                                        "Change the array element type to Union{$T, Missing} using convert if you want to transform some levels to missing values."))
            end
        end
    end

    # actually apply changes
    oldindex = copy(index(A.pool))
    levels!(A.pool, newlevels)

    if index(A.pool) != oldindex
        levelsmap = similar(A.refs, length(oldindex)+1)
        # 0 maps to a missing value
        levelsmap[1] = 0
        levelsmap[2:end] .= something.(indexin(oldindex, index(A.pool)), 0)

        @inbounds for (i, x) in enumerate(A.refs)
            A.refs[i] = levelsmap[x+1]
        end
    end

    A
end

function _unique(::Type{S},
                 refs::AbstractArray{T},
                 pool::CategoricalPool) where {S, T<:Integer}
    nlevels = length(index(pool)) + 1
    order = fill(0, nlevels) # 0 indicates not seen
    # If we don't track missings, short-circuit even if none has been seen
    count = S >: Missing ? 0 : 1
    @inbounds for i in refs
        if order[i + 1] == 0
            count += 1
            order[i + 1] = count
            count == nlevels && break
        end
    end
    S[i == 1 ? missing : index(pool)[i - 1] for i in sortperm(order) if order[i] != 0]
end

"""
    unique(A::CategoricalArray)

Return levels which appear in `A` in their order of appearance.
This function is significantly slower than [`levels`](@ref)
since it needs to check whether levels are used or not.
"""
unique(A::CategoricalArray{T}) where {T} = _unique(T, A.refs, A.pool)

if VERSION >= v"0.7.0-DEV.4882"
    """
        droplevels!(A::CategoricalArray)

    Drop levels which do not appear in categorical array `A` (so that they will no longer be
    returned by [`levels`](@ref)).
    """
    droplevels!(A::CategoricalArray) = levels!(A, intersect!(levels(A), unique(A)))
else # intersect! method missing on Julia 0.6
    """
        droplevels!(A::CategoricalArray)

    Drop levels which do not appear in categorical array `A` (so that they will no longer be
    returned by [`levels`](@ref)).
    """
    droplevels!(A::CategoricalArray) = levels!(A, intersect(levels(A), filter!(!ismissing, unique(A))))
end

"""
    isordered(A::CategoricalArray)

Test whether entries in `A` can be compared using `<`, `>` and similar operators,
using the ordering of levels.
"""
isordered(A::CategoricalArray) = isordered(A.pool)

"""
    ordered!(A::CategoricalArray, ordered::Bool)

Set whether entries in `A` can be compared using `<`, `>` and similar operators,
using the ordering of levels. Return the modified `A`.
"""
ordered!(A::CategoricalArray, ordered) = (ordered!(A.pool, ordered); return A)

function Base.resize!(A::CategoricalVector, n::Integer)
    n_orig = length(A)
    resize!(A.refs, n)
    if n > n_orig
        A.refs[n_orig+1:end] .= 0
    end
    A
end

function Base.push!(A::CategoricalVector, item)
    r = get!(A.pool, item)
    push!(A.refs, r)
    A
end

function Base.append!(A::CategoricalVector, B::CatArrOrSub)
    levels!(A, union(levels(A), levels(B)))
    len = length(A)
    len2 = length(B)
    resize!(A.refs, len + len2)
    for i = 1:len2
        A[len + i] = B[i]
    end
    return A
end

Base.empty!(A::CategoricalArray) = (empty!(A.refs); return A)

function Base.reshape(A::CategoricalArray{T, N}, dims::Dims) where {T, N}
    x = reshape(A.refs, dims)
    res = CategoricalArray{T, ndims(x)}(x, A.pool)
    ordered!(res, isordered(res))
end

"""
    categorical{T}(A::AbstractArray{T}[, compress::Bool]; ordered::Bool=false)

Construct a categorical array with the values from `A`.

If the element type supports it, levels are sorted in ascending order;
else, they are kept in their order of appearance in `A`. The `ordered` keyword
argument determines whether the array values can be compared according to the
ordering of levels or not (see [`isordered`](@ref)).

If `compress` is provided and set to `true`, the smallest reference type able to hold the
number of unique values in `A` will be used. While this will reduce memory use, passing
this parameter will also introduce a type instability which can affect performance inside
the function where the call is made. Therefore, use this option with caution (the
one-argument version does not suffer from this problem).

    categorical{T}(A::CategoricalArray{T}[, compress::Bool]; ordered::Bool=isordered(A))

If `A` is already a `CategoricalArray`, its levels are preserved;
the same applies to the ordered property, and to the reference type
unless `compress` is passed.
"""
function categorical end

categorical(A::AbstractArray; ordered=_isordered(A)) = CategoricalArray(A, ordered=ordered)

# Type-unstable methods
function categorical(A::AbstractArray{T, N}, compress; ordered=_isordered(A)) where {T, N}
    RefType = compress ? reftype(length(unique(A))) : DefaultRefType
    CategoricalArray{T, N, RefType}(A, ordered=ordered)
end
function categorical(A::CategoricalArray{T, N, R}, compress; ordered=_isordered(A)) where {T, N, R}
    RefType = compress ? reftype(length(levels(A))) : R
    CategoricalArray{T, N, RefType}(A, ordered=ordered)
end

function in(x::Any, y::CategoricalArray{T, N, R}) where {T, N, R}
    ref = get(y.pool, x, zero(R))
    ref != 0 ? ref in y.refs : false
end

function in(x::CategoricalValue, y::CategoricalArray{T, N, R}) where {T, N, R}
    if x.pool === y.pool
        return x.level in y.refs
    else
        ref = get(y.pool, index(x.pool)[x.level], zero(R))
        return ref != 0 ? ref in y.refs : false
    end
end

Array(A::CategoricalArray{T}) where {T} = Array{T}(A)
collect(A::CategoricalArray{T}) where {T} = Array{T}(A)

function float(A::CategoricalArray{T}) where T
    if !isconcretetype(T)
        error("`float` not defined on abstractly-typed arrays; please convert to a more specific type")
    end
    convert(AbstractArray{typeof(float(zero(T)))}, A)
end
function complex(A::CategoricalArray{T}) where T
    if !isconcretetype(T)
        error("`complex` not defined on abstractly-typed arrays; please convert to a more specific type")
    end
    convert(AbstractArray{typeof(complex(zero(T)))}, A)
end

# Override AbstractArray method to avoid printing useless type parameters
if VERSION >= v"0.7.0-DEV.2657"
    summary(io::IO, A::CategoricalArray{T, N, R}) where {T, N, R} =
        print(io, Base.dims2string(size(A)), " $CategoricalArray{$T,$N,$R}")
else
    summary(A::CategoricalArray{T, N, R}) where {T, N, R} =
        string(Base.dims2string(size(A)), " $CategoricalArray{$T,$N,$R}")
end

refs(A::CategoricalArray) = A.refs
pool(A::CategoricalArray) = A.pool
