module TestExtras

using Base.Test
using CategoricalArrays
using NullableArrays
using Compat

# == currently throws an error for Nullables
const ==  = isequal

# Test cut

for (A, CA) in zip((Array, NullableArray, Array{Nullable}),
                    (CategoricalArray, NullableCategoricalArray, NullableCategoricalArray))
    x = cut(A([2, 3, 5]), [1, 3, 6])
    @test x == CA(["[1, 3)", "[3, 6)", "[3, 6)"])
    @test isa(x, CA)
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)"]

    err = @test_throws ArgumentError cut(A([2, 3, 5]), [3, 6])
    if A === Array
        @test err.value.msg == "value 2 (at index 1) is outside the breaks: adapt them manually, or pass extend=true"
    else
        @test err.value.msg == "value 2 (at index 1) is outside the breaks: adapt them manually, or pass extend=true or nullok=true"
    end


    err = @test_throws ArgumentError cut(A([2, 3, 5]), [2, 5])
    if A === Array
        @test err.value.msg == "value 5 (at index 3) is outside the breaks: adapt them manually, or pass extend=true"
    else
        @test err.value.msg == "value 5 (at index 3) is outside the breaks: adapt them manually, or pass extend=true or nullok=true"
    end

    if A === Array
        err = @test_throws ArgumentError cut(A([2, 3, 5]), [2, 5], nullok=true)
        @test err.value.msg == "value 5 (at index 3) is outside the breaks: adapt them manually, or pass extend=true"
    else
        x = cut(A([2, 3, 5]), [2, 5], nullok=true)
        @test x == CA(["[2, 5)", "[2, 5)", Nullable()])
        @test isa(x, CA)
        @test isordered(x)
        @test levels(x) == ["[2, 5)"]
    end

    x = cut(A([2, 3, 5]), [3, 6], extend=true)
    @test x == CA(["[2, 3)", "[3, 6]", "[3, 6]"])
    @test isa(x, CA)
    @test isordered(x)
    @test levels(x) == ["[2, 3)", "[3, 6]"]

    x = cut(A([2, 3, 5, 6]), [3, 6], extend=true)
    @test x == CA(["[2, 3)", "[3, 6]", "[3, 6]", "[3, 6]"])
    @test isordered(x)
    @test levels(x) == ["[2, 3)", "[3, 6]"]

    x = cut(A([1, 2, 4]), [1, 3, 6])
    @test x == CA(["[1, 3)", "[1, 3)", "[3, 6)"])
    @test isa(x, CA)
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)"]

    x = cut(A([1, 2, 4]), [3, 6], extend=true)
    @test x == CA(["[1, 3)", "[1, 3)", "[3, 6]"])
    @test isa(x, CA)
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6]"]

    x = cut(A([1, 2, 4]), [3], extend=true)
    @test x == CA(["[1, 3)", "[1, 3)", "[3, 4]"])
    @test isa(x, CA)
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 4]"]

    x = cut(A([1, 5, 7]), [3, 6], extend=true)
    @test x == CA(["[1, 3)", "[3, 6)", "[6, 7]"])
    @test isa(x, CA)
    @test isordered(x)
    @test levels(x) == ["[1, 3)", "[3, 6)", "[6, 7]"]

    ages = [20, 22, 25, 27, 21, 23, 37, 31, 61, 45, 41, 32]
    breaks = [18, 25, 35, 60, 100]
    x = cut(A(ages), breaks)
    @test x == CA(["[18, 25)", "[18, 25)", "[25, 35)", "[25, 35)", "[18, 25)", "[18, 25)",
                   "[35, 60)", "[25, 35)", "[60, 100)", "[35, 60)", "[35, 60)", "[25, 35)"])
    @test isa(x, CA)
    @test isordered(x)
    @test levels(x) == ["[18, 25)", "[25, 35)", "[35, 60)", "[60, 100)"]

    labels = ["b", "a"]
    x = cut(A([2, 3, 5]), [1, 3, 6], labels=labels)
    @test x == CA(["b", "a", "a"])
    @test isa(x, CA)
    @test isordered(x)
    labels[1] = "c" # Check that labels are copied
    @test levels(x) == ["b", "a"]
end

end
