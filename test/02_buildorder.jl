module TestUpdateOrder
    using Base.Test
    using CategoricalArrays
    using CategoricalArrays: DefaultRefType

    for P in (NominalPool, OrdinalPool)
        pool = P(
            [
                "a",
                "b",
                "c"
            ],
            Dict(
                "a" => convert(DefaultRefType, 1),
                "b" => convert(DefaultRefType, 2),
                "c" => convert(DefaultRefType, 3),
            )
        )

        order = Array(DefaultRefType, length(pool.index))

        CategoricalArrays.buildorder!(order, pool.invindex, ["b", "a", "c"])

        @test order[1] == convert(DefaultRefType, 2)
        @test order[2] == convert(DefaultRefType, 1)
        @test order[3] == convert(DefaultRefType, 3)
    end
end
