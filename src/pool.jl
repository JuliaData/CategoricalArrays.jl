function CategoricalPool{S, T <: Integer, R <: Integer}(index::Vector{S},
                                           invindex::Dict{S, T},
                                           order::Vector{R},
                                           ordered::Bool=false)
    invindex = convert(Dict{S, R}, invindex)
    CategoricalPool{S, R, CategoricalValue{S, R}}(index, invindex, order, ordered)
end

@compat (::Type{CategoricalPool{T, R}}){T, R}(ordered::Bool=false) =
    CategoricalPool(T[], Dict{T, R}(), R[], ordered)
@compat (::Type{CategoricalPool{T}}){T}(ordered::Bool=false) =
    CategoricalPool(T[], Dict{T, DefaultRefType}(), DefaultRefType[], ordered)

@compat function (::Type{CategoricalPool{T, R}}){T, R}(index::Vector,
                                                       ordered::Bool=false)
    invindex = buildinvindex(index, R)
    order = Vector{R}(1:length(index))
    CategoricalPool(index, invindex, order, ordered)
end

function CategoricalPool(index::Vector, ordered::Bool=false)
    invindex = buildinvindex(index)
    order = Vector{DefaultRefType}(1:length(index))
    return CategoricalPool(index, invindex, order, ordered)
end

function CategoricalPool{S, R <: Integer}(invindex::Dict{S, R},
                                          ordered::Bool=false)
    index = buildindex(invindex)
    order = Vector{DefaultRefType}(1:length(index))
    return CategoricalPool(index, invindex, order, ordered)
end

# TODO: Add tests for this
function CategoricalPool{S, R <: Integer}(index::Vector{S},
                                          invindex::Dict{S, R},
                                          ordered::Bool=false)
    order = Vector{DefaultRefType}(1:length(index))
    return CategoricalPool(index, invindex, order, ordered)
end

function CategoricalPool{T}(index::Vector{T},
                            levels::Vector{T},
                            ordered::Bool=false)
    invindex = buildinvindex(index)
    order = buildorder(invindex, levels)
    return CategoricalPool(index, invindex, order, ordered)
end

function CategoricalPool{S, R <: Integer}(invindex::Dict{S, R},
                                          levels::Vector{S},
                                          ordered::Bool=false)
    index = buildindex(invindex)
    order = buildorder(invindex, levels)
    return CategoricalPool(index, invindex, order, ordered)
end

Base.convert(::Type{CategoricalPool}, pool::CategoricalPool) = pool
Base.convert{T}(::Type{CategoricalPool{T}}, pool::CategoricalPool{T}) = pool
Base.convert{T, R}(::Type{CategoricalPool{T, R}}, pool::CategoricalPool{T, R}) = pool

Base.convert{S, T, R}(::Type{CategoricalPool{S}}, pool::CategoricalPool{T, R}) =
    convert(CategoricalPool{S, R}, pool)
Base.convert{T, R}(::Type{CategoricalPool}, pool::CategoricalPool{T, R}) =
    convert(CategoricalPool{T, R}, pool)

function Base.convert{S, R}(::Type{CategoricalPool{S, R}}, pool::CategoricalPool)
    if length(levels(pool)) > typemax(R)
        throw(LevelsException{S, R}(levels(pool)[typemax(R)+1:end]))
    end

    indexS = convert(Vector{S}, pool.index)
    invindexS = convert(Dict{S, R}, pool.invindex)
    order = convert(Vector{R}, pool.order)
    return CategoricalPool(indexS, invindexS, order, pool.ordered)
end

function Base.show{T, R}(io::IO, pool::CategoricalPool{T, R})
    @printf(io, "%s{%s,%s}([%s])", typeof(pool).name, T, R,
                join(map(repr, levels(pool)), ","))

    pool.ordered && print(io, " with ordered levels")
end

Base.length(pool::CategoricalPool) = length(pool.index)

Base.getindex(pool::CategoricalPool, i::Integer) = pool.valindex[i]
Base.get(pool::CategoricalPool, level::Any) = pool.invindex[level]
Base.get(pool::CategoricalPool, level::Any, default::Any) = get(pool.invindex, level, default)

function Base.get!{T, R, V}(pool::CategoricalPool{T, R, V}, level)
    get!(pool.invindex, level) do
        x = convert(T, level)
        n = length(pool)
        if n >= typemax(R)
            throw(LevelsException{T, R}([level]))
        end

        i = R(n + 1)
        push!(pool.index, x)
        push!(pool.order, i)
        push!(pool.levels, x)
        push!(pool.valindex, V(i, pool))
        i
    end
end

Base.push!(pool::CategoricalPool, level) = (get!(pool, level); pool)

# TODO: optimize for multiple additions
function Base.append!(pool::CategoricalPool, levels)
    for level in levels
        push!(pool, level)
    end
    return pool
end

function Base.delete!{S, R, V}(pool::CategoricalPool{S, R, V}, levels...)
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
                pool.valindex[i] = V(i, pool)
            end
            for i in 1:length(pool)
                pool.order[i] > ord && (pool.order[i] -= 1)
            end
        end
    end
    return pool
end

function levels!{S, R, V}(pool::CategoricalPool{S, R, V}, newlevels::Vector)
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
    if issubset(pool.index, levs)
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
            pool.valindex[i] = V(i, pool)
        end
    end

    buildorder!(pool.order, pool.invindex, levs)
    for (i, x) in enumerate(pool.order)
        pool.levels[x] = pool.index[i]
    end
    return pool
end

index(pool::CategoricalPool) = pool.index
levels(pool::CategoricalPool) = pool.levels
order(pool::CategoricalPool) = pool.order

isordered(pool::CategoricalPool) = pool.ordered
ordered!(pool::CategoricalPool, ordered) = (pool.ordered = ordered; pool)


# LevelsException
function Base.showerror{T, R}(io::IO, err::LevelsException{T, R})
    levs = join(repr.(err.levels), ", ", " and ")
    print(io, "cannot store level(s) $levs since reference type $R can only hold $(typemax(R)) levels. Use the decompress function to make room for more levels.")
end
