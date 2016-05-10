function CategoricalValue(level::Integer, pool::CategoricalPool)
    return CategoricalValue(convert(RefType, level), pool)
end

function Base.convert{S, T}(::Type{S}, x::CategoricalValue{T})
    return convert(S, x.pool.index[x.level])
end

function Base.show{T}(io::IO, x::CategoricalValue{T})
    @printf(io, "Categorical '%s'", convert(T, x))
    return
end

function Base.isless{S, T}(x::CategoricalValue{S}, y::CategoricalValue{T})
    error("CategoricalValue objects cannot be tested for order")
end
