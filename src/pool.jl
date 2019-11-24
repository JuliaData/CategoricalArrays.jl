function CategoricalPool{T, R, V}(index::Vector{T},
                                  invindex::Dict{T, R},
                                  order::Vector{R},
                                  ordered::Bool) where {T, R, V}
    levels = similar(index)
    levels[order] = index
    pool = CategoricalPool{T, R, V}(index, invindex, order, levels, V[], ordered)
    buildvalues!(pool)
    return pool
end

function CategoricalPool(index::Vector{S},
                         invindex::Dict{S, T},
                         order::Vector{R},
                         ordered::Bool=false) where {S, T <: Integer, R <: Integer}
    invindex = convert(Dict{S, R}, invindex)
    V = CategoricalValue{S, R}
    CategoricalPool{S, R, V}(index, invindex, order, ordered)
end

CategoricalPool{T, R, V}(ordered::Bool=false) where {T, R, V} =
    CategoricalPool{T, R, V}(T[], Dict{T, R}(), R[], ordered)
CategoricalPool{T, R}(ordered::Bool=false) where {T, R} =
    CategoricalPool(T[], Dict{T, R}(), R[], ordered)
CategoricalPool{T}(ordered::Bool=false) where {T} =
    CategoricalPool{T, DefaultRefType}(ordered)

function CategoricalPool{T, R}(index::Vector,
                               ordered::Bool=false) where {T, R}
    invindex = buildinvindex(index, R)
    order = Vector{R}(1:length(index))
    CategoricalPool(index, invindex, order, ordered)
end

function CategoricalPool(index::Vector, ordered::Bool=false)
    invindex = buildinvindex(index)
    order = Vector{DefaultRefType}(1:length(index))
    return CategoricalPool(index, invindex, order, ordered)
end

function CategoricalPool(invindex::Dict{S, R},
                         ordered::Bool=false) where {S, R <: Integer}
    index = buildindex(invindex)
    order = Vector{DefaultRefType}(1:length(index))
    return CategoricalPool(index, invindex, order, ordered)
end

# TODO: Add tests for this
function CategoricalPool(index::Vector{S},
                         invindex::Dict{S, R},
                         ordered::Bool=false) where {S, R <: Integer}
    order = Vector{DefaultRefType}(1:length(index))
    return CategoricalPool(index, invindex, order, ordered)
end

function CategoricalPool(index::Vector{T},
                         levels::Vector{T},
                         ordered::Bool=false) where {T}
    invindex = buildinvindex(index)
    order = buildorder(invindex, levels)
    return CategoricalPool(index, invindex, order, ordered)
end

function CategoricalPool(invindex::Dict{S, R},
                         levels::Vector{S},
                         ordered::Bool=false) where {S, R <: Integer}
    index = buildindex(invindex)
    order = buildorder(invindex, levels)
    return CategoricalPool(index, invindex, order, ordered)
end

Base.convert(::Type{T}, pool::T) where {T <: CategoricalPool} = pool

Base.convert(::Type{CategoricalPool{S}}, pool::CategoricalPool{T, R}) where {S, T, R <: Integer} =
    convert(CategoricalPool{S, R}, pool)

function Base.convert(::Type{CategoricalPool{S, R}}, pool::CategoricalPool) where {S, R <: Integer}
    if length(levels(pool)) > typemax(R)
        throw(LevelsException{S, R}(levels(pool)[typemax(R)+1:end]))
    end

    indexS = convert(Vector{S}, pool.index)
    invindexS = convert(Dict{S, R}, pool.invindex)
    order = convert(Vector{R}, pool.order)
    return CategoricalPool(indexS, invindexS, order, pool.ordered)
end

function Base.copy(pool::CategoricalPool{T, R, V}) where {T, R, V}
    newpool = CategoricalPool{T, R, V}(copy(pool.index), copy(pool.invindex), copy(pool.order),
                                       copy(pool.levels), similar(pool.valindex), pool.ordered)
    buildvalues!(newpool) # With a plain copy values would refer to the old pool
    newpool
end

function Base.show(io::IO, pool::CategoricalPool{T, R}) where {T, R}
    @printf(io, "%s{%s,%s}([%s])", typeof(pool).name, T, R,
                join(map(repr, levels(pool)), ","))

    pool.ordered && print(io, " with ordered levels")
end

Base.length(pool::CategoricalPool) = length(pool.index)

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
    push!(pool.index, x)
    push!(pool.order, i)
    push!(pool.levels, x)
    push!(pool.valindex, CategoricalValue(i, pool))
    i
end

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
    # Use invindex for O(1) lookup
    # TODO: use a global table to cache this information for all pairs of pools
    if level.pool.levels ⊈ keys(pool.invindex)
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

function Base.delete!(pool::CategoricalPool{S}, levels...) where S
    for level in levels
        levelS = convert(S, level)
        if haskey(pool.invindex, levelS)
            ind = pool.invindex[levelS]
            delete!(pool.invindex, levelS)
            splice!(pool.index, ind)
            ord = splice!(pool.order, ind)
            splice!(pool.levels, ord)
            splice!(pool.valindex, ind)
            for i in ind:length(pool)
                pool.invindex[pool.index[i]] -= 1
                pool.valindex[i] = CategoricalValue(i, pool)
            end
            for i in 1:length(pool)
                pool.order[i] > ord && (pool.order[i] -= 1)
            end
        end
    end
    return pool
end

function levels!(pool::CategoricalPool{S, R}, newlevels::Vector) where {S, R}
    levs = convert(Vector{S}, newlevels)
    if !allunique(levs)
        throw(ArgumentError(string("duplicated levels found in levs: ",
                                   join(unique(filter(x->sum(levs.==x)>1, levs)), ", "))))
    end

    n = length(levs)

    if n > typemax(R)
        throw(LevelsException{S, R}(setdiff(levs, levels(pool))[typemax(R)-length(levels(pool))+1:end]))
    end

    # No deletions: can preserve position of existing levels
    # equivalent to issubset but faster due to JuliaLang/julia#24624
    if isempty(setdiff(pool.index, levs))
        append!(pool, setdiff(levs, pool.index))
    else
        empty!(pool.invindex)
        resize!(pool.index, n)
        resize!(pool.valindex, n)
        resize!(pool.order, n)
        resize!(pool.levels, n)
        for i in 1:n
            v = levs[i]
            pool.index[i] = v
            pool.invindex[v] = i
            pool.valindex[i] = CategoricalValue(i, pool)
        end
    end

    buildorder!(pool.order, pool.invindex, levs)
    for (i, x) in enumerate(pool.order)
        pool.levels[x] = pool.index[i]
    end
    return pool
end

index(pool::CategoricalPool) = pool.index
DataAPI.levels(pool::CategoricalPool) = pool.levels
order(pool::CategoricalPool) = pool.order

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
