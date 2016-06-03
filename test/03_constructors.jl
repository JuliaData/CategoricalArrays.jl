module TestConstructors
    using Base.Test
    using CategoricalData

    for P in (NominalPool, OrdinalPool)
        pool = P(["a", "b", "c"])

        @test isa(pool, P)

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

        pool = P(
            Dict(
                "a" => convert(CategoricalData.RefType, 1),
                "b" => convert(CategoricalData.RefType, 2),
                "c" => convert(CategoricalData.RefType, 3),
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
        @test pool.invindex["a"] === convert(CategoricalData.RefType, 1)
        @test pool.invindex["b"] === convert(CategoricalData.RefType, 2)
        @test pool.invindex["c"] === convert(CategoricalData.RefType, 3)

        # TODO: Make sure that invindex input is exhaustive
        # Raise an error if map misses any entries
        pool = P(
            Dict(
                "a" => 1,
                "b" => 2,
                "c" => 3,
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
        @test pool.invindex["a"] === convert(CategoricalData.RefType, 1)
        @test pool.invindex["b"] === convert(CategoricalData.RefType, 2)
        @test pool.invindex["c"] === convert(CategoricalData.RefType, 3)

        pool = P(["c", "b", "a"])

        @test isa(pool, P)

        @test length(pool.index) == 3
        @test pool.index[1] == "c"
        @test pool.index[2] == "b"
        @test pool.index[3] == "a"

        @test isa(pool.invindex, Dict)
        @test length(pool.invindex) == 3
        @test pool.invindex["c"] === convert(CategoricalData.RefType, 1)
        @test pool.invindex["b"] === convert(CategoricalData.RefType, 2)
        @test pool.invindex["a"] === convert(CategoricalData.RefType, 3)

        @test isa(pool.order, Vector{CategoricalData.RefType})
        @test length(pool.order) == 3
        @test pool.order[1] === convert(CategoricalData.RefType, 3)
        @test pool.order[2] === convert(CategoricalData.RefType, 2)
        @test pool.order[3] === convert(CategoricalData.RefType, 1)

        pool = P(
            Dict(
                "a" => convert(CategoricalData.RefType, 3),
                "b" => convert(CategoricalData.RefType, 2),
                "c" => convert(CategoricalData.RefType, 1),
            )
        )

        @test isa(pool, P)

        @test isa(pool, CategoricalPool)
        @test length(pool.index) == 3
        @test pool.index[1] == "c"
        @test pool.index[2] == "b"
        @test pool.index[3] == "a"

        @test isa(pool.invindex, Dict)
        @test length(pool.invindex) == 3
        @test pool.invindex["c"] === convert(CategoricalData.RefType, 1)
        @test pool.invindex["b"] === convert(CategoricalData.RefType, 2)
        @test pool.invindex["a"] === convert(CategoricalData.RefType, 3)

        @test isa(pool.order, Vector{CategoricalData.RefType})
        @test length(pool.order) == 3
        @test pool.order[1] === convert(CategoricalData.RefType, 3)
        @test pool.order[2] === convert(CategoricalData.RefType, 2)
        @test pool.order[3] === convert(CategoricalData.RefType, 1)

        pool = P(["c", "b", "a"], ["c", "b", "a"])

        @test isa(pool, P)

        @test length(pool.index) == 3
        @test pool.index[1] == "c"
        @test pool.index[2] == "b"
        @test pool.index[3] == "a"

        @test isa(pool.invindex, Dict)
        @test length(pool.invindex) == 3
        @test pool.invindex["c"] === convert(CategoricalData.RefType, 1)
        @test pool.invindex["b"] === convert(CategoricalData.RefType, 2)
        @test pool.invindex["a"] === convert(CategoricalData.RefType, 3)

        @test isa(pool.order, Vector{CategoricalData.RefType})
        @test length(pool.order) == 3
        @test pool.order[1] === convert(CategoricalData.RefType, 1)
        @test pool.order[2] === convert(CategoricalData.RefType, 2)
        @test pool.order[3] === convert(CategoricalData.RefType, 3)

        pool = P(
            Dict(
                "a" => convert(CategoricalData.RefType, 3),
                "b" => convert(CategoricalData.RefType, 2),
                "c" => convert(CategoricalData.RefType, 1),
            ),
            ["c", "b", "a"]
        )

        @test isa(pool, P)

        @test length(pool.index) == 3
        @test pool.index[1] == "c"
        @test pool.index[2] == "b"
        @test pool.index[3] == "a"

        @test isa(pool.invindex, Dict)
        @test length(pool.invindex) == 3
        @test pool.invindex["c"] === convert(CategoricalData.RefType, 1)
        @test pool.invindex["b"] === convert(CategoricalData.RefType, 2)
        @test pool.invindex["a"] === convert(CategoricalData.RefType, 3)

        @test isa(pool.order, Vector{CategoricalData.RefType})
        @test length(pool.order) == 3
        @test pool.order[1] === convert(CategoricalData.RefType, 1)
        @test pool.order[2] === convert(CategoricalData.RefType, 2)
        @test pool.order[3] === convert(CategoricalData.RefType, 3)
    end
end
