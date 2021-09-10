const catpool_seed = UInt === UInt32 ? 0xe3cf1386 : 0x356f2c715023f1a5

hashlevels(levs::AbstractVector) = foldl((h, x) -> hash(x, h), levs, init=catpool_seed)

CategoricalPool{T, R, V}(ordered::Bool=false) where {T, R, V} =
    CategoricalPool{T, R, V}(T[], ordered)
CategoricalPool{T, R}(ordered::Bool=false) where {T, R} =
    CategoricalPool{T, R}(T[], ordered)
CategoricalPool{T}(ordered::Bool=false) where {T} =
    CategoricalPool{T, DefaultRefType}(T[], ordered)

CategoricalPool{T, R}(levels::AbstractVector, ordered::Bool=false) where {T, R} =
    CategoricalPool{T, R, CategoricalValue{T, R}}(convert(Vector{T}, levels), ordered)
CategoricalPool(levels::AbstractVector{T}, ordered::Bool=false) where {T} =
    CategoricalPool{T, DefaultRefType}(convert(Vector{T}, levels), ordered)

CategoricalPool(invindex::Dict{T, R}, ordered::Bool=false) where {T, R <: Integer} =
    CategoricalPool{T, R, CategoricalValue{T, R}}(invindex, ordered)

Base.convert(::Type{T}, pool::T) where {T <: CategoricalPool} = pool

Base.convert(::Type{CategoricalPool{S}}, pool::CategoricalPool{T, R}) where {S, T, R <: Integer} =
    convert(CategoricalPool{S, R}, pool)

function Base.convert(::Type{CategoricalPool{T, R}}, pool::CategoricalPool) where {T, R <: Integer}
    if length(levels(pool)) > typemax(R)
        throw(LevelsException{T, R}(levels(pool)[typemax(R)+1:end]))
    end

    levelsT = convert(Vector{T}, pool.levels)
    invindexT = convert(Dict{T, R}, pool.invindex)
    return CategoricalPool{T, R, CategoricalValue{T, R}}(levelsT, invindexT, pool.ordered)
end

Base.copy(pool::CategoricalPool{T, R, V}) where {T, R, V} =
    CategoricalPool{T, R, V}(copy(pool.levels), copy(pool.invindex),
                             pool.ordered, pool.hash)

function Base.show(io::IO, pool::CategoricalPool{T, R}) where {T, R}
    @static if VERSION >= v"1.6.0"
        @printf(io, "%s{%s, %s}([%s])", CategoricalPool, T, R,
                join(map(repr, levels(pool)), ", "))
    else
        @printf(io, "%s{%s,%s}([%s])", CategoricalPool, T, R,
                join(map(repr, levels(pool)), ", "))
    end

    pool.ordered && print(io, " with ordered levels")
end

Base.length(pool::CategoricalPool) = length(pool.levels)

Base.getindex(pool::CategoricalPool, i::Integer) = CategoricalValue(pool, i)
Base.get(pool::CategoricalPool, level::Any) = pool.invindex[level]
Base.get(pool::CategoricalPool, level::Any, default::Any) = get(pool.invindex, level, default)

"""
after calling this method, add the returned value to pool.invindex:
it doesn't do this itself to avoid doing a dict lookup twice
"""
@inline function push_level!(pool::CategoricalPool{T, R}, level) where {T, R}
    x = convert(T, level)
    n = length(pool)
    if n >= typemax(R)
        throw(LevelsException{T, R}([level]))
    end

    i = R(n + 1)
    push!(pool.levels, x)
    if pool.hash !== nothing
        pool.hash = hash(x, pool.hash)
    end
    pool.equalto = C_NULL
    pool.subsetof = C_NULL
    i
end

"""
    mergelevels(ordered::Bool, levels::AbstractVector...) -> (vec::Vector, ordered′::Bool)

Merge vectors of values `levels` and return:
- `vec`: a superset of all values in `levels`, respecting orders of values
  in each vector of levels if possible
- `ordered′`: if `ordered=true`, whether order comparisons between all pairs
  of levels in `vec` have a defined result based on orders of values in input `levels`
"""
function mergelevels(ordered::Bool, levels::AbstractVector...)
    T = cat_promote_eltype(levels...)
    res = Vector{T}(undef, 0)

    nonempty_lv = findfirst(!isempty, levels)
    if nonempty_lv === nothing
        # no levels
        return res, ordered
    elseif all(l -> isempty(l) || l == levels[nonempty_lv], levels)
        # Fast path if all non-empty levels are equal
        append!(res, levels[nonempty_lv])
        return res, ordered
    end

    union!(res, levels...)

    # Ensure that relative orders of levels are preserved if possible,
    # giving priority to the first sets of levels in case of conflicts
    for levs in reverse(levels)
        levelsmap = indexin(res, levs)

        # Do not touch levels from other sets at the end
        n = length(res)
        @inbounds for i in length(levelsmap):-1:1
            levelsmap[i] === nothing || break
            levelsmap[i] = n
        end
        j = 1
        @inbounds for i in 1:length(levelsmap)
            if levelsmap[i] === nothing
                levelsmap[i] = j
            else
                j = levelsmap[i] + 1
            end
        end
        permute!(res, sortperm(levelsmap, alg=Base.Sort.MergeSort))
    end

    # Check that result is ordered
    if ordered
        levelsmaps = [indexin(res, l) for l in levels]

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

