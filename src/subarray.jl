# delegate methods for SubArrays to support view

for f in [:levels, :isordered]
    @eval begin
        $f(sa::SubArray{T,N,P}) where {T,N,P<:CategoricalArray} = $f(parent(sa))
    end
end

function unique(sa::SubArray{T,N,P}) where {T,N,P<:CategoricalArray}
    A = parent(sa)
    refs = view(A.refs, sa.indexes...)
    S = eltype(P) >: Null ? Union{eltype(index(A.pool)), Null} : eltype(index(A.pool))
    _unique(S, refs, A.pool)
end
