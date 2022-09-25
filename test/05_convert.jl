module TestConvert
using Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType, refcode, reftype, leveltype

@testset "convert() for CategoricalPool{Int, DefaultRefType} and values" begin
    pool = CategoricalPool([1, 2, 3])
    @test convert(CategoricalPool{Int, DefaultRefType}, pool) === pool
    @test convert(CategoricalPool{Int}, pool) === pool
    @test convert(CategoricalPool, pool) === pool
    convert(CategoricalPool{Float64, UInt8}, pool)
    convert(CategoricalPool{Float64}, pool)
    convert(CategoricalPool, pool)

    v1 = CategoricalValue(pool, 1)
    v2 = CategoricalValue(pool, 2)
    v3 = CategoricalValue(pool, 3)
    @test eltype(v1) === Any
    @test eltype(typeof(v1)) === Any
    @test leveltype(v1) === Int
    @test leveltype(typeof(v1)) === Int
    @test reftype(v1) === DefaultRefType
    @test reftype(typeof(v1)) === DefaultRefType
    @test v1 isa CategoricalArrays.CategoricalValue{Int, DefaultRefType}

    @test convert(Int, v1) === 1
    @test convert(Int, v2) === 2
    @test convert(Int, v3) === 3

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

    for T in (typeof(v1), CategoricalValue{Int}, CategoricalValue), U in (Missing, Nothing)
        @test convert(Union{T, U}, v1) === v1
        @test convert(Union{T, U}, v2) === v2
        @test convert(Union{T, U}, v3) === v3
    end

    for T in (Int, Int8, Float64), U in (Missing, Nothing)
        @test convert(Union{T, U}, v1)::T == v1
        @test convert(Union{T, U}, v2)::T == v2
        @test convert(Union{T, U}, v3)::T == v3
    end

    @test unwrap(v1) === get(v1) === 1
    @test unwrap(v2) === get(v2) === 2
    @test unwrap(v3) === get(v3) === 3

    @test promote(1, v1) === (1, 1)
    @test promote(1.0, v1) === (1.0, 1.0)
    @test promote(0x1, v1) === (1, 1)
end

