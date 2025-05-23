module TestExtras
using Test
using CategoricalArrays
using StatsBase
using Missings

const ≅ = isequal

@testset "cut($(Union{Int, T})[...])" for T in (Union{}, Missing)
    x = @inferred cut(Vector{Union{Int, T}}([2, 3, 5]), [1, 3, 6])
    @test x == ["[1, 3)", "[3, 6]", "[3, 6]"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6]"]

    @test cut(Vector{Union{T, Int}}([2, 3, 5]), [2, 5], extend=false) ==
        ["[2, 5]", "[2, 5]", "[2, 5]"]

    err = @test_throws ArgumentError cut(Vector{Union{T, Int}}([2, 3, 5]), [3, 6])
    @test err.value.msg == "value 2 (at index 1) does not fall inside the breaks: adapt them manually, or pass extend=true or extend=missing"


    if T === Missing
        x = @inferred cut(Vector{Union{T, Int}}([2, 3, 5]), [2, 5], extend=missing)
    else
        x = cut(Vector{Union{T, Int}}([2, 3, 5]), [2, 5], extend=missing)
    end
    @test x ≅ ["[2, 5]", "[2, 5]", "[2, 5]"]
    @test isa(x, CategoricalVector{Union{String, Missing}})
    @test isordered(x)
    @test levels(x) == ["[2, 5]"]

    if T === Missing
        x = @inferred cut(Vector{Union{T, Int}}([2, 3, 6]), [2, 5], extend=missing)
    else
        x = cut(Vector{Union{T, Int}}([2, 3, 6]), [2, 5], extend=missing)
    end
    @test x ≅ ["[2, 5]", "[2, 5]", missing]
    @test isa(x, CategoricalVector{Union{String, Missing}})
    @test isordered(x)
    @test levels(x) == ["[2, 5]"]

    x = @inferred cut(Vector{Union{T, Int}}([2, 3, 5]), [3, 6], extend=true)
    @test x == ["[2, 3)", "[3, 6]", "[3, 6]"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[2, 3)", "[3, 6]"]

    x = @inferred cut(Vector{Union{T, Int}}([2, 3, 5, 6]), [3, 6], extend=true)
    @test x == ["[2, 3)", "[3, 6]", "[3, 6]", "[3, 6]"]
    @test isordered(x)
    @test levels(x) == ["[2, 3)", "[3, 6]"]

    x = @inferred cut(Vector{Union{T, Int}}([1, 2, 4]), [1, 3, 6])
    @test x == ["[1, 3)", "[1, 3)", "[3, 6]"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6]"]

    x = @inferred cut(Vector{Union{T, Int}}([1, 2, 4]), [3, 6], extend=true)
    @test x == ["[1, 3)", "[1, 3)", "[3, 6]"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6]"]

    x = @inferred cut(Vector{Union{T, Int}}([1, 2, 4]), [3], extend=true)
    @test x == ["[1, 3)", "[1, 3)", "[3, 4]"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 4]"]

    x = @inferred cut(Vector{Union{T, Int}}([1, 5, 7]), [3, 6], extend=true)
    @test x == ["[1, 3)", "[3, 6)", "[6, 7]"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)", "[6, 7]"]

    ages = [20, 22, 25, 27, 21, 23, 37, 31, 61, 45, 41, 32]
    breaks = [18, 25, 35, 60, 100]
    x = @inferred cut(Vector{Union{T, Int}}(ages), breaks)
    @test x == ["[18, 25)", "[18, 25)", "[25, 35)", "[25, 35)", "[18, 25)", "[18, 25)",
                "[35, 60)", "[25, 35)", "[60, 100]", "[35, 60)", "[35, 60)", "[25, 35)"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[18, 25)", "[25, 35)", "[35, 60)", "[60, 100]"]

    breaks = [1, 6, 3] # Unsorted breaks
    labels = ["b", "a"] # Differs from lexical ordering
    x = @inferred cut(Vector{Union{T, Int}}([2, 3, 5]), breaks, labels=labels)
    @test x == ["b", "a", "a"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test breaks == [1, 6, 3] # Check that breaks are copied before sorting
    labels[1] = "c" # Check that labels are copied
    @test levels(x) == ["b", "a"]

    x = @inferred cut(Matrix{Union{Float64, T}}([-1.1 3.0; 1.456 10.394]), [-2.134, 3.0, 12.5])
    @test x == ["[-2.13, 3)" "[3, 12.5]"; "[-2.13, 3)" "[3, 12.5]"]
    @test isa(x, CategoricalMatrix{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[-2.13, 3)", "[3, 12.5]"]

    labels = 0:2:8
    x = @inferred cut(Vector{Union{T, Int}}(1:8), 0:2:10, labels=labels)
    @test x == [0,2,2,4,4,6,6,8]
    @test isa(x, CategoricalVector{Union{Int, T}})
    @test isordered(x)
    @test levels(x) == [0, 2, 4, 6, 8]

    labels = Union{Int, String}[0, "2", 4, "6", 8]
    x = @inferred cut(Vector{Union{T, Int}}(1:8), 10:-2:0, labels=labels)
    @test x == [0, "2", "2", 4, 4, "6", "6", 8]
    @test isa(x, CategoricalVector{Union{Int, String, T}})
    @test isordered(x)
    @test levels(x) == [0, "2", 4, "6", 8]
end

@testset "cut with missing values in input" begin
    # use a large vector since values can be zero by chance
    x = [1; fill(missing, 100)]
    y = cut(x, [1, 5])
    y[1] = missing
    @test all(ismissing, y)

    y = cut(x, [1, 5], labels=[1])
    y[1] = missing
    @test all(ismissing, y)
end

@testset "cut([5, 4, 3, 2], 2)" begin
    x = @inferred cut([5, 4, 3, 2], 2)
    @test x == ["[4, 5]", "[4, 5]", "[2, 4)", "[2, 4)"]
    @test isa(x, CategoricalArray)
    @test isordered(x)
    @test levels(x) == ["[2, 4)", "[4, 5]"]
end

@testset "cut(x, n) with missing values" begin
    x = @inferred cut([5, 4, 3, missing, 2], 2)
    @test x ≅ ["[4, 5]", "[4, 5]", "[2, 4)", missing, "[2, 4)"]
    @test isa(x, CategoricalArray)
    @test isordered(x)
    @test levels(x) == ["[2, 4)", "[4, 5]"]
end

@testset "cut(x, n) with invalid n" begin
    @test_throws ArgumentError cut(1:10, 0)
    @test_throws ArgumentError cut(1:10, -1)
end

@testset "cut with formatter function" begin
    my_formatter(from, to, i; leftclosed, rightclosed, sigdigits) = "$i: $from -- $to"

    x = 0.15:0.20:0.95
    p = [0, 0.4, 0.8, 1.0]

    a = @inferred cut(x, p, labels=my_formatter)
    @test a == ["1: 0.0 -- 0.4", "1: 0.0 -- 0.4", "2: 0.4 -- 0.8", "2: 0.4 -- 0.8", "3: 0.8 -- 1.0"]

    my_old_formatter(from, to, i; leftclosed, rightclosed) = "$i: $from -- $to"
    a = @test_deprecated r"`labels`.*" cut(x, p, labels=my_old_formatter)
    @test a == ["1: 0.0 -- 0.4", "1: 0.0 -- 0.4", "2: 0.4 -- 0.8", "2: 0.4 -- 0.8", "3: 0.8 -- 1.0"]

    # GH 274
    my_formatter_2(from, to, i; leftclosed, rightclosed, sigdigits) = "$i: $(from+1) -- $(to+1)"
    a = @inferred cut(x, p, labels=my_formatter_2)
    @test a == ["1: 1.0 -- 1.4", "1: 1.0 -- 1.4", "2: 1.4 -- 1.8", "2: 1.4 -- 1.8", "3: 1.8 -- 2.0"]

    for T in (Union{}, Missing)
        labels = (from, to, i; leftclosed, rightclosed, sigdigits) -> (to+from)/2
        a = @inferred cut(Vector{Union{T, Int}}(1:8), 0:2:10, labels=labels)
        @test a == [1.0, 3.0, 3.0, 5.0, 5.0, 7.0, 7.0, 9.0]
        @test isa(a, CategoricalVector{Union{Float64, T}})
        @test isordered(a)
        @test levels(a) == [1.0, 3.0, 5.0, 7.0, 9.0]

        labels = (from, to, i; leftclosed, rightclosed, sigdigits) -> "$((to+from)/2)"
        a = @inferred cut(Vector{Union{T, Int}}(1:8), 0:2:10, labels=labels)
        @test a == string.([1.0, 3.0, 3.0, 5.0, 5.0, 7.0, 7.0, 9.0])
        @test isa(a, CategoricalVector{Union{String, T}})
        @test isordered(a)
        @test levels(a) == string.([1.0, 3.0, 5.0, 7.0, 9.0])
    end

    @test cut(0.0:8.0, 3, labels=[-0.0, 0.0, 1.0]) ==
        [-0.0, -0.0, -0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0]

    @test cut([-0.0, 0.0, 1.0, 2.0, 3.0, 4.0], [-0.0, 0.0, 5.0], labels=[-0.0, 0.0]) ==
        [-0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
end

@testset "cut with duplicated breaks" begin
    x = [zeros(10); ones(10)]
    @test_throws ArgumentError cut(x, [0, 0.1, 0.1, 10])
    @test_throws ArgumentError cut(x, 10)
    y = cut(x, [0, 0.1, 10, 10])
    @test y == [fill("[0, 0.1)", 10); fill("[0.1, 10)", 10)]
    @test levels(y) == ["[0, 0.1)", "[0.1, 10)", "[10, 10]"]

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 11])
    y = cut(1:10, [1, 5, 5, 11], allowempty=true)
    @test y == cut(1:10, [1, 5, 11])
    @test levels(y) == ["[1, 5)", "(5, 5)", "[5, 11]"]
    y = cut(1:10, [1, 5, 11, 11])
    @test y == [fill("[1, 5)", 4); fill("[5, 11)", 6)]
    @test levels(y) == ["[1, 5)", "[5, 11)", "[11, 11]"]
    y = cut(1:10, [1, 5, 10, 10])
    @test y == [fill("[1, 5)", 4); fill("[5, 10)", 5); "[10, 10]"]
    @test levels(y) == ["[1, 5)", "[5, 10)", "[10, 10]"]

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 11])
    @test_throws ArgumentError cut(1:10, [1, 5, 5, 11],
                                   labels=["[1, 5)", "(5, 5)", "(5, 5)", "[5, 11)"])
    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 11], allowempty=true)

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 5, 11])
    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 5, 11], allowempty=true)

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 11], labels=string.(1:3))
    y = cut(1:10, [1, 5, 5, 11], allowempty=true, labels=string.(1:3))
    @test y == recode(cut(1:10, [1, 5, 11]), "[1, 5)" => "1", "[5, 11]" => "3")
    @test levels(y) == string.(1:3)

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 11], labels=string.(1:4))
    y = cut(1:10, [1, 5, 5, 5, 11], allowempty=true, labels=string.(1:4))
    @test y == recode(cut(1:10, [1, 5, 11]), "[1, 5)" => "1", "[5, 11]" => "4")
    @test levels(y) == string.(1:4)

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 5, 11], labels=string.(1:5))
    y = cut(1:10, [1, 5, 5, 5, 5, 11], allowempty=true, labels=string.(1:5))
    @test y == recode(cut(1:10, [1, 5, 11]), "[1, 5)" => "1", "[5, 11]" => "5")
    @test levels(y) == string.(1:5)

    @test_throws ArgumentError cut(1:10, [1, 3, 3, 5, 5, 11], labels=string.(1:5))
    y = cut(1:10, [1, 3, 3, 5, 5, 11], allowempty=true, labels=string.(1:5))
    @test y == recode(cut(1:10, [1, 3, 5, 11]),
                      "[1, 3)" => "1", "[3, 5)" => "3", "[5, 11]" => "5")
    @test levels(y) == string.(1:5)

    @test_throws ArgumentError cut(1:10, [1, 3, 3, 3, 5, 5, 5, 11], labels=string.(1:7))
    y = cut(1:10, [1, 3, 3, 3, 5, 5, 5, 11], allowempty=true, labels=string.(1:7))
    @test y == recode(cut(1:10, [1, 3, 5, 11]),
                      "[1, 3)" => "1", "[3, 5)" => "4", "[5, 11]" => "7")
    @test levels(y) == string.(1:7)

    @test_throws ArgumentError cut(1:10, [1, 3, 5, 5, 11],
                                   labels=["1", "2", "2", "3"])
    @test_throws ArgumentError cut(1:10, [1, 3, 5, 5, 11], allowempty=true,
                                   labels=["1", "2", "2", "3"])
    @test_throws ArgumentError cut(1:10, [1, 3, 5, 7, 11],
                                   labels=["1", "2", "2", "3"])
    @test_throws ArgumentError cut(1:10, [1, 3, 5, 7, 11], allowempty=true,
                                   labels=["1", "2", "2", "3"])
    @test_throws ArgumentError cut(1:10, [1, 3, 3, 5, 5, 11], allowempty=true,
                                   labels=["1", "2", "3", "2", "4"])

    @test_throws ArgumentError cut(1:8, 0:2:10, labels=[0, 1, 1, 2, 3])
    @test_throws ArgumentError cut(1:8, [0, 2, 2, 6, 8, 10], labels=[0, 1, 1, 2, 3], allowempty=true)

    fmt = (from, to, i; leftclosed, rightclosed, sigdigits) -> (i % 2 == 0 ? to : 0.0)
    @test_throws ArgumentError cut(1:8, 0:2:10, labels=fmt)

    @test_throws ArgumentError cut([fill(1, 10); 4], 2)
    x = cut([fill(1, 10); 4], 2, allowempty=true)
    @test unique(x) == ["2: [1, 4]"]
    @test levels(x) == ["1: (1, 1)", "2: [1, 4]"]
    @test_throws ArgumentError cut([fill(1, 10); 4], 3)
    x = cut([fill(1, 10); 4], 3, allowempty=true)
    @test unique(x) == ["3: [1, 4]"]
    @test levels(x) == ["1: (1, 1)", "2: (1, 1)", "3: [1, 4]"]

    x = cut([fill(4, 10); 1], 2)
    @test x == [fill("[4, 4]", 10); "[1, 4)"]
    @test levels(x) == ["[1, 4)"; "[4, 4]"]
    @test_throws ArgumentError cut([fill(4, 10); 1], 3)
    x = cut([fill(4, 10); 1], 3, allowempty=true)
    @test x == [fill("3: [4, 4]", 10); "1: [1, 4)"]
    @test levels(x) == ["1: [1, 4)", "2: (4, 4)", "3: [4, 4]"]

    x = cut([fill(1, 5); fill(4, 5)], 2)
    @test x == [fill("[1, 4)", 5); fill("[4, 4]", 5)]
    @test levels(x) == ["[1, 4)", "[4, 4]"]
    @test_throws ArgumentError  cut([fill(1, 5); fill(4, 5)], 3)
    x = cut([fill(1, 5); fill(4, 5)], 3, allowempty=true)
    @test x == [fill("2: [1, 4)", 5); fill("3: [4, 4]", 5)]
    @test levels(x) == ["1: (1, 1)", "2: [1, 4)", "3: [4, 4]"]
