# delegate methods for SubArrays to support view

for f in [:levels, :isordered]
    @eval begin
        $f{T,N,P<:CatArray}(sa::SubArray{T,N,P}) = $f(parent(sa))
    end
end

function unique{T,N,P<:CatArray}(sa::SubArray{T,N,P})
    A = parent(sa)
    refs = view(A.refs, sa.indexes...)
    S = eltype(P) >: Null ? Union{eltype(index(A.pool)), Null} : eltype(index(A.pool))
    _unique(S, refs, A.pool)
end
