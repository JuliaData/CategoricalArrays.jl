module TestConstructors
    using Base.Test
    using CategoricalArrays
    using CategoricalArrays: DefaultRefType, catvalue

    pool = CategoricalPool{String}()

    @test isa(pool, CategoricalPool{String})

    @test isa(pool.index, Vector{String})
    @test length(pool.index) == 0

    @test isa(pool.invindex, Dict{String, DefaultRefType})
    @test length(pool.invindex) == 0

    pool = CategoricalPool{Int, UInt8}()

    @test isa(pool, CategoricalPool{Int, UInt8, CategoricalValue{Int, UInt8}})

    @test isa(pool.index, Vector{Int})
    @test length(pool.index) == 0

    @test isa(pool.invindex, Dict{Int, UInt8})
    @test length(pool.invindex) == 0

    pool = CategoricalPool(["a", "b", "c"])

    @test isa(pool, CategoricalPool{String, UInt32, CategoricalString{UInt32}})

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

    pool = CategoricalPool{String, UInt8}(["a", "b", "c"])

    @test isa(pool, CategoricalPool)

    @test isa(pool.index, Vector{String})
    @test length(pool.index) == 3
    @test pool.index[1] == "a"
    @test pool.index[2] == "b"
    @test pool.index[3] == "c"

    @test isa(pool.invindex, Dict{String, UInt8})
    @test length(pool.invindex) == 3
    @test pool.invindex["a"] === UInt8(1)
    @test pool.invindex["b"] === UInt8(2)
    @test pool.invindex["c"] === UInt8(3)

    pool = CategoricalPool(
        Dict(
            "a" => DefaultRefType(1),
            "b" => DefaultRefType(2),
            "c" => DefaultRefType(3),
        )
    )

    @test isa(pool, CategoricalPool)

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
    pool = CategoricalPool(
        Dict(
            "a" => 1,
            "b" => 2,
            "c" => 3,
        )
    )

    @test isa(pool, CategoricalPool)

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

    pool = CategoricalPool(["c", "b", "a"])

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
    @test pool.order[1] === DefaultRefType(1)
    @test pool.order[2] === DefaultRefType(2)
    @test pool.order[3] === DefaultRefType(3)

    pool = CategoricalPool(
        Dict(
            "a" => DefaultRefType(3),
            "b" => DefaultRefType(2),
            "c" => DefaultRefType(1),
        )
    )

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
    @test pool.order[1] === DefaultRefType(1)
    @test pool.order[2] === DefaultRefType(2)
    @test pool.order[3] === DefaultRefType(3)

    pool = CategoricalPool(["c", "b", "a"], ["c", "b", "a"])

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
    @test pool.order[1] === DefaultRefType(1)
    @test pool.order[2] === DefaultRefType(2)
    @test pool.order[3] === DefaultRefType(3)

    pool = CategoricalPool(
        Dict(
            "a" => DefaultRefType(3),
            "b" => DefaultRefType(2),
            "c" => DefaultRefType(1),
        ),
        ["c", "b", "a"]
    )

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
    @test pool.order[1] === DefaultRefType(1)
    @test pool.order[2] === DefaultRefType(2)
    @test pool.order[3] === DefaultRefType(3)

    # test floating point pool
    pool = CategoricalPool{Float64, UInt8}([1.0, 2.0, 3.0])

    @test isa(pool, CategoricalPool{Float64, UInt8, CategoricalValue{Float64, UInt8}})
    @test catvalue(1, pool) isa CategoricalValue{Float64, UInt8}
end
