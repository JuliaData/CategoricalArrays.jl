module TestIsLess
using Compat
using Compat.Test
using CategoricalArrays

pool = CategoricalPool([1, 2, 3])

v1 = CategoricalArrays.catvalue(1, pool)
v2 = CategoricalArrays.catvalue(2, pool)
v3 = CategoricalArrays.catvalue(3, pool)

@testset "values from unordered CategoricalPool" begin
    @test_throws ArgumentError v1 < v1
    @test_throws ArgumentError v1 < v2
    @test_throws ArgumentError v1 < v3
    @test_throws ArgumentError v2 < v1
    @test_throws ArgumentError v2 < v2
    @test_throws ArgumentError v2 < v3
    @test_throws ArgumentError v3 < v1
    @test_throws ArgumentError v3 < v2
    @test_throws ArgumentError v3 < v3

    @test_throws ArgumentError v1 <= v1
    @test_throws ArgumentError v1 <= v2
    @test_throws ArgumentError v1 <= v3
    @test_throws ArgumentError v2 <= v1
    @test_throws ArgumentError v2 <= v2
    @test_throws ArgumentError v2 <= v3
    @test_throws ArgumentError v3 <= v1
    @test_throws ArgumentError v3 <= v2
    @test_throws ArgumentError v3 <= v3

    @test_throws ArgumentError v1 > v1
    @test_throws ArgumentError v1 > v2
    @test_throws ArgumentError v1 > v3
    @test_throws ArgumentError v2 > v1
    @test_throws ArgumentError v2 > v2
    @test_throws ArgumentError v2 > v3
    @test_throws ArgumentError v3 > v1
    @test_throws ArgumentError v3 > v2
    @test_throws ArgumentError v3 > v3

    @test_throws ArgumentError v1 >= v1
    @test_throws ArgumentError v1 >= v2
    @test_throws ArgumentError v1 >= v3
    @test_throws ArgumentError v2 >= v1
    @test_throws ArgumentError v2 >= v2
    @test_throws ArgumentError v2 >= v3
    @test_throws ArgumentError v3 >= v1
    @test_throws ArgumentError v3 >= v2
    @test_throws ArgumentError v3 >= v3

    @test isless(v1, v1) === false
    @test isless(v1, v2) === true
    @test isless(v1, v3) === true
    @test isless(v2, v1) === false
    @test isless(v2, v2) === false
    @test isless(v2, v3) === true
    @test isless(v3, v1) === false
    @test isless(v3, v2) === false
    @test isless(v3, v3) === false

    @testset "comparison with missing" begin
        @test isless(v1, missing)
        @test !isless(missing, v1)
        @test ismissing(v1 < missing)
        @test ismissing(v1 <= missing)
        @test ismissing(v1 > missing)
        @test ismissing(v1 >= missing)
        @test ismissing(missing < v1)
        @test ismissing(missing <= v1)
        @test ismissing(missing > v1)
        @test ismissing(missing >= v1)
    end
end

