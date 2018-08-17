module TestArrayCommon
using Compat
using Compat.Test
@static if VERSION >= v"0.7.0-DEV.3208"
    using Future: copy!
end
using CategoricalArrays
using CategoricalArrays: DefaultRefType, index

const ≅ = isequal
const ≇ = !isequal

@testset "mergelevels()" begin
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
end

@testset "Testing $T" for T in (Union{}, Missing)
    @testset "vcat()" begin
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
        a1 = Array{Int}(undef, 2, 3, 4, 5)
        a2 = Array{Int}(undef, 3, 3, 4, 5)
        a1[1:end] = (length(a1):-1:1) .+ 2
        a2[1:end] = (1:length(a2)) .+ 10
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
    end

    @testset "similar()" begin
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        y = similar(x)
        @test typeof(x) === typeof(y)
        @test size(y) == size(x)
        if T === Missing
            @test all(ismissing, y)
        else
            @test !any(isassigned(y, i) for i in 1:length(y))
        end

        y = similar(x, 3)
        @test typeof(x) === typeof(y)
        @test size(y) == (3,)
        if T === Missing
            @test all(ismissing, y)
        else
            @test !any(isassigned(y, i) for i in 1:length(y))
        end

        y = similar(x, Int)
        @test isa(y, Vector{Int})
        @test size(y) == size(x)

        y = similar(x, Int, 3, 2)
        @test isa(y, Matrix{Int})
        @test size(y) == (3, 2)

        x = CategoricalArray{Union{T, String}, 1, UInt8}(["Old", "Young", "Middle", "Young"])
        y = similar(x, Union{T, CategoricalString})
        @test typeof(x) === typeof(y)
        @test size(y) == size(x)
        T === Missing && @test all(ismissing, y)

        y = similar(x, Union{T, CategoricalString{UInt32}})
        @test isa(y, CategoricalVector{Union{T, String}, UInt32})
        @test size(y) == size(x)
        T === Missing && @test all(ismissing, y)

        y = similar(x, Union{Missing, CategoricalString}, 3, 2)
        @test isa(y, CategoricalMatrix{Union{String, Missing}, UInt8})
        @test size(y) == (3, 2)
        @test all(ismissing, y)

        y = similar(x, CategoricalString)
        @test isa(y, CategoricalVector{String, UInt8})
        @test size(y) == size(x)
        @test !any(isassigned(y, i) for i in 1:length(y))

        y = similar(x, CategoricalString{UInt32})
        @test isa(y, CategoricalVector{String, UInt32})
        @test size(y) == size(x)
        @test !any(isassigned(y, i) for i in 1:length(y))

        y = similar(x, CategoricalValue{Int, UInt32})
        @test isa(y, CategoricalVector{Int, UInt32})
        @test size(y) == size(x)
    end

    @testset "copy! and copyto!" begin
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)

        for copyf! in (copy!, copyto!)
            y = CategoricalArray{Union{T, String}}(["X", "Z", "Y", "X"])
            @test copyf!(x, y) === x
            @test x == y
            @test levels(x) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x)
        end

        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CategoricalArray{Union{T, String}}(["X", "Z", "Y", "X"])
        a = (Union{String, Missing})["Z", "Y", "X", "Young"]
        # Test with missing values
        if T === Missing
            x[3] = missing
            y[3] = a[2] = missing
        end
        @test copyto!(x, 1, y, 2) === x
        @test x ≅ a
        @test levels(x) == ["Young", "Middle", "Old", "X", "Y", "Z"]
        @test !isordered(x)

        @testset "0-length copy!/copyto! does nothing (including bounds checks)" begin
            u = x[1:0]
            v = y[1:0]

            @test copyto!(x, 1, y, 3, 0) === x
            @test x ≅ a
            @test copyto!(x, 1, y, 5, 0) === x
            @test x ≅ a

            @test copyto!(u, -5, v, 2, 0) === u
            @test u ≅ v
            @test copyto!(x, -5, v, 2, 0) === x
            @test x ≅ a
            @test copyto!(u, v) === u
            @test u ≅ v
            @test copyto!(x, v) === x
            @test x ≅ a
            @test copy!(u, v) === u
            @test u ≅ v
            @test copy!(x, v) === x
            @test x ≅ a
        end

        @testset "nonzero-length copy!/copyto! into/from empty array throws bounds error" begin
            u = x[1:0]
            v = y[1:0]

            @test_throws BoundsError copy!(u, x)
            @test u ≅ v
            @test_throws BoundsError copyto!(u, x)
            @test u ≅ v
            @test_throws BoundsError copyto!(u, 1, v, 1, 1)
            @test u ≅ v
            @test_throws BoundsError copyto!(x, 1, v, 1, 1)
            @test x ≅ a
        end

        @testset "no corruption happens in case of bounds error" begin
            @test_throws BoundsError copyto!(x, 10, y, 2)
            @test x ≅ a
            @test_throws BoundsError copyto!(x, 1, y, 10)
            @test x ≅ a
            @test_throws BoundsError copyto!(x, 10, y, 20)
            @test x ≅ a
            @test_throws BoundsError copyto!(x, 10, y, 2)
            @test x ≅ a
            @test_throws BoundsError copyto!(x, 1, y, 2, 10)
            @test x ≅ a
            @test_throws BoundsError copyto!(x, 4, y, 1, 2)
            @test x ≅ a
            @test_throws BoundsError copyto!(x, 1, y, 4, 2)
            @test x ≅ a
        end
    end

    @testset "$copyf!" for copyf! in (copy!, copyto!)
        @testset "copy src not supporting missings into dest not supporting missings" begin
            v = ["a", "b", "c"]
            src = levels!(CategoricalVector(v), reverse(v))
            dest = CategoricalVector{String}(undef, 3)
            copyf!(dest, src)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)
        end

        @testset "copy src supporting missings into dest not supporting missings" begin
            v = ["a", "b", "c"]
            src = levels!(CategoricalVector{Union{Missing, String}}(v), reverse(v))
            dest = CategoricalVector{String}(undef, 3)
            copyf!(dest, src)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)
        end

        @testset "copy src not supporting missings into dest supporting missings" begin
            v = ["a", "b", "c"]
            src = levels!(CategoricalVector(v), reverse(v))
            dest = CategoricalVector{Union{String, Missing}}(undef, 3)
            copyf!(dest, src)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)
        end

        @testset "copy src supporting missings into dest supporting missings" begin
            v = ["a", "b", "c"]
            src = levels!(CategoricalVector{Union{String, Missing}}(v), reverse(v))
            dest = CategoricalVector{Union{String, Missing}}(undef, 3)
            copyf!(dest, src)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)
        end

        @testset "copy viewed src not supporting missings into dest not supporting missings" begin
            v = ["a", "b", "c"]
            src = levels!(CategoricalVector(v), reverse(v))
            vsrc = view(src, 1:length(src))
            dest = CategoricalVector{String}(undef, 3)
            copyf!(dest, vsrc)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)
        end

        @testset "copy viewed src supporting missings into dest not supporting missings" begin
            v = ["a", "b", "c"]
            src = levels!(CategoricalVector{Union{String, Missing}}(v), reverse(v))
            vsrc = view(src, 1:length(src))
            dest = CategoricalVector{String}(undef, 3)
            copyf!(dest, vsrc)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)
        end

        @testset "copy viewed src not supporting missings into dest supporting missings" begin
            v = ["a", "b", "c"]
            src = levels!(CategoricalVector(v), reverse(v))
            vsrc = view(src, 1:length(src))
            dest = CategoricalVector{Union{String, Missing}}(undef, 3)
            copyf!(dest, vsrc)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)
        end

        @testset "copy viewed src supporting missings into dest supporting missings" begin
            v = ["a", "b", "c"]
            src = levels!(CategoricalVector{Union{String, Missing}}(v), reverse(v))
            vsrc = view(src, 1:length(src))
            dest = CategoricalVector{Union{String, Missing}}(undef, 3)
            copyf!(dest, vsrc)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)
        end

        @testset "copy a viewed subset of src into dest" begin
            v = ["a", "b", "c"]
            src = levels!(CategoricalVector(v), reverse(v))
            vsrc = view(src, 1:2)
            dest = CategoricalVector{String}(undef, 3)
            copyf!(dest, vsrc)
            @test dest[1:2] == src[1:2]
            @test levels(dest) == levels(src)

            vsrc = view(src, 1:2)
            dest = CategoricalVector{String}(undef, 2)
            copyf!(dest, vsrc)
            @test dest == src[1:2]
            @test levels(dest) == levels(src)
        end

        @testset "copy a src into viewed dest" begin
            v = ["a", "b"]
            src = levels!(CategoricalVector(v), reverse(v))
            dest = CategoricalVector{String}(["e", "f", "g"])
            vdest = view(dest, 1:2)
            copyf!(vdest, src)
            @test dest[1:2] == src[1:2]
            @test levels(dest) == levels(vdest) == ["e", "f", "g", "b", "a"]

            dest = CategoricalVector{String}(["e", "f"])
            vdest = view(dest, 1:2)
            copyf!(vdest, src)
            @test vdest == src[1:2]
            @test levels(dest) == levels(vdest) == ["e", "f", "b", "a"]
        end

        @testset "copy a src into viewed dest and breaking orderedness" begin
            v = ["a", "b"]
            src = levels!(CategoricalVector(v), reverse(v))
            dest = CategoricalVector{String}(["e", "f", "g"], ordered=true)
            vdest = view(dest, 1:2)
            res = @test_throws ArgumentError copyf!(vdest, src)
            @test res.value.msg == "cannot set ordered=false on dest SubArray as it would affect the parent. " *
                "Found when trying to set levels to $(["e", "f", "g", "b", "a"])."
            @test dest[1:2] ==  ["e", "f"]
            @test levels(dest) == levels(vdest) == ["e", "f", "g"]
            @test isordered(dest) && isordered(vdest)

            dest = CategoricalVector{String}(["e", "f"], ordered=true)
            vdest = view(dest, 1:2)
            res = @test_throws ArgumentError copyf!(vdest, src)
            @test res.value.msg == "cannot set ordered=false on dest SubArray as it would affect the parent. " *
                "Found when trying to set levels to $(["e", "f", "b", "a"])."
            @test dest == ["e", "f"]
            @test levels(dest) == levels(vdest) == ["e", "f"]
            @test isordered(dest) && isordered(vdest)
        end

        @testset "viable mixed src and dest types" begin
            v = ["a", "b", "c"]
            src = CategoricalVector{Union{eltype(v), Missing}}(v)
            levels!(src, reverse(v))
            dest = CategoricalVector{String}(undef, 3)
            copyf!(dest, src)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)

            vsrc = view(src, 1:length(src))
            copyf!(dest, vsrc)
            @test dest == vsrc
            @test levels(dest) == levels(vsrc) == reverse(v)

            src = CategoricalVector{AbstractString}(v)
            levels!(src, reverse(v))
            dest = CategoricalVector{String}(undef, 3)
            copyf!(dest, src)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)

            src = CategoricalVector{String}(v)
            levels!(src, reverse(v))
            dest = CategoricalVector{AbstractString}(undef, 3)
            copyf!(dest, src)
            @test dest == src
            @test levels(dest) == levels(src) == reverse(v)
        end

        @testset "inviable mixed src and dest types" begin
            v = ["a", "b", missing]
            src = CategoricalVector(v)
            dest = CategoricalVector{String}(undef, 3)
            @test_throws MissingException copyf!(dest, src)

            vsrc = view(src, 1:length(src))
            @test_throws MissingException copyf!(dest, vsrc)

            v = Integer[-1, -2, -3]
            src = CategoricalVector(v)
            dest = CategoricalVector{UInt}(undef, 3)
            @test_throws InexactError copyf!(dest, src)
        end
    end

    @testset "resize!()" begin
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        @test resize!(x, 3) === x
        @test x == ["Old", "Young", "Middle"]
        @test resize!(x, 4) === x
        if T === Missing
            @test x ≅ ["Old", "Young", "Middle", missing]
        else
            @test x[1:3] == ["Old", "Young", "Middle"]
            @test !isassigned(x, 4)
        end
    end

    @testset "$copyf! and conflicting orders sstart=$sstart dstart=$dstart n=$n" for
        (sstart, dstart, n) in ((1, 1, 4), (1, 2, 3)),
        copyf! in (copy!, copyto!)
        # Conflicting orders: check that the destination wins and that result is not ordered
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["Old", "Middle", "Young"])
        ordered!(x, true)
        @test copyf!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test !isordered(x)

        # Destination ordered, but not origin: check that destination wins
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["Young", "Middle", "Old"])
        @test copyf!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test isordered(x)

        # Origin ordered, but not destination: check that destination wins
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        ordered!(y, true)
        levels!(y, ["Young", "Middle", "Old"])
        @test copyf!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test !isordered(x)

        # Origin ordered, destination ordered with no levels: check that result is ordered
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        ordered!(y, true)
        levels!(y, ["Young", "Middle", "Old"])
        x = similar(x)
        ordered!(x, true)
        @test copyf!(x, y) === x
        @test levels(x) == ["Young", "Middle", "Old"]
        @test isordered(x)

        # Destination ordered, but not origin, and new levels: check that result is unordered
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["X", "Young", "Middle", "Old"])
        @test copyf!(x, y) === x
        @test levels(x) == ["X", "Young", "Middle", "Old"]
        @test !isordered(x)
    end

    @testset "fill!()" begin
        x = CategoricalArray{Union{String, T}}(["a", "b", "c"])
        x2 = copy(x)
        @test fill!(x2, "a") === x2
        @test x2 == ["a", "a", "a"]
        @test levels(x2) == ["a", "b", "c"]

        @test fill!(x2, x[2]) == ["b", "b", "b"]
        @test levels(x2) == ["a", "b", "c"]

        x2 = copy(x)
        @test_throws MethodError fill!(x2, 3)
        @test x2 == x

        if T === Missing
            x2 = fill!(copy(x), missing)
            @test all(ismissing, x2)
        else
            @test_throws MethodError fill!(x2, missing)
            @test x2 == x
        end

        fill!(x2, "c")
        @test x2 == ["c", "c", "c"]
        @test levels(x2) == ["a", "b", "c"]

        fill!(x2, "0")
        @test x2 == ["0", "0", "0"]
        @test levels(x2) == ["a", "b", "c", "0"]
    end

    @testset "overflow of reftype is detected and doesn't corrupt data and levels" begin
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
    end

    @testset "compress()/decompress()" begin
        x = compress(CategoricalArray{Union{T, Int}}([1, 3, 736251]))
        ux = decompress(x)
        @test x == ux
        @test isa(x, CategoricalArray{Union{T, Int}, 1, UInt8})
        @test isa(ux, CategoricalArray{Union{T, Int}, 1, CategoricalArrays.DefaultRefType})
    end

    @testset "reshape()" begin
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

        # Test with missing values
        if T === Missing
            x[3] = missing
            y = reshape(x, 1, 4)
            @test isa(y, CategoricalArray{Union{T, String}, 2, CategoricalArrays.DefaultRefType})
            @test y ≅ ["Old" "Young" missing "Young"]
            @test levels(x) == levels(y)
            @test isordered(x)
        end
    end

    @testset "sort() on both unordered and ordered arrays" begin
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        @test sort(x) == ["Young", "Young", "Middle", "Old"]
        ordered!(x, true)
        @test sort(x) == ["Young", "Young", "Middle", "Old"]
        @test sort!(x) === x
        @test x == ["Young", "Young", "Middle", "Old"]
    end
