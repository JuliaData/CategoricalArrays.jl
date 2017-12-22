module TestConstructors
using Compat
using Compat.Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType, catvalue

@testset "Type parameter constraints" begin
    # cannot use categorical value as level type
    @test_throws ArgumentError CategoricalPool{CategoricalValue{Int,UInt8}, UInt8, CategoricalValue{CategoricalValue{Int,UInt8},UInt8}}(
            CategoricalValue{Int,UInt8}[], Dict{CategoricalValue{Int,UInt8}, UInt8}(), UInt8[], false)
    # cannot use non-categorical value as categorical value type
    @test_throws ArgumentError CategoricalPool{Int, UInt8, Int}(Int[], Dict{Int, UInt8}(), UInt8[], false)
    # level type of the pool and categorical value should match
    @test_throws ArgumentError CategoricalPool{Int, UInt8, CategoricalString{UInt8}}(Int[], Dict{Int, UInt8}(), UInt8[], false)
    # reference type of the pool and categorical value should match
    @test_throws ArgumentError CategoricalPool{Int, UInt8, CategoricalValue{Int, UInt16}}(Int[], Dict{Int, UInt8}(), UInt8[], false)
    # correct types combination
    @test CategoricalPool{Int, UInt8, CategoricalValue{Int, UInt8}}(Int[], Dict{Int, UInt8}(), UInt8[], false) isa CategoricalPool
end

@testset "empty CategoricalPool{String}" begin
    pool = CategoricalPool{String}()

    @test isa(pool, CategoricalPool{String})

    @test isa(pool.index, Vector{String})
    @test length(pool.index) == 0

    @test isa(pool.invindex, Dict{String, DefaultRefType})
    @test length(pool.invindex) == 0
end

@testset "empty CategoricalPool{Int}" begin
    pool = CategoricalPool{Int, UInt8}()

    @test isa(pool, CategoricalPool{Int, UInt8, CategoricalValue{Int, UInt8}})

    @test isa(pool.index, Vector{Int})
    @test length(pool.index) == 0

    @test isa(pool.invindex, Dict{Int, UInt8})
    @test length(pool.invindex) == 0
end

@testset "CategoricalPool{String, DefaultRefType}(a b c)" begin
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
end

@testset "CategoricalPool{String, UInt8}(a b c)" begin
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
end

@testset "CategoricalPool(a b c) with specified reference codes" begin
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
end

@testset "CategoricalPool(a b c) with specified Int ref codes" begin
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
end

@testset "CategoricalPool(c b a)" begin
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

@testset "CategoricalPool(a b c) with specified levels order" begin
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
end

@testset "CategoricalPool(a b c) with specified index and levels order" begin
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
end

@testset "CategoricalPool{Float64, UInt8}()" begin
    pool = CategoricalPool{Float64, UInt8}([1.0, 2.0, 3.0])

    @test isa(pool, CategoricalPool{Float64, UInt8, CategoricalValue{Float64, UInt8}})
    @test catvalue(1, pool) isa CategoricalValue{Float64, UInt8}
end

end