end

@testset "cut with -0.0" begin
    x = cut([-0.0, 0.0, 0.0, -0.0], 2)
    @test x == ["[-0, 0)", "[0, 0]", "[0, 0]", "[-0, 0)"]
    @test levels(x) == ["[-0, 0)", "[0, 0]"]

    x = cut([-0.0, 0.0, 0.0, -0.0], [-0.0, 0.0, 0.0])
    @test x == ["[-0, 0)", "[0, 0]", "[0, 0]", "[-0, 0)"]
    @test levels(x) == ["[-0, 0)", "[0, 0]"]

    x = cut([-0.0, 0.0, 0.0, -0.0], [-0.0, 0.0])
    @test x == fill("[-0, 0]", 4)
    @test levels(x) == ["[-0, 0]"]

    x = cut([-0.0, 0.0, 0.0, -0.0], [0.0], extend=true)
    @test x == fill("[-0, 0]", 4)
    @test levels(x) == ["[-0, 0]"]

    x = cut([-0.0, 0.0, 0.0, -0.0], [-0.0], extend=true)
    @test x == fill("[-0, 0]", 4)
    @test levels(x) == ["[-0, 0]"]

    x = cut([-0.0, 0.0, 0.0, -0.0], 2, labels=[-0.0, 0.0])
    @test x == [-0.0, 0.0, 0.0, -0.0]

    @test_throws ArgumentError cut([-0.0, 0.0, 0.0, -0.0], [-0.0, -0.0, 0.0])