end

@testset "constructors and convert() between categorical arrays, ordered_orig=$ordered_orig, ordered=$ordered, R=$R, T=$T, CVM2=$CVM2, N=$N" for ordered_orig in (true, false),
    ordered in (true, false),
    R in (DefaultRefType, UInt8, UInt, Int8, Int),
    T in (String, Union{String, Missing}),
    (CVM2, N) in ((CategoricalVector, 1), (CategoricalMatrix, 2))
    # check that ctors/converters preserve levels and ordering by default even across types,
    # do not modify original array when changing ordering, and make copies
    # only when necessary (though for construcors the pool is always copied because of ordered)
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
        @test y.refs !== x.refs
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
        @test y.refs !== x.refs
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
        @test y.refs !== x.refs
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
        @test y.refs !== x.refs
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

@testset "converting from array with missings to array without missings CategoricalArray fails with missings" begin
    x = CategoricalArray{Union{String, Missing}}(undef, 1)
    @test_throws MissingException CategoricalArray{String}(x)
    @test_throws MissingException convert(CategoricalArray{String}, x)
end

@testset "in($T, CategoricalArray{$T})" for T in (Int, Union{Int, Missing})
    ca1 = CategoricalArray{T}([1, 2, 3])
    ca2 = CategoricalArray{T}([4, 3, 2])

    @test (ca1[1] in ca1) === true
    @test (ca2[2] in ca1) === true
    @test (ca2[1] in ca1) === false

    @test (1 in ca1) === true
    @test (5 in ca1) === false
