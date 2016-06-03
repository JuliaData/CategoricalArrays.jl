module TestUpdateOrder
    using Base.Test
    using CategoricalData

    pool = OrdinalPool(
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

    CategoricalData.updateorder!(order, pool.invindex, ["b", "a", "c"])

    @test order[1] == convert(CategoricalData.RefType, 2)
    @test order[2] == convert(CategoricalData.RefType, 1)
    @test order[3] == convert(CategoricalData.RefType, 3)
end
