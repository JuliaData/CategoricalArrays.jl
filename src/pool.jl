CategoricalPool{T, R, V}(ordered::Bool=false) where {T, R, V} =
    CategoricalPool{T, R, V}(T[], ordered)
CategoricalPool{T, R}(ordered::Bool=false) where {T, R} =
    CategoricalPool{T, R}(T[], ordered)
CategoricalPool{T}(ordered::Bool=false) where {T} =
    CategoricalPool{T, DefaultRefType}(T[], ordered)

CategoricalPool{T, R}(levels::Vector, ordered::Bool=false) where {T, R} =
    CategoricalPool{T, R, CategoricalValue{T, R}}(convert(Vector{T}, levels), ordered)
CategoricalPool(levels::Vector{T}, ordered::Bool=false) where {T} =
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
    CategoricalPool{T, R, V}(copy(pool.levels), copy(pool.invindex), pool.ordered)

function Base.show(io::IO, pool::CategoricalPool{T, R}) where {T, R}
    @printf(io, "%s{%s,%s}([%s])", typeof(pool).name, T, R,
            join(map(repr, levels(pool)), ", "))

    pool.ordered && print(io, " with ordered levels")
end

Base.length(pool::CategoricalPool) = length(pool.levels)

Base.getindex(pool::CategoricalPool, i::Integer) = pool.valindex[i]
Base.get(pool::CategoricalPool, level::Any) = pool.invindex[level]
Base.get(pool::CategoricalPool, level::Any, default::Any) = get(pool.invindex, level, default)

"""
add the returned value to pool.invindex, this function doesn't do this itself to
avoid doing a dict lookup twice
"""
@inline function push_level!(pool::CategoricalPool{T, R}, level) where {T, R}
    x = convert(T, level)
    n = length(pool)
    if n >= typemax(R)
        throw(LevelsException{T, R}([level]))
    end

    i = R(n + 1)
    push!(pool.levels, x)
    push!(pool.valindex, CategoricalValue(i, pool))
    i
end

function mergelevels(ordered, levels...)
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
        if isordered(pool)
            throw(OrderedLevelsException(level, pool.levels))
        end

        push_level!(pool, level)
    end
end

@inline function Base.get!(pool::CategoricalPool, level::CategoricalValue)
    pool === level.pool && return level.level
    # TODO: use a global table to cache subset relations for all pairs of pools
    if level.pool ⊈ pool
        if isordered(pool)
            throw(OrderedLevelsException(level, pool.levels))
        end
        newlevs, ordered = mergelevels(isordered(pool), pool.levels, level.pool.levels)
        # Exception: empty pool marked as ordered if new value is ordered
        if length(pool) == 0 && isordered(level.pool)
            ordered!(pool, true)
        end
        levels!(pool, newlevs)
    end
    get!(pool, get(level))
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
        nl, ordered = mergelevels(isordered(a), a.levels, b.levels)
        newlevs = convert(Vector{T}, nl)
    end
    newlevs, ordered
end

Base.issubset(a::CategoricalPool, b::CategoricalPool) = issubset(a.levels, keys(b.invindex))

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
    resize!(pool.valindex, n)
    for i in 1:n
        v = levs[i]
        pool.levels[i] = v
        pool.invindex[v] = i
        pool.valindex[i] = CategoricalValue(i, pool)
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


# OrderedLevelsException
function Base.showerror(io::IO, err::OrderedLevelsException)
    print(io, "cannot add new level $(err.newlevel) since ordered pools cannot be extended implicitly. Use the levels! function to set new levels, or the ordered! function to mark the pool as unordered.")
end