end

@testset "comparison" begin
    a1 = [1, 2, 3]
    a2 = Union{Int, Missing}[1, 2, 3]
    a3 = [1, 2, missing]
    a4 = [4, 3, 2]
    a5 = [1 2; 3 4]
    ca1 = CategoricalArray(a1)
    ca2 = CategoricalArray{Union{Int, Missing}}(a2)
    ca2b = CategoricalArray{Union{Int, Missing}, 1}(ca2.refs, ca2.pool)
    ca3 = CategoricalArray(a3)
    ca3b = CategoricalArray{Union{Int, Missing}, 1}(ca3.refs, ca2.pool)
    ca4 = CategoricalArray(a4)
    ca5 = CategoricalArray(a5)

    @testset "==" begin
        @test ca1 == copy(ca1) == a1
        @test ca2 == copy(ca2) == a2
        @test ismissing(ca3 == copy(ca3)) && ismissing(ca3 == ca3b) && ismissing(ca3 == a3)
        @test ca4 == copy(ca4) == a4
        @test ca5 == copy(ca5) == a5
        @test ca1 == ca2 == a2
        @test ismissing(ca1 != ca3) && ismissing(ca1 != a3)
        @test ca1 != ca4
        @test ca1 != a4
        @test a1 != ca4
        @test ca1 != ca5
        @test ca1 != a5
        @test a1 != ca5
        @test ca3 != ca4
        @test ca3 != a4
        @test a3 != ca4
        @test ismissing(ca2b != ca3b)
    end

    @testset "isequal()" begin
        @test ca1 ≅ copy(ca1) ≅ a1
        @test ca2 ≅ copy(ca2) ≅ a2
        @test ca3 ≅ copy(ca3) ≅ ca3b ≅ a3
        @test ca4 ≅ copy(ca4) ≅ a4
        @test ca5 ≅ copy(ca5) ≅ a5
        @test ca1 ≅ ca2 ≅ a2
        @test ca1 ≇ ca3 && ca1 ≇ a3
        @test ca1 ≇ ca4
        @test ca1 ≇ a4
        @test a1 ≇ ca4
        @test ca1 ≇ ca5
        @test ca1 ≇ a5
        @test a1 ≇ ca5
        @test ca3 ≇ ca4
        @test ca3 ≇ a4
        @test a3 ≇ ca4
        @test ca2b ≇ ca3b
    end
