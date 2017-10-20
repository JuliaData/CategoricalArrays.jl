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

    v1 = CategoricalArrays.catvalue(1, pool)
    v2 = CategoricalArrays.catvalue(2, pool)
    v3 = CategoricalArrays.catvalue(3, pool)

    @test convert(Int32, v1) === Int32(1)
    @test convert(Int32, v2) === Int32(2)
    @test convert(Int32, v3) === Int32(3)

    @test convert(UInt8, v1) === 0x01
    @test convert(UInt8, v2) === 0x02
    @test convert(UInt8, v3) === 0x03

    @test convert(CategoricalValue, v1) === v1
    @test convert(CategoricalValue{Int}, v1) === v1
    @test convert(CategoricalValue{Int, CategoricalArrays.DefaultRefType}, v1) === v1
    @test convert(Any, v1) === v1

    convert(Any, v1)
    convert(Any, v2)
    convert(Any, v3)

    @test get(v1) === 1
    @test get(v2) === 2
    @test get(v3) === 3

    @test promote(1, v1) === (1, 1)
    @test promote(1.0, v1) === (1.0, 1.0)
    @test promote(0x1, v1) === (1, 1)

    @test promote_type(CategoricalValue, Null) === Union{CategoricalValue, Null}
    @test promote_type(CategoricalValue{Int}, Null) === Union{CategoricalValue{Int}, Null}
    @test promote_type(CategoricalValue{Int, UInt32}, Null) ===
        Union{CategoricalValue{Int, UInt32}, Null}

    # Test that ordered property is preserved
    pool = CategoricalPool([1, 2, 3], true)
    @test convert(CategoricalPool{Float64, UInt8}, pool).ordered === true
end
