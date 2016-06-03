module TestConstructors
    using Base.Test
    using CategoricalData

    pool = CategoricalPool(["a", "b", "c"])

    @test isa(pool, CategoricalPool)

    @test isa(pool.index, Vector)
    @test length(pool.index) == 3
    @test pool.index[1] == "a"
    @test pool.index[2] == "b"
    @test pool.index[3] == "c"

    @test isa(pool.invindex, Dict)
    @test length(pool.invindex) == 3
    @test pool.invindex["a"] === convert(CategoricalData.RefType, 1)
    @test pool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test pool.invindex["c"] === convert(CategoricalData.RefType, 3)

    pool = CategoricalPool(
        Dict(
            "a" => convert(CategoricalData.RefType, 1),
            "b" => convert(CategoricalData.RefType, 2),
            "c" => convert(CategoricalData.RefType, 3),
        )
    )

    @test isa(pool, CategoricalPool)

    @test isa(pool.index, Vector)
    @test length(pool.index) == 3
    @test pool.index[1] == "a"
    @test pool.index[2] == "b"
    @test pool.index[3] == "c"

    @test isa(pool.invindex, Dict)
    @test length(pool.invindex) == 3
    @test pool.invindex["a"] === convert(CategoricalData.RefType, 1)
    @test pool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test pool.invindex["c"] === convert(CategoricalData.RefType, 3)

    # TODO: Make sure that invindex input is exhaustive
    # Raise an error if map misses any entries
    pool = CategoricalPool(
        Dict(
            "a" => 1,
            "b" => 2,
            "c" => 3,
        )
    )

    @test isa(pool, CategoricalPool)

    @test isa(pool.index, Vector)
    @test length(pool.index) == 3
    @test pool.index[1] == "a"
    @test pool.index[2] == "b"
    @test pool.index[3] == "c"

    @test isa(pool.invindex, Dict)
    @test length(pool.invindex) == 3
    @test pool.invindex["a"] === convert(CategoricalData.RefType, 1)
    @test pool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test pool.invindex["c"] === convert(CategoricalData.RefType, 3)

    opool = CategoricalPool(["c", "b", "a"])

    @test isa(opool, CategoricalPool)

    @test length(opool.index) == 3
    @test opool.index[1] == "c"
    @test opool.index[2] == "b"
    @test opool.index[3] == "a"

    @test isa(opool.invindex, Dict)
    @test length(opool.invindex) == 3
    @test opool.invindex["c"] === convert(CategoricalData.RefType, 1)
    @test opool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test opool.invindex["a"] === convert(CategoricalData.RefType, 3)

    @test isa(opool.order, Vector{CategoricalData.RefType})
    @test length(opool.order) == 3
    @test opool.order[1] === convert(CategoricalData.RefType, 3)
    @test opool.order[2] === convert(CategoricalData.RefType, 2)
    @test opool.order[3] === convert(CategoricalData.RefType, 1)

    opool = CategoricalPool(
        Dict(
            "a" => convert(CategoricalData.RefType, 3),
            "b" => convert(CategoricalData.RefType, 2),
            "c" => convert(CategoricalData.RefType, 1),
        )
    )

    @test isa(opool, CategoricalPool)

    @test isa(opool, CategoricalPool)
    @test length(opool.index) == 3
    @test opool.index[1] == "c"
    @test opool.index[2] == "b"
    @test opool.index[3] == "a"

    @test isa(opool.invindex, Dict)
    @test length(opool.invindex) == 3
    @test opool.invindex["c"] === convert(CategoricalData.RefType, 1)
    @test opool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test opool.invindex["a"] === convert(CategoricalData.RefType, 3)

    @test isa(opool.order, Vector{CategoricalData.RefType})
    @test length(opool.order) == 3
    @test opool.order[1] === convert(CategoricalData.RefType, 3)
    @test opool.order[2] === convert(CategoricalData.RefType, 2)
    @test opool.order[3] === convert(CategoricalData.RefType, 1)

    opool = CategoricalPool(["c", "b", "a"], ["c", "b", "a"])

    @test isa(opool, CategoricalPool)

    @test length(opool.index) == 3
    @test opool.index[1] == "c"
    @test opool.index[2] == "b"
    @test opool.index[3] == "a"

    @test isa(opool.invindex, Dict)
    @test length(opool.invindex) == 3
    @test opool.invindex["c"] === convert(CategoricalData.RefType, 1)
    @test opool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test opool.invindex["a"] === convert(CategoricalData.RefType, 3)

    @test isa(opool.order, Vector{CategoricalData.RefType})
    @test length(opool.order) == 3
    @test opool.order[1] === convert(CategoricalData.RefType, 1)
    @test opool.order[2] === convert(CategoricalData.RefType, 2)
    @test opool.order[3] === convert(CategoricalData.RefType, 3)

    opool = CategoricalPool(
        Dict(
            "a" => convert(CategoricalData.RefType, 3),
            "b" => convert(CategoricalData.RefType, 2),
            "c" => convert(CategoricalData.RefType, 1),
        ),
        ["c", "b", "a"]
    )

    @test isa(opool, CategoricalPool)

    @test length(opool.index) == 3
    @test opool.index[1] == "c"
    @test opool.index[2] == "b"
    @test opool.index[3] == "a"

    @test isa(opool.invindex, Dict)
    @test length(opool.invindex) == 3
    @test opool.invindex["c"] === convert(CategoricalData.RefType, 1)
    @test opool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test opool.invindex["a"] === convert(CategoricalData.RefType, 3)

    @test isa(opool.order, Vector{CategoricalData.RefType})
    @test length(opool.order) == 3
    @test opool.order[1] === convert(CategoricalData.RefType, 1)
    @test opool.order[2] === convert(CategoricalData.RefType, 2)
    @test opool.order[3] === convert(CategoricalData.RefType, 3)
end