end

@testset "summary()" begin
    @test summary(CategoricalArray([1, 2, 3])) ==
        "3-element $CategoricalArray{$Int,1,UInt32}"
    @test summary(CategoricalArray{Union{Int, Missing}}([1 2 3])) ==
        "1×3 $CategoricalArray{$(Union{Missing, Int}),2,UInt32}"
end

@testset "vcat() takes into account element type even when array is empty" begin
    # or when both arrays have the same levels but of different types
    x = CategoricalVector{String}(undef, 0)
    y = CategoricalVector{Int}(undef, 0)
    z1 = CategoricalVector{Float64}([1.0])
    z2 = CategoricalVector{Int}([1])
    @inferred vcat(x, y)
    @test vcat(x, y) isa CategoricalVector{Any}
    @inferred vcat(x, z1)
    @test vcat(x, z1) isa CategoricalVector{Any}
    @inferred vcat(y, z1)
    @test vcat(y, z1) isa CategoricalVector{Float64}
    @inferred vcat(x, x)
    @test vcat(x, x) isa CategoricalVector{String}
    @inferred vcat(y, y)
    @test vcat(y, y) isa CategoricalVector{Int}
    @inferred vcat(z1, z1)
    @test vcat(z1, z1) isa CategoricalVector{Float64}
    @inferred vcat(z1, z2)
    @test vcat(z1, z2) isa CategoricalVector{Float64}