@testset "values from ordered CategoricalPool" begin
    @test ordered!(pool, true) === pool
    @test isordered(pool) === true

    @test (v1 < v1) === false
    @test (v1 < v2) === true
    @test (v1 < v3) === true
    @test (v2 < v1) === false
    @test (v2 < v2) === false
    @test (v2 < v3) === true
    @test (v3 < v1) === false
    @test (v3 < v2) === false
    @test (v3 < v3) === false

    @test (v1 <= v1) === true
    @test (v1 <= v2) === true
    @test (v1 <= v3) === true
    @test (v2 <= v1) === false
    @test (v2 <= v2) === true
    @test (v2 <= v3) === true
    @test (v3 <= v1) === false
    @test (v3 <= v2) === false
    @test (v3 <= v3) === true

    @test (v1 > v1) === false
    @test (v1 > v2) === false
    @test (v1 > v3) === false
    @test (v2 > v1) === true
    @test (v2 > v2) === false
    @test (v2 > v3) === false
    @test (v3 > v1) === true
    @test (v3 > v2) === true
    @test (v3 > v3) === false

    @test (v1 >= v1) === true
    @test (v1 >= v2) === false
    @test (v1 >= v3) === false
    @test (v2 >= v1) === true
    @test (v2 >= v2) === true
    @test (v2 >= v3) === false
    @test (v3 >= v1) === true
    @test (v3 >= v2) === true
    @test (v3 >= v3) === true

    @test isless(v1, v1) === false
    @test isless(v1, v2) === true
    @test isless(v1, v3) === true
    @test isless(v2, v1) === false
    @test isless(v2, v2) === false
    @test isless(v2, v3) === true
    @test isless(v3, v1) === false
    @test isless(v3, v2) === false
    @test isless(v3, v3) === false

    @testset "comparison with missing" begin
        @test isless(v1, missing)
        @test !isless(missing, v1)
        @test ismissing(v1 < missing)
        @test ismissing(v1 <= missing)
        @test ismissing(v1 > missing)
        @test ismissing(v1 >= missing)
        @test ismissing(missing < v1)
        @test ismissing(missing <= v1)
        @test ismissing(missing > v1)
        @test ismissing(missing >= v1)
    end
end

@testset "comparisons with reordered levels" begin
    @test CategoricalArrays.levels!(pool, [2, 3, 1]) === pool
    @test levels(pool) == [2, 3, 1]

    @test (v1 < v1) === false
    @test (v1 < v2) === false
    @test (v1 < v3) === false
    @test (v2 < v1) === true
    @test (v2 < v2) === false
    @test (v2 < v3) === true
    @test (v3 < v1) === true
    @test (v3 < v2) === false
    @test (v3 < v3) === false

    @test (v1 <= v1) === true
    @test (v1 <= v2) === false
    @test (v1 <= v3) === false
    @test (v2 <= v1) === true
    @test (v2 <= v2) === true
    @test (v2 <= v3) === true
    @test (v3 <= v1) === true
    @test (v3 <= v2) === false
    @test (v3 <= v3) === true

    @test (v1 > v1) === false
    @test (v1 > v2) === true
    @test (v1 > v3) === true
    @test (v2 > v1) === false
    @test (v2 > v2) === false
    @test (v2 > v3) === false
    @test (v3 > v1) === false
    @test (v3 > v2) === true
    @test (v3 > v3) === false

    @test (v1 >= v1) === true
    @test (v1 >= v2) === true
    @test (v1 >= v3) === true
    @test (v2 >= v1) === false
    @test (v2 >= v2) === true
    @test (v2 >= v3) === false
    @test (v3 >= v1) === false
    @test (v3 >= v2) === true
    @test (v3 >= v3) === true

    @test isless(v1, v1) === false
    @test isless(v1, v2) === false
    @test isless(v1, v3) === false
    @test isless(v2, v1) === true
    @test isless(v2, v2) === false
    @test isless(v2, v3) === true
    @test isless(v3, v1) === true
    @test isless(v3, v2) === false
    @test isless(v3, v3) === false

    @test ordered!(pool, false) === pool
    @test isordered(pool) === false

    @test_throws ArgumentError v1 < v1
    @test_throws ArgumentError v1 < v2
    @test_throws ArgumentError v1 < v3
    @test_throws ArgumentError v2 < v1
    @test_throws ArgumentError v2 < v2
    @test_throws ArgumentError v2 < v3
    @test_throws ArgumentError v3 < v1
    @test_throws ArgumentError v3 < v2
    @test_throws ArgumentError v3 < v3

    @test_throws ArgumentError v1 <= v1
    @test_throws ArgumentError v1 <= v2
    @test_throws ArgumentError v1 <= v3
    @test_throws ArgumentError v2 <= v1
    @test_throws ArgumentError v2 <= v2
    @test_throws ArgumentError v2 <= v3
    @test_throws ArgumentError v3 <= v1
    @test_throws ArgumentError v3 <= v2
    @test_throws ArgumentError v3 <= v3

    @test_throws ArgumentError v1 > v1
    @test_throws ArgumentError v1 > v2
    @test_throws ArgumentError v1 > v3
    @test_throws ArgumentError v2 > v1
    @test_throws ArgumentError v2 > v2
    @test_throws ArgumentError v2 > v3
    @test_throws ArgumentError v3 > v1
    @test_throws ArgumentError v3 > v2
    @test_throws ArgumentError v3 > v3

    @test_throws ArgumentError v1 >= v1
    @test_throws ArgumentError v1 >= v2
    @test_throws ArgumentError v1 >= v3
    @test_throws ArgumentError v2 >= v1
    @test_throws ArgumentError v2 >= v2
    @test_throws ArgumentError v2 >= v3
    @test_throws ArgumentError v3 >= v1
    @test_throws ArgumentError v3 >= v2
    @test_throws ArgumentError v3 >= v3

    @test isless(v1, v1) === false
    @test isless(v1, v2) === false
    @test isless(v1, v3) === false
    @test isless(v2, v1) === true
    @test isless(v2, v2) === false
    @test isless(v2, v3) === true
    @test isless(v3, v1) === true
    @test isless(v3, v2) === false
    @test isless(v3, v3) === false
