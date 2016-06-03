function NominalValue(level::Integer, pool::CategoricalPool)
    return NominalValue{CategoricalPool}(convert(RefType, level), pool)
end

Base.convert{T}(::Type{NominalValue{T}}, x::NominalValue{T}) = x
Base.convert(::Type{NominalValue}, x::NominalValue) = x

# To fix ambiguity with definition from Base
function Base.convert{S, T}(::Type{Nullable{S}}, x::NominalValue{Nullable{T}})
    return convert(Nullable{S}, levels(x.pool)[x.level])
end

function Base.convert{S, T}(::Type{S}, x::NominalValue{T})
    return convert(S, levels(x.pool)[x.level])
end

function Base.show{T}(io::IO, x::NominalValue{T})
    if get(io, :compact, false)
        print(io, repr(levels(x.pool)[x.level]))
    else
        @printf(io, "NominalValue{%s} %s", T, repr(levels(x.pool)[x.level]))
    end
end

Base.:(==)(x::NominalValue, y::NominalValue) =
    levels(x.pool)[x.level] == levels(y.pool)[y.level]
Base.:(==)(x::NominalValue, y::Any) = levels(x.pool)[x.level] == y
Base.:(==)(x::Any, y::NominalValue) = y == x

Base.isequal(x::NominalValue, y::NominalValue) =
    isequal(levels(x.pool)[x.level], levels(y.pool)[y.level])
Base.isequal(x::NominalValue, y::Any) = isequal(levels(x.pool)[x.level], y)
Base.isequal(x::Any, y::NominalValue) = isequal(y, x)

function Base.isless{S, T}(x::NominalValue{S}, y::NominalValue{T})
    error("NominalValue objects cannot be tested for order")
end
