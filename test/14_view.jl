module TestView

using Base.Test
using CategoricalArrays
using NullableArrays

# == currently throws an error for Nullables
(==) = isequal

for (A, T) in zip((Array, NullableArray), (CategoricalArray, NullableCategoricalArray))
    for order in (true, false)
        for a in (1:10, 10:-1:1, ["a", "c", "b", "b", "a"])
            for inds in [1:2, :, 1, []]
                x = T(a, ordered=order)
                v = view(x, inds)
                @test levels(v) === levels(x)
                @test unique(v) == (ndims(v) > 0 ? sort(A(unique(a[inds]))) : A([a[inds]]))
                @test isordered(v) === isordered(x)
            end
        end
    end
end

end
