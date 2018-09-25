module TestConvert
using Compat
using Compat.Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType, level, reftype, leveltype, catvalue, iscatvalue, CatValue

@testset "convert() for CategoricalPool{Int, DefaultRefType} and values" begin
    pool = CategoricalPool([1, 2, 3])
    @test convert(CategoricalPool{Int, DefaultRefType}, pool) === pool
    @test convert(CategoricalPool{Int}, pool) === pool
    @test convert(CategoricalPool, pool) === pool
    convert(CategoricalPool{Float64, UInt8}, pool)
    convert(CategoricalPool{Float64}, pool)
    convert(CategoricalPool, pool)

    v1 = catvalue(1, pool)
    v2 = catvalue(2, pool)
    v3 = catvalue(3, pool)
    @test iscatvalue(v1)
    @test iscatvalue(typeof(v1))
    @test eltype(v1) === Any
    @test eltype(typeof(v1)) === Any
    @test leveltype(v1) === Int
    @test leveltype(typeof(v1)) === Int
    @test reftype(v1) === DefaultRefType
    @test reftype(typeof(v1)) === DefaultRefType
    @test v1 isa CategoricalArrays.CategoricalValue{Int, DefaultRefType}

    @test convert(Int32, v1) === Int32(1)
    @test convert(Int32, v2) === Int32(2)
    @test convert(Int32, v3) === Int32(3)

    @test convert(UInt8, v1) === 0x01
    @test convert(UInt8, v2) === 0x02
    @test convert(UInt8, v3) === 0x03

    @test convert(CategoricalValue, v1) === v1
    @test convert(CategoricalValue{Int}, v1) === v1
    @test convert(CategoricalValue{Int, DefaultRefType}, v1) === v1

    @test convert(Any, v1) === v1
    @test convert(Any, v2) === v2
    @test convert(Any, v3) === v3

    for T in (typeof(v1), CatValue, CategoricalValue), U in (Missing, Nothing)
        @test convert(Union{T, U}, v1) === v1
        @test convert(Union{T, U}, v2) === v2
        @test convert(Union{T, U}, v3) === v3
    end

    @test get(v1) === 1
    @test get(v2) === 2
    @test get(v3) === 3

    @test promote(1, v1) === (1, 1)
    @test promote(1.0, v1) === (1.0, 1.0)
    @test promote(0x1, v1) === (1, 1)

    # Tests that return Any are due to JuliaLang/julia#29348
    # It is not clear what would be the most appropriate promotion type for them,
    # but at least they should not throw an error
    @test promote_type(CategoricalValue{Int}, CategoricalValue{Float64}) ===
        CategoricalValue{Float64}
    @test promote_type(CategoricalValue{Int, UInt8}, CategoricalValue{Float64, UInt32}) ===
        CategoricalValue{Float64, UInt32}
    @test promote_type(CategoricalValue{Int, UInt8}, CategoricalValue{Float64}) ===
        CategoricalValue{Float64}
    @test promote_type(CategoricalValue{Int},
                       Union{CategoricalValue{Float64}, Missing}) ===
        Any
    @test promote_type(CategoricalValue{Int, UInt8},
                       Union{CategoricalValue{Float64, UInt32}, Missing}) ===
        Union{CategoricalValue{Float64, UInt32}, Missing}
    @test promote_type(Union{CategoricalValue{Int}, Missing},
                       CategoricalValue{Float64}) ===
        Any
    @test promote_type(Union{CategoricalValue{Int, UInt8}, Missing},
                       CategoricalValue{Float64, UInt32}) ===
        Union{CategoricalValue{Float64, UInt32}, Missing}
    @test promote_type(Union{CategoricalValue{Int}, Missing},
                       Union{CategoricalValue{Float64}, Missing}) ===
        Any
    @test promote_type(Union{CategoricalValue{Int, UInt8}, Missing},
                       Union{CategoricalValue{Float64, UInt32}, Missing}) ===
        Union{CategoricalValue{Float64, UInt32}, Missing}

    @test promote_type(CategoricalValue, Missing) === Union{CategoricalValue, Missing}
    @test promote_type(CategoricalValue{Int}, Missing) === Union{CategoricalValue{Int}, Missing}
    @test promote_type(CategoricalValue{Int, UInt32}, Missing) ===
        Union{CategoricalValue{Int, UInt32}, Missing}
    @test promote_type(CategoricalValue{Int, UInt32}, Any) === Any

    @test promote_type(CategoricalString{UInt8}, CategoricalString{UInt32}) ===
        CategoricalString{UInt32}
    @test promote_type(CategoricalString, CategoricalString{UInt32}) ===
        CategoricalString
    @test promote_type(Union{CategoricalString{UInt8}, Missing}, CategoricalString{UInt32}) ===
        Union{CategoricalString{UInt32}, Missing}
    @test promote_type(Union{CategoricalString{UInt8}, Missing}, Union{CategoricalString{UInt32}, Missing}) ===
        Union{CategoricalString{UInt32}, Missing}

    @test promote_type(CategoricalString{UInt8}, CategoricalValue{Int, UInt32}) ===
        CategoricalValue{Any, UInt32}
    @test promote_type(Union{CategoricalString{UInt8}, Missing}, CategoricalValue{Int, UInt32}) ===
        Union{CategoricalValue{Any, UInt32}, Missing}
end

@testset "convert() preserves `ordered`" begin
    pool = CategoricalPool([1, 2, 3], true)
    @test convert(CategoricalPool{Float64, UInt8}, pool).ordered === true
end

end
