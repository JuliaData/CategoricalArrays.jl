module TestTypeDef
    using Base.Test
    using CategoricalArrays
    using CategoricalArrays: DefaultRefType

    for (P, V) in ((NominalPool, NominalValue), (OrdinalPool, OrdinalValue))
        pool = P(
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

        @test isa(pool, P)

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
            x = V(i, pool)

            @test isa(x, V)

            @test isa(x.level, DefaultRefType)
            @test x.level === DefaultRefType(i)

            @test isa(x.pool, P)
            @test x.pool === pool
        end

        pool = P(
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

        @test isa(pool, P)

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
            y = V(i, pool)

            @test isa(y, V)

            @test isa(y.level, DefaultRefType)
            @test y.level === DefaultRefType(i)

            @test isa(y.pool, P)
            @test y.pool === pool
        end
    end
end
