function CategoricalVariable(level::Integer, pool::CategoricalPool)
    return CategoricalVariable(convert(RefType, level), pool)
end

function Base.convert{S, T}(::Type{S}, x::CategoricalVariable{T})
    return convert(S, x.pool.index[x.level])
end

function Base.show{T}(io::IO, x::CategoricalVariable{T})
    @printf(io, "Categorical '%s'", convert(T, x))
    return
end

function Base.isless{S, T}(x::CategoricalVariable{S}, y::CategoricalVariable{T})
    error("CategoricalVariable objects cannot be tested for order")
end
