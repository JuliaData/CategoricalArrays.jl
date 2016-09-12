function CategoricalPool{S, T <: Integer, R <: Integer}(index::Vector{S},
                                           invindex::Dict{S, T},
                                           order::Vector{R},
                                           isordered::Bool=false)
    invindex = convert(Dict{S, R}, invindex)
    CategoricalPool{S, R, CategoricalValue{S, R, isordered}, isordered}(index, invindex, order)
end

@compat (::Type{CategoricalPool{T, R, O}}){T, R, O}() = CategoricalPool(T[], Dict{T, R}(), R[], O)
@compat (::Type{CategoricalPool{T}}){T}() = CategoricalPool(T[], Dict{T, DefaultRefType}(), DefaultRefType[])

@compat function (::Type{CategoricalPool{T, R}}){T, R}(index::Vector, isordered::Bool=false)
    invindex = buildinvindex(index, R)
    order = Vector{R}(1:length(index))
    CategoricalPool(index, invindex, order, isordered)
end

function CategoricalPool(index::Vector, isordered::Bool=false)
    invindex = buildinvindex(index)
    order = Vector{DefaultRefType}(1:length(index))
    return CategoricalPool(index, invindex, order, isordered)
end

function CategoricalPool{S, R <: Integer}(invindex::Dict{S, R}, isordered::Bool=false)
    index = buildindex(invindex)
    order = Vector{DefaultRefType}(1:length(index))
    return CategoricalPool(index, invindex, order, isordered)
end

# TODO: Add tests for this
function CategoricalPool{S, R <: Integer}(index::Vector{S}, invindex::Dict{S, R}, isordered::Bool=false)
    order = Vector{DefaultRefType}(1:length(index))
    return CategoricalPool(index, invindex, order, isordered)
end

function CategoricalPool{T}(index::Vector{T}, ordered::Vector{T}, isordered::Bool=false)
    invindex = buildinvindex(index)
    order = buildorder(invindex, ordered)
    return CategoricalPool(index, invindex, order, isordered)
end

function CategoricalPool{S, R <: Integer}(invindex::Dict{S, R}, ordered::Vector{S}, isordered::Bool=false)
    index = buildindex(invindex)
    order = buildorder(invindex, ordered)
    return CategoricalPool(index, invindex, order, isordered)
end

Base.convert(::Type{CategoricalPool}, pool::CategoricalPool) = pool
Base.convert{T}(::Type{CategoricalPool{T}}, pool::CategoricalPool{T}) = pool
Base.convert{T, R}(::Type{CategoricalPool{T, R}}, pool::CategoricalPool{T, R}) = pool
Base.convert{T, R, O}(::Type{CategoricalPool{T, R, O}}, pool::CategoricalPool{T, R, O}) = pool

function Base.convert{S, R}(::Type{CategoricalPool{S, R}}, pool::CategoricalPool)
    indexS = convert(Vector{S}, pool.index)
    invindexS = convert(Dict{S, R}, pool.invindex)
    order = convert(Vector{R}, pool.order)
    return CategoricalPool(indexS, invindexS, order)
end

Base.convert{S, T, R}(::Type{CategoricalPool{S}}, pool::CategoricalPool{T, R}) = convert(CategoricalPool{S, R}, pool)
Base.convert{T, R}(::Type{CategoricalPool}, pool::CategoricalPool{T, R}) = convert(CategoricalPool{T, R}, pool)

function Base.show{T, R, O}(io::IO, pool::CategoricalPool{T, R, O})
    @printf(io, "%s{%s,%s,%s}([%s])", typeof(pool).name, T, R, O,
            join(map(repr, levels(pool)), ","))
end

Base.length(pool::CategoricalPool) = length(pool.index)

Base.getindex(pool::CategoricalPool, i::Integer) = pool.valindex[i]
Base.get(pool::CategoricalPool, level::Any) = pool.invindex[level]

levels(pool::CategoricalPool) = pool.ordered

function Base.get!{T, R, V}(pool::CategoricalPool{T, R, V}, level)
    get!(pool.invindex, level) do
        i = length(pool) + 1
        push!(pool.index, level)
        push!(pool.order, i)
        push!(pool.ordered, level)
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
            splice!(pool.ordered, ord)
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
    if !allunique(newlevels)
        throw(ArgumentError(string("duplicated levels found in newlevels: ",
                                   join(unique(filter(x->sum(newlevels.==x)>1, newlevels)), ", "))))
    end

    n = length(newlevels)

    # No deletions: can preserve position of existing levels
    if issubset(pool.index, newlevels)
        append!(pool, setdiff(newlevels, pool.index))
    else
        empty!(pool.invindex)
        resize!(pool.index, n)
        resize!(pool.valindex, n)
        resize!(pool.order, n)
        resize!(pool.ordered, n)
        for i in 1:n
            v = newlevels[i]
            pool.index[i] = v
            pool.invindex[v] = i
            pool.valindex[i] = V(i, pool)
        end
    end

    buildorder!(pool.order, pool.invindex, newlevels)
    for (i, x) in enumerate(pool.order)
        pool.ordered[x] = pool.index[i]
    end
    return newlevels
end

order(pool::CategoricalPool) = pool.order
index(pool::CategoricalPool) = pool.index
