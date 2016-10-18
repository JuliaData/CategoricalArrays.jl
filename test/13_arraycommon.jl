module TestArrayCommon

using Base.Test
using CategoricalArrays
using NullableArrays
using CategoricalArrays: DefaultRefType
using Compat

typealias String Compat.ASCIIString

# == currently throws an error for Nullables
(==) = isequal


# Test that mergelevels handles mutually compatible orderings
@test CategoricalArrays.mergelevels(true, [6, 2, 4, 8], [2, 3, 5, 4], [2, 4, 8]) ==
    ([6, 2, 3, 5, 4, 8], true)
@test CategoricalArrays.mergelevels(true, ["A", "B", "D"], ["C", "D", "E", "F"], ["B", "C", "E"]) ==
    (["A", "B", "C", "D", "E", "F"], true)
@test CategoricalArrays.mergelevels(true, ["A", "B", "D"], ["C", "D", "E", "F"], ["A", "B", "C", "F"]) ==
    (["A", "B", "C", "D", "E", "F"], true)
@test CategoricalArrays.mergelevels(true, ["B", "C", "D"], ["A", "B"]) ==
    (["A", "B", "C", "D"], true)
@test CategoricalArrays.mergelevels(true, ["B", "C", "D"], []) ==
    (["B", "C", "D"], true)
@test CategoricalArrays.mergelevels(true, [], ["A", "C"]) ==
    (["A", "C"], true)
@test CategoricalArrays.mergelevels(true, [], []) ==
    ([], true)
@test CategoricalArrays.mergelevels(true, ["A", "B", "C"], [], ["A", "C", "D"]) ==
    (["A", "B", "C", "D"], true)
@test CategoricalArrays.mergelevels(true, [], ["A", "B", "C"], ["A", "C", "D"]) ==
    (["A", "B", "C", "D"], true)
@test CategoricalArrays.mergelevels(true, ["A", "C", "D"], ["A", "B", "C"], []) ==
    (["A", "B", "C", "D"], true)
@test CategoricalArrays.mergelevels(true, [], ["A", "C", "D"], []) ==
    (["A", "C", "D"], true)
@test CategoricalArrays.mergelevels(true, ["A", "C", "D"], [], []) ==
    (["A", "C", "D"], true)
@test CategoricalArrays.mergelevels(true, [], [], ["A", "C", "D"]) ==
    (["A", "C", "D"], true)
@test CategoricalArrays.mergelevels(true, [], [], []) ==
    ([], true)
@test CategoricalArrays.mergelevels(true, ["A", "C", "D"], ["A", "B", "C"], ["A", "D", "E"], ["C", "D"]) ==
    (["A", "B", "C", "D", "E"], true)

# Test that mergelevels handles mutually incompatible orderings
@test CategoricalArrays.mergelevels(true, [6, 3, 4, 7], [2, 3, 6, 5, 4], [2, 4, 8]) ==
    ([6, 2, 3, 5, 4, 7, 8], false)
@test CategoricalArrays.mergelevels(true, ["A", "C", "D"], ["D", "C"], []) ==
    (["A", "C", "D"], false)
@test CategoricalArrays.mergelevels(true, ["A", "D", "C"], ["A", "B", "C"], ["A", "D", "E"], ["C", "D"]) ==
    (["A", "D", "B", "C", "E"], false)

# Test that mergelevels handles incomplete orderings
@test CategoricalArrays.mergelevels(true, ["B", "C", "D"], ["A", "C"]) ==
    (["B", "A", "C", "D"], false)
@test CategoricalArrays.mergelevels(true, ["A", "B", "D"], ["C", "D", "E", "F"]) ==
    (["A", "B", "C", "D", "E", "F"], false)
@test CategoricalArrays.mergelevels(true, ["A", "B", "E", "G"], ["C", "D", "E", "F"]) ==
    (["A", "B", "C", "D", "E", "G", "F"], false)
@test CategoricalArrays.mergelevels(true, ["A", "B", "D"], ["C", "D", "E", "F"], ["A", "B", "D", "F"]) ==
    (["A", "B", "C", "D", "E", "F"], false)

# Test with ordered=false (simpler, almost a subset of code paths tested above)
@test CategoricalArrays.mergelevels(false, ["A", "B", "E", "G"], ["C", "D", "E", "F"]) ==
    (["A", "B", "C", "D", "E", "G", "F"], false)