end

@testset "categorical() makes a copy of pool and refs" begin
    xs = Any[Int8[1:10;], [Int8[1:10;]; missing]]
    for x in xs, o1 in [true, false], o2 in [true, false], T in [Int64, Int8]
        y = categorical(x, ordered=o1)
        if x === xs[1]
            z = CategoricalArray{T}(y, ordered=o2)
        else
            z = CategoricalArray{Union{T, Missing}}(y, ordered=o2)
        end
        @test z.refs !== y.refs
        @test z.pool !== y.pool
    end
end

@testset "collect of CategoricalArray produces Array" begin
    x = [1,1,2,2]
    y = categorical(x)
    z = collect(y)
    @test typeof(x) == typeof(z)
    @test z == x

    x = [1,1,2,missing]
    y = categorical(x)
    z = collect(y)
    @test typeof(x) == typeof(z)
    @test z ≅ x
end

@testset "Array(::CategoricalArray{T}) produces Array{T}" begin
    x = [1,1,2,2]
    y = categorical(x)
    z = Array(y)
    @test typeof(x) == typeof(z)
    @test z == x

    x = [1,1,2,missing]
    y = categorical(x)
    z = Array(y)
    @test typeof(x) == typeof(z)
    @test z ≅ x
end

@testset "Array{T} constructors and convert" begin
    x = [1,1,2,2]
    y = categorical(x)
    z = Array{Int}(y)
    @test typeof(x) == typeof(z)
    @test z == x
    z = convert(Array{Int}, y)
    @test typeof(x) == typeof(z)
    @test z == x

    x = [1,1,2,missing]
    y = categorical(x)
    z = Array{Union{Int, Missing}}(y)
    @test typeof(x) == typeof(z)
    @test z ≅ x
    z = convert(Array{Union{Int, Missing}}, y)
    @test typeof(x) == typeof(z)
    @test z ≅ x
