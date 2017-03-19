module TestConvert
    using Base.Test
    using CategoricalArrays

    pool = CategoricalPool([1, 2, 3])
    @test convert(CategoricalPool{Int, CategoricalArrays.DefaultRefType}, pool) === pool
    @test convert(CategoricalPool{Int}, pool) === pool
    @test convert(CategoricalPool, pool) === pool
    convert(CategoricalPool{Float64, UInt8}, pool)
    convert(CategoricalPool{Float64}, pool)
    convert(CategoricalPool, pool)

    v1 = CategoricalValue(1, pool)
    v2 = CategoricalValue(2, pool)
    v3 = CategoricalValue(3, pool)

    convert(Int32, v1)
    convert(Int32, v2)
    convert(Int32, v3)

    convert(UInt8, v1)
    convert(UInt8, v2)
    convert(UInt8, v3)

    @test get(v1) === 1
    @test get(v2) === 2
    @test get(v3) === 3

    @test promote(1, v1) === (1, 1)
    @test promote(1.0, v1) === (1.0, 1.0)
    @test promote(0x1, v1) === (1, 1)

    # Test that ordered property is preserved
    pool = CategoricalPool([1, 2, 3], true)
    @test convert(CategoricalPool{Float64, UInt8}, pool).ordered === true
end
