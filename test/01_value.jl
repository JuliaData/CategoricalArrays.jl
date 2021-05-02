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
        x = CategoricalValue(i, pool)

        @test leveltype(x) === String
        @test leveltype(typeof(x)) === String
        @test reftype(x) === DefaultRefType
        @test reftype(typeof(x)) === DefaultRefType
        @test x isa CategoricalValue{String, DefaultRefType}

        @test refcode(x) === DefaultRefType(i)
        @test CategoricalArrays.pool(x) === pool

        @test typeof(x)(x) === x
        @test CategoricalValue(UInt8(i), pool) == x
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
        x = CategoricalValue(i, pool)

        @test leveltype(x) === String
        @test leveltype(typeof(x)) === String
        @test reftype(x) === UInt8
        @test reftype(typeof(x)) === UInt8
        @test x isa CategoricalValue{String, UInt8}

        @test refcode(x) === UInt8(i)
        @test CategoricalArrays.pool(x) === pool

        @test typeof(x)(x) === x
        @test CategoricalValue(UInt32(i), pool) == x
    end
end

end
