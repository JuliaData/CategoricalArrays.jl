function OrdinalValue(level::Integer, pool::CategoricalPool)
    return OrdinalValue(convert(RefType, level), pool)
end

Base.convert{T}(::Type{OrdinalValue{T}}, x::OrdinalValue{T}) = x
Base.convert(::Type{OrdinalValue}, x::OrdinalValue) = x

# To fix ambiguity with definition from Base
function Base.convert{S, T}(::Type{Nullable{S}}, x::OrdinalValue{Nullable{T}})
    return convert(Nullable{S}, levels(x.opool)[x.level])
end

function Base.convert{S, T}(::Type{S}, x::OrdinalValue{T})
    return convert(S, levels(x.opool)[x.level])
end

function Base.show{T}(io::IO, x::OrdinalValue{T})
    if get(io, :compact, false)
        print(io, repr(levels(x.opool)[x.level]))
    else
        @printf(io, "OrdinalValue{%s} %s (%i/%i)",
                T,
                repr(levels(x.opool)[x.level]),
                order(x.opool)[x.level], length(x.opool))
    end
end

Base.:(==)(x::OrdinalValue, y::OrdinalValue) =
    levels(x.opool)[x.level] == levels(y.opool)[y.level]
Base.:(==)(x::OrdinalValue, y::Any) = levels(x.opool)[x.level] == y
Base.:(==)(x::Any, y::OrdinalValue) = y == x

Base.isequal(x::OrdinalValue, y::OrdinalValue) =
    isequal(levels(x.opool)[x.level], levels(y.opool)[y.level])
Base.isequal(x::OrdinalValue, y::Any) = isequal(levels(x.opool)[x.level], y)
Base.isequal(x::Any, y::OrdinalValue) = isequal(y, x)

function Base.isless{S, T}(x::OrdinalValue{S}, y::OrdinalValue{T})
    error("OrdinalValue objects with different pools cannot be compared")
end

function Base.isless{T}(x::OrdinalValue{T}, y::OrdinalValue{T})
    if !(x.opool === y.opool)
        error("OrdinalValue objects with different pools cannot be compared")
    else
        return isless(order(x.opool)[x.level], order(y.opool)[y.level])
    end
end