end

@testset "cut with extend=true" begin
    err = @test_throws ArgumentError cut([1, 1], [], extend=true)
    @test err.value.msg == "at least one break must be provided"

    err = @test_throws ArgumentError cut([1, 1], [1], extend=true)
    @test err.value.msg == "could not extend breaks as all values are equal: please specify at least two breaks manually"

    err = @test_throws ArgumentError cut([1, 1, missing], [1], extend=true)
    @test err.value.msg == "could not extend breaks as all values are equal: please specify at least two breaks manually"

    err = @test_throws ArgumentError cut([missing], [1], extend=true)
    @test err.value.msg == "could not extend breaks as all values are missing: please specify at least two breaks manually"

    @test cut([missing], [1, 2], extend=true) ≅ [missing]

    @test cut([-0.0, 0.0, 1.0, 2.0, 3.0, 4.0], [-0.0, 0.0, 3.0],
              labels=[-0.0, 0.0, 3.0], extend=true) ==
        [-0.0, 0.0, 0.0, 0.0, 3.0, 3.0]
end

@testset "cut with extend=missing" begin
    x = @inferred cut([-0.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0], [-0.0, 0.0, 3.0],
                      labels=[-0.0, 0.0], extend=missing)
    @test x ≅ [-0.0, 0.0, 0.0, 0.0, 0.0, missing, missing]
    @test x isa CategoricalArray{Union{Missing, Float64},1,UInt32}
    @test isordered(x)
    @test levels(x) == [-0.0, 0.0]

    x = @inferred cut(-1:0.5:1, [0, 1], extend=true)
    @test x == ["[-1, 0)", "[-1, 0)", "[0, 1]", "[0, 1]", "[0, 1]"]
