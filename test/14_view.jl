module TestView

using Base.Test
using CategoricalArrays

for order in [true, false]
    x = categorical(collect(1:10), ordered=order)
    for inds in [1:2, :, 1, []]
        v = view(x, inds)
        @test levels(v) == levels(x)
        @test ordered(v) == ordered(x)
    end
end

end
