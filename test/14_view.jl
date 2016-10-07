module TestView

using Base.Test
using CategoricalArrays

for T in [CategoricalArray, NullableCategoricalArray]
    for order in [true, false]
        x = T(1:10, ordered=order)
        for inds in [1:2, :, 1, []]
            v = view(x, inds)
            @test levels(v) === levels(x)
            @test isordered(v) === isordered(x)
        end
    end
end

end
