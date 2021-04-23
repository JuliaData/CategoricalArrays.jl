module TestValue
using Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType, refcode,  reftype, leveltype

@testset "leveltype on non CategoricalValue types" begin
    @test leveltype("abc") === String
    @test leveltype(String) === String
    @test leveltype(1.0) === Float64
    @test leveltype(Float64) === Float64
end

@testset "CategoricalValue on DefaultRefType pool in sorted order" begin
    pool = CategoricalPool(
        Dict(
            "a" => DefaultRefType(1),
            "b" => DefaultRefType(2),
            "c" => DefaultRefType(3),
        )
    )

    for i in 1:3
        x = CategoricalValue(pool, i)

        @test leveltype(x) === String
        @test leveltype(typeof(x)) === String
        @test reftype(x) === DefaultRefType
        @test reftype(typeof(x)) === DefaultRefType
        @test x isa CategoricalValue{String, DefaultRefType}

        @test refcode(x) === DefaultRefType(i)
        @test CategoricalArrays.pool(x) === pool

        @test typeof(x)(x) === x
        @test CategoricalValue(pool, UInt8(i)) == x
    end
end

@testset "CategoricalValue on UInt8 pool in custom order" begin
    pool = CategoricalPool(
        Dict(
            "a" => UInt8(3),
            "b" => UInt8(2),
            "c" => UInt8(1),
        )
    )

    for i in 1:3
        x = CategoricalValue(pool, i)

        @test leveltype(x) === String
        @test leveltype(typeof(x)) === String
        @test reftype(x) === UInt8
        @test reftype(typeof(x)) === UInt8
        @test x isa CategoricalValue{String, UInt8}

        @test refcode(x) === UInt8(i)
        @test CategoricalArrays.pool(x) === pool

        @test typeof(x)(x) === x
        @test CategoricalValue(pool, UInt32(i)) == x
    end
end

@testset "constructor from other value" begin
    pool = CategoricalPool([2, 3, 1])
    arr = CategoricalVector{Int}(DefaultRefType[2, 1, 3], pool)
    for x in (CategoricalValue(pool, 1), arr, view(arr, 2:3))
        for (i, v) in enumerate(levels(pool))
            @test CategoricalValue(v, x) ===
                CategoricalValue(float(v), x) ===
                CategoricalValue(CategoricalValue(pool, i), x) ===
                CategoricalValue(pool, i)
        end

        @test_throws ArgumentError CategoricalValue(4, x)
        @test_throws ArgumentError CategoricalValue(missing, x)
    end
end

end
