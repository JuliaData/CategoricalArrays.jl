module TestTypeDef
    using Base.Test
    using CategoricalArrays
    using CategoricalArrays: DefaultRefType

    pool = CategoricalPool(
        [
            "a",
            "b",
            "c"
        ],
        Dict(
            "a" => DefaultRefType(1),
            "b" => DefaultRefType(2),
            "c" => DefaultRefType(3),
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
    @test pool.invindex["a"] === DefaultRefType(1)
    @test pool.invindex["b"] === DefaultRefType(2)
    @test pool.invindex["c"] === DefaultRefType(3)

    @test isa(pool.order, Vector{DefaultRefType})
    @test length(pool.order) == 3
    @test pool.order[1] === DefaultRefType(1)
    @test pool.order[2] === DefaultRefType(2)
    @test pool.order[3] === DefaultRefType(3)

    for i in 1:3
        x = catvalue(i, pool)

        @test CategoricalArrays.iscatvalue(x) === CategoricalArrays.IsCatValue

        @test isa(x.level, DefaultRefType)
        @test x.level === DefaultRefType(i)

        @test isa(x.pool, CategoricalPool)
        @test x.pool === pool
    end

    pool = CategoricalPool(
        [
            "a",
            "b",
            "c"
        ],
        Dict(
            "a" => DefaultRefType(1),
            "b" => DefaultRefType(2),
            "c" => DefaultRefType(3),
        ),
        [
            DefaultRefType(3),
            DefaultRefType(2),
            DefaultRefType(1),
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
    @test pool.invindex["a"] === DefaultRefType(1)
    @test pool.invindex["b"] === DefaultRefType(2)
    @test pool.invindex["c"] === DefaultRefType(3)

    @test isa(pool.order, Vector{DefaultRefType})
    @test length(pool.order) == 3
    @test pool.order[1] === DefaultRefType(3)
    @test pool.order[2] === DefaultRefType(2)
    @test pool.order[3] === DefaultRefType(1)

    for i in 1:3
        y = catvalue(i, pool)

        @test CategoricalArrays.iscatvalue(y) === CategoricalArrays.IsCatValue

        @test isa(y.level, DefaultRefType)
        @test y.level === DefaultRefType(i)

        @test isa(y.pool, CategoricalPool)
        @test y.pool === pool
    end
end
