module TestOrder
    using Base.Test
    using CategoricalData

    for P in (NominalPool, OrdinalPool)
        pool = P([1, 2, 3])

        @test order(pool) == CategoricalData.RefType[1, 2, 3]

        order!(pool, [3, 1, 2])
        @test_throws ArgumentError order!(pool, [1, 2])
        @test_throws ArgumentError order!(pool, [3, 1, 2, 3])
        @test_throws ArgumentError order!(pool, [3, 4, 2])
        @test_throws ArgumentError order!(pool, ["a", "c", "b"])

        @test pool.index == [1, 2, 3]
        @test pool.invindex == Dict(
            2 => convert(CategoricalData.RefType, 2),
            3 => convert(CategoricalData.RefType, 3),
            1 => convert(CategoricalData.RefType, 1),
        )
        @test pool.order == CategoricalData.RefType[2, 3, 1]

        pool = P(["a", "b", "c"], ["c", "b", "a"])

        @test order(pool) == CategoricalData.RefType[3, 2, 1]

        order!(pool, ["a", "c", "b"])

        @test pool.index == ["a", "b", "c"]
        @test pool.invindex == Dict(
            "a" => convert(CategoricalData.RefType, 1),
            "b" => convert(CategoricalData.RefType, 2),
            "c" => convert(CategoricalData.RefType, 3),
        )
        @test pool.order == CategoricalData.RefType[1, 3, 2]
    end
end