end

@testset "convert(AbstractArray{T}, x)" begin
    x = [1,1,2,2]
    y = categorical(x)
    z = convert(AbstractArray{Int}, y)
    @test typeof(x) == typeof(z)
    @test z == x

    x = [1,1,2,missing]
    y = categorical(x)
    z = convert(AbstractArray{Union{Int, Missing}}, y)
    @test typeof(x) == typeof(z)
    @test z ≅ x

    # Check that convert is a no-op when appropriate
    for x in (categorical([1,1,2,2]), categorical([1,1,2,missing]))
        y = convert(AbstractArray, x)
        @test x === y
        y = convert(AbstractVector, x)
        @test x === y
        y = convert(AbstractArray{eltype(x)}, x)
        @test x === y
        y = convert(AbstractArray{eltype(x), 1}, x)
        @test x === y
    end
end

@testset "new levels can't be added through assignment when levels are ordered" begin
    x = categorical([1,2,3])
    ordered!(x, true)
    lev = copy(levels(x))
    res = @test_throws OrderedLevelsException{Int, Float64} x[1] = 4.0
    @test res.value.newlevel == 4
    @test sprint(showerror, res.value) ==
        "cannot add new level 4.0 since ordered pools cannot be extended implicitly. " *
        "Use the levels! function to set new levels, or the ordered! function to mark the pool as unordered."
    @test lev == levels(x)

    # Assignment works after adding the level to the pool
    levels!(x, [3,4,1,2])
    x[1] = 4
    @test x == [4,2,3]
end

@testset "float() and complex()" begin
    x = categorical([1,2,3])
    @test float(x) == x
    @test float(x) isa Vector{Float64}

    x = categorical([1,2,3])
    @test complex(x) == x
    @test complex(x) isa Vector{Complex{Int}}

    @test_throws ErrorException float(categorical(Union{Int,Missing}[1]))
    @test_throws ErrorException complex(categorical(Union{Int,Missing}[1]))
end

@testset "droplevels" for a in (["a", "b", "c"], ["a", "b", missing, "c"])
    x = categorical(a)
    levels!(x, ["b", "c", "a"])
    @test droplevels!(x) === x
    @test levels(x) == ["b", "c", "a"]
    x[2] = "a"
    @test droplevels!(x) === x
    @test levels(x) == ["c", "a"]
end

@testset "show" begin
    x = categorical([2, 1])
    @test sprint((io,a)->show(io, "text/plain", a), x) ==
        """
        2-element $CategoricalArray{$Int,1,UInt32}:
         2
         1"""

    x = categorical([2, 1, missing])
    @test sprint((io,a)->show(io, "text/plain", a), x) ==
        """
        3-element $CategoricalArray{$(Union{Missing,Int}),1,UInt32}:
         2      
         1      
         missing"""
end

end