@inline function Base.get!(pool::CategoricalPool, level::Any)
    get!(pool.invindex, level) do
        ordered!(pool, false)
        push_level!(pool, level)
    end
end

@inline function Base.get!(pool::CategoricalPool, level::CategoricalValue)
    if pool === level.pool || pool == level.pool
        return refcode(level)
    end
    if level.pool ⊈ pool
        newlevs, ordered = merge_pools(pool, level.pool)
        levels!(pool, newlevs)
        ordered!(pool, ordered)
    end
    get!(pool, unwrap(level))
end

@inline function Base.push!(pool::CategoricalPool, level)
    get!(pool.invindex, level) do
        push_level!(pool, level)
    end
    return pool
end

# TODO: optimize for multiple additions
function Base.append!(pool::CategoricalPool, levels)
    for level in levels
        push!(pool, level)
    end
    return pool
end

# Do not override Base.merge as for internal use we need to use the type and orderedness
# of the first pool rather than promoting both pools
function merge_pools(a::CategoricalPool{T}, b::CategoricalPool) where {T}
    if length(a) == 0 && length(b) == 0
        newlevs = T[]
        ordered = isordered(a)
    elseif length(a) == 0
        newlevs = Vector{T}(levels(b))
        ordered = isordered(b)
    elseif length(b) == 0
        newlevs = copy(levels(a))
        ordered = isordered(a)
    else
        ordered = isordered(a) && (isordered(b) || b ⊆ a)
        nl, ordered = mergelevels(ordered, a.levels, b.levels)
        newlevs = convert(Vector{T}, nl)
    end
    newlevs, ordered
end

@inline function Base.hash(pool::CategoricalPool, h::UInt)
    if pool.hash === nothing
        pool.hash = hashlevels(levels(pool))
    end
    hash(pool.hash, h)
end

@inline function Base.:(==)(a::CategoricalPool, b::CategoricalPool)
    pa = pointer_from_objref(a)
    pb = pointer_from_objref(b)
    # Checking both ways is needed to detect changes to a or b
    if a === b || (a.equalto == pb && b.equalto == pa)
        return true
    else
        if hash(a) == hash(b) && isequal(a.levels, b.levels)
            a.equalto = pb
            b.equalto = pa
            return true
        else
            return false
        end
    end
end

# Efficient equivalent of issubset(levels(a), levels(b)), i.e. ignoring order
function Base.issubset(a::CategoricalPool, b::CategoricalPool)
    pa = pointer_from_objref(a)
    pb = pointer_from_objref(b)
    # Checking both ways is needed to detect changes to a or b
    if a === b || (a.equalto == pb && b.equalto == pa) || a.subsetof == pb
        return true
    else
        # Equality check is faster than subset check so do it first
        if hash(a) == hash(b) && isequal(a.levels, b.levels)
            a.equalto = pb
            b.equalto = pa
            return true
        elseif issubset(a.levels, keys(b.invindex))
            a.subsetof = pb
            return true
        else
            return false
        end
    end
end

# Contrary to the CategoricalArray one, this method only allows adding new levels at the end
# so that existing CategoricalValue objects still point to the same value
function levels!(pool::CategoricalPool{S, R}, newlevels::Vector;
                 checkunique::Bool=true) where {S, R}
    levs = convert(Vector{S}, newlevels)
    if checkunique && !allunique(levs)
        throw(ArgumentError(string("duplicated levels found in levs: ",
                                   join(unique(filter(x->sum(levs.==x)>1, levs)), ", "))))
    elseif length(levs) < length(pool) || view(levs, 1:length(pool)) != pool.levels
        throw(ArgumentError("removing or reordering levels of existing CategoricalPool is not allowed"))
    end

    n = length(levs)

    if n > typemax(R)
        throw(LevelsException{S, R}(setdiff(levs, levels(pool))[typemax(R)-length(levels(pool))+1:end]))
    end

    empty!(pool.invindex)
    resize!(pool.levels, n)
    pool.hash = nothing
    pool.equalto = C_NULL
    pool.subsetof = C_NULL
    for i in 1:n
        v = levs[i]
        pool.levels[i] = v
        pool.invindex[v] = i
    end

    return pool
end

DataAPI.levels(pool::CategoricalPool) = pool.levels

isordered(pool::CategoricalPool) = pool.ordered
ordered!(pool::CategoricalPool, ordered) = (pool.ordered = ordered; pool)


# LevelsException
function Base.showerror(io::IO, err::LevelsException{T, R}) where {T, R}
    levs = join(repr.(err.levels), ", ", " and ")
    print(io, "cannot store level(s) $levs since reference type $R can only hold $(typemax(R)) levels. Use the decompress function to make room for more levels.")
end
