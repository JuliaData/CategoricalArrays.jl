module TestLength
    using Base.Test
    using CategoricalData

    pool = OrdinalPool([1, 2, 3])
    opool = OrdinalPool([1, 2, 3], [3, 2, 1])

    @test length(pool) == 3
    @test length(opool) == 3
end
