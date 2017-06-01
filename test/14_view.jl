module TestView

using Base.Test
using CategoricalArrays
using Nulls

for T in (Union{}, Null)
    for order in (true, false)
        for a in (1:10, 10:-1:1, ["a", "c", "b", "b", "a"])
            for inds in [1:2, :, 1, []]
                x = CategoricalArray{Union{T, eltype(a)}}(a, ordered=order)
                v = view(x, inds)
                @test levels(v) === levels(x)
                @test unique(v) == (ndims(v) > 0 ? sort(unique(a[inds])) : [a[inds]])
                @test isordered(v) === isordered(x)
            end
        end
    end
end

# Test ==
ca1 = CategoricalArray([1, 2, 3])
ca2 = CategoricalArray{?Int}([1, 2, 3])
ca3 = CategoricalArray([1, 2, null])
ca4 = CategoricalArray([4, 3, 2])
ca5 = CategoricalArray([1 2; 3 4])

@test view(ca1, 1:2) == view(ca1, 1:2)
@test view(ca2, 1:2) == view(ca2, 1:2)
@test view(ca1, 1:2) == view(ca2, 1:2)
@test view(ca1, 1:2) == view(ca3, 1:2)
@test view(ca1, 1:2) != view(ca2, 1:3)
@test view(ca1, 1:2) != view(ca5, 1:2, 1:1)

end