@testset "promote_type" begin
    @test promote_type(CategoricalValue{Int}, CategoricalValue{Float64}) ===
        CategoricalValue{Float64}
    @test promote_type(CategoricalValue{Int, UInt8}, CategoricalValue{Float64, UInt32}) ===
        CategoricalValue{Float64, UInt32}
    @test promote_type(CategoricalValue{Int, UInt8}, CategoricalValue{Float64}) ===
        CategoricalValue{Float64}
    @test promote_type(CategoricalValue{Int, UInt8}, CategoricalValue{String}) ===
        CategoricalValue{Union{Int, String}}
    # Tests that return Any before Julia 1.3 are due to JuliaLang/julia#29348
    if VERSION >= v"1.3.0-DEV"
        @test promote_type(CategoricalValue{Int},
                           Union{CategoricalValue{Float64}, Missing}) ===
            Union{CategoricalValue{Float64}, Missing}
        @test promote_type(CategoricalValue{Int},
                           Union{CategoricalValue{String}, Missing}) ===
            Union{CategoricalValue{Union{Int, String}}, Missing}
        @test promote_type(CategoricalValue{Int, UInt8},
                           Union{CategoricalValue{Float64, UInt32}, Missing}) ===
            Union{CategoricalValue{Float64, UInt32}, Missing}
        @test promote_type(CategoricalValue{Int, UInt8},
                           Union{CategoricalValue{String, UInt32}, Missing}) ===
            Union{CategoricalValue{Union{Int, String}, UInt32}, Missing}
        @test promote_type(Union{CategoricalValue{Int}, Missing},
                           CategoricalValue{Float64}) ===
            Union{CategoricalValue{Float64}, Missing}
        @test promote_type(Union{CategoricalValue{Int}, Missing},
                           CategoricalValue{String}) ===
            Union{CategoricalValue{Union{Int, String}}, Missing}
        @test promote_type(Union{CategoricalValue{Int, UInt8}, Missing},
                           CategoricalValue{Float64, UInt32}) ===
            Union{CategoricalValue{Float64, UInt32}, Missing}
        @test promote_type(Union{CategoricalValue{Int, UInt8}, Missing},
                           CategoricalValue{String, UInt32}) ===
            Union{CategoricalValue{Union{Int, String}, UInt32}, Missing}
        @test promote_type(Union{CategoricalValue{Int}, Missing},
                           Union{CategoricalValue{Float64}, Missing}) ===
            Union{CategoricalValue{Float64}, Missing}
        @test promote_type(Union{CategoricalValue{Int}, Missing},
                           Union{CategoricalValue{String}, Missing}) ===
            Union{CategoricalValue{Union{Int, String}}, Missing}
    else
        @test promote_type(CategoricalValue{Int},
                           Union{CategoricalValue{Float64}, Missing}) ===
            Union{CategoricalValue{Float64}, Missing}
        @test promote_type(CategoricalValue{Int},
                           Union{CategoricalValue{String}, Missing}) ===
            Union{CategoricalValue{Union{Int, String}}, Missing}
        @test promote_type(CategoricalValue{Int, UInt8},
                           Union{CategoricalValue{Float64, UInt32}, Missing}) ===
            Union{CategoricalValue{Float64, UInt32}, Missing}
        @test promote_type(CategoricalValue{Int, UInt8},
                           Union{CategoricalValue{String, UInt32}, Missing}) ===
            Union{CategoricalValue{Union{Int, String}, UInt32}, Missing}
        @test promote_type(Union{CategoricalValue{Int}, Missing},
                           CategoricalValue{Float64}) ===
            Union{CategoricalValue{Float64}, Missing}
        @test promote_type(Union{CategoricalValue{Int}, Missing},
                           CategoricalValue{String}) ===
            Union{CategoricalValue{Union{Int, String}}, Missing}
        @test promote_type(Union{CategoricalValue{Int, UInt8}, Missing},
                           CategoricalValue{Float64, UInt32}) ===
            Union{CategoricalValue{Float64, UInt32}, Missing}
        @test promote_type(Union{CategoricalValue{Int, UInt8}, Missing},
                           CategoricalValue{String, UInt32}) ===
            Union{CategoricalValue{Union{Int, String}, UInt32}, Missing}
        @test promote_type(Union{CategoricalValue{Int}, Missing},
                           Union{CategoricalValue{Float64}, Missing}) ===
            Any
        @test promote_type(Union{CategoricalValue{Int}, Missing},
                           Union{CategoricalValue{String}, Missing}) ===
            Any
    end
    @test promote_type(Union{CategoricalValue{Int, UInt8}, Missing},
                       Union{CategoricalValue{Float64, UInt32}, Missing}) ===
        Union{CategoricalValue{Float64, UInt32}, Missing}
    @test promote_type(Union{CategoricalValue{Int, UInt8}, Missing},
                       Union{CategoricalValue{String, UInt32}, Missing}) ===
        Union{CategoricalValue{Union{Int, String}, UInt32}, Missing}

    @test promote_type(CategoricalValue, Missing) === Union{CategoricalValue, Missing}
    @test promote_type(CategoricalValue{Int}, Missing) === Union{CategoricalValue{Int}, Missing}
    @test promote_type(CategoricalValue{Int, UInt32}, Missing) ===
        Union{CategoricalValue{Int, UInt32}, Missing}
    @test promote_type(CategoricalValue{Int, UInt32}, Any) === Any
end

@testset "convert() preserves `ordered`" begin
    pool = CategoricalPool([1, 2, 3], true)
    @test convert(CategoricalPool{Float64, UInt8}, pool).ordered === true
end

@testset "levelcode" begin
    pool = CategoricalPool{Int,UInt8}([2, 1, 3])
    for i in 1:3
        v = CategoricalValue(pool, i)
        @test levelcode(v) isa Int16
        @test levels(pool)[levelcode(v)] == v
    end

    @test levelcode(missing) === missing
end


end
