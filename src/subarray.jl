# delegate methods for SubArrays to support view

for f in [:levels, :isordered]
    @eval begin
        $f{T,N,P<:CatArray}(sa::SubArray{T,N,P}) = $f(parent(sa))
    end
end

function unique{T,N,P<:CatArray}(sa::SubArray{T,N,P})
    A = parent(sa)
    refs = view(A.refs, sa.indexes...)
    _unique(eltype(P) <: Nullable ? NullableArray : Array, refs, A.pool)
end
