import Base: getindex, setindex!, similar, in, collect

@inline function getindex(A::CategoricalArray{T}, I...) where {T>:Missing}
    @boundscheck checkbounds(A, I...)
    # Let Array indexing code handle everything
    @inbounds r = A.refs[I...]

    if isa(r, Array)
        ret = CategoricalArray{T, ndims(r)}(r, copy(A.pool))
        return ordered!(ret, isordered(A))
    else
        if r > 0
            @inbounds return A.pool[r]
        else
            return missing
        end
    end
end

@inline function setindex!(A::CategoricalArray{>:Missing}, v::Missing, I::Real...)
    @boundscheck checkbounds(A, I...)
    @inbounds A.refs[I...] = 0
end

@inline function Base.push!(A::CategoricalVector{>:Missing}, v::Missing)
    push!(A.refs, 0)
    return A
end

@inline function Base.insert!(A::CategoricalVector{>:Missing}, i::Integer, v::Missing)
    i isa Bool && throw(ArgumentError("invalid index: $i of type Bool"))
    if !(1 <= i <= length(A.refs) + 1)
        throw(BoundsError("attempt to insert to a vector with length $(length(A)) at index $i"))
    end
    insert!(A.refs, i, 0)
    return A
end

Base.fill!(A::CategoricalArray{>:Missing}, ::Missing) = (fill!(A.refs, 0); A)

in(x::Missing, y::CategoricalArray) = false
in(x::Missing, y::CategoricalArray{>:Missing}) = !all(v -> v > 0, y.refs)

function Missings.replace(a::CategoricalArray{T, N, R, V, C}, replacement::V) where {T, N, R, V, C}
    pool = copy(a.pool)
    v = C(pool, get!(pool, replacement))
    Missings.replace(a, v)
end

function collect(r::Missings.EachReplaceMissing{<:CategoricalArray{T, N, R, V}}) where {T, N, R, V}
    CategoricalArray{V,N}(R[refcode(v) for v in r], r.replacement.pool)
end
