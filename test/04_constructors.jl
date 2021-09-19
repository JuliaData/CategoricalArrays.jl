module TestConstructors
using Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType

@testset "Type parameter constraints" begin
    # cannot use categorical value as level type
    @test_throws TypeError CategoricalPool{CategoricalValue{Int,UInt8}, UInt8, CategoricalValue{CategoricalValue{Int,UInt8},UInt8}}(
            Dict{CategoricalValue{Int,UInt8}, UInt8}(), false)
    @test_throws TypeError CategoricalPool{CategoricalValue{Int,UInt8}, UInt8, CategoricalValue{CategoricalValue{Int,UInt8},UInt8}}(
                CategoricalValue{Int,UInt8}[], false)
    # cannot use non-categorical value as categorical value type
    @test_throws ArgumentError CategoricalPool{Int, UInt8, Int}(Int[], false)
    @test_throws ArgumentError CategoricalPool{Int, UInt8, Int}(Dict{Int, UInt8}(), false)
    # level type of the pool and categorical value must match
    @test_throws ArgumentError CategoricalPool{Int, UInt8, CategoricalValue{String, UInt8}}(Int[], false)
    @test_throws ArgumentError CategoricalPool{Int, UInt8, CategoricalValue{String, UInt8}}(Dict{Int, UInt8}(), false)
    # reference type of the pool and categorical value must match
    @test_throws ArgumentError CategoricalPool{Int, UInt8, CategoricalValue{Int, UInt16}}(Int[], false)
    @test_throws ArgumentError CategoricalPool{Int, UInt8, CategoricalValue{Int, UInt16}}(Dict{Int, UInt8}(), false)
    # correct types combination
    @test CategoricalPool{Int, UInt8, CategoricalValue{Int, UInt8}}(Int[], false) isa CategoricalPool
    @test CategoricalPool{Int, UInt8, CategoricalValue{Int, UInt8}}(Dict{Int, UInt8}(), false) isa CategoricalPool
end

@testset "empty CategoricalPool{String}" begin
    pool = CategoricalPool{String}()

    @test isa(pool, CategoricalPool{String})

    @test isa(pool.levels, Vector{String})
    @test length(pool.levels) == 0

    @test isa(pool.invindex, Dict{String, DefaultRefType})
    @test length(pool.invindex) == 0
end

@testset "empty CategoricalPool{Int}" begin
    pool = CategoricalPool{Int, UInt8}()

    @test isa(pool, CategoricalPool{Int, UInt8, CategoricalValue{Int, UInt8}})

    @test isa(pool.levels, Vector{Int})
    @test length(pool.levels) == 0

    @test isa(pool.invindex, Dict{Int, UInt8})
    @test length(pool.invindex) == 0
end

@testset "CategoricalPool{String, DefaultRefType}(a b c)" begin
    pool = CategoricalPool(["a", "b", "c"])

    @test isa(pool, CategoricalPool{String, UInt32, CategoricalValue{String, UInt32}})

    @test isa(pool.levels, Vector{String})
    @test pool.levels == ["a", "b", "c"]

    @test isa(pool.invindex, Dict{String, DefaultRefType})
    @test length(pool.invindex) == 3
    @test pool.invindex["a"] === DefaultRefType(1)
    @test pool.invindex["b"] === DefaultRefType(2)
    @test pool.invindex["c"] === DefaultRefType(3)
end

@testset "CategoricalPool{String, UInt8}(a b c)" begin
    pool = CategoricalPool{String, UInt8}(["a", "b", "c"])

    @test isa(pool, CategoricalPool)

    @test isa(pool.levels, Vector{String})
    @test pool.levels == ["a", "b", "c"]

    @test isa(pool.invindex, Dict{String, UInt8})
    @test length(pool.invindex) == 3
    @test pool.invindex["a"] === UInt8(1)
    @test pool.invindex["b"] === UInt8(2)
    @test pool.invindex["c"] === UInt8(3)
end

@testset "CategoricalPool(a b c) with invindex" begin
    pool = CategoricalPool(
        Dict(
            "a" => DefaultRefType(1),
            "b" => DefaultRefType(2),
            "c" => DefaultRefType(3),
        )
    )

    @test isa(pool, CategoricalPool)

    @test isa(pool.levels, Vector{String})
    @test pool.levels == ["a", "b", "c"]

    @test isa(pool.invindex, Dict{String, DefaultRefType})
    @test length(pool.invindex) == 3
    @test pool.invindex["a"] === DefaultRefType(1)
    @test pool.invindex["b"] === DefaultRefType(2)
    @test pool.invindex["c"] === DefaultRefType(3)
end

@testset "CategoricalPool(a b c) with invindex" begin
    pool = CategoricalPool(
        Dict(
            "a" => 1,
            "b" => 2,
            "c" => 3,
        )
    )

    @test isa(pool, CategoricalPool)

    @test isa(pool.levels, Vector{String})
    @test pool.levels == ["a", "b", "c"]

    @test isa(pool.invindex, Dict{String, Int})
    @test length(pool.invindex) == 3
    @test pool.invindex["a"] === 1
    @test pool.invindex["b"] === 2
    @test pool.invindex["c"] === 3
end

@testset "CategoricalPool(c b a)" begin
    pool = CategoricalPool(["c", "b", "a"])

    @test isa(pool, CategoricalPool)

    @test pool.levels == ["c", "b", "a"]

    @test isa(pool.invindex, Dict{String, DefaultRefType})
    @test length(pool.invindex) == 3
    @test pool.invindex["c"] === DefaultRefType(1)
    @test pool.invindex["b"] === DefaultRefType(2)
    @test pool.invindex["a"] === DefaultRefType(3)
end

@testset "CategoricalPool(a b c) with ref codes not matching the natural order" begin
    pool = CategoricalPool(
        Dict(
            "a" => DefaultRefType(3),
            "b" => DefaultRefType(2),
            "c" => DefaultRefType(1),
        )
    )

    @test isa(pool, CategoricalPool)

    @test pool.levels == ["c", "b", "a"]

    @test isa(pool.invindex, Dict{String, DefaultRefType})
    @test length(pool.invindex) == 3
    @test pool.invindex["c"] === DefaultRefType(1)
    @test pool.invindex["b"] === DefaultRefType(2)
    @test pool.invindex["a"] === DefaultRefType(3)
end

@testset "CategoricalPool{Float64, UInt8}()" begin
    pool = CategoricalPool{Float64, UInt8}([1.0, 2.0, 3.0])

    @test isa(pool, CategoricalPool{Float64, UInt8, CategoricalValue{Float64, UInt8}})
    @test CategoricalValue(pool, 1) isa CategoricalValue{Float64, UInt8}
end

@testset "Invalid arguments" begin
    @test_throws ArgumentError CategoricalPool(Dict("a" => 1, "b" => 3))
    @test_throws ArgumentError CategoricalPool(["a", "a"])
end

@testset "Constructor with various vector types" begin
    @test CategoricalPool(2:4) == CategoricalPool(2.0:4.0) ==
        CategoricalPool([2, 3, 4])
    @test CategoricalPool(2:4, true) == CategoricalPool(2.0:4.0, true) ==
        CategoricalPool([2, 3, 4], true)
end

end