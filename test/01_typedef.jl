module TestTypeDef
using Compat
using Compat.Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType, level,  reftype, leveltype

@testset "CategoricalPool, a b c order" begin
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

    @test leveltype("abc") === String
    @test leveltype(String) === String
    @test leveltype(1.0) === Float64
    @test leveltype(Float64) === Float64

    for i in 1:3
        x = CategoricalValue(i, pool)

        @test leveltype(x) === String
        @test leveltype(typeof(x)) === String
        @test reftype(x) === DefaultRefType
        @test reftype(typeof(x)) === DefaultRefType
        @test x isa CategoricalValue{String, DefaultRefType}

        @test isa(level(x), DefaultRefType)
        @test level(x) === DefaultRefType(i)

        @test isa(CategoricalArrays.pool(x), CategoricalPool)
        @test CategoricalArrays.pool(x) === pool

        @test typeof(x)(x) === x

        @test CategoricalValue(UInt8(i), pool) == x
    end
end

@testset "CategoricalPool, c b a order" begin
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
        y = CategoricalValue(i, pool)

        @test isa(level(y), DefaultRefType)
        @test level(y) === DefaultRefType(i)

        @test isa(CategoricalArrays.pool(y), CategoricalPool)
        @test CategoricalArrays.pool(y) === pool

        @test typeof(y)(y) === y

        @test CategoricalValue(UInt8(i), pool) == y
    end
end

end
