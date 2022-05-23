module TestExtras
using Test
using CategoricalArrays

const ≅ = isequal

@testset "cut($(Union{Int, T})[...])" for T in (Union{}, Missing)
    x = @inferred cut(Vector{Union{Int, T}}([2, 3, 5]), [1, 3, 6])
    @test x == ["[1, 3)", "[3, 6)", "[3, 6)"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)"]

    err = @test_throws ArgumentError cut(Vector{Union{T, Int}}([2, 3, 5]), [3, 6])
    @test err.value.msg == "value 2 (at index 1) does not fall inside the breaks: adapt them manually, or pass extend=true or extend=missing"


    err = @test_throws ArgumentError cut(Vector{Union{T, Int}}([2, 3, 5]), [2, 5])
    @test err.value.msg == "value 5 (at index 3) does not fall inside the breaks: adapt them manually, or pass extend=true or extend=missing"

    if T === Missing
        x = @inferred cut(Vector{Union{T, Int}}([2, 3, 5]), [2, 5], extend=missing)
    else
        x = cut(Vector{Union{T, Int}}([2, 3, 5]), [2, 5], extend=missing)
    end
    @test x ≅ ["[2, 5)", "[2, 5)", missing]
    @test isa(x, CategoricalVector{Union{String, Missing}})
    @test isordered(x)
    @test levels(x) == ["[2, 5)"]

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
    @test x == ["[1, 3)", "[1, 3)", "[3, 6)"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)"]

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
                "[35, 60)", "[25, 35)", "[60, 100)", "[35, 60)", "[35, 60)", "[25, 35)"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[18, 25)", "[25, 35)", "[35, 60)", "[60, 100)"]

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
    @test x == ["[-2.134, 3.0)" "[3.0, 12.5)"; "[-2.134, 3.0)" "[3.0, 12.5)"]
    @test isa(x, CategoricalMatrix{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[-2.134, 3.0)", "[3.0, 12.5)"]

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

    @test_throws ArgumentError cut([-0.0, 0.0], 2)
    @test_throws ArgumentError cut([-0.0, 0.0], 2, labels=[-0.0, 0.0])
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
    @test x == ["Q2: [3.5, 5.0]", "Q2: [3.5, 5.0]", "Q1: [2.0, 3.5)", "Q1: [2.0, 3.5)"]
    @test isa(x, CategoricalArray)
    @test isordered(x)
    @test levels(x) == ["Q1: [2.0, 3.5)", "Q2: [3.5, 5.0]"]
end

@testset "cut(x, n) with missing values" begin
    x = @inferred cut([5, 4, 3, missing, 2], 2)
    @test x ≅ ["Q2: [3.5, 5.0]", "Q2: [3.5, 5.0]", "Q1: [2.0, 3.5)", missing, "Q1: [2.0, 3.5)"]
    @test isa(x, CategoricalArray)
    @test isordered(x)
    @test levels(x) == ["Q1: [2.0, 3.5)", "Q2: [3.5, 5.0]"]
end

@testset "cut with formatter function" begin
    my_formatter(from, to, i; leftclosed, rightclosed) = "$i: $from -- $to"

    x = 0.15:0.20:0.95
    p = [0, 0.4, 0.8, 1.0]

    a = @inferred cut(x, p, labels=my_formatter)
    @test a == ["1: 0.0 -- 0.4", "1: 0.0 -- 0.4", "2: 0.4 -- 0.8", "2: 0.4 -- 0.8", "3: 0.8 -- 1.0"]

    # GH 274
    my_formatter_2(from, to, i; leftclosed, rightclosed) = "$i: $(from+1) -- $(to+1)"
    a = @inferred cut(x, p, labels=my_formatter_2)
    @test a == ["1: 1.0 -- 1.4", "1: 1.0 -- 1.4", "2: 1.4 -- 1.8", "2: 1.4 -- 1.8", "3: 1.8 -- 2.0"]

    for T in (Union{}, Missing)
        labels = (from, to, i; leftclosed, rightclosed) -> (to+from)/2
        a = @inferred cut(Vector{Union{T, Int}}(1:8), 0:2:10, labels=labels)
        @test a == [1.0, 3.0, 3.0, 5.0, 5.0, 7.0, 7.0, 9.0]
        @test isa(a, CategoricalVector{Union{Float64, T}})
        @test isordered(a)
        @test levels(a) == [1.0, 3.0, 5.0, 7.0, 9.0]

        labels = (from, to, i; leftclosed, rightclosed) -> "$((to+from)/2)"
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

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 11])
    y = cut(1:10, [1, 5, 5, 11], allowempty=true)
    @test y == cut(1:10, [1, 5, 11])
    @test levels(y) == ["[1, 5)", "(5, 5)", "[5, 11)"]

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 11])
    @test_throws ArgumentError cut(1:10, [1, 5, 5, 11],
                                   labels=["[1, 5)", "(5, 5)", "(5, 5)", "[5, 11)"])
    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 11], allowempty=true)

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 5, 11])
    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 5, 11], allowempty=true)

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 11], labels=string.(1:3))
    y = cut(1:10, [1, 5, 5, 11], allowempty=true, labels=string.(1:3))
    @test y == recode(cut(1:10, [1, 5, 11]), "[1, 5)" => "1", "[5, 11)" => "3")
    @test levels(y) == string.(1:3)

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 11], labels=string.(1:4))
    y = cut(1:10, [1, 5, 5, 5, 11], allowempty=true, labels=string.(1:4))
    @test y == recode(cut(1:10, [1, 5, 11]), "[1, 5)" => "1", "[5, 11)" => "4")
    @test levels(y) == string.(1:4)

    @test_throws ArgumentError cut(1:10, [1, 5, 5, 5, 5, 11], labels=string.(1:5))
    y = cut(1:10, [1, 5, 5, 5, 5, 11], allowempty=true, labels=string.(1:5))
    @test y == recode(cut(1:10, [1, 5, 11]), "[1, 5)" => "1", "[5, 11)" => "5")
    @test levels(y) == string.(1:5)

    @test_throws ArgumentError cut(1:10, [1, 3, 3, 5, 5, 11], labels=string.(1:5))
    y = cut(1:10, [1, 3, 3, 5, 5, 11], allowempty=true, labels=string.(1:5))
    @test y == recode(cut(1:10, [1, 3, 5, 11]),
                      "[1, 3)" => "1", "[3, 5)" => "3", "[5, 11)" => "5")
    @test levels(y) == string.(1:5)

    @test_throws ArgumentError cut(1:10, [1, 3, 3, 3, 5, 5, 5, 11], labels=string.(1:7))
    y = cut(1:10, [1, 3, 3, 3, 5, 5, 5, 11], allowempty=true, labels=string.(1:7))
    @test y == recode(cut(1:10, [1, 3, 5, 11]),
                      "[1, 3)" => "1", "[3, 5)" => "4", "[5, 11)" => "7")
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

    fmt = (from, to, i; leftclosed, rightclosed) -> (i % 2 == 0 ? to : 0.0)
    @test_throws ArgumentError cut(1:8, 0:2:10, labels=fmt)
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
    x = @inferred cut([-0.0, 0.0, 1.0, 2.0, 3.0, 4.0], [-0.0, 0.0, 3.0],
                      labels=[-0.0, 0.0], extend=missing)
    @test x ≅ [-0.0, 0.0, 0.0, 0.0, missing, missing]
    @test x isa CategoricalArray{Union{Missing, Float64},1,UInt32}
    @test isordered(x)
    @test levels(x) == [-0.0, 0.0]

    x = @inferred cut(-1:0.5:1, [0, 1], extend=true)
    @test x == ["[-1.0, 0.0)", "[-1.0, 0.0)", "[0.0, 1.0]", "[0.0, 1.0]", "[0.0, 1.0]"]
end

end
