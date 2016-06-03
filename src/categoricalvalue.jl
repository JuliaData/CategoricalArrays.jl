function CategoricalValue(level::Integer, pool::CategoricalPool)
    return CategoricalValue(convert(RefType, level), pool)
end

Base.convert{T}(::Type{CategoricalValue{T}}, x::CategoricalValue{T}) = x
Base.convert(::Type{CategoricalValue}, x::CategoricalValue) = x

# To fix ambiguity with definition from Base
function Base.convert{S, T}(::Type{Nullable{S}}, x::CategoricalValue{Nullable{T}})
    return convert(Nullable{S}, levels(x.pool)[x.level])
end

function Base.convert{S, T}(::Type{S}, x::CategoricalValue{T})
    return convert(S, levels(x.pool)[x.level])
end

function Base.show{T}(io::IO, x::CategoricalValue{T})
    if get(io, :compact, false)
        print(io, repr(levels(x.pool)[x.level]))
    else
        @printf(io, "CategoricalValue{%s} %s", T, repr(levels(x.pool)[x.level]))
    end
end

Base.:(==)(x::CategoricalValue, y::CategoricalValue) =
    levels(x.pool)[x.level] == levels(y.pool)[y.level]
Base.:(==)(x::CategoricalValue, y::Any) = levels(x.pool)[x.level] == y
Base.:(==)(x::Any, y::CategoricalValue) = y == x

Base.isequal(x::CategoricalValue, y::CategoricalValue) =
    isequal(levels(x.pool)[x.level], levels(y.pool)[y.level])
Base.isequal(x::CategoricalValue, y::Any) = isequal(levels(x.pool)[x.level], y)
Base.isequal(x::Any, y::CategoricalValue) = isequal(y, x)

function Base.isless{S, T}(x::CategoricalValue{S}, y::CategoricalValue{T})
    error("CategoricalValue objects cannot be tested for order")
end
