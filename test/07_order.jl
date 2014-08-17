module TestOrder
    using Base.Test
    using CategoricalData

    opool = OrdinalPool([1, 2, 3])

    @test order(opool) == CategoricalData.RefType[1, 2, 3]

    order!(opool, [3, 1, 2])

    @test opool.pool.index == [1, 2, 3]
    @test opool.pool.invindex == [
        2 => convert(CategoricalData.RefType, 2),
        3 => convert(CategoricalData.RefType, 3),
        1 => convert(CategoricalData.RefType, 1),
    ]
    @test opool.order == CategoricalData.RefType[2, 3, 1]

    opool = OrdinalPool(["a", "b", "c"])

    @test order(opool) == CategoricalData.RefType[1, 2, 3]

    order!(opool, ["a", "c", "b"])

    @test opool.pool.index == ["a", "b", "c"]
    @test opool.pool.invindex == [
        "a" => convert(CategoricalData.RefType, 1),
        "b" => convert(CategoricalData.RefType, 2),
        "c" => convert(CategoricalData.RefType, 3),
    ]
    @test opool.order == CategoricalData.RefType[1, 3, 2]
end
