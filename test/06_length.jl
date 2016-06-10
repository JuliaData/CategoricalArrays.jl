module TestLength
    using Base.Test
    using CategoricalArrays

    for P in (NominalPool, OrdinalPool)
        pool = P([1, 2, 3])
        @test length(pool) == 3

        opool = P([1, 2, 3], [3, 2, 1])
        @test length(opool) == 3
    end
end
