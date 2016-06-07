module TestConstructors
    using Base.Test
    using CategoricalData
    using CategoricalData: DefaultRefType

    for P in (NominalPool, OrdinalPool)
        pool = P{String}()

        @test isa(pool, P{String})

        @test isa(pool.index, Vector{String})
        @test length(pool.index) == 0

        @test isa(pool.invindex, Dict{String, DefaultRefType})
        @test length(pool.invindex) == 0

        pool = P{Int, UInt8}()

        @test isa(pool, P{Int, UInt8})

        @test isa(pool.index, Vector{Int})
        @test length(pool.index) == 0

        @test isa(pool.invindex, Dict{Int, UInt8})
        @test length(pool.invindex) == 0

        pool = P(["a", "b", "c"])

        @test isa(pool, P)

        @test isa(pool.index, Vector{String})
        @test length(pool.index) == 3
        @test pool.index[1] == "a"
        @test pool.index[2] == "b"
        @test pool.index[3] == "c"

        @test isa(pool.invindex, Dict{String, DefaultRefType})
        @test length(pool.invindex) == 3
        @test pool.invindex["a"] === DefaultRefType(1)
        @test pool.invindex["b"] === DefaultRefType(2)
        @test pool.invindex["c"] === DefaultRefType(3)

        pool = P(
            Dict(
                "a" => DefaultRefType(1),
                "b" => DefaultRefType(2),
                "c" => DefaultRefType(3),
            )
        )

        @test isa(pool, P)

        @test isa(pool.index, Vector{String})
        @test length(pool.index) == 3
        @test pool.index[1] == "a"
        @test pool.index[2] == "b"
        @test pool.index[3] == "c"

        @test isa(pool.invindex, Dict{String, DefaultRefType})
        @test length(pool.invindex) == 3
        @test pool.invindex["a"] === DefaultRefType(1)
        @test pool.invindex["b"] === DefaultRefType(2)
        @test pool.invindex["c"] === DefaultRefType(3)

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

        @test isa(pool.index, Vector{String})
        @test length(pool.index) == 3
        @test pool.index[1] == "a"
        @test pool.index[2] == "b"
        @test pool.index[3] == "c"

        @test isa(pool.invindex, Dict{String, DefaultRefType})
        @test length(pool.invindex) == 3
        @test pool.invindex["a"] === DefaultRefType(1)
        @test pool.invindex["b"] === DefaultRefType(2)
        @test pool.invindex["c"] === DefaultRefType(3)

        pool = P(["c", "b", "a"])

        @test isa(pool, P)

        @test length(pool.index) == 3
        @test pool.index[1] == "c"
        @test pool.index[2] == "b"
        @test pool.index[3] == "a"

        @test isa(pool.invindex, Dict{String, DefaultRefType})
        @test length(pool.invindex) == 3
        @test pool.invindex["c"] === DefaultRefType(1)
        @test pool.invindex["b"] === DefaultRefType(2)
        @test pool.invindex["a"] === DefaultRefType(3)

        @test isa(pool.order, Vector{DefaultRefType})
        @test length(pool.order) == 3
        @test pool.order[1] === DefaultRefType(3)
        @test pool.order[2] === DefaultRefType(2)
        @test pool.order[3] === DefaultRefType(1)

        pool = P(
            Dict(
                "a" => DefaultRefType(3),
                "b" => DefaultRefType(2),
                "c" => DefaultRefType(1),
            )
        )

        @test isa(pool, P)

        @test isa(pool, CategoricalPool)
        @test length(pool.index) == 3
        @test pool.index[1] == "c"
        @test pool.index[2] == "b"
        @test pool.index[3] == "a"

        @test isa(pool.invindex, Dict{String, DefaultRefType})
        @test length(pool.invindex) == 3
        @test pool.invindex["c"] === DefaultRefType(1)
        @test pool.invindex["b"] === DefaultRefType(2)
        @test pool.invindex["a"] === DefaultRefType(3)

        @test isa(pool.order, Vector{DefaultRefType})
        @test length(pool.order) == 3
        @test pool.order[1] === DefaultRefType(3)
        @test pool.order[2] === DefaultRefType(2)
        @test pool.order[3] === DefaultRefType(1)

        pool = P(["c", "b", "a"], ["c", "b", "a"])

        @test isa(pool, P)

        @test length(pool.index) == 3
        @test pool.index[1] == "c"
        @test pool.index[2] == "b"
        @test pool.index[3] == "a"

        @test isa(pool.invindex, Dict{String, DefaultRefType})
        @test length(pool.invindex) == 3
        @test pool.invindex["c"] === DefaultRefType(1)
        @test pool.invindex["b"] === DefaultRefType(2)
        @test pool.invindex["a"] === DefaultRefType(3)

        @test isa(pool.order, Vector{DefaultRefType})
        @test length(pool.order) == 3
        @test pool.order[1] === DefaultRefType(1)
        @test pool.order[2] === DefaultRefType(2)
        @test pool.order[3] === DefaultRefType(3)

        pool = P(
            Dict(
                "a" => DefaultRefType(3),
                "b" => DefaultRefType(2),
                "c" => DefaultRefType(1),
            ),
            ["c", "b", "a"]
        )

        @test isa(pool, P)

        @test length(pool.index) == 3
        @test pool.index[1] == "c"
        @test pool.index[2] == "b"
        @test pool.index[3] == "a"

        @test isa(pool.invindex, Dict{String, DefaultRefType})
        @test length(pool.invindex) == 3
        @test pool.invindex["c"] === DefaultRefType(1)
        @test pool.invindex["b"] === DefaultRefType(2)
        @test pool.invindex["a"] === DefaultRefType(3)

        @test isa(pool.order, Vector{DefaultRefType})
        @test length(pool.order) == 3
        @test pool.order[1] === DefaultRefType(1)
        @test pool.order[2] === DefaultRefType(2)
        @test pool.order[3] === DefaultRefType(3)
    end
end
