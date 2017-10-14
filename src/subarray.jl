# delegate methods for SubArrays to support view

Nulls.levels(sa::SubArray{T,N,P}) where {T,N,P<:CategoricalArray} = levels(parent(sa))
isordered(sa::SubArray{T,N,P}) where {T,N,P<:CategoricalArray} = isordered(parent(sa))

function unique(sa::SubArray{T,N,P}) where {T,N,P<:CategoricalArray}
    A = parent(sa)
    refs = view(A.refs, sa.indexes...)
    S = eltype(P) >: Null ? Union{eltype(index(A.pool)), Null} : eltype(index(A.pool))
    _unique(S, refs, A.pool)
end
