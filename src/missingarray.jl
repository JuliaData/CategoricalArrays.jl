import Base: getindex, setindex!, similar, in

@inline function getindex(A::CategoricalArray{T}, I...) where {T>:Missing}
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
            return missing
        end
    end
end

@inline function setindex!(A::CategoricalArray{>:Missing}, v::Missing, I::Real...)
    @boundscheck checkbounds(A, I...)
    @inbounds A.refs[I...] = 0
end

Base.fill!(A::CategoricalArray{>:Missing}, ::Missing) = (fill!(A.refs, 0); A)

in(x::Missing, y::CategoricalArray) = false
in(x::Missing, y::CategoricalArray{>:Missing}) = !all(v -> v > 0, y.refs)