for (CA, A) in ((CategoricalArray, Array), (NullableCategoricalArray, NullableArray))
    # Test vcat()

    # Test that vcat of compact arrays uses a reftype that doesn't overflow
    a1 = 3:200
    a2 = 300:-1:100
    ca1 = CA(a1)
    ca2 = CA(a2)
    cca1 = compact(ca1)
    cca2 = compact(ca2)
    r = vcat(cca1, cca2)
    @test r == A(vcat(a1, a2))
    @test isa(cca1, CA{Int, 1, UInt8})
    @test isa(cca2, CA{Int, 1, UInt8})
    @test isa(r, CA{Int, 1, CategoricalArrays.DefaultRefType})
    @test isa(vcat(cca1, ca2), CA{Int, 1, CategoricalArrays.DefaultRefType})
    @test isordered(r) == false
    @test levels(r) == collect(3:300)

    # Test vcat of multidimensional arrays
    a1 = Array{Int}(2, 3, 4, 5)
    a2 = Array{Int}(3, 3, 4, 5)
    a1[1:end] = (length(a1):-1:1) + 2
    a2[1:end] = (1:length(a2)) + 10
    ca1 = CA(a1)
    ca2 = CA(a2)
    cca1 = compact(ca1)
    cca2 = compact(ca2)
    r = vcat(cca1, cca2)
    @test r == A(vcat(a1, a2))
    @test isa(r, CA{Int, 4, CategoricalArrays.DefaultRefType})
    @test isordered(r) == false
    @test levels(r) == collect(3:length(a2)+10)

    # Test concatenation of mutually compatible levels
    a1 = ["Young", "Middle"]
    a2 = ["Middle", "Old"]
    ca1 = CA(a1, ordered=true)
    ca2 = CA(a2, ordered=true)
    @test levels!(ca1, ["Young", "Middle"]) === ca1
    @test levels!(ca2, ["Middle", "Old"]) === ca2
    r = vcat(ca1, ca2)
    @test r == A(vcat(a1, a2))
    @test levels(r) == ["Young", "Middle", "Old"]
    @test isordered(r) == true

    # Test concatenation of conflicting ordering. This drops the ordering
    a1 = ["Old", "Young", "Young"]
    a2 = ["Old", "Young", "Middle", "Young"]
    ca1 = CA(a1, ordered=true)
    ca2 = CA(a2, ordered=true)
    levels!(ca1, ["Young", "Middle", "Old"])
    # ca2 has another order
    r = vcat(ca1, ca2)
    @test r == A(vcat(a1, a2))
    @test levels(r) == ["Young", "Middle", "Old"]
    @test isordered(r) == false


    # Test similar()

    x = CA(["Old", "Young", "Middle", "Young"])
    y = similar(x)
    @test typeof(x) === typeof(y)
    @test size(y) == size(x)

    x = CA(["Old", "Young", "Middle", "Young"])
    y = similar(x, 3)
    @test typeof(x) === typeof(y)
    @test size(y) == (3,)

    x = CA{String, 1, UInt8}(["Old", "Young", "Middle", "Young"])
    y = similar(x, Int)
    @test isa(y, CA{Int, 1, UInt8})
    @test size(y) == size(x)

    x = CA(["Old", "Young", "Middle", "Young"])
    y = similar(x, Int, 3, 2)
    @test isa(y, CA{Int, 2, CategoricalArrays.DefaultRefType})
    @test size(y) == (3, 2)


    # Test copy!()

    x = CA(["Old", "Young", "Middle", "Young"])
    levels!(x, ["Young", "Middle", "Old"])
    ordered!(x, true)
    y = CA(["X", "Z", "Y", "X"])
    @test copy!(x, y) === x
    @test x == y
    @test levels(x) == ["Young", "Middle", "Old", "X", "Y", "Z"]
    @test !isordered(x)

    x = CA(["Old", "Young", "Middle", "Young"])
    levels!(x, ["Young", "Middle", "Old"])
    ordered!(x, true)
    y = CA(["X", "Z", "Y", "X"])
    a = A(["Z", "Y", "X", "Young"])
    # Test with null values
    if CA === NullableCategoricalArray
        x[3] = Nullable()
        y[3] = a[2] = Nullable()
    end
    @test copy!(x, 1, y, 2) === x
    @test x == a
    @test levels(x) == ["Young", "Middle", "Old", "X", "Y", "Z"]
    @test !isordered(x)

    # Test that no corruption happens in case of bounds error
    @test_throws BoundsError copy!(x, 10, y, 2)
    @test x == a
    @test_throws BoundsError copy!(x, 1, y, 10)
    @test x == a
    @test_throws BoundsError copy!(x, 10, y, 20)
    @test x == a
    @test_throws BoundsError copy!(x, 10, y, 2)
    @test x == a
    @test_throws BoundsError copy!(x, 1, y, 2, 10)
    @test x == a
    @test_throws BoundsError copy!(x, 4, y, 1, 2)
    @test x == a
    @test_throws BoundsError copy!(x, 1, y, 4, 2)
    @test x == a

    for (sstart, dstart, n) in ((1, 1, 4), (1, 2, 3))
        # Conflicting orders: check that the destination wins and that result is not ordered
        x = CA(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CA(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["Old", "Middle", "Young"])
        ordered!(x, true)
        @test copy!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test !isordered(x)

        # Destination ordered, but not origin: check that destination wins
        x = CA(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CA(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["Young", "Middle", "Old"])
        @test copy!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test isordered(x)

        # Origin ordered, but not destination: check that destination wins
        x = CA(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        y = CA(["Middle", "Middle", "Old", "Young"])
        ordered!(y, true)
        levels!(y, ["Young", "Middle", "Old"])
        @test copy!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test !isordered(x)

        # Destination ordered, but not origin, and new levels: check that result is unordered
        x = CA(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CA(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["X", "Young", "Middle", "Old"])
        @test copy!(x, y) === x
        @test levels(x) == ["X", "Young", "Middle", "Old"]
        @test !isordered(x)
    end
end

end
