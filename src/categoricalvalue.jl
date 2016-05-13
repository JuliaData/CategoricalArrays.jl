function CategoricalValue(level::Integer, pool::CategoricalPool)
    return CategoricalValue(convert(RefType, level), pool)
end

function Base.convert{S, T}(::Type{S}, x::CategoricalValue{T})
    return convert(S, x.pool.index[x.level])
end

function Base.show{T}(io::IO, x::CategoricalValue{T})
    if limit_output(io)
        print(io, repr(x.pool.index[x.level]))
    else
        @printf(io, "CategoricalValue{%s} %s", T, repr(x.pool.index[x.level]))
    end
end

Base.:(==)(x::CategoricalValue, y::CategoricalValue) =
    x.pool.index[x.level] == y.pool.index[y.level]
Base.:(==)(x::CategoricalValue, y::Any) = x.pool.index[x.level] == y
Base.:(==)(x::Any, y::CategoricalValue) = y == x

Base.isequal(x::CategoricalValue, y::CategoricalValue) =
    isequal(x.pool.index[x.level], y.pool.index[y.level])
Base.isequal(x::CategoricalValue, y::Any) = isequal(x.pool.index[x.level], y)
Base.isequal(x::Any, y::CategoricalValue) = isequal(y, x)

function Base.isless{S, T}(x::CategoricalValue{S}, y::CategoricalValue{T})
    error("CategoricalValue objects cannot be tested for order")
end
