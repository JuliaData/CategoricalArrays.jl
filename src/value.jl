
function CategoricalValue{T, R, O}(level::Integer, pool::CategoricalPool{T, R, O})
    return CategoricalValue(convert(R, level), pool)
end

Base.convert{T, R, O}(::Type{CategoricalValue{T, R, O}}, x::CategoricalValue{T, R, O}) = x
Base.convert{T, R}(::Type{CategoricalValue{T, R}}, x::CategoricalValue{T, R}) = x
Base.convert{T}(::Type{CategoricalValue{T}}, x::CategoricalValue{T}) = x
Base.convert(::Type{CategoricalValue}, x::CategoricalValue) = x

Base.promote_rule{S, T, R, O}(::Type{CategoricalValue{S, R, O}}, ::Type{T}) = promote_type(S, T)
Base.promote_rule{S, T, R}(::Type{CategoricalValue{S, R}}, ::Type{T}) = promote_type(S, T)
Base.promote_rule{S, T}(::Type{CategoricalValue{S}}, ::Type{T}) = promote_type(S, T)
Base.promote_rule{T}(::Type{CategoricalValue}, ::Type{T}) = T

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

function Base.show{T}(io::IO, x::CategoricalValue{T})
    if @compat(get(io, :compact, false))
        print(io, repr(index(x.pool)[x.level]))
    else
        @printf(io, "%s %s",
                typeof(x),
                repr(index(x.pool)[x.level]))
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

function Base.isless{S, T}(x::CategoricalValue{S}, y::CategoricalValue{T})
    error("CategoricalValue objects with different pools cannot be tested for order")
end

function Base.isless{T, R1, R2}(x::CategoricalValue{T, R1, false}, y::CategoricalValue{T, R2, true})
    error("CategoricalValue objects cannot be compared unless both are ordered")
end

function Base.isless{T, R1, R2}(x::CategoricalValue{T, R1, true}, y::CategoricalValue{T, R2, false})
    error("CategoricalValue objects cannot be compared unless both are ordered")
end

function Base.isless{T, R1, R2}(x::CategoricalValue{T, R1, false}, y::CategoricalValue{T, R2, false})
    error("CategoricalValue objects cannot be compared unless both are ordered")
end

function Base.isless{T, R1, R2}(x::CategoricalValue{T, R1, true}, y::CategoricalValue{T, R2, true})
    if !(x.pool === y.pool)
        error("CategoricalValue objects with different pools cannot be compared")
    else
        return isless(order(x.pool)[x.level], order(y.pool)[y.level])
    end
end