end

@testset "comparisons for CategoricalString" begin
    # check that ordering comparisons also fail for CategoricalString
    # (since the AbstractString fallback could break this)
    pool1 = CategoricalPool(["a", "b", "c"])

    v4 = CategoricalArrays.catvalue(1, pool1)
    v5 = CategoricalArrays.catvalue(2, pool1)
    v6 = CategoricalArrays.catvalue(3, pool1)

    @test_throws ArgumentError v4 < v4
    @test_throws ArgumentError v4 < v5
    @test_throws ArgumentError v4 < v6
    @test_throws ArgumentError v5 < v4
    @test_throws ArgumentError v5 < v5
    @test_throws ArgumentError v5 < v6
    @test_throws ArgumentError v6 < v4
    @test_throws ArgumentError v6 < v5
    @test_throws ArgumentError v6 < v6

    @test_throws ArgumentError v4 <= v4
    @test_throws ArgumentError v4 <= v5
    @test_throws ArgumentError v4 <= v6
    @test_throws ArgumentError v5 <= v4
    @test_throws ArgumentError v5 <= v5
    @test_throws ArgumentError v5 <= v6
    @test_throws ArgumentError v6 <= v4
    @test_throws ArgumentError v6 <= v5
    @test_throws ArgumentError v6 <= v6

    @test_throws ArgumentError v4 > v4
    @test_throws ArgumentError v4 > v5
    @test_throws ArgumentError v4 > v6
    @test_throws ArgumentError v5 > v4
    @test_throws ArgumentError v5 > v5
    @test_throws ArgumentError v5 > v6
    @test_throws ArgumentError v6 > v4
    @test_throws ArgumentError v6 > v5
    @test_throws ArgumentError v6 > v6

    @test_throws ArgumentError v4 >= v4
    @test_throws ArgumentError v4 >= v5
    @test_throws ArgumentError v4 >= v6
    @test_throws ArgumentError v5 >= v4
    @test_throws ArgumentError v5 >= v5
    @test_throws ArgumentError v5 >= v6
    @test_throws ArgumentError v6 >= v4
    @test_throws ArgumentError v6 >= v5
    @test_throws ArgumentError v6 >= v6

    @test isless(v4, v4) === false
    @test isless(v4, v5) === true
    @test isless(v4, v6) === true
    @test isless(v5, v4) === false
    @test isless(v5, v5) === false
    @test isless(v5, v6) === true
    @test isless(v6, v4) === false
    @test isless(v6, v5) === false
    @test isless(v6, v6) === false
end

@testset "ordering comparisons between pools fail" begin
    ordered!(pool, true)
    pool2 = CategoricalPool([1, 2, 3])
    ordered!(pool2, true)

    v = CategoricalArrays.catvalue(1, pool2)

    @test_throws ArgumentError v < v1
    @test_throws ArgumentError v <= v1
    @test_throws ArgumentError v > v1
    @test_throws ArgumentError v >= v1
    @test_throws ArgumentError isless(v, v1)
end

end
