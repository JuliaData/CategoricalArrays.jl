# delegate methods for SubArrays to support view

for f in [:levels, :isordered]
    @eval begin
        $f{T,N,P<:CatArray,I,L}(sa::SubArray{T,N,P,I,L}) = $f(parent(sa))
    end
end
