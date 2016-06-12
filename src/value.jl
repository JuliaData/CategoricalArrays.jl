for (P, V) in ((:NominalPool, :NominalValue), (:OrdinalPool, :OrdinalValue))
    @eval begin
        function $V{T, R}(level::Integer, pool::$P{T, R})
            return $V(convert(R, level), pool)
        end

        Base.convert{T, R}(::Type{$V{T, R}}, x::$V{T}) = x
        Base.convert{T}(::Type{$V{T}}, x::$V{T}) = x
        Base.convert(::Type{$V}, x::$V) = x

        Base.promote_rule{S, T, R}(::Type{$V{S, R}}, ::Type{T}) = promote_type(S, T)
        Base.promote_rule{S, T}(::Type{$V{S}}, ::Type{T}) = promote_type(S, T)
        Base.promote_rule{T}(::Type{$V}, ::Type{T}) = T
    end
end

# To fix ambiguities with definitions from Base
Base.convert{S}(::Type{Nullable{S}}, x::CategoricalValue{Nullable}) =
    convert(Nullable{S}, index(x.pool)[x.level])
Base.convert{S}(::Type{Nullable}, x::CategoricalValue{S}) = convert(Nullable{S}, x)
Base.convert{T}(::Type{Nullable{CategoricalValue{Nullable{T}}}},
                x::CategoricalValue{Nullable{T}}) =
    Nullable(x)
Base.convert(::Type{Nullable{CategoricalValue}}, x::CategoricalValue{Nullable}) =
    Nullable(x)
Base.convert{T}(::Type{Ref}, x::CategoricalValue{T}) = RefValue{T}(x)

Base.convert{S, T}(::Type{S}, x::CategoricalValue{T}) = convert(S, index(x.pool)[x.level])

function Base.show{T}(io::IO, x::NominalValue{T})
    if @compat(get(io, :compact, false))
        print(io, repr(index(x.pool)[x.level]))
    else
        @printf(io, "%s %s",
                typeof(x),
                repr(index(x.pool)[x.level]))
    end
end

function Base.show{T}(io::IO, x::OrdinalValue{T})
    if @compat(get(io, :compact, false))
        print(io, repr(index(x.pool)[x.level]))
    else
        @printf(io, "%s %s (%i/%i)",
                typeof(x),
                repr(index(x.pool)[x.level]),
                order(x.pool)[x.level], length(x.pool))
    end
end

if VERSION < v"0.5.0-dev+1936"
    Base.showcompact{T}(io::IO, x::CategoricalValue{T}) =
        print(io, repr(index(x.pool)[x.level]))
end

@compat Base.:(==)(x::CategoricalValue, y::CategoricalValue) =
    index(x.pool)[x.level] == index(y.pool)[y.level]

# To fix ambiguities with Base
@compat Base.:(==)(x::CategoricalValue, y::WeakRef) = index(x.pool)[x.level] == y
@compat Base.:(==)(x::WeakRef, y::CategoricalValue) = y == x

@compat Base.:(==)(x::CategoricalValue, y::Any) = index(x.pool)[x.level] == y
@compat Base.:(==)(x::Any, y::CategoricalValue) = y == x

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
