module TestTypeDef
    using Base.Test
    using CategoricalData

    @test CategoricalData.RefType === Uint

    pool = CategoricalPool(
        [
            "a",
            "b",
            "c"
        ],
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

    # TODO: Need constructors that take in arbitrary integers
    for i in 1:3
        x = CategoricalVariable(convert(CategoricalData.RefType, i), pool)

        @test isa(x, CategoricalVariable)

        @test isa(x.level, CategoricalData.RefType)
        @test x.level === convert(CategoricalData.RefType, i)

        @test isa(x.pool, CategoricalPool)
        @test x.pool === pool
    end

    opool = OrdinalPool(
        pool,
        [
            convert(CategoricalData.RefType, 3),
            convert(CategoricalData.RefType, 2),
            convert(CategoricalData.RefType, 1),
        ]
    )

    @test isa(opool, OrdinalPool)

    @test isa(opool.pool, CategoricalPool)
    @test opool.pool === pool

    @test isa(opool.order, Vector{CategoricalData.RefType})
    @test length(opool.order) == 3
    @test opool.order[1] === convert(CategoricalData.RefType, 3)
    @test opool.order[2] === convert(CategoricalData.RefType, 2)
    @test opool.order[3] === convert(CategoricalData.RefType, 1)

    for i in 1:3
        y = OrdinalVariable(convert(CategoricalData.RefType, i), opool)

        @test isa(y, OrdinalVariable)

        @test isa(y.level, CategoricalData.RefType)
        @test y.level === convert(CategoricalData.RefType, i)

        @test isa(y.opool, OrdinalPool)
        @test y.opool === opool
    end
end
