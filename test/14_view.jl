module TestView

using Base.Test
using CategoricalArrays

for CA in (CategoricalArray, NullableCategoricalArray)
    for order in (true, false)
        for a in (1:10, 10:-1:1, ["a", "c", "b", "b", "a"])
            for inds in [1:2, :, 1, []]
                x = CA(a, ordered=order)
                v = view(x, inds)
                @test levels(v) === levels(x)
                @test unique(v) == (ndims(v) > 0 ? sort(unique(a[inds])) : [a[inds]])
                @test isordered(v) === isordered(x)
            end
        end
    end
end

end
