# delegate methods for SubArrays to support view

for f in [:levels, :isordered]
    @eval begin
        $f{T,N,P<:CatArray}(sa::SubArray{T,N,P}) = $f(parent(sa))
    end
end
