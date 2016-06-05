module TestUpdateOrder
    using Base.Test
    using CategoricalData

    for P in (NominalPool, OrdinalPool)
        pool = P(
            [
                "a",
                "b",
                "c"
            ],
            Dict(
                "a" => convert(CategoricalData.RefType, 1),
                "b" => convert(CategoricalData.RefType, 2),
                "c" => convert(CategoricalData.RefType, 3),
            )
        )

        order = Array(CategoricalData.RefType, length(pool.index))

        CategoricalData.buildorder!(order, pool.invindex, ["b", "a", "c"])

        @test order[1] == convert(CategoricalData.RefType, 2)
        @test order[2] == convert(CategoricalData.RefType, 1)
        @test order[3] == convert(CategoricalData.RefType, 3)
    end
end
