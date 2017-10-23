import Base: convert, getindex, setindex!, similar, in

## Constructors and converters
## (special methods for AbstractArray{Union{T, Null}}, to avoid wrapping nulls inside CategoricalValues)

function convert(::Type{CategoricalArray{T, N, R}}, A::AbstractArray{S, N}) where {S, T>:Null, N, R}
    res = CategoricalArray{T, N, R}(size(A))
    copy!(res, A)

    if method_exists(isless, Tuple{Nulls.T(T), Nulls.T(T)})
        levels!(res, sort(levels(res)))
    end

    res
end

@inline function getindex(A::CategoricalArray{T}, I...) where {T>:Null}
    @boundscheck checkbounds(A, I...)
    # Let Array indexing code handle everything
    @inbounds r = A.refs[I...]

    if isa(r, Array)
        ret = CategoricalArray{T, ndims(r)}(r, deepcopy(A.pool))
        return ordered!(ret, isordered(A))
    else
        if r > 0
            @inbounds return A.pool[r]
        else
            return null
        end
    end
end

@inline function setindex!(A::CategoricalArray{>:Null}, v::Null, I::Real...)
    @boundscheck checkbounds(A, I...)
    @inbounds A.refs[I...] = 0
end

in(x::Null, y::CategoricalArray) = false
in(x::Null, y::CategoricalArray{>:Null}) = !all(v -> v > 0, y.refs)
