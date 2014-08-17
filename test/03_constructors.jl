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
        [
            "a" => convert(CategoricalData.RefType, 1),
            "b" => convert(CategoricalData.RefType, 2),
            "c" => convert(CategoricalData.RefType, 3),
        ]
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
        [
            "a" => 1,
            "b" => 2,
            "c" => 3,
        ]
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

    opool = OrdinalPool(["c", "b", "a"])

    @test isa(opool, OrdinalPool)

    @test isa(opool.pool, CategoricalPool)
    @test length(opool.pool.index) == 3
    @test opool.pool.index[1] == "c"
    @test opool.pool.index[2] == "b"
    @test opool.pool.index[3] == "a"

    @test isa(opool.pool.invindex, Dict)
    @test length(opool.pool.invindex) == 3
    @test opool.pool.invindex["c"] === convert(CategoricalData.RefType, 1)
    @test opool.pool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test opool.pool.invindex["a"] === convert(CategoricalData.RefType, 3)

    @test isa(opool.order, Vector{CategoricalData.RefType})
    @test length(opool.order) == 3
    @test opool.order[1] === convert(CategoricalData.RefType, 3)
    @test opool.order[2] === convert(CategoricalData.RefType, 2)
    @test opool.order[3] === convert(CategoricalData.RefType, 1)

    opool = OrdinalPool(
        [
            "a" => convert(CategoricalData.RefType, 3),
            "b" => convert(CategoricalData.RefType, 2),
            "c" => convert(CategoricalData.RefType, 1),
        ]
    )

    @test isa(opool, OrdinalPool)

    @test isa(opool.pool, CategoricalPool)
    @test length(opool.pool.index) == 3
    @test opool.pool.index[1] == "c"
    @test opool.pool.index[2] == "b"
    @test opool.pool.index[3] == "a"

    @test isa(opool.pool.invindex, Dict)
    @test length(opool.pool.invindex) == 3
    @test opool.pool.invindex["c"] === convert(CategoricalData.RefType, 1)
    @test opool.pool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test opool.pool.invindex["a"] === convert(CategoricalData.RefType, 3)

    @test isa(opool.order, Vector{CategoricalData.RefType})
    @test length(opool.order) == 3
    @test opool.order[1] === convert(CategoricalData.RefType, 3)
    @test opool.order[2] === convert(CategoricalData.RefType, 2)
    @test opool.order[3] === convert(CategoricalData.RefType, 1)

    opool = OrdinalPool(["c", "b", "a"], ["c", "b", "a"])

    @test isa(opool, OrdinalPool)

    @test isa(opool.pool, CategoricalPool)
    @test length(opool.pool.index) == 3
    @test opool.pool.index[1] == "c"
    @test opool.pool.index[2] == "b"
    @test opool.pool.index[3] == "a"

    @test isa(opool.pool.invindex, Dict)
    @test length(opool.pool.invindex) == 3
    @test opool.pool.invindex["c"] === convert(CategoricalData.RefType, 1)
    @test opool.pool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test opool.pool.invindex["a"] === convert(CategoricalData.RefType, 3)

    @test isa(opool.order, Vector{CategoricalData.RefType})
    @test length(opool.order) == 3
    @test opool.order[1] === convert(CategoricalData.RefType, 1)
    @test opool.order[2] === convert(CategoricalData.RefType, 2)
    @test opool.order[3] === convert(CategoricalData.RefType, 3)

    opool = OrdinalPool(
        [
            "a" => convert(CategoricalData.RefType, 3),
            "b" => convert(CategoricalData.RefType, 2),
            "c" => convert(CategoricalData.RefType, 1),
        ],
        ["c", "b", "a"]
    )

    @test isa(opool, OrdinalPool)

    @test isa(opool.pool, CategoricalPool)
    @test length(opool.pool.index) == 3
    @test opool.pool.index[1] == "c"
    @test opool.pool.index[2] == "b"
    @test opool.pool.index[3] == "a"

    @test isa(opool.pool.invindex, Dict)
    @test length(opool.pool.invindex) == 3
    @test opool.pool.invindex["c"] === convert(CategoricalData.RefType, 1)
    @test opool.pool.invindex["b"] === convert(CategoricalData.RefType, 2)
    @test opool.pool.invindex["a"] === convert(CategoricalData.RefType, 3)

    @test isa(opool.order, Vector{CategoricalData.RefType})
    @test length(opool.order) == 3
    @test opool.order[1] === convert(CategoricalData.RefType, 1)
    @test opool.order[2] === convert(CategoricalData.RefType, 2)
    @test opool.order[3] === convert(CategoricalData.RefType, 3)
end
