for (P, V) in ((:NominalPool, :NominalValue), (:OrdinalPool, :OrdinalValue))
    @eval begin
        function $P{S, T <: Integer}(index::Vector{S}, invindex::Dict{S, T}, order::Vector{RefType})
            invindex = convert(Dict{S, RefType}, invindex)
            $P{S, $V{S}}(index, invindex, order)
        end

        function $P{T}(index::Vector{T})
            invindex = buildinvindex(index)
            order = buildorder(index)
            return $P(index, invindex, order)
        end

        function $P{S, T <: Integer}(invindex::Dict{S, T})
            invindex = convert(Dict{S, RefType}, invindex)
            index = buildindex(invindex)
            order = buildorder(index)
            return $P(index, invindex, order)
        end

        # TODO: Add tests for this
        function $P{S, T <: Integer}(index::Vector{S}, invindex::Dict{S, T})
            invindex = convert(Dict{S, RefType}, invindex)
            order = buildorder(index)
            return $P(index, invindex, order)
        end

        function $P{T}(index::Vector{T}, ordered::Vector{T})
            invindex = buildinvindex(index)
            order = buildorder(invindex, ordered)
            return $P(index, invindex, order)
        end

        function $P{S, T <: Integer}(invindex::Dict{S, T}, ordered::Vector{S})
            invindex = convert(Dict{S, RefType}, invindex)
            index = buildindex(invindex)
            order = buildorder(invindex, ordered)
            return $P(index, invindex, order)
        end

        # TODO: Add tests for this
        function $P{S, T <: Integer}(index::Vector{S},
                                     invindex::Dict{S, T},
                                     ordered::Vector{S})
            invindex = convert(Dict{S, RefType}, invindex)
            index = buildindex(invindex)
            order = buildorder(invindex, ordered)
            return $P(index, invindex, order)
        end

        function Base.convert{S, T}(::Type{$P{S}}, pool::$P{T})
            indexS = convert(Vector{S}, pool.index)
            invindexS = convert(Dict{S, RefType}, pool.invindex)
            return $P(indexS, invindexS, pool.order)
        end

        Base.convert{T}(::Type{$P}, pool::$P{T}) = pool
        Base.convert{T}(::Type{$P{T}}, pool::$P{T}) = pool
    end
end

function Base.show{T}(io::IO, pool::CategoricalPool{T})
    @printf(io, "%s{%s}([%s])", typeof(pool).name, T,
            join(map(repr, levels(pool)[pool.order]), ","))
end

Base.length(pool::CategoricalPool) = length(pool.index)

Base.getindex(pool::CategoricalPool, i::Integer) = pool.valindex[i]
Base.get(pool::CategoricalPool, level::Any) = pool.invindex[level]

levels(pool::CategoricalPool) = pool.index

function Base.get!{T, V}(f, pool::CategoricalPool{T, V}, level)
    get!(pool.invindex, level) do
        f()
        i = length(pool) + 1
        push!(pool.index, level)
        push!(pool.order, i)
        push!(pool.valindex, V(i, pool))
        i
    end
end
Base.get!(pool::CategoricalPool, level) = get!(Void, pool, level)

Base.push!(pool::CategoricalPool, level) = (get!(pool, level); pool)

function Base.append!(pool::CategoricalPool, levels)
    for level in levels
        push!(pool, level)
    end
    return pool
end

function Base.delete!{S, V}(pool::CategoricalPool{S, V}, level)
    levelS = convert(S, level)
    if haskey(pool.invindex, levelS)
        ind = pool.invindex[levelS]
        delete!(pool.invindex, levelS)
        splice!(pool.index, ind)
        ord = splice!(pool.order, ind)
        splice!(pool.valindex, ind)
        for i in ind:length(pool)
            pool.invindex[pool.index[i]] -= 1
            pool.valindex[i] = V(i, pool)
        end
        for i in 1:length(pool)
            pool.order[i] > ord && (pool.order[i] -= 1)
        end
    end
    return pool
end

function Base.delete!(pool::CategoricalPool, levels...)
    for level in levels
        delete!(pool, level)
    end
    return pool
end

function levels!{S, V, T}(pool::CategoricalPool{S, V}, newlevels::Vector{T})
    for (k, v) in pool.invindex
        delete!(pool.invindex, k)
    end
    n = length(newlevels)
    resize!(pool.index, n)
    resize!(pool.valindex, n)
    resize!(pool.order, n)
    for i in 1:n
        v = newlevels[i]
        pool.index[i] = v
        pool.valindex[i] = V(i, pool)
        pool.invindex[v] = i
    end
    order = buildorder(pool.invindex, newlevels)
    for i in 1:n
        pool.order[i] = order[i]
    end
    buildvalues!(pool)
    return newlevels
end

function levels!{S, V, T}(pool::CategoricalPool{S, V},
                          newlevels::Vector{T},
                          ordered::Vector{T})
    if !allunique(newlevels)
        throw(ArgumentError(string("duplicated levels found: ",
                                   join(unique(filter(x->sum(newlevels.==x)>1, newlevels)), ", "))))
    end

    order = buildorder(pool.invindex, ordered)
    n = length(newlevels)
    resize!(order, n)
    for i in 1:n
        pool.order[i] = order[i]
    end
    buildvalues!(pool)
    return newlevels
end

order{T}(pool::CategoricalPool{T}) = pool.order

function order!{S, T}(pool::CategoricalPool{S}, ordered::Vector{T})
    if !allunique(ordered)
        throw(ArgumentError(string("duplicated levels found: ",
                                   join(unique(filter(x->sum(ordered.==x)>1, ordered)), ", "))))
    end
    d = symdiff(ordered, levels(pool))
    if length(d) > 0
        throw(ArgumentError(string("found levels not in existing levels or vice-versa: ",
                                   join(d, ", "))))
    end
    updateorder!(pool.order, pool.invindex, ordered)
    return ordered
end
