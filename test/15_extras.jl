module TestExtras
using Compat
using Compat.Test
using CategoricalArrays

const ≅ = isequal

@testset "cut($(Union{Int, T})[...])" for T in (Union{}, Missing)
    x = @inferred cut(Vector{Union{Int, T}}([2, 3, 5]), [1, 3, 6])
    @test x == ["[1, 3)", "[3, 6)", "[3, 6)"]
    @test isa(x, CategoricalVector{Union{String, T}})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)"]

    err = @test_throws ArgumentError cut(Vector{Union{T, Int}}([2, 3, 5]), [3, 6])
    if T === Missing
        @test err.value.msg == "value 2 (at index 1) does not fall inside the breaks: adapt them manually, or pass extend=true or allow_missing=true"
    else
        @test err.value.msg == "value 2 (at index 1) does not fall inside the breaks: adapt them manually, or pass extend=true"
    end


    err = @test_throws ArgumentError cut(Vector{Union{T, Int}}([2, 3, 5]), [2, 5])
    if T === Missing
        @test err.value.msg == "value 5 (at index 3) does not fall inside the breaks: adapt them manually, or pass extend=true or allow_missing=true"
    else
        @test err.value.msg == "value 5 (at index 3) does not fall inside the breaks: adapt them manually, or pass extend=true"
    end

    if T === Missing
        x = @inferred cut(Vector{Union{T, Int}}([2, 3, 5]), [2, 5], allow_missing=true)
        @test x ≅ ["[2, 5)", "[2, 5)", missing]
        @test isa(x, CategoricalVector{Union{String, T}})
        @test isordered(x)
        @test levels(x) == ["[2, 5)"]
    else
        err = @test_throws ArgumentError cut(Vector{Int}([2, 3, 5]), [2, 5], allow_missing=true)
        @test err.value.msg == "value 5 (at index 3) does not fall inside the breaks: adapt them manually, or pass extend=true"
    end

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
end

# TODO: test on arrays supporting missing values once a quantile() method is provided for them
@testset "cut([5, 4, 3, 2], 2)" begin
    x = @inferred cut([5, 4, 3, 2], 2)
    @test x == ["[3.5, 5.0]", "[3.5, 5.0]", "[2.0, 3.5)", "[2.0, 3.5)"]
    @test isa(x, CategoricalArray)
    @test isordered(x)
    @test levels(x) == ["[2.0, 3.5)", "[3.5, 5.0]"]
end

@testset "formatter function" begin
  my_formatter1(from, to, i; extend) = "group $i"
  my_formatter2(from, to, i; extend) = "$i: $from -- $to"
  function my_formatter3(from, to, i; extend)
    percentile(x) = Int(round(100 * parse.(Float64,x),digits=0))
    string("P",percentile(from),"P",percentile(to))
  end

  x = collect(0.15:0.20:0.95)
  p = [0, 0.4, 0.8, 1.0]

  @test cut(x, p, labels=my_formatter1) == ["group 1", "group 1", "group 2", "group 2", "group 3"]
  @test cut(x, p, labels=my_formatter2) == ["1: 0.0 -- 0.4", "1: 0.0 -- 0.4", "2: 0.4 -- 0.8", "2: 0.4 -- 0.8", "3: 0.8 -- 1.0"]
  @test cut(x, p, labels=my_formatter3) == ["P0P40"  , "P0P40"  , "P40P80" , "P40P80" , "P80P100"]
end

end
