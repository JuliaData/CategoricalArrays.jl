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

    @testset "comparison with a value" begin
        @test isless(v1, 1) === false
        @test isless(v1, 2) === true
        @test_throws KeyError isless(v1, 10)
        @test_throws MethodError isless(v1, 1.0)
        @test isless(1, v1) == false
        @test_throws MethodError isless(1.0, v1)
        @test_throws ArgumentError v1 < 1
        @test_throws KeyError v1 < 10
        @test_throws ArgumentError v1 < 2
        @test_throws MethodError v1 < 1.0
        @test_throws ArgumentError v1 <= 1
        @test_throws ArgumentError v1 <= 2
        @test_throws MethodError v1 <= 1.0
        @test_throws ArgumentError v1 > 1
        @test_throws ArgumentError v1 > 2
        @test_throws MethodError v1 > 1.0
        @test_throws ArgumentError v1 >= 1
        @test_throws ArgumentError v1 >= 2
        @test_throws MethodError v1 >= 1.0
    end

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

    @testset "comparison with a value" begin
        @test isless(v1, 1) === false
        @test isless(v1, 2) === true
        @test_throws KeyError isless(v1, 10)
        @test_throws MethodError isless(v1, 1.0)
        @test isless(1, v1) == false
        @test_throws MethodError isless(1.0, v1)
        @test (v1 < 1) === false
        @test (v1 < 2) === true
        @test_throws KeyError v1 < 10
        @test_throws MethodError v1 < 1.0
        @test (v1 <= 1) === true
        @test (v1 <= 2) === true
        @test_throws MethodError v1 <= 1.0
        @test (v1 > 1) === false
        @test (v1 > 2) === false
        @test_throws MethodError v1 > 1.0
        @test (v1 >= 1) === true
        @test (v1 >= 2) === false
        @test_throws MethodError v1 >= 1.0
    end

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

    @testset "comparison with a value" begin
        @test isless(v1, 1) === false
        @test isless(v1, 2) === false
        @test isless(v2, 1) === true
        @test_throws KeyError isless(v1, 10)
        @test_throws MethodError isless(v1, 1.0)
        @test isless(1, v1) == false
        @test isless(2, v1) == true
        @test_throws MethodError isless(1.0, v1)
        @test (v1 < 1) === false
        @test (v1 < 2) === false
        @test (v2 < 1) === true
        @test_throws KeyError v1 < 10
        @test_throws MethodError v1 < 1.0
        @test (v1 <= 1) === true
        @test (v1 <= 2) === false
        @test (v2 <= 1) === false
        @test_throws MethodError v1 <= 1.0
        @test (v1 > 1) === false
        @test (v1 > 2) === true
        @test (v2 > 1) === true
        @test_throws MethodError v1 > 1.0
        @test (v1 >= 1) === true
        @test (v1 >= 2) === true
        @test (v2 >= 1) === false
        @test_throws MethodError v1 >= 1.0
    end
end

@testset "comparisons for CategoricalString" begin
    # check that ordering comparisons also fail for CategoricalString
    # (since the AbstractString fallback could break this)
    pool = CategoricalPool(["a", "b", "c"])

    v1 = CategoricalArrays.catvalue(1, pool)
    v2 = CategoricalArrays.catvalue(2, pool)
    v3 = CategoricalArrays.catvalue(3, pool)

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

    @testset "comparison with a value" begin
        @test isless(v1, "a") === false
        @test isless(v1, "b") === true
        @test_throws KeyError isless(v1, "abc")
        @test_throws MethodError isless(v1, 1.0)
        @test isless("a", v1) == false
        @test_throws MethodError isless(1.0, v1)
        @test_throws ArgumentError v1 < "a"
        @test_throws ArgumentError v1 < "b"
        @test_throws KeyError v1 < "abc"
        @test_throws MethodError v1 < 1.0
        @test_throws ArgumentError v1 <= "a"
        @test_throws ArgumentError v1 <= "b"
        @test_throws MethodError v1 <= 1.0
        @test_throws ArgumentError v1 > "a"
        @test_throws ArgumentError v1 > "b"
        @test_throws MethodError v1 > 1.0
        @test_throws ArgumentError v1 >= "a"
        @test_throws ArgumentError v1 >= "b"
        @test_throws MethodError v1 >= 1.0
    end
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

@testset "values from ordered CategoricalString"
    @testset "comparison with a value" begin
        @test isless(v1, "a") === false
        @test isless(v1, "b") === true
        @test_throws KeyError isless(v1, "abc")
        @test_throws MethodError isless(v1, 1.0)
        @test isless("a", v1) == false
        @test_throws MethodError isless(1.0, v1)
        @test (v1 < "a") === false
        @test (v1 < "b") === true
        @test_throws KeyError v1 < "abc"
        @test_throws MethodError v1 < 1.0
        @test (v1 <= "a") === true
        @test (v1 <= "b") === true
        @test_throws MethodError v1 <= 1.0
        @test (v1 > "a") === false
        @test (v1 > "b") === false
        @test_throws MethodError v1 > 1.0
        @test (v1 >= "a") === true
        @test (v1 >= "b") === false
        @test_throws MethodError v1 >= 1.0
    end
end

@testset "comparisons with reordered levels" begin
    @test CategoricalArrays.levels!(pool, ["b", "c", "a"]) === pool

    @testset "comparison with a value" begin
        @test isless(v1, "a") === false
        @test isless(v1, "b") === false
        @test isless(v2, "a") === true
        @test_throws KeyError isless(v1, "abc")
        @test_throws MethodError isless(v1, 1.0)
        @test isless("a", v1) == false
        @test isless("b", v1) == true
        @test_throws MethodError isless(1.0, v1)
        @test (v1 < "a") === false
        @test (v1 < "b") === false
        @test (v2 < "a") === true
        @test_throws KeyError v1 < "abc"
        @test_throws MethodError v1 < 1.0
        @test (v1 <= "a") === true
        @test (v1 <= "b") === false
        @test (v2 <= "a") === false
        @test_throws MethodError v1 <= 1.0
        @test (v1 > "a") === false
        @test (v1 > "b") === true
        @test (v2 > "a") === true
        @test_throws MethodError v1 > 1.0
        @test (v1 >= "a") === true
        @test (v1 >= "b") === true
        @test (v2 >= "a") === false
        @test_throws MethodError v1 >= 1.0
    end
end
