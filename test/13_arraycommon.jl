module TestArrayCommon

using Base.Test
using CategoricalArrays
using Nulls
using CategoricalArrays: DefaultRefType, index
using Compat

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


for T in (Union{}, Null)
    # Test vcat()

    # Test that vcat of compress arrays uses a reftype that doesn't overflow
    a1 = 3:200
    a2 = 300:-1:100
    ca1 = CategoricalArray{Union{T, Int}}(a1)
    ca2 = CategoricalArray{Union{T, Int}}(a2)
    cca1 = compress(ca1)
    cca2 = compress(ca2)
    r = vcat(cca1, cca2)
    @test r == vcat(a1, a2)
    @test isa(cca1, CategoricalArray{Union{T, Int}, 1, UInt8})
    @test isa(cca2, CategoricalArray{Union{T, Int}, 1, UInt8})
    @test isa(r, CategoricalArray{Union{T, Int}, 1, CategoricalArrays.DefaultRefType})
    @test isa(vcat(cca1, ca2), CategoricalArray{Union{T, Int}, 1, CategoricalArrays.DefaultRefType})
    @test isordered(r) == false
    @test levels(r) == collect(3:300)

    # Test vcat of multidimensional arrays
    a1 = Array{Int}(2, 3, 4, 5)
    a2 = Array{Int}(3, 3, 4, 5)
    a1[1:end] = (length(a1):-1:1) + 2
    a2[1:end] = (1:length(a2)) + 10
    ca1 = CategoricalArray{Union{T, Int}}(a1)
    ca2 = CategoricalArray{Union{T, Int}}(a2)
    cca1 = compress(ca1)
    cca2 = compress(ca2)
    r = vcat(cca1, cca2)
    @test r == vcat(a1, a2)
    @test isa(r, CategoricalArray{Union{T, Int}, 4, CategoricalArrays.DefaultRefType})
    @test isordered(r) == false
    @test levels(r) == collect(3:length(a2)+10)

    # Test concatenation of mutually compatible levels
    a1 = ["Young", "Middle"]
    a2 = ["Middle", "Old"]
    ca1 = CategoricalArray{Union{T, String}}(a1, ordered=true)
    ca2 = CategoricalArray{Union{T, String}}(a2, ordered=true)
    @test levels!(ca1, ["Young", "Middle"]) === ca1
    @test levels!(ca2, ["Middle", "Old"]) === ca2
    r = vcat(ca1, ca2)
    @test r == vcat(a1, a2)
    @test levels(r) == ["Young", "Middle", "Old"]
    @test isordered(r) == true

    # Test concatenation of conflicting ordering. This drops the ordering
    a1 = ["Old", "Young", "Young"]
    a2 = ["Old", "Young", "Middle", "Young"]
    ca1 = CategoricalArray{Union{T, String}}(a1, ordered=true)
    ca2 = CategoricalArray{Union{T, String}}(a2, ordered=true)
    levels!(ca1, ["Young", "Middle", "Old"])
    # ca2 has another order
    r = vcat(ca1, ca2)
    @test r == vcat(a1, a2)
    @test levels(r) == ["Young", "Middle", "Old"]
    @test isordered(r) == false


    # Test similar()

    x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
    y = similar(x)
    @test typeof(x) === typeof(y)
    @test size(y) == size(x)

    x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
    y = similar(x, 3)
    @test typeof(x) === typeof(y)
    @test size(y) == (3,)

    x = CategoricalArray{Union{T, String}, 1, UInt8}(["Old", "Young", "Middle", "Young"])
    y = similar(x, Int)
    @test isa(y, CategoricalArray{Int, 1, UInt8})
    @test size(y) == size(x)

    x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
    y = similar(x, Int, 3, 2)
    @test isa(y, CategoricalArray{Int, 2, CategoricalArrays.DefaultRefType})
    @test size(y) == (3, 2)


    # Test copy!()

    x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
    levels!(x, ["Young", "Middle", "Old"])
    ordered!(x, true)
    y = CategoricalArray{Union{T, String}}(["X", "Z", "Y", "X"])
    @test copy!(x, y) === x
    @test x == y
    @test levels(x) == ["Young", "Middle", "Old", "X", "Y", "Z"]
    @test !isordered(x)

    x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
    levels!(x, ["Young", "Middle", "Old"])
    ordered!(x, true)
    y = CategoricalArray{Union{T, String}}(["X", "Z", "Y", "X"])
    a = (?String)["Z", "Y", "X", "Young"]
    # Test with null values
    if T === Null
        x[3] = null
        y[3] = a[2] = null
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

    # Test resize!()
    x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
    @test resize!(x, 3) === x
    @test x == ["Old", "Young", "Middle"]
    @test resize!(x, 4) === x
    if T === Null
        @test x == ["Old", "Young", "Middle", null]
    else
        @test x[1:3] == ["Old", "Young", "Middle"]
        @test !isassigned(x, 4)
    end

    for (sstart, dstart, n) in ((1, 1, 4), (1, 2, 3))
        # Conflicting orders: check that the destination wins and that result is not ordered
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["Old", "Middle", "Young"])
        ordered!(x, true)
        @test copy!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test !isordered(x)

        # Destination ordered, but not origin: check that destination wins
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["Young", "Middle", "Old"])
        @test copy!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test isordered(x)

        # Origin ordered, but not destination: check that destination wins
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        ordered!(y, true)
        levels!(y, ["Young", "Middle", "Old"])
        @test copy!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test !isordered(x)

        # Origin ordered, destination ordered with no levels: check that result is ordered
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        ordered!(y, true)
        levels!(y, ["Young", "Middle", "Old"])
        x = similar(x)
        ordered!(x, true)
        @test copy!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test isordered(x)

        # Destination ordered, but not origin, and new levels: check that result is unordered
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["X", "Young", "Middle", "Old"])
        @test copy!(x, y) === x
        @test levels(x) == ["X", "Young", "Middle", "Old"]
        @test !isordered(x)
    end


    # Test that overflow of reftype is detected and doesn't corrupt data and levels

    res = @test_throws LevelsException{Int, UInt8} CategoricalArray{Union{T, Int}, 1, UInt8}(256:-1:1)
    @test res.value.levels == [1]
    @test sprint(showerror, res.value) == "cannot store level(s) 1 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."

    x = CategoricalArray{Union{T, Int}, 1, UInt8}(254:-1:1)
    x[1] = 1000
    res = @test_throws LevelsException{Int, UInt8} x[1] = 1001
    @test res.value.levels == [1001]
    @test sprint(showerror, res.value) == "cannot store level(s) 1001 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."
    @test x == vcat(1000, 253:-1:1)
    @test levels(x) == vcat(1:254, 1000)

    x = CategoricalArray{Union{T, Int}, 1, UInt8}(1:254)
    res = @test_throws LevelsException{Int, UInt8} x[1:2] = 1000:1001
    @test res.value.levels == [1001]
    @test sprint(showerror, res.value) == "cannot store level(s) 1001 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."
    @test x == vcat(1000, 2:254)
    @test levels(x) == vcat(1:254, 1000)

    x = CategoricalArray{Union{T, Int}, 1, UInt8}([1, 3, 256])
    res = @test_throws LevelsException{Int, UInt8} levels!(x, collect(1:256))
    @test res.value.levels == [255]
    @test sprint(showerror, res.value) == "cannot store level(s) 255 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."

    x = CategoricalArray{Union{T, Int}}(30:2:131115)
    res = @test_throws LevelsException{Int, UInt16} CategoricalVector{Int, UInt16}(x)
    @test res.value.levels == collect(131100:2:131114)
    @test sprint(showerror, res.value) == "cannot store level(s) 131100, 131102, 131104, 131106, 131108, 131110, 131112 and 131114 since reference type UInt16 can only hold 65535 levels. Use the decompress function to make room for more levels."

    x = CategoricalArray{Union{T, String}, 1, UInt8}(string.(Char.(65:318)))
    res = @test_throws LevelsException{String, UInt8} levels!(x, vcat(levels(x), "az", "bz", "cz"))
    @test res.value.levels == ["bz", "cz"]
    @test sprint(showerror, res.value) == "cannot store level(s) \"bz\" and \"cz\" since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."
    @test x == string.(Char.(65:318))
    lev = copy(levels(x))
    levels!(x, vcat(lev, "az"))
    @test levels(x) == vcat(lev, "az")

    x = compress(CategoricalArray{Union{T, Int}}([1, 3, 736251]))
    ux = decompress(x)
    @test x == ux
    @test isa(x, CategoricalArray{Union{T, Int}, 1, UInt8})
    @test isa(ux, CategoricalArray{Union{T, Int}, 1, CategoricalArrays.DefaultRefType})

    # Test reshape()
    x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
    levels!(x, ["Young", "Middle", "Old"])
    ordered!(x, true)

    y = reshape(x, 1, 4)
    @test isa(y, CategoricalArray{Union{T, String}, 2, CategoricalArrays.DefaultRefType})
    @test y == ["Old" "Young" "Middle" "Young"]
    @test levels(x) == levels(y)
    @test isordered(x)

    y = reshape(x, 2, 2)
    @test isa(y, CategoricalArray{Union{T, String}, 2, CategoricalArrays.DefaultRefType})
    @test y == ["Old"  "Middle"; "Young" "Young"]
    @test levels(x) == levels(y)
    @test isordered(x)

    # Test with null values
    if T === Null
        x[3] = null
        y = reshape(x, 1, 4)
        @test isa(y, CategoricalArray{Union{T, String}, 2, CategoricalArrays.DefaultRefType})
        @test y == ["Old" "Young" null "Young"]
        @test levels(x) == levels(y)
        @test isordered(x)
    end

    # Test sort() on both unordered and ordered arrays
    x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
    levels!(x, ["Young", "Middle", "Old"])
    @test sort(x) == ["Young", "Young", "Middle", "Old"]
    ordered!(x, true)
    @test sort(x) == ["Young", "Young", "Middle", "Old"]
    @test sort!(x) === x
    @test x == ["Young", "Young", "Middle", "Old"]

    # Test constructors and convert() between categorical arrays:
    # check that they preserve levels and ordering by default even across types,
    # do not modify original array when changing ordering, and make copies
    # only when necessary (though for construcors the pool is always copied because of ordered)
    for ordered_orig in (true, false),
        ordered in (true, false),
        R in (DefaultRefType, UInt8, UInt, Int8, Int),
        T in (String, ?String),
        (CVM2, N) in ((CategoricalVector, 1), (CategoricalMatrix, 2))
        if CVM2 <: AbstractVector
            x = CategoricalArray{T, N, R}(["A", "B"], ordered=ordered_orig)
        else
            x = CategoricalArray{T, N, R}(["A" "B"], ordered=ordered_orig)
        end

        # Do not use lexicographic order in order to catch bugs about order preservation
        levels!(x, ["B", "A"])

        for y in (CategoricalArray(x),
                  CategoricalArray{T}(x),
                  CategoricalArray{T, N}(x),
                  CategoricalArray{T, N, R}(x),
                  CategoricalArray{T, N, DefaultRefType}(x),
                  CategoricalArray{T, N, UInt8}(x),
                  CVM2(x),
                  CVM2{T}(x),
                  CVM2{T, R}(x),
                  CVM2{T, DefaultRefType}(x),
                  CVM2{T, UInt8}(x))
            @test isa(y, CVM2{T})
            @test isordered(y) === isordered(x)
            @test isordered(x) === ordered_orig
            @test y.refs == x.refs
            @test index(y.pool) == index(x.pool)
            @test levels(y) == levels(x)
            @test (y.refs === x.refs) == (eltype(x.refs) === eltype(y.refs))
            @test y.pool !== x.pool
        end
        for y in (categorical(x),
                  categorical(x, false),
                  categorical(x, true))
            @test isa(y, CategoricalArray{T, N})
            @test isordered(y) === isordered(x)
            @test isordered(x) === ordered_orig
            @test y.refs == x.refs
            @test index(y.pool) == index(x.pool)
            @test levels(y) == levels(x)
            @test (y.refs === x.refs) == (eltype(x.refs) === eltype(y.refs))
            @test y.pool !== x.pool
        end
        for y in (CategoricalArray(x, ordered=ordered),
                  CategoricalArray{T}(x, ordered=ordered),
                  CategoricalArray{T, N}(x, ordered=ordered),
                  CategoricalArray{T, N, R}(x, ordered=ordered),
                  CategoricalArray{T, N, DefaultRefType}(x, ordered=ordered),
                  CategoricalArray{T, N, UInt8}(x, ordered=ordered),
                  CVM2(x, ordered=ordered),
                  CVM2{T}(x, ordered=ordered),
                  CVM2{T, R}(x, ordered=ordered),
                  CVM2{T, DefaultRefType}(x, ordered=ordered),
                  CVM2{T, UInt8}(x, ordered=ordered))
            @test isa(y, CVM2{T})
            @test isordered(y) === ordered
            @test isordered(x) === ordered_orig
            @test y.refs == x.refs
            @test index(y.pool) == index(x.pool)
            @test levels(y) == levels(x)
            @test (y.refs === x.refs) == (eltype(x.refs) === eltype(y.refs))
            @test y.pool !== x.pool
        end
        for y in (categorical(x, ordered=ordered),
                  categorical(x, false, ordered=ordered),
                  categorical(x, true, ordered=ordered))
            @test isa(y, CategoricalArray{T, N})
            @test isordered(y) === ordered
            @test isordered(x) === ordered_orig
            @test y.refs == x.refs
            @test index(y.pool) == index(x.pool)
            @test levels(y) == levels(x)
            @test (y.refs === x.refs) == (eltype(x.refs) === eltype(y.refs))
            @test y.pool !== x.pool
        end
        for y in (convert(CategoricalArray, x),
                  convert(CategoricalArray{T}, x),
                  convert(CategoricalArray{T, N}, x),
                  convert(CategoricalArray{T, N, R}, x),
                  convert(CategoricalArray{T, N, DefaultRefType}, x),
                  convert(CategoricalArray{T, N, UInt8}, x))
            @test isa(y, CVM2{T})
            @test isordered(y) === isordered(x)
            @test isordered(x) === ordered_orig
            @test y.refs == x.refs
            @test index(y.pool) == index(x.pool)
            @test levels(y) == levels(x)
            @test (y.refs === x.refs) == (eltype(x.refs) === eltype(y.refs))
            @test (y.pool === x.pool) == (eltype(x.refs) === eltype(y.refs))
        end
    end
end

# Check that converting from nullable to non-nullable CategoricalArray fails with nulls
x = CategoricalArray{?String}(1)
@test_throws NullException CategoricalArray{String}(x)
@test_throws NullException convert(CategoricalArray{String}, x)


# Test in()
for T in (Int, ?Int)
    ca1 = CategoricalArray{T}([1, 2, 3])
    ca2 = CategoricalArray{T}([4, 3, 2])

    @test (ca1[1] in ca1) === true
    @test (ca2[2] in ca1) === true
    @test (ca2[1] in ca1) === false

    @test (1 in ca1) === true
    @test (5 in ca1) === false
end

# Test ==
ca1 = CategoricalArray([1, 2, 3])
ca2 = CategoricalArray{?Int}([1, 2, 3])
ca3 = CategoricalArray([1, 2, null])
ca4 = CategoricalArray([4, 3, 2])
ca5 = CategoricalArray([1 2; 3 4])

@test ca1 == copy(ca1)
@test ca2 == copy(ca2)
@test ca3 == copy(ca3)
@test ca4 == copy(ca4)
@test ca5 == copy(ca5)
@test ca1 == ca2
@test ca1 != ca3
@test ca1 != ca4
@test ca1 != ca5

end
