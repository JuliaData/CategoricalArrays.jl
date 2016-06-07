for (P, V) in ((:NominalPool, :NominalValue), (:OrdinalPool, :OrdinalValue))
    @eval begin
        function $V{T, R}(level::Integer, pool::$P{T, R})
            return $V(convert(R, level), pool)
        end

        Base.convert{T, R}(::Type{$V{T, R}}, x::$V{T}) = x
        Base.convert{T}(::Type{$V{T}}, x::$V{T}) = x
        Base.convert(::Type{$V}, x::$V) = x
    end
end

# To fix ambiguity with definition from Base
function Base.convert{S, T}(::Type{Nullable{S}}, x::CategoricalValue{Nullable{T}})
    return convert(Nullable{S}, index(x.pool)[x.level])
end

function Base.convert{S, T}(::Type{S}, x::CategoricalValue{T})
    return convert(S, index(x.pool)[x.level])
end

function Base.show{T}(io::IO, x::NominalValue{T})
    if get(io, :compact, false)
        print(io, repr(index(x.pool)[x.level]))
    else
        @printf(io, "%s %s",
                typeof(x),
                repr(index(x.pool)[x.level]))
    end
end

function Base.show{T}(io::IO, x::OrdinalValue{T})
    if get(io, :compact, false)
        print(io, repr(index(x.pool)[x.level]))
    else
        @printf(io, "%s %s (%i/%i)",
                typeof(x),
                repr(index(x.pool)[x.level]),
                order(x.pool)[x.level], length(x.pool))
    end
end

Base.:(==)(x::CategoricalValue, y::CategoricalValue) =
    index(x.pool)[x.level] == index(y.pool)[y.level]
Base.:(==)(x::CategoricalValue, y::Any) = index(x.pool)[x.level] == y
Base.:(==)(x::Any, y::CategoricalValue) = y == x

Base.isequal(x::CategoricalValue, y::CategoricalValue) =
    isequal(index(x.pool)[x.level], index(y.pool)[y.level])
Base.isequal(x::CategoricalValue, y::Any) = isequal(index(x.pool)[x.level], y)
Base.isequal(x::Any, y::CategoricalValue) = isequal(y, x)

function Base.isless{S, T}(x::NominalValue{S}, y::NominalValue{T})
    error("NominalValue objects cannot be tested for order")
end

function Base.isless{S, T}(x::OrdinalValue{S}, y::OrdinalValue{T})
    error("OrdinalValue objects with different pools cannot be compared")
end

function Base.isless{T}(x::OrdinalValue{T}, y::OrdinalValue{T})
    if !(x.pool === y.pool)
        error("OrdinalValue objects with different pools cannot be compared")
    else
        return isless(order(x.pool)[x.level], order(y.pool)[y.level])
    end
end
