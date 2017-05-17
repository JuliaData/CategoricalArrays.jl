module TestExtras

using Base.Test
using CategoricalArrays
using Nulls
using Compat

# Test cut

for (A, CA) in zip((Array{Int}, Array{Union{Int, Null}}),
                   (CategoricalArray, NullableCategoricalArray))
    x = @inferred cut(A([2, 3, 5]), [1, 3, 6])
    @test x == ["[1, 3)", "[3, 6)", "[3, 6)"]
    @test isa(x, CA{String, 1})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)"]

    err = @test_throws ArgumentError cut(A([2, 3, 5]), [3, 6])
    if eltype(A) >: Null
        @test err.value.msg == "value 2 (at index 1) does not fall inside the breaks: adapt them manually, or pass extend=true or nullok=true"
    else
        @test err.value.msg == "value 2 (at index 1) does not fall inside the breaks: adapt them manually, or pass extend=true"
    end


    err = @test_throws ArgumentError cut(A([2, 3, 5]), [2, 5])
    if eltype(A) >: Null
        @test err.value.msg == "value 5 (at index 3) does not fall inside the breaks: adapt them manually, or pass extend=true or nullok=true"
    else
        @test err.value.msg == "value 5 (at index 3) does not fall inside the breaks: adapt them manually, or pass extend=true"
    end

    if eltype(A) >: Null
        x = @inferred cut(A([2, 3, 5]), [2, 5], nullok=true)
        @test x == ["[2, 5)", "[2, 5)", null]
        @test isa(x, CA{String, 1})
        @test isordered(x)
        @test levels(x) == ["[2, 5)"]
    else
        err = @test_throws ArgumentError cut(A([2, 3, 5]), [2, 5], nullok=true)
        @test err.value.msg == "value 5 (at index 3) does not fall inside the breaks: adapt them manually, or pass extend=true"
    end

    x = @inferred cut(A([2, 3, 5]), [3, 6], extend=true)
    @test x == ["[2, 3)", "[3, 6]", "[3, 6]"]
    @test isa(x, CA{String, 1})
    @test isordered(x)
    @test levels(x) == ["[2, 3)", "[3, 6]"]

    x = @inferred cut(A([2, 3, 5, 6]), [3, 6], extend=true)
    @test x == ["[2, 3)", "[3, 6]", "[3, 6]", "[3, 6]"]
    @test isordered(x)
    @test levels(x) == ["[2, 3)", "[3, 6]"]

    x = @inferred cut(A([1, 2, 4]), [1, 3, 6])
    @test x == ["[1, 3)", "[1, 3)", "[3, 6)"]
    @test isa(x, CA{String, 1})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)"]

    x = @inferred cut(A([1, 2, 4]), [3, 6], extend=true)
    @test x == ["[1, 3)", "[1, 3)", "[3, 6]"]
    @test isa(x, CA{String, 1})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6]"]

    x = @inferred cut(A([1, 2, 4]), [3], extend=true)
    @test x == ["[1, 3)", "[1, 3)", "[3, 4]"]
    @test isa(x, CA{String, 1})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 4]"]

    x = @inferred cut(A([1, 5, 7]), [3, 6], extend=true)
    @test x == ["[1, 3)", "[3, 6)", "[6, 7]"]
    @test isa(x, CA{String, 1})
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)", "[6, 7]"]

    ages = [20, 22, 25, 27, 21, 23, 37, 31, 61, 45, 41, 32]
    breaks = [18, 25, 35, 60, 100]
    x = @inferred cut(A(ages), breaks)
    @test x == ["[18, 25)", "[18, 25)", "[25, 35)", "[25, 35)", "[18, 25)", "[18, 25)",
                "[35, 60)", "[25, 35)", "[60, 100)", "[35, 60)", "[35, 60)", "[25, 35)"]
    @test isa(x, CA{String, 1})
    @test isordered(x)
    @test levels(x) == ["[18, 25)", "[25, 35)", "[35, 60)", "[60, 100)"]

    breaks = [1, 6, 3] # Unsorted breaks
    labels = ["b", "a"] # Differs from lexical ordering
    x = @inferred cut(A([2, 3, 5]), breaks, labels=labels)
    @test x == ["b", "a", "a"]
    @test isa(x, CA{String, 1})
    @test isordered(x)
    @test breaks == [1, 6, 3] # Check that breaks are copied before sorting
    labels[1] = "c" # Check that labels are copied
    @test levels(x) == ["b", "a"]
end

for (A, CA) in zip((Array{Float64}, Array{Union{Float64, Null}}),
                   (CategoricalArray, NullableCategoricalArray))
    x = @inferred cut(A([-1.1 3.0; 1.456 10.394]), [-2.134, 3.0, 12.5])
    @test x == ["[-2.134, 3.0)" "[3.0, 12.5)"; "[-2.134, 3.0)" "[3.0, 12.5)"]
    @test isa(x, CA{String, 2})
    @test isordered(x)
    @test levels(x) == ["[-2.134, 3.0)", "[3.0, 12.5)"]
end

# TODO: test on nullable arrays once a quantile() method is provided for them
x = @inferred cut([5, 4, 3, 2], 2)
@test x == ["[3.5, 5.0]", "[3.5, 5.0]", "[2.0, 3.5)", "[2.0, 3.5)"]
@test isa(x, CategoricalArray)
@test isordered(x)
@test levels(x) == ["[2.0, 3.5)", "[3.5, 5.0]"]

end
