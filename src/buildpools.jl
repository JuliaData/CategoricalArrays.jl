# TODO: Make values an explicit iterable of type T
function build{T}(::Type{CategoricalPool}, values::Array{T})
    index = T[]
    invindex = Dict{T, RefType}()
    i = one(RefType)
    for v in values
        if !haskey(invindex, v)
            push!(index, v)
            invindex[v] = i
            i = convert(RefType, i + one(RefType))
        end
    end
    return CategoricalPool(index, invindex)
end

# TODO: Make values an explicit iterable of type T
function build{T}(::Type{OrdinalPool}, values::Array{T})
    pool = build(CategoricalPool, values)
    return OrdinalPool(pool, buildorder(pool.index))
end