end

@testset "cut with NaN and Inf" begin
    @test_throws ArgumentError("NaN values are not allowed in input vector") cut([1, NaN, 2, 3], [1, 10])
    @test_throws ArgumentError("NaN values are not allowed in input vector") cut([1, NaN, 2, 3], [1], extend=true)
    @test_throws ArgumentError("NaN values are not allowed in input vector") cut([1, NaN, 2, 3], 2)
    @test_throws ArgumentError("NaN values are not allowed in breaks") cut([1, 2], [1, NaN])

    x = cut([1, Inf], [1], extend=true)
    @test x ≅ ["[1, Inf]", "[1, Inf]"]
    @test levels(x) == ["[1, Inf]"]

    x = cut([1, -Inf], [1], extend=true)
    @test x ≅ ["[-Inf, 1]", "[-Inf, 1]"]
    @test levels(x) == ["[-Inf, 1]"]

    x = cut([1:5; Inf], [1, 2, Inf])
    @test x ≅ ["[1, 2)"; fill("[2, Inf]", 5)]
    @test levels(x) == ["[1, 2)", "[2, Inf]"]

    x = cut([1:5; -Inf], [-Inf, 2, 5])
    @test x ≅ ["[-Inf, 2)"; fill("[2, 5]", 4); "[-Inf, 2)"]
    @test levels(x) == ["[-Inf, 2)", "[2, 5]"]

    x = cut([1:5; Inf], 2)
    @test x ≅ [fill("[1, 4)", 3); fill("[4, Inf]", 3)]
    @test levels(x) == ["[1, 4)", "[4, Inf]"]

    x = cut([1:5; -Inf], 2)
    @test x ≅ [fill("[-Inf, 3)", 2); fill("[3, 5]", 3); "[-Inf, 3)"]
    @test levels(x) == ["[-Inf, 3)", "[3, 5]"]
