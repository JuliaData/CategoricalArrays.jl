module TestIsLess
using Test
using CategoricalArrays

pool = CategoricalPool([1, 2, 3])

v1 = CategoricalValue(pool, 1)
v2 = CategoricalValue(pool, 2)
v3 = CategoricalValue(pool, 3)

@testset "values from unordered CategoricalPool" begin
    @test isordered(v1) === false
    @test isordered(v2) === false
    @test isordered(v3) === false

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

    @testset "comparison with values of different types" begin
        @test_throws ArgumentError isless(v1, 1)
        @test_throws ArgumentError isless(v1, 2)
        @test_throws ArgumentError isless(v1, 10)
        @test_throws ArgumentError isless(v1, "a")
        @test_throws ArgumentError isless(1, v1)
        @test_throws ArgumentError isless("a", v1)
        @test_throws ArgumentError v1 < 1
        @test_throws ArgumentError v1 < 10
        @test_throws ArgumentError v1 < 2
        @test_throws ArgumentError v1 < "a"
        @test_throws ArgumentError v1 <= 1
        @test_throws ArgumentError v1 <= 2
        @test_throws ArgumentError v1 <= "a"
        @test_throws ArgumentError v1 > 1
        @test_throws ArgumentError v1 > 2
        @test_throws ArgumentError v1 > "a"
        @test_throws ArgumentError v1 >= 1
        @test_throws ArgumentError v1 >= 2
        @test_throws ArgumentError v1 >= "a"
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
    @test isordered(v1) === true
    @test isordered(v2) === true
    @test isordered(v3) === true

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

    @testset "comparison with values of different types" begin
        @test_throws ArgumentError isless(v1, 1)
        @test_throws ArgumentError isless(v1, 2)
        @test_throws ArgumentError isless(v1, 10)
        @test_throws ArgumentError isless(v1, "a")
        @test_throws ArgumentError isless(1, v1)
        @test_throws ArgumentError isless("a", v1)
        @test_throws ArgumentError (v1 < 1)
        @test_throws ArgumentError (v1 < 2)
        @test_throws ArgumentError v1 < 10
        @test_throws ArgumentError v1 < "a"
        @test_throws ArgumentError (v1 <= 1)
        @test_throws ArgumentError (v1 <= 2)
        @test_throws ArgumentError v1 <= "a"
        @test_throws ArgumentError (v1 > 1)
        @test_throws ArgumentError (v1 > 2)
        @test_throws ArgumentError v1 > "a"
        @test_throws ArgumentError (v1 >= 1)
        @test_throws ArgumentError (v1 >= 2)
        @test_throws ArgumentError v1 >= "a"
    end

    @testset "comparison with values from different pools" begin
        poolb = copy(pool)
        v1b = CategoricalValue(poolb, 1)
        v2b = CategoricalValue(poolb, 2)
        v3b = CategoricalValue(poolb, 3)

        @test (v1 < v1b) === false
        @test (v1 < v2b) === true
        @test (v1 < v3b) === true
        @test (v2 < v1b) === false
        @test (v2 < v2b) === false
        @test (v2 < v3b) === true
        @test (v3 < v1b) === false
        @test (v3 < v2b) === false
        @test (v3 < v3b) === false

        @test isless(v1, v1b) === false
        @test isless(v1, v2b) === true
        @test isless(v1, v3b) === true
        @test isless(v2, v1b) === false
        @test isless(v2, v2b) === false
        @test isless(v2, v3b) === true
        @test isless(v3, v1b) === false
        @test isless(v3, v2b) === false
        @test isless(v3, v3b) === false

        poolc = copy(poolb)
        @test poolb == poolc # To set subsetof field
        v1c = CategoricalValue(poolc, 1)
        push!(poolc, 4)

        @test_throws ArgumentError v1b < v1c
        @test_throws ArgumentError isless(v1b, v1c)

        poolc = copy(poolb)
        @test poolb == poolc # To set subsetof field
        v1c = CategoricalValue(poolc, 1)
        push!(poolc, 4)

        @test_throws ArgumentError v1b < v1c
        @test_throws ArgumentError isless(v1b, v1c)

        poolc = copy(poolb)
        @test poolb == poolc # To set subsetof field
        v1c = CategoricalValue(poolc, 1)
        levels!(poolc, collect(1:4))

        @test_throws ArgumentError v1b < v1c
        @test_throws ArgumentError isless(v1b, v1c)
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

end
