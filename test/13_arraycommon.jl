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

    # Test that vcat of compress arrays uses a reftype that doesn't overflow
    a1 = 3:200
    a2 = 300:-1:100
    ca1 = CA(a1)
    ca2 = CA(a2)
    cca1 = compress(ca1)
    cca2 = compress(ca2)
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
    cca1 = compress(ca1)
    cca2 = compress(ca2)
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

        # Origin ordered, destination ordered with no levels: check that result is ordered
        y = CA(["Middle", "Middle", "Old", "Young"])
        ordered!(y, true)
        levels!(y, ["Young", "Middle", "Old"])
        x = similar(x)
        ordered!(x, true)
        @test copy!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test isordered(x)

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


    # Test that overflow of reftype is detected and doesn't corrupt data and levels

    res = @test_throws LevelsException{Int, UInt8} CA{Int, 1, UInt8}(256:-1:1)
    @test res.value.levels == [1]
    @test sprint(showerror, res.value) == "cannot store level(s) 1 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."

    x = CA{Int, 1, UInt8}(254:-1:1)
    x[1] = 1000
    res = @test_throws LevelsException{Int, UInt8} x[1] = 1001
    @test res.value.levels == [1001]
    @test sprint(showerror, res.value) == "cannot store level(s) 1001 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."
    @test x == A(vcat(1000, 253:-1:1))
    @test levels(x) == vcat(1:254, 1000)

    x = CA{Int, 1, UInt8}(1:254)
    res = @test_throws LevelsException{Int, UInt8} x[1:2] = 1000:1001
    @test res.value.levels == [1001]
    @test sprint(showerror, res.value) == "cannot store level(s) 1001 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."
    @test x == A(vcat(1000, 2:254))
    @test levels(x) == vcat(1:254, 1000)

    x = CA{Int, 1, UInt8}([1, 3, 256])
    res = @test_throws LevelsException{Int, UInt8} levels!(x, collect(1:256))
    @test res.value.levels == [255]
    @test sprint(showerror, res.value) == "cannot store level(s) 255 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."

    x = CA(30:2:131115)
    res = @test_throws LevelsException{Int, UInt16} CategoricalVector{Int, UInt16}(x)
    @test res.value.levels == collect(131100:2:131114)
    @test sprint(showerror, res.value) == "cannot store level(s) 131100, 131102, 131104, 131106, 131108, 131110, 131112 and 131114 since reference type UInt16 can only hold 65535 levels. Use the decompress function to make room for more levels."

    x = CA{String, 1, UInt8}(string.(Char.(65:318)))
    res = @test_throws LevelsException{String, UInt8} levels!(x, vcat(levels(x), "az", "bz", "cz"))
    @test res.value.levels == ["bz", "cz"]
    @test sprint(showerror, res.value) == "cannot store level(s) \"bz\" and \"cz\" since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."
    @test x == A(string.(Char.(65:318)))
    lev = copy(levels(x))
    levels!(x, vcat(lev, "az"))
    @test levels(x) == vcat(lev, "az")

    x = compress(CA([1, 3, 736251]))
    ux = decompress(x)
    @test x == ux
    @test typeof(x) == CA{Int, 1, UInt8}
    @test typeof(ux) == CA{Int, 1, CategoricalArrays.DefaultRefType}
end

end