end

@testset "cut when quantile falls exactly on a data value" begin
    x = cut([11, 14, 43, 54, 54, 56, 73, 79, 84, 84], 3)
    @test x ==
        ["[11, 54)", "[11, 54)", "[11, 54)",
        "[54, 73)", "[54, 73)", "[54, 73)",
        "[73, 84]", "[73, 84]", "[73, 84]", "[73, 84]"]
    @test levels(x) == ["[11, 54)", "[54, 73)", "[73, 84]"]
end

@testset "cut computation of sigdigits" begin
    x = cut([1.2, 1.3, 2], 2)
    @test levels(x) == ["[1.2, 1.3)", "[1.3, 2]"]

    x = cut([1.0, 2.0, 3.0], 2)
    @test levels(x) == ["[1, 2)", "[2, 3]"]

    x = cut([1.00002, 1.00003, 2], 2)
    @test levels(x) == ["[1.00002, 1.00003)", "[1.00003, 2]"]

    x = cut([1.00002, 1.00003, 1.00005, 2], 2)
    @test levels(x) == ["[1, 1.0001)", "[1.0001, 2]"]

    x = cut([1.00001, 1.00002, 1.00002, 2], 2)
    @test levels(x) == ["[1.00001, 1.00002)", "[1.00002, 2]"]

    x = cut([1.00001, 1.00003, 1.1, 2], 2)
    @test levels(x) == ["[1, 1.1)", "[1.1, 2]"]

    # @sprintf with %g uses scientific notation even in some cases
    # where classic notation would be shorter
    x = cut([1.0, 10.0, 100.0, 1000.0], [1.0, 10.0, 100.0, 1000.0])
    @test levels(x) == ["[1, 10)", "[10, 100)", "[100, 1e+03]"]
    # But integers are rendered using plain `string`
    x = cut([1, 10, 100], [1, 10, 100, 1000])
    @test levels(x) == ["[1, 10)", "[10, 100)", "[100, 1000]"]

    # Extreme case
    x = cut([8.85718832925723e-7, 8.572446994052413e-7, 1.40217695121027e-7, 8.966449714804087e-7,
             3.070384341319470e-7, 3.070384341319471e-7, 1.8520709563325888e-7, 5.630461710066611e-7,
             6.781422109070843e-7, 4.776113711396994e-7, 0.2538909094146984, 0.5249665525921473,
             0.8321957380046366, 0.9648282851978118, 0.36084175275805797, 0.7851054639425253,
             0.6875195857202754, 0.614940093507575, 0.6224944997292978, 0.6055683461790675,
             5.349085340927365e11, 1.3471583229449602e11, 6.538893396835975e11, 4.826316844547661e11,
             8.803607035550856e11, 1.8174694671397316e10, 1.6709745443719125e11, 3.2050577954311835e11,
             1.6134999167460663e11, 7.396308745225059e11], 3)
    @test levels(x) == ["[1.4e-07, 0.254)", "[0.254, 1.82e+10)", "[1.82e+10, 8.8e+11]"]

end

@testset "cut with weighted quantiles" begin
    @test_throws ArgumentError cut(1:3, 3, weights=1:3)

    x = collect(Float64, 1:100)
    w = fweights(repeat(1:10, inner=10))
    y = cut(x, 10, weights=w)
    @test levelcode.(y) == levelcode.(cut(x, quantile(x, w, (0:10)./10)))
    @test levels(y) == ["[1, 29)", "[29, 43)", "[43, 53)", "[53, 62)", "[62, 70)",
                        "[70, 77)", "[77, 83)", "[83, 89)", "[89, 95)", "[95, 100]"]

    mx = allowmissing(x)
    mx[2] = mx[10] = missing
    nm_inds = .!ismissing.(mx)
    y = cut(mx, 10, weights=w)
    @test levelcode.(y) ≅ levelcode.(cut(mx, quantile(x[nm_inds], w[nm_inds], (0:10)./10)))
    @test levels(y) == ["[1, 30)", "[30, 43)", "[43, 53)", "[53, 62)", "[62, 70)",
                        "[70, 77)", "[77, 83)", "[83, 89)", "[89, 95)", "[95, 100]"]

    x[5] = NaN
    @test_throws ArgumentError cut(x, 3, weights=w)
end

end