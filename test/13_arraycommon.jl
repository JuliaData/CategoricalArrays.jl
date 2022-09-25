module TestArrayCommon
using Test
using Missings
using Future: copy!
using CategoricalArrays, DataAPI
using CategoricalArrays: DefaultRefType, pool
using PooledArrays
using JSON3
using StructTypes
using RecipesBase
using Plots
using SentinelArrays

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
    # by giving priority to first sets of levels
    @test CategoricalArrays.mergelevels(true, [6, 3, 4, 7], [2, 3, 6, 5, 4], [2, 4, 8]) ==
        ([2, 6, 3, 5, 4, 7, 8], false)
    @test CategoricalArrays.mergelevels(true, ["A", "C", "D"], ["D", "C"], []) ==
        (["A", "C", "D"], false)
    @test CategoricalArrays.mergelevels(true, ["A", "D", "C"], ["A", "B", "C"], ["A", "D", "E"], ["C", "D"]) ==
        (["A", "B", "D", "C", "E"], false)

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

    @testset "undef constructors preserve reftype" begin
        x = CategoricalArray{Union{T, CategoricalValue{Int, UInt8}}}(undef, 3)
        @test x isa CategoricalArray{Union{T, Int}, 1, UInt8}

        x = CategoricalArray{Union{T, CategoricalValue{Int, UInt8}}, 1}(undef, 3)
        @test x isa CategoricalArray{Union{T, Int}, 1, UInt8}
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
        y = similar(x, Union{T, CategoricalValue{String}})
        @test typeof(x) === typeof(y)
        @test size(y) == size(x)
        T === Missing && @test all(ismissing, y)

        y = similar(x, Union{T, CategoricalValue{String, UInt32}})
        @test isa(y, CategoricalVector{Union{T, String}, UInt32})
        @test size(y) == size(x)
        T === Missing && @test all(ismissing, y)

        y = similar(x, Union{Missing, CategoricalValue{String}}, 3, 2)
        @test isa(y, CategoricalMatrix{Union{String, Missing}, UInt8})
        @test size(y) == (3, 2)
        @test all(ismissing, y)

        y = similar(x, CategoricalValue{String})
        @test isa(y, CategoricalVector{String, UInt8})
        @test size(y) == size(x)
        @test !any(isassigned(y, i) for i in 1:length(y))

        y = similar(x, CategoricalValue{String, UInt32})
        @test isa(y, CategoricalVector{String, UInt32})
        @test size(y) == size(x)
        @test !any(isassigned(y, i) for i in 1:length(y))

        y = similar(x, CategoricalValue{Int, UInt32})
        @test isa(y, CategoricalVector{Int, UInt32})
        @test size(y) == size(x)

        y = similar([], Union{CategoricalValue{Int}, T}, (3,))
        @test isa(y, CategoricalVector{Union{Int, T}, UInt32})
        @test size(y) == (3,)

        y = similar([], Union{CategoricalValue{String}, T}, (3,))
        @test isa(y, CategoricalVector{Union{String, T}, UInt32})
        @test size(y) == (3,)

        y = similar([], Union{CategoricalValue{Int, UInt8}, T}, (3,))
        @test isa(y, CategoricalVector{Union{Int, T}, UInt8})
        @test size(y) == (3,)

        y = similar([], Union{CategoricalValue{String, UInt8}, T}, (3,))
        @test isa(y, CategoricalVector{Union{String, T}, UInt8})
        @test size(y) == (3,)

        y = similar(Vector{Union{CategoricalValue{Int}, T}}, (3,))
        @test isa(y, CategoricalVector{Union{Int, T}, UInt32})
        @test size(y) == (3,)

        y = similar(Vector{Union{CategoricalValue{String}, T}}, (3,))
        @test isa(y, CategoricalVector{Union{String, T}, UInt32})
        @test size(y) == (3,)

        y = similar(Vector{Union{CategoricalValue{Int, UInt8}, T}}, (3,))
        @test isa(y, CategoricalVector{Union{Int, T}, UInt8})
        @test size(y) == (3,)

        y = similar(Vector{Union{CategoricalValue{String, UInt8}, T}}, (3,))
        @test isa(y, CategoricalVector{Union{String, T}, UInt8})
        @test size(y) == (3,)

        y = similar(Vector{T}, (3,))
        @test isa(y, Vector{T})
        @test size(y) == (3,)

        y = similar(1:1, Union{CategoricalValue{String, UInt8}, T})
        @test isa(y, CategoricalVector{Union{String, T}, UInt8})
        @test size(y) == (1,)

        y = similar(1:1, Union{CategoricalValue{String, UInt8}, T}, (3,))
        @test isa(y, CategoricalVector{Union{String, T}, UInt8})
        @test size(y) == (3,)
    end

    @testset "copy" begin
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)

        y = copy(x)
        @test y == x
        levels!(y, ["Z", "Middle", "Old", "Young"])
        y[1] = "Z"
        @test x == ["Old", "Young", "Middle", "Young"]
        @test levels(x) == ["Young", "Middle", "Old"]

        # Test with missing values
        if T === Missing
            x[3] = missing
            @test copy(x) ≅ x
        end
    end

    @testset "copy! and copyto!" for ordered in (false, true)
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, ordered)
        y = CategoricalArray{Union{T, String}}(["X", "Z", "Y", "X"])

        for copyf! in (copy!, copyto!)
            x2 = copy(x)
            @test copyf!(x2, y) === x2
            @test x2 == y
            @test levels(x2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x2)
        end

        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, ordered)
        x2 = copy(x)
        y = CategoricalArray{Union{T, String}}(["X", "Z", "Y", "X"])
        a = Union{String, Missing}["Z", "Y", "X", "Young"]
        # Test with missing values
        if T === Missing
            x[3] = x2[3] = missing
            y[3] = a[2] = missing
        end
        @test copyto!(x2, 1, y, 2) === x2
        @test x2 ≅ a
        @test levels(x2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
        @test !isordered(x2)

        @testset "0-length copy!/copyto!" begin
            # 0-length copy!/copyto! does nothing (including bounds checks) except setting levels
            u = x[1:0]
            v = y[1:0]

            x2 = copy(x)
            @test copyto!(x2, 1, y, 3, 0) === x2
            @test levels(x2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x2)
            @test x2 ≅ x

            x2 = copy(x)
            @test copyto!(x2, 1, y, 5, 0) === x2
            @test levels(x2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x2)
            @test x2 ≅ x

            u2 = copy(u)
            @test copyto!(u2, -5, v, 2, 0) === u2
            @test levels(u2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x2)
            @test isempty(u2)

            x2 = copy(x)
            @test copyto!(x2, -5, v, 2, 0) === x2
            @test levels(x2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x2)
            @test x2 ≅ x

            u2 = copy(u)
            @test copyto!(u2, v) === u2
            @test levels(u2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x2)
            @test isempty(u2)

            x2 = copy(x)
            @test copyto!(x2, v) === x2
            @test levels(x2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x2)
            @test x2 ≅ x

            u2 = copy(u)
            @test copy!(u2, v) === u2
            @test levels(u2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x2)
            @test isempty(u2)

            x2 = copy(x)
            @test copy!(x2, v) === x2
            @test levels(x2) == ["Young", "Middle", "Old", "X", "Y", "Z"]
            @test !isordered(x2)
            @test x2 ≅ x

            # test with zero-levels source
            x2 = copy(x)
            @test copy!(x2, categorical(String[])) === x2
            @test levels(x2) == ["Young", "Middle", "Old"]
            @test isordered(x2) === ordered
            @test x2 ≅ x

            # test with zero-levels destination
            for ordered2 in (true, false)
                x2 = CategoricalArray{String}(undef, 2, ordered=ordered2)
                @test copy!(x2, u) === x2
                @test levels(x2) == ["Young", "Middle", "Old"]
                @test isordered(x2) === ordered
                @test length(x2) == 2
                @test !any(isassigned(x2, i) for i in eachindex(x2))
            end

            # test with zero-levels source and destination
            for ordered2 in (true, false)
                x2 = CategoricalArray{String}(undef, 2, ordered=ordered2)
                @test copy!(x2, categorical(String[], ordered=ordered)) === x2
                @test isempty(levels(x2))
                @test isordered(x2) === ordered2
                @test length(x2) == 2
                @test !any(isassigned(x2, i) for i in eachindex(x2))
            end
        end

        @testset "nonzero-length copy!/copyto! into/from empty array throws bounds error" begin
            u = x[1:0]
            v = y[1:0]
            x2 = copy(x)

            @test_throws BoundsError copy!(u, x)
            @test u ≅ v
            @test_throws BoundsError copyto!(u, x)
            @test u ≅ v
            @test_throws BoundsError copyto!(u, 1, v, 1, 1)
            @test u ≅ v
            @test_throws BoundsError copyto!(x2, 1, v, 1, 1)
            @test x2 ≅ x
        end

        @testset "no corruption happens in case of bounds error" begin
            @test_throws BoundsError copyto!(x2, 10, y, 2)
            @test x2 ≅ x
            @test_throws BoundsError copyto!(x2, 1, y, 10)
            @test x2 ≅ x
            @test_throws BoundsError copyto!(x2, 10, y, 20)
            @test x2 ≅ x
            @test_throws BoundsError copyto!(x2, 10, y, 2)
            @test x2 ≅ x
            @test_throws BoundsError copyto!(x2, 1, y, 2, 10)
            @test x2 ≅ x
            @test_throws BoundsError copyto!(x2, 4, y, 1, 2)
            @test x2 ≅ x
            @test_throws BoundsError copyto!(x2, 1, y, 4, 2)
            @test x2 ≅ x
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

            # Destination without any levels should be marked as ordered
            src = levels!(CategoricalVector(v, ordered=true), reverse(v))
            dest = CategoricalVector{Union{String,Missing}}([missing, missing])
            vdest = view(dest, 1:2)
            copyf!(vdest, src)
            @test dest ≅ src
            @test levels(vdest) == levels(dest)
            @test isordered(dest)
        end

        @testset "copy a src into viewed dest and breaking orderedness" begin
            v = ["a", "b"]
            src = levels!(CategoricalVector(v), reverse(v))
            dest = CategoricalVector{String}(["e", "f", "g"], ordered=true)
            vdest = view(dest, 1:2)
            copyf!(vdest, src)
            @test dest[1:2] == ["a", "b"]
            @test levels(dest) == levels(vdest) == ["e", "f", "g", "b", "a"]
            @test !isordered(dest) && !isordered(vdest)

            dest = CategoricalVector{String}(["e", "f"], ordered=true)
            vdest = view(dest, 1:2)
            copyf!(vdest, src)
            @test dest == ["a", "b"]
            @test levels(dest) == levels(vdest) == ["e", "f", "b", "a"]
            @test !isordered(dest) && !isordered(vdest)
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

        @testset "partial copyto! between arrays with identical levels" begin
            v = ["a", "b", "c"]
            src = CategoricalVector{Union{eltype(v), Missing}}(v)
            levels!(src, reverse(v))
            dest = CategoricalVector{Union{eltype(v), Missing}}(fill(missing, 6))
            levels!(dest, levels(src))
            copyto!(dest, 3, src)
            @test dest ≅ [missing, missing, "a", "b", "c", missing]
            @test levels(dest) == levels(src) == reverse(v)
            copyto!(dest, 3, src, 2, 1)
            @test dest ≅ [missing, missing, "b", "b", "c", missing]
            @test levels(dest) == levels(src) == reverse(v)
        end
    end

    @testset "assigning into array with empty levels uses orderedness of source" begin
        # destination is marked as ordered when source is ordered
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)

        for copyf! in (copyto!, copy!)
            y = CategoricalArray{Union{T, String}}(undef, 4)
            copyf!(y, x)
            @test isordered(y)
            @test levels(y) == levels(x)
            if T >: Missing
                y = CategoricalArray{Union{T, String}}(fill(missing, 4))
                copyf!(y, x)
                @test isordered(y)
                @test levels(y) == levels(x)
            end
        end

        y = CategoricalArray{Union{T, String}}(undef, 4)
        y[1] = x[1]
        @test isordered(y)
        @test levels(y) == levels(x)
        if T >: Missing
            y = CategoricalArray{Union{T, String}}(fill(missing, 4))
            y[1] = x[1]
            @test isordered(y)
            @test levels(y) == levels(x)
        end

        # destination is marked as unordered when source is unordered
        ordered!(x, false)

        for copyf! in (copyto!, copy!)
            y = CategoricalArray{Union{T, String}}(undef, 4)
            ordered!(y, true)
            copyf!(y, x)
            @test !isordered(y)
            @test levels(y) == levels(x)
            if T >: Missing
                y = CategoricalArray{Union{T, String}}(fill(missing, 4))
                ordered!(y, true)
                copyf!(y, x)
                @test !isordered(y)
                @test levels(y) == levels(x)
            end
        end

        y = CategoricalArray{Union{T, String}}(undef, 4)
        y[1] = x[1]
        @test !isordered(y)
        @test levels(y) == levels(x)
        if T >: Missing
            y = CategoricalArray{Union{T, String}}(fill(missing, 4))
            y[1] = x[1]
            @test !isordered(y)
            @test levels(y) == levels(x)
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
        @test x == y
        @test levels(x) == ["Young", "Middle", "Old"]
        @test !isordered(x)

        # Destination ordered, but not origin: check that destination wins
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["Young", "Middle", "Old"])
        @test copyf!(x, y) === x
        @test x == y
        @test levels(x) == ["Young", "Middle", "Old"]
        @test isordered(x)

        # Origin ordered, but not destination: check that destination wins
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        ordered!(y, true)
        levels!(y, ["Young", "Middle", "Old"])
        @test copyf!(x, y) === x
        @test x == y
        @test levels(x) == ["Young", "Middle", "Old"]
        @test !isordered(x)

        # Origin ordered, destination ordered with no levels: check that result is ordered
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        ordered!(y, true)
        levels!(y, ["Young", "Middle", "Old"])
        x = similar(x)
        ordered!(x, true)
        @test copyf!(x, y) === x
        @test x == y
        @test levels(x) == ["Young", "Middle", "Old"]
        @test isordered(x)

        # Destination ordered, but not origin, and new levels: check that result is unordered
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        ordered!(x, true)
        y = CategoricalArray{Union{T, String}}(["Middle", "Middle", "Old", "Young"])
        levels!(y, ["X", "Young", "Middle", "Old"])
        copyf!(x, y)
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

        y = categorical(["d", "e"])
        ordered!(y, true)
        levels!(y, ["0", "e", "d"])
        fill!(x2, y[1])
        @test x2 == ["d", "d", "d"]
        @test levels(x2) == ["a", "b", "c", "0", "e", "d"]

        x3 = similar(x2)
        fill!(x3, y[1])
        @test x3 == ["d", "d", "d"]
        @test levels(x3) == ["0", "e", "d"]
        @test isordered(x3)
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
        @test res.value.levels == [256]
        @test sprint(showerror, res.value) == "cannot store level(s) 256 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."

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

    @testset "sort" begin
        x = CategoricalArray{Union{T, String}}(["Old", "Young", "Middle", "Young"])
        levels!(x, ["Young", "Middle", "Old"])
        @test sort(x) == ["Young", "Young", "Middle", "Old"]
        ordered!(x, true)
        @test sort(x) == ["Young", "Young", "Middle", "Old"]
        @test sort!(x) === x
        @test x == ["Young", "Young", "Middle", "Old"]

        if T !== Missing
            v = rand(["a", "b", "c", "d"], 1000)
        else
            v = rand(["a", "b", "c", "d", missing], 1000)
        end

        for rev in (true, false)
            cv = categorical(v)
            sv = sort(v, rev=rev)

            @test sort(cv, rev=rev) ≅ sv
            @test sort!(cv, rev=rev) === cv ≅ sv

            cv = categorical(v)
            levels!(cv, ["b", "a", "c", "d"])
            @test sort(cv, rev=rev) ≅
                ["b", "a", "c", "d", missing][sort([5; 1:4][cv.refs .+ 1], rev=rev)]

            levels!(cv, ["x", "z", "b", "a", "y", "c", "d", "0"])
            @test sort(cv, rev=rev) ≅
                ["x", "z", "b", "a", "y", "c", "d", "0", missing][sort([9; 1:8][cv.refs .+ 1], rev=rev)]

            cv = categorical(v)
            @test sort(cv, rev=rev, lt=(x, y) -> isless(y, x)) ≅
                sort(cv, rev=!rev) ≅
                sort(cv, order=Base.Sort.ord((x, y) -> isless(y, x), identity, rev))

            # Function changing order
            byf1 = x -> ismissing(x) ? "c" : (x == "a" ? "z" : "b")
            @test sort(cv, rev=rev, by=byf1) ≅ sort(cv, rev=rev, by=byf1)

            # Check that by function is not called on unused levels/missing
            byf2 = x -> (@assert get(x) != "b"; x)
            replace!(cv, missing=>"a", "b"=>"a")
            @test sort(cv, rev=rev, by=byf2) ≅ sort(cv, rev=rev, by=byf2)
        end
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
        @test levels(y) == levels(x)
        @test y.refs !== x.refs
        @test y.pool !== x.pool
    end
    for y in (@inferred(categorical(x)),
              categorical(x, compress=false),
              categorical(x, compress=true))
        @test isa(y, CategoricalArray{T, N})
        @test isordered(y) === isordered(x)
        @test isordered(x) === ordered_orig
        @test y.refs == x.refs
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
        @test levels(y) == levels(x)
        @test y.refs !== x.refs
        @test y.pool !== x.pool
    end
    for y in (@inferred(categorical(x, ordered=ordered)),
              categorical(x, compress=false, ordered=ordered),
              categorical(x, compress=true, ordered=ordered))
        @test isa(y, CategoricalArray{T, N})
        @test isordered(y) === ordered
        @test isordered(x) === ordered_orig
        @test y.refs == x.refs
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
        @test levels(y) == levels(x)
        @test (y.refs === x.refs) == (eltype(x.refs) === eltype(y.refs))
        @test (y.pool === x.pool) == (eltype(x.refs) === eltype(y.refs))
    end
end

@testset "levels argument to constructors" begin
    for T in (String, Union{String, Missing}),
        ord in (false, true),
        levs in (nothing, [], ["a"], ["b", "c", "a"])
        for (U, x) in ((String, CategoricalArray(undef, 2, levels=levs, ordered=ord)),
                        (T, CategoricalArray{T}(undef, 2, levels=levs, ordered=ord)),
                        (T, CategoricalArray{T, 1}(undef, 2, levels=levs, ordered=ord)),
                        (T, CategoricalArray{T, 1, UInt32}(undef, 2, levels=levs, ordered=ord)),
                        (String, CategoricalVector(undef, 2, levels=levs, ordered=ord)),
                        (T, CategoricalVector{T}(undef, 2, levels=levs, ordered=ord)),
                        (T, CategoricalVector{T, UInt32}(undef, 2, levels=levs, ordered=ord)),
                        (String, CategoricalArray(undef, 2, 3, levels=levs, ordered=ord)),
                        (T, CategoricalArray{T}(undef, 2, 3, levels=levs, ordered=ord)),
                        (T, CategoricalArray{T, 2}(undef, 2, 3, levels=levs, ordered=ord)),
                        (T, CategoricalArray{T, 2, UInt32}(undef, 2, 3, levels=levs, ordered=ord)),
                        (String, CategoricalMatrix(undef, 2, 3, levels=levs, ordered=ord)),
                        (T, CategoricalMatrix{T}(undef, 2, 3, levels=levs, ordered=ord)),
                        (T, CategoricalMatrix{T, UInt32}(undef, 2, 3, levels=levs, ordered=ord)))
            @test x isa CategoricalArray{U, <:Any, UInt32}
            if U >: Missing
                @test all(ismissing, x)
            else
                @test !any(i -> isassigned(x, i), eachindex(x))
            end
            @test levels(x) == something(levs, [])
            @test isordered(x) === ord
            @test CategoricalArrays.pool(x).levels !== levs
        end

        for v in (T["b", "c", "a"], categorical(T["b", "c", "a"]))
            if levs === nothing || unique(v) ⊆ levs
                for x in (categorical(v, levels=levs, ordered=ord),
                          CategoricalArray(v, levels=levs, ordered=ord),
                          CategoricalArray{T}(v, levels=levs, ordered=ord),
                          CategoricalArray{T, 1}(v, levels=levs, ordered=ord),
                          CategoricalArray{T, 1, UInt32}(v, levels=levs, ordered=ord),
                          CategoricalVector(v, levels=levs, ordered=ord),
                          CategoricalVector{T}(v, levels=levs, ordered=ord),
                          CategoricalVector{T, UInt32}(v, levels=levs, ordered=ord),
                          CategoricalArray(v, levels=levs, ordered=ord))
                        @test x isa CategoricalVector{T, UInt32}
                        @test x == v
                        @test levels(x) == something(levs, sort!(unique(x)))
                        @test isordered(x) === ord
                        @test CategoricalArrays.pool(x).levels !== levs
                end
            else
                @test_throws ArgumentError categorical(v, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalArray(v, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalArray{T}(v, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalArray{T, 1}(v, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalArray{T, 1, UInt32}(v, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalVector(v, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalVector{T}(v, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalVector{T, UInt32}(v, levels=levs, ordered=ord)
            end
        end

        for m in (T["c" "b"; "a" "b"], categorical(T["c" "b"; "a" "b"]))
            if levs === nothing || unique(m) ⊆ levs
                for x in (categorical(m, levels=levs, ordered=ord),
                          CategoricalArray{T}(m, levels=levs, ordered=ord),
                          CategoricalArray{T, 2}(m, levels=levs, ordered=ord),
                          CategoricalArray{T, 2, UInt32}(m, levels=levs, ordered=ord),
                          CategoricalMatrix(m, levels=levs, ordered=ord),
                          CategoricalMatrix{T}(m, levels=levs, ordered=ord),
                          CategoricalMatrix{T, UInt32}(m, levels=levs, ordered=ord))
                    @test x isa CategoricalMatrix{T, UInt32}
                    @test x == m
                    @test levels(x) == something(levs, sort!(unique(x)))
                    @test isordered(x) === ord
                    @test CategoricalArrays.pool(x).levels !== levs
                end
            else
                @test_throws ArgumentError categorical(m, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalArray(m, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalArray{T}(m, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalArray{T, 2}(m, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalArray{T, 2, UInt32}(m, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalMatrix(m, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalMatrix{T}(m, levels=levs, ordered=ord)
                @test_throws ArgumentError CategoricalMatrix{T, UInt32}(m, levels=levs, ordered=ord)
            end
        end
    end
end

@testset "constructors with SubString" begin
    for x in ([SubString("ab", 1, 1), SubString("c", 1, 1)],
              SubString[SubString("ab", 1, 1), SubString("c", 1, 1)],
              [SubString("ab", 1, 1), "c"]),
        f in (CategoricalArray, CategoricalVector, categorical)
        y = @inferred f(x)
        @test y isa CategoricalArray{String}
        @test y == x

        y = @inferred f(allowmissing(x))
        @test y isa CategoricalArray{Union{String, Missing}}
        @test y == x
    end

    for x in ([SubString("ab", 1, 1) SubString("c", 1, 1)],
              SubString[SubString("ab", 1, 1) SubString("c", 1, 1)],
              [SubString("ab", 1, 1) "c"]),
        f in (CategoricalArray, CategoricalMatrix, categorical)
        y = @inferred f(x)
        @test y isa CategoricalArray{String}
        @test y == x

        y = @inferred f(allowmissing(x))
        @test y isa CategoricalArray{Union{String, Missing}}
        @test y == x
    end
end

@testset "constructors from arrays with unsupported eltypes" begin
    for (CT, a) in zip((CategoricalVector, CategoricalMatrix),
                        ([1, 2, 3], [1 2 3])),
        f in (categorical, CategoricalArray, CT,
                x -> convert(CategoricalArray, x),
                x -> convert(CT, x)),
        T in (Any, Union{Int, Symbol}, Union{Real, Symbol, Missing})
        x = f(collect(T, a))
        @test x isa CT{Int}
        @test x == categorical(a)
    end
    for (CT, a) in zip((CategoricalVector, CategoricalMatrix),
                        ([1, missing, 3], [1 missing 3])),
        f in (categorical, CategoricalArray, CT,
                x -> convert(CategoricalArray, x),
                x -> convert(CT, x)),
        T in (Any, Union{Int, Symbol, Missing}, Union{Real, Symbol, Missing})
        x = f(collect(T, a))
        @test x isa CT{Union{Int, Missing}}
        @test x ≅ categorical(a)
    end

    for f in (categorical, CategoricalArray, CategoricalVector,
              x -> convert(CategoricalArray, x),
              x -> convert(CategoricalVector, x))
        @test_throws ArgumentError f([:a])
        @test_throws ArgumentError f(Any[:a])
        @test_throws ArgumentError f([nothing])
        @test_throws ArgumentError f(Any[nothing])
        @test_throws ArgumentError f([1, nothing])
    end
    for f in (categorical, CategoricalArray, CategoricalMatrix,
              x -> convert(CategoricalArray, x),
              x -> convert(CategoricalMatrix, x))
        @test_throws ArgumentError f([:a :a])
        @test_throws ArgumentError f(Any[:a :a])
        @test_throws ArgumentError f([nothing nothing])
        @test_throws ArgumentError f(Any[nothing nothing])
        @test_throws ArgumentError f([1 nothing])
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
    if VERSION > v"1.2.0-DEV"
        @inferred vcat(x, y)
    end
    @test vcat(x, y) isa CategoricalVector{Union{String, Int}}
    if VERSION > v"1.2.0-DEV"
        @inferred vcat(x, z1)
    end
    @test vcat(x, z1) isa CategoricalVector{Union{String, Float64}}
    if VERSION > v"1.2.0-DEV"
        @inferred vcat(y, z1)
    end
    @test vcat(y, z1) isa CategoricalVector{Float64}
    if VERSION > v"1.2.0-DEV"
        @inferred vcat(x, x)
    end
    @test vcat(x, x) isa CategoricalVector{String}
    if VERSION > v"1.2.0-DEV"
        @inferred vcat(y, y)
    end
    @test vcat(y, y) isa CategoricalVector{Int}
    if VERSION > v"1.2.0-DEV"
        @inferred vcat(z1, z1)
    end
    @test vcat(z1, z1) isa CategoricalVector{Float64}
    if VERSION > v"1.2.0-DEV"
        @inferred vcat(z1, z2)
    end
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

@testset "collect of CategoricalArray produces CategoricalArray" begin
    x = [1,1,2,2]
    y = categorical(x)
    for z in (collect(y), collect(eltype(y), y), collect(Iterators.take(y, 4)))
        @test typeof(y) == typeof(z)
        @test z == y == x
    end

    x = [1,1,2,missing]
    y = categorical(x)
    for z in (collect(y), collect(eltype(y), y), collect(Iterators.take(y, 4)))
        @test typeof(y) == typeof(z)
        @test z ≅ y ≅ x
    end
end

@testset "collect for SkipMissing" begin
    for x in (categorical([1, missing, 3, missing, 2]),
              view(categorical([2, 1, missing, 3, missing, 2]), 2:6),
              categorical([1 missing; 3 missing]),
              view(categorical([2 1; missing 3; missing 2]), 2:3, :),
              categorical(fill(1)))
        levels!(x, [2, 1, 3, 4])
        res = collect(skipmissing(x))
        @test res == collect(skipmissing(unwrap.(x)))
        @test res isa CategoricalVector{Int, UInt32}
        @test levels(x) == [2, 1, 3, 4]
    end

    x = categorical(Array{Union{Int,Missing}, 0}(undef))
    x[1] = 1
    levels!(x, [2, 1, 3, 4])
    res = collect(skipmissing(x))
    @test res isa CategoricalVector{Int, UInt32}
    @test res == [1]
    @test levels(x) == [2, 1, 3, 4]

    x = categorical(Array{Union{Int,Missing}, 0}(missing))
    levels!(x, [2, 1, 3, 4])
    res = collect(skipmissing(x))
    @test res isa CategoricalVector{Int, UInt32}
    @test isempty(res)
    @test levels(x) == [2, 1, 3, 4]

    res = collect(skipmissing(categorical(fill(missing))))
    @test res isa CategoricalVector{Union{}, UInt32}
    @test isempty(res)
    @test levels(x) == [2, 1, 3, 4]
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

@testset "DataAPI.refarray constructors and copyto!" begin
    for y1 in (CategoricalVector{Int}(undef, 6),
               CategoricalVector([1, 2, 1, 1, 3, 2], levels=[2, 1, 3]),
               CategoricalVector([2, 2, 2, 2, 2, 2], levels=[2]),
               CategoricalVector([2, 2, 2, 2, 2, 2], levels=[3, 1, 2, 4]),
               CategoricalVector([1, 2, 1, 3, 3, 2], levels=[3, 1, 2, 4]),
               CategoricalVector(Float64[2, 3, 1, 2, 2, 1], levels=[3, 1, 2]),
               view(CategoricalVector([3, 1, 2, 1, 1, 2, 2, 3], levels=[3, 1, 2, 4]), 2:7)),
        x in (PooledArray([3, 1, 2, 1, 1, 3]),
              PooledArray(PooledArrays.RefArray([3, 1, 2, 1, 1, 3]), Dict(1=>1, 0=>2, 3=>3, 2=>4)),
              PooledArray(PooledArrays.RefArray([3, 1, 4, 1, 1, 3]), Dict(1=>1, missing=>2, 3=>3, 2=>4)))
        levs = levels(y1)

        y2 = deepcopy(y1)
        @test copyto!(y2, x) === y2
        @test x == y2
        @test levels(y2) == [levs; sort!(setdiff(unique(x), levs))]

        y2 = deepcopy(y1)
        @test copy!(y2, x) === y2
        @test x == y2
        @test levels(y2) == [levs; sort!(setdiff(unique(x), levs))]

        y2 = deepcopy(y1)
        @test copyto!(y2, 1, x, 1, length(x)) === y2
        @test x == y2
        @test levels(y2) == [levs; sort!(setdiff(unique(x), levs))]

        y2 = deepcopy(y1)
        @test copyto!(y2, 2, x, 3, 3) === y2
        @test x[3:5] ≅ y2[2:4]
        @test levels(y2) == [levs; sort!(setdiff(unique(x[3:5]), levs))]

        y2 = deepcopy(y1)
        @test copyto!(y2, 2, x[3:end]) === y2
        @test x[3:6] ≅ y2[2:5]
        @test levels(y2) == [levs; sort!(setdiff(unique(x[3:6]), levs))]
    end

    for y1 in (CategoricalVector{Union{Int, Missing}}(undef, 6),
               CategoricalVector([1, 2, missing, 1, 3, 2], levels=[2, 1, 3]),
               CategoricalVector([2, 2, missing, 2, 2, 2], levels=[2]),
               CategoricalVector([2, 2, missing, 2, 2, 2], levels=[3, 1, 2, 4]),
               CategoricalVector([1, 2, missing, 3, 3, 2], levels=[3, 1, 2, 4]),
               CategoricalVector(Union{Float64, Missing}[2, 3, missing, 2, 2, 1], levels=[3, 1, 2]),
               view(CategoricalVector([3, 1, 2, missing, 1, 2, 2, 3], levels=[3, 1, 2, 4]), 2:7),
               view(CategoricalVector([3, 1, 2, 1, 1, 2, 2, missing], levels=[3, 1, 2, 4]), 2:7)),
         x in (PooledArray([3, 1, 2, 1, missing, 3]),
               PooledArray(PooledArrays.RefArray([3, 1, 2, 1, 1, 3]), Dict(1=>1, 0=>2, 3=>3, 2=>4)),
               PooledArray(PooledArrays.RefArray([3, 1, 4, 1, 1, 3]), Dict(1=>1, missing=>2, 3=>3, 2=>4)))
        levs = levels(y1)

        y2 = deepcopy(y1)
        @test copyto!(y2, x) === y2
        @test x ≅ y2
        @test levels(y2) == [levs; sort!(setdiff(skipmissing(unique(x)), levs))]

        y2 = deepcopy(y1)
        @test copy!(y2, x) === y2
        @test x ≅ y2
        @test levels(y2) == [levs; sort!(setdiff(skipmissing(unique(x)), levs))]

        y2 = deepcopy(y1)
        @test copyto!(y2, 1, x, 1, length(x)) === y2
        @test x ≅ y2
        @test levels(y2) == [levs; sort!(setdiff(skipmissing(unique(x)), levs))]

        y2 = deepcopy(y1)
        @test copyto!(y2, 2, x, 3, 3) === y2
        @test x[3:5] ≅ y2[2:4]
        @test levels(y2) == [levs; sort!(setdiff(skipmissing(unique(x[3:5])), levs))]

        y2 = deepcopy(y1)
        @test copyto!(y2, 2, x[3:6]) === y2
        @test x[3:6] ≅ y2[2:5]
        @test levels(y2) == [levs; sort!(setdiff(skipmissing(unique(x[3:6])), levs))]
    end

    x = PooledArray(["c", missing, "b", "c", "b", "a"])
    y = CategoricalVector{String}(undef, length(x))
    @test_throws MethodError copyto!(y, x)
    @test_throws MethodError copy!(y, x)
    @test_throws MethodError copyto!(y, 1, x, 1, length(x))
    y = CategoricalVector{Union{Missing, Int}}(undef, length(x))
    @test_throws MethodError copyto!(y, x)
    @test_throws MethodError copy!(y, x)
    @test_throws MethodError copyto!(y, 1, x, 1, length(x))
end

@testset "copyto! from CategoricalArray" begin
    vecs = (CategoricalVector([1, 2, 1, 1, 3, 2], levels=[2, 1, 3]),
            CategoricalVector([2, 2, 2, 2, 2, 2], levels=[2]),
            CategoricalVector([2, 2, 2, 2, 2, 2], levels=[3, 1, 2, 4]),
            CategoricalVector([1, 2, 1, 3, 3, 2], levels=[3, 1, 2, 4]),
            CategoricalVector(Float64[2, 3, 1, 2, 2, 1], levels=[3, 1, 2]),
            view(CategoricalVector([3, 1, 2, 1, 1, 2, 2, 3], levels=[3, 1, 2, 4]), 2:7))
    for y1 in vecs, x in vecs
        levs = levels(y1)
        newlevs, _ = CategoricalArrays.mergelevels(false, levs, levels(x))

        y2 = deepcopy(y1)
        @test copyto!(y2, x) === y2
        @test x == y2
        @test levels(y2) == newlevs

        y2 = deepcopy(y1)
        @test copy!(y2, x) === y2
        @test x == y2
        @test levels(y2) == newlevs

        y2 = deepcopy(y1)
        @test copyto!(y2, 1, x, 1, length(x)) === y2
        @test x == y2
        @test levels(y2) == newlevs

        y2 = deepcopy(y1)
        @test copyto!(y2, 2, x, 3, 3) === y2
        @test x[3:5] ≅ y2[2:4]
        @test levels(y2) == newlevs

        y2 = deepcopy(y1)
        @test copyto!(y2, 2, x[3:end]) === y2
        @test x[3:6] ≅ y2[2:5]
        @test levels(y2) == newlevs
    end

    vecs = (CategoricalVector{Union{Int, Missing}}(undef, 6),
            CategoricalVector([1, 2, missing, 1, 3, 2], levels=[2, 1, 3]),
            CategoricalVector([2, 2, missing, 2, 2, 2], levels=[2]),
            CategoricalVector([2, 2, missing, 2, 2, 2], levels=[3, 1, 2, 4]),
            CategoricalVector([1, 2, missing, 3, 3, 2], levels=[3, 1, 2, 4]),
            CategoricalVector(Union{Float64, Missing}[2, 3, missing, 2, 2, 1], levels=[3, 1, 2]),
            view(CategoricalVector([3, 1, 2, missing, 1, 2, 2, 3], levels=[3, 1, 2, 4]), 2:7),
            view(CategoricalVector([3, 1, 2, 1, 1, 2, 2, missing], levels=[3, 1, 2, 4]), 2:7))
    for y1 in vecs, x in vecs
        levs = levels(y1)
        newlevs, _ = CategoricalArrays.mergelevels(false, levs, levels(x))

        y2 = deepcopy(y1)
        @test copyto!(y2, x) === y2
        @test x ≅ y2
        @test levels(y2) == newlevs

        y2 = deepcopy(y1)
        @test copy!(y2, x) === y2
        @test x ≅ y2
        @test levels(y2) == newlevs

        y2 = deepcopy(y1)
        @test copyto!(y2, 1, x, 1, length(x)) === y2
        @test x ≅ y2
        @test levels(y2) == newlevs

        y2 = deepcopy(y1)
        @test copyto!(y2, 2, x, 3, 3) === y2
        @test x[3:5] ≅ y2[2:4]
        @test levels(y2) == newlevs

        y2 = deepcopy(y1)
        @test copyto!(y2, 2, x[3:6]) === y2
        @test x[3:6] ≅ y2[2:5]
        @test levels(y2) == newlevs
    end
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
    x .= "a"
    @test droplevels!(x) === x
    @test levels(x) == ["a"]
end

@testset "show" begin
    x = categorical([2, 1])
    @test sprint((io,a)->show(io, "text/plain", a), x) ==
        """
        2-element $CategoricalArray{$Int,1,UInt32}:
         2
         1"""

    x = categorical([2, 1, missing])
    if VERSION >= v"1.4-DEV"
        @test sprint((io,a)->show(io, "text/plain", a), x) ==
            """
            3-element $CategoricalArray{$(Union{Missing,Int}),1,UInt32}:
             2
             1
             missing"""
    else
        @test sprint((io,a)->show(io, "text/plain", a), x) ==
            """
            3-element $CategoricalArray{$(Union{Missing,Int}),1,UInt32}:
             2      
             1      
             missing"""
    end
end

@testset "broadcast" for x in (CategoricalArray(1:3),
                               CategoricalArray{Union{Int,Missing}}(1:3),
                               CategoricalArray(["a", "b", "c"]),
                               CategoricalArray(["a", missing, "c"]),
                               CategoricalArray([missing, "b", "c"]))
    y = identity.(x)
    @test x ≅ y
    @test x !== y
    @test y isa CategoricalArray

    y = broadcast(v->v, x)
    @test x ≅ y
    @test x !== y
    @test y isa CategoricalArray

    y = broadcast(v->x[3], x)
    @test x !== y
    @test y isa CategoricalArray

    y = broadcast(v->1, x)
    @test y == [1, 1, 1]
    @test y isa Vector{Int}

    x[1:2] .= x[3]
    @test x == fill(x[3], 3)
end

@testset "append! ordered=$ordered" for ordered in (false, true)
    @testset "append! String" begin
        a = ["a", "b", "c"]
        x = CategoricalVector{String}(a, ordered=ordered)

        append!(x, x)
        @test length(x) == 6
        @test x == ["a", "b", "c", "a", "b", "c"]
        @test isordered(x) === ordered
        @test levels(x) == ["a", "b", "c"]

        b = ["z","y","x"]
        y = CategoricalVector{String}(b)
        ordered!(x, ordered)
        append!(x, y)
        @test !isordered(x)
        @test length(x) == 9
        @test x == ["a", "b", "c", "a", "b", "c", "z", "y", "x"]
        @test levels(x) == ["a", "b", "c", "x", "y", "z"]

        z1 = view(CategoricalVector{String}(["ex1", "ex2"]), 1)
        z2 = view(CategoricalVector{String}(["ex3", "ex4"]), 1:1)
        ordered!(x, ordered)
        append!(x, z1)
        append!(x, z2)
        @test !isordered(x)
        @test length(x) == 11
        @test x == ["a", "b", "c", "a", "b", "c", "z", "y", "x", "ex1", "ex3"]
        @test levels(x) == ["a", "b", "c", "x", "y", "z", "ex1", "ex2", "ex3", "ex4"]
    end

    @testset "append! Float64" begin
        a = [-1.0, 0.0, 1.0]
        x = CategoricalVector{Float64}(a, ordered=ordered)

        append!(x, x)
        @test length(x) == 6
        @test x == [-1.0, 0.0, 1.0, -1.0, 0.0, 1.0]
        @test isordered(x) === ordered
        @test levels(x) == [-1.0, 0.0, 1.0]

        b = [2.5, 3.0, 3.5]
        y = CategoricalVector{Float64}(b, ordered=ordered)
        append!(x, y)
        @test length(x) == 9
        @test x == [-1.0, 0.0, 1.0, -1.0, 0.0, 1.0, 2.5, 3.0, 3.5]
        @test !isordered(x)
        @test levels(x) == [-1.0, 0.0, 1.0, 2.5, 3.0, 3.5]

        z1 = view(CategoricalVector{Float64}([100.0, 101.0]), 1)
        z2 = view(CategoricalVector{Float64}([102.0, 103.0]), 1:1)
        ordered!(x, ordered)
        append!(x, z1)
        append!(x, z2)
        @test length(x) == 11
        @test x == [-1.0, 0.0, 1.0, -1.0, 0.0, 1.0, 2.5, 3.0, 3.5, 100.0, 102.0]
        @test !isordered(x)
        @test levels(x) == [-1.0, 0.0, 1.0, 2.5, 3.0, 3.5, 100.0, 101.0, 102.0, 103.0]
    end
end

@testset "append! ordered=$ordered" for ordered in (false, true)
    cases = (["b", "a", missing], Union{String, Missing}["b", "a", "b"])
    @testset "String, has missing: $(any(ismissing.(a)))" for a in cases
        x = CategoricalVector{Union{String, Missing}}(a, ordered=ordered)

        append!(x, x)
        @test x ≅ [a; a]
        @test levels(x) == ["a", "b"]
        @test isordered(x) === ordered
        @test length(x) == 6

        b = ["x","y",missing]
        y = CategoricalVector{Union{String, Missing}}(b)
        ordered!(x, ordered)
        append!(x, y)
        @test length(x) == 9
        @test !isordered(x)
        @test levels(x) == ["a", "b", "x", "y"]
        @test x ≅ [a; a; b]

        z1 = view(CategoricalVector{Union{String, Missing}}([missing, "ex2"]), 1)
        z2 = view(CategoricalVector{Union{String, Missing}}(["ex3", "ex4"]), 1:1)
        ordered!(x, ordered)
        append!(x, z1)
        append!(x, z2)
        @test length(x) == 11
        @test !isordered(x)
        @test levels(x) == ["a", "b", "x", "y", "ex2", "ex3", "ex4"]
        @test x ≅ [a; a; b; missing; "ex3"]
    end

    @testset "Float64" begin
        a = 0.0:0.5:1.0
        x = CategoricalVector{Union{Float64, Missing}}(a, ordered=ordered)

        append!(x, x)
        @test length(x) == 6
        @test x == [a; a]
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0]

        b = [2.5, 3.0, missing]
        y = CategoricalVector{Union{Float64, Missing}}(b)
        ordered!(x, ordered)
        append!(x, y)
        @test length(x) == 9
        @test x ≅ [a; a; b]
        @test !isordered(x)
        @test levels(x) == [0.0, 0.5, 1.0, 2.5, 3.0]

        z1 = view(CategoricalVector{Union{Float64, Missing}}([missing, 101.0]), 1)
        z2 = view(CategoricalVector{Union{Float64, Missing}}([102.0, 103.0]), 1:1)
        ordered!(x, ordered)
        append!(x, z1)
        append!(x, z2)
        @test length(x) == 11
        @test x ≅ [a; a; b; missing; 102.0]
        @test !isordered(x)
        @test levels(x) == [0.0, 0.5, 1.0, 2.5, 3.0, 101.0, 102.0, 103.0]
    end
end

@testset "push! ordered=$ordered" for ordered in (false, true)
    @testset "push! String" begin
        a = ["a", "b", "c"]
        x = CategoricalVector{String}(a, ordered=ordered)

        push!(x, "a")
        @test x == ["a", "b", "c", "a"]
        @test isordered(x) === ordered
        @test levels(x) == ["a", "b", "c"]

        push!(x, "z")
        @test !isordered(x)
        @test x == ["a", "b", "c", "a", "z"]
        @test levels(x) == ["a", "b", "c", "z"]

        b = ["z","y","x"]
        y = CategoricalVector{String}(b)
        ordered!(x, ordered)
        push!(x, y[1])
        @test !isordered(x)
        @test x == ["a", "b", "c", "a", "z", "z"]
        @test levels(x) == ["a", "b", "c", "x", "y", "z"]
    end

    @testset "push! Float64" begin
        a = [-1.0, 0.0, 1.0]
        x = CategoricalVector{Float64}(a, ordered=ordered)

        push!(x, 0.0)
        @test x == [-1.0, 0.0, 1.0, 0.0]
        @test isordered(x) === ordered
        @test levels(x) == [-1.0, 0.0, 1.0]

        push!(x, 3.0)
        @test x == [-1.0, 0.0, 1.0, 0.0, 3.0]
        @test !isordered(x)
        @test levels(x) == [-1.0, 0.0, 1.0, 3.0]

        b = [2.5, 3.0, 3.5]
        y = CategoricalVector{Float64}(b, ordered=ordered)
        ordered!(x, ordered)
        push!(x, y[1])
        @test x == [-1.0, 0.0, 1.0, 0.0, 3.0, 2.5]
        @test !isordered(x)
        @test levels(x) == [-1.0, 0.0, 1.0, 2.5, 3.0, 3.5]
    end
end

@testset "insert! ordered=$ordered" for ordered in (false, true)
    @testset "insert! String" begin
        a = ["a", "b", "c"]
        x = CategoricalVector{String}(a, ordered=ordered)

        insert!(x, 4, "a")
        @test x == ["a", "b", "c", "a"]
        @test isordered(x) === ordered
        @test levels(x) == ["a", "b", "c"]

        insert!(x, 5, "z")
        @test !isordered(x)
        @test x == ["a", "b", "c", "a", "z"]
        @test levels(x) == ["a", "b", "c", "z"]

        b = ["z","y","x"]
        y = CategoricalVector{String}(b)
        ordered!(x, ordered)
        insert!(x, 6, y[1])
        @test !isordered(x)
        @test x == ["a", "b", "c", "a", "z", "z"]
        insert!(x, 1, "b")
        @test x == ["b", "a", "b", "c", "a", "z", "z"]
        @test levels(x) == ["a", "b", "c", "x", "y", "z"]
    end

    @testset "insert! Float64" begin
        a = [-1.0, 0.0, 1.0]
        x = CategoricalVector{Float64}(a, ordered=ordered)

        insert!(x, 4, 0.0)
        @test x == [-1.0, 0.0, 1.0, 0.0]
        @test isordered(x) === ordered
        @test levels(x) == [-1.0, 0.0, 1.0]

        insert!(x, 5, 3.0)
        @test x == [-1.0, 0.0, 1.0, 0.0, 3.0]
        @test !isordered(x)
        @test levels(x) == [-1.0, 0.0, 1.0, 3.0]

        b = [2.5, 3.0, 3.5]
        y = CategoricalVector{Float64}(b, ordered=ordered)
        ordered!(x, ordered)
        insert!(x, 6, y[1])
        @test x == [-1.0, 0.0, 1.0, 0.0, 3.0, 2.5]
        insert!(x, 3, -1.0)
        @test x == [-1.0, 0.0, -1.0, 1.0, 0.0, 3.0, 2.5]
        @test !isordered(x)
        @test levels(x) == [-1.0, 0.0, 1.0, 2.5, 3.0, 3.5]
    end
end

@testset "append! ordered=$ordered" for ordered in (false, true)
    cases = (["b", "a", missing], Union{String, Missing}["b", "a", "b"])
    @testset "String, has missing: $(any(ismissing.(a)))" for a in cases
        x = CategoricalVector{Union{String, Missing}}(a, ordered=ordered)

        push!(x, missing)
        @test x ≅ [a; missing]
        insert!(x, 1, missing)
        @test x ≅ [missing; a; missing]
        insert!(x, 2, missing)
        @test x ≅ [missing; missing; a; missing]
        @test levels(x) == ["a", "b"]
        @test isordered(x) === ordered
    end

    @testset "Float64" begin
        a = 0.0:0.5:1.0
        x = CategoricalVector{Union{Float64, Missing}}(a, ordered=ordered)

        push!(x, missing)
        @test x ≅ [a; missing]
        insert!(x, 1, missing)
        @test x ≅ [missing; a; missing]
        insert!(x, 2, missing)
        @test x ≅ [missing; missing; a; missing]
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0]
    end
end

@testset "deleteat!" begin
    x = ['a':'z';]
    y = categorical(x)
    deleteat!(x, [1, 3])
    deleteat!(y, [1, 3])
    @test x == y
    @test levels(y) == 'a':'z'
end

@testset "DataAPI" begin
    @test DataAPI.defaultarray(CategoricalValue{String, UInt32}, 1) <: CategoricalArray{String,1,UInt32}
    @test DataAPI.defaultarray(Union{Missing, CategoricalValue{String, UInt32}}, 1) <: CategoricalArray{Union{Missing, String},1,UInt32}
    @test DataAPI.defaultarray(CategoricalValue{Int, UInt32}, 1) <: CategoricalArray{Int,1,UInt32}
    @test DataAPI.defaultarray(Union{Missing, CategoricalValue{Int, UInt32}}, 1) <: CategoricalArray{Union{Missing, Int},1,UInt32}
end

@testset "optimized broadcasting with ismissing" begin
    x = categorical([1, missing, 3, 4, missing])
    @test ismissing.(x) == [false, true, false, false, true]
    @test ismissing.(view(x, 2:4)) == [true, false, false]
    @test (!ismissing).(x) == [true, false, true, true, false]
    @test (!ismissing).(view(x, 2:4)) == [false, true, true]

    x = categorical([1, 0, 3, 4, 0])
    @test ismissing.(x) == [false, false, false, false, false]
    @test ismissing.(view(x, 2:4)) == [false, false, false]
    @test (!ismissing).(x) == [true, true, true, true, true]
    @test (!ismissing).(view(x, 2:4)) == [true, true, true]
end

@testset "optimized broadcasting with levelcode" begin
    x = categorical([3, missing, 1, 4, missing])
    levels!(x, [4, 1, 3])
    @test levelcode.(x) ≅ [3, missing, 2, 1, missing]
    @test levelcode.(x) isa Vector{Union{Missing,Int64}}

    replace!(x, missing=>1)
    @test levelcode.(x) ≅ [3, 2, 2, 1, 2]
    @test levelcode.(x) isa Vector{Int64}

    x = CategoricalVector{Int,UInt8}([3, 0, 1, 4, 0])
    levels!(x, [4, 1, 3, 0])
    @test levelcode.(x) ≅ [3, 4, 2, 1, 4]
    @test levelcode.(x) isa Vector{Int16}

    x = CategoricalVector{Union{Missing,Int},UInt8}([3, missing, 1, 4, missing])
    levels!(x, [4, 1, 3])
    @test levelcode.(x) ≅ [3, missing, 2, 1, missing]
    @test levelcode.(x) isa Vector{Union{Missing,Int16}}
end

@testset "fill()" begin
    for ordered in (false, true), dims in ([1], [(1,)], [2, 3], [(2, 3)], [], [()])
        x = CategoricalArray{String, 1, UInt8}(["a", "b", "c"],
                                            ordered=ordered)

        y = fill(x[1], dims...)
        yref = fill("a", dims...)
        @test y == yref
        @test y isa CategoricalArray{String, ndims(yref), UInt8}
        @test levels(y) == levels(x)
        @test isordered(y) === isordered(x)
    end
end

@testset "repeat" begin
    for o in (false, true), c in (false, true), i in 0:2,
        a in (["b", "a", "b"], ["b" "a"; "b" "c"],
              [missing, "a", "b"], ["b" "a"; missing "c"]),
        x in (categorical(a, ordered=o, compress=c),
              view(categorical(a, ordered=o, compress=c), axes(a)...),
              view(categorical([a a], ordered=o, compress=c), axes(a)...))
        xr = @inferred repeat(x, i)
        @test which(repeat, (typeof(x), Int)).module == CategoricalArrays
        @test typeof(parent(x)) == typeof(xr)
        @test isordered(x) == isordered(xr)
        @test xr ≅ categorical(repeat(a, i), ordered=o, compress=c)
        for j in 0:2
            ir = ntuple(x -> i, ndims(a))
            or = ntuple(x -> j, ndims(a))
            xr = @inferred repeat(x, inner=ir, outer=or)
            @test which(repeat, (typeof(x),)).module == CategoricalArrays
            @test typeof(parent(x)) == typeof(xr)
            @test isordered(x) == isordered(xr)
            @test xr ≅ categorical(repeat(a, inner=ir, outer=or), ordered=o, compress=c)
        end
    end
end

@testset "levels! with #undef" begin
    x = CategoricalVector(undef, 3)
    x[2] = "a"
    @test levels!(x, ["b", "a"]) === x
    @test levels(x) == ["b", "a"]
    @test x[2] == "a"
    @test !isassigned(x, 1)
    @test !isassigned(x, 3)
end

@testset "levels! with various vector types" begin
    for levs in (3:-1:1, categorical(3:-1:1),
                 3.0:-1.0:1.0, categorical(3.0:-1.0:1.0))
        x = CategoricalVector([1, 2, 3])
        @test levels!(x, levs) === x
        @test levels(x) == 3:-1:1
    end
end

# TODO: move struct definition inside @testset block once we require Julia 1.6
struct UnorderedBar <: Number
    a::String
end

@testset "vector of unordered" begin
    x0 = [UnorderedBar("s$i") for i in 1:10]
    x = CategoricalArray(x0)
    @test x == x0
    @test levels(x) == x0

    Base.isless(::UnorderedBar, ::UnorderedBar) = throw(ArgumentError("Blah"))
    @test_throws ArgumentError sort(x0)
    @test_throws ArgumentError CategoricalArray(x0)
end

struct MyCustomTypeMissing
    id::Vector{Int}
    var::CategoricalVector{Union{Missing,String}}
end
StructTypes.StructType(::Type{<:MyCustomTypeMissing}) = StructTypes.Struct()

struct MyCustomType
    id::Vector{Int}
    var::CategoricalVector{String}
end
StructTypes.StructType(::Type{<:MyCustomType}) = StructTypes.Struct()

@testset "Reading CategoricalVector objects using JSON3" begin
    x = CategoricalArray(["x","y","z","y","y","z"])
    str = JSON3.write(x)
    readx = JSON3.read(str, CategoricalArray)
    @test readx == x
    @test levels(readx) == levels(x)
    @test readx isa CategoricalVector{String}

    x = CategoricalArray([missing,"y","z","y",missing,"z","x"])
    str = JSON3.write(x)

    readx = JSON3.read(str, CategoricalVector)
    @test x ≅ readx
    @test sort(levels(readx)) == levels(x)
    @test readx isa CategoricalVector{Union{Missing,String}}

    readx = JSON3.read(str, CategoricalArray)
    @test x ≅ readx
    @test sort(levels(readx)) == levels(x)
    @test readx isa CategoricalVector{Union{Missing,String}}

    readx = JSON3.read(str, CategoricalArray{Union{Missing,String}})
    @test x ≅ readx
    @test levels(readx) == levels(x)
    @test readx isa CategoricalVector{Union{Missing,String}}

    readx = JSON3.read(str, CategoricalVector{Union{Missing,String}})
    @test x ≅ readx
    @test levels(readx) == levels(x)
    @test readx isa CategoricalVector{Union{Missing,String}}

    x = MyCustomType(
        collect(1:3),
        CategoricalArray(["x","y","z"])
    )
    str = JSON3.write(x)
    readx = JSON3.read(str, MyCustomType)
    @test readx.var == x.var
    @test levels(readx.var) == levels(x.var)

    x = MyCustomTypeMissing(
        collect(1:3),
        CategoricalArray(["x","y","z",missing])
    )
    str = JSON3.write(x)
    readx = JSON3.read(str, MyCustomTypeMissing)
    @test x.var ≅ readx.var
    @test levels(readx.var) == levels(x.var)
end

@testset "refarray, refvalue, refpool, and invrefpool" begin
    for y in (categorical(["b", "a", "c", "b"]),
              view(categorical(["a", "a", "c", "b"]), 1:3),
              categorical(["b" missing; "a" "c"; "b" missing]),
              view(categorical(["b" missing; "a" "c"; "b" missing]), 2:3, 1))
        @test DataAPI.refarray(y) === CategoricalArrays.refs(y)
        @test DataAPI.refvalue.(Ref(y), DataAPI.refarray(y)) ≅ y
        @test DataAPI.getindex.(Ref(DataAPI.refpool(y)), DataAPI.refarray(y)) ≅ y
        @test_throws BoundsError DataAPI.refvalue(y, -1)
        @test_throws BoundsError DataAPI.refvalue(y, length(levels(y))+1)
        if !(eltype(y) >: Missing)
            @test_throws BoundsError DataAPI.refvalue(y, 0)
        end

        rp = DataAPI.refpool(y)
        @test rp isa AbstractVector{eltype(y)}
        @test Base.IndexStyle(rp) isa Base.IndexLinear
        @test LinearIndices(rp) == axes(rp, 1)
        if eltype(y) >: Missing
            @test collect(rp) ≅ [missing; levels(y)]
            @test size(rp) == (length(levels(y)) + 1,)
            @test axes(rp) == (0:length(levels(y)),)
            if VERSION >= v"1.5"
                @test_throws ArgumentError reshape(rp, length(rp))
            end
        else
            @test collect(rp) == levels(y)
            @test size(rp) == (length(levels(y)),)
            @test axes(rp) == (1:length(levels(y)),)
            @test reshape(rp, length(rp)) == rp
            @test_throws BoundsError rp[0]
        end
        @test_throws BoundsError rp[-1]
        @test_throws BoundsError rp[end + 1]
        @test_throws MethodError similar(rp)

        irp = DataAPI.invrefpool(y)
        for lev in (eltype(y) >: Missing ? [missing; levels(y)] : levels(y))
            @test isequal(rp[irp[lev]], lev)
            @test isequal(rp[get(irp, lev, nothing)], lev)
        end

        @test_throws KeyError irp[1]
        @test_throws KeyError irp["z"]
        @test get(irp, 1, nothing) === nothing
        @test get(irp, "z", nothing) === nothing
        if !(eltype(y) >: Missing)
            @test_throws KeyError irp[missing]
        end
    end
end

@testset "unwrap" begin
    x = categorical(["a", missing, "b", missing])
    @test unwrap.(x) ≅ ["a", missing, "b", missing]
end

@testset "plot recipes" begin
    x = categorical(["B", "A", "C", "A"], levels=["C", "A", "B"])
    y = categorical([10, 1, missing, 2], levels=[10, 2, 1])

    res = RecipesBase.apply_recipe(Dict{Symbol, Any}(:plot_object => nothing), x, y)[1]
    @test res.args[1] isa Formatted
    @test res.args[1].data == [3, 2, 1, 2]
    @test res.args[2] isa Formatted
    @test res.args[2].data == [1, 3, 4, 2]
end

@testset "sizehint! tests and additional empty! tests" begin
    x = categorical([1])
    @test sizehint!(x, 1000) === x
    @test x == [1]
    @test_throws MethodError empty!(categorical([1 2; 3 4]))
    @test_throws MethodError sizehint!(categorical([1 2; 3 4]))
end


@testset "levels!() exceptions handling and rolling back to previous state" begin
    orig = ["A", "B", "B", "C", "D", "B", "A"]
    origmissing = convert(Vector{Union{String,Missing}}, orig)
    origmissing[2] = missing

    @testset "throws if duplicate levels provided" begin
        x = CategoricalArray(orig)
        oldpool = pool(x)
        @test_throws ArgumentError levels!(x, ["B", "A", "C", "D", "A"])
        @test x == orig
        @test pool(x) == oldpool
        @test levels(x) == ["A", "B", "C", "D"]
    end

    @testset "can drop unused levels if element type is $(eltype(x0))" for x0 in (orig, origmissing)
        x = CategoricalArray(x0)
        levels!(x, ["E", "A", "B", "C", "D"])
        @test levels(x) == ["E", "A", "B", "C", "D"]
        @test x === levels!(x, ["B", "A", "C", "D"])
        @test x ≅ x0
        @test levels(x) == ["B", "A", "C", "D"]
    end

    @testset "CategoricalArray which cannot store missings" begin
        x = CategoricalArray(orig)
        @test levels(x) == ["A", "B", "C", "D"]
        oldpool = pool(x)
        @test_throws ArgumentError levels!(x, ["B", "A", "C"])
        # check that the x contents have not changed
        @test x == orig
        @test pool(x) === oldpool
        @test levels(x) == ["A", "B", "C", "D"]

        # still throws even if allowmissing=true
        @test_throws ArgumentError levels!(x, ["B", "A", "C"], allowmissing=true)
        # check that the x contents have not changed
        @test x == orig
        @test pool(x) === oldpool
        @test levels(x) == ["A", "B", "C", "D"]
    end

    @testset "CategoricalArray which can store missing" begin
        x = CategoricalArray(origmissing)
        oldpool = pool(x)
        @test levels(x) == ["A", "B", "C", "D"]
        # throws if missings are not explicitly allowed
        @test_throws ArgumentError levels!(x, ["B", "A", "C"])
        # check that the x contents have not changed
        @test x ≅ origmissing
        @test pool(x) === oldpool
        @test levels(x) == ["A", "B", "C", "D"]

        @test x === levels!(x, ["B", "A", "C", "E"], allowmissing=true)
        @test x ≅ ["A", missing, "B", "C", missing, "B", "A"]
        @test levels(x) == ["B", "A", "C", "E"]
    end

    @testset "interaction with ChainedVector" begin
        x = ChainedVector([["a", "b"], ["c", "d", "e"]])
        @test CategoricalArray(x) == CategoricalArray{String}(x) ==
            CategoricalArray{Union{String, Missing}}(x) == x
        @test copy!(CategoricalArray{String}(undef, 5), x) ==
            copyto!(CategoricalArray{String}(undef, 5), x) ==
            copyto!(CategoricalArray{String}(undef, 5), 1, x, 1, 5) ==
            x

        x .= "z"
        y = categorical(["a", "b", "c", "d", "e"])
        @test copy!(x, y) == y
        x .= "z"
        @test copyto!(x, y) == y
        x .= "z"
        @test copyto!(x, 1, y, 1, 5) == y
    end
end

@testset "promotion" begin
    @test [CategoricalVector([1, 2]),
           CategoricalVector(["a", "b"])] isa
        Vector{CategoricalVector{<:Any, UInt32, <:Any, <:Any, Union{}}}
    @test [CategoricalVector([1, missing]),
           CategoricalVector(["a", "b"])] isa
        Vector{CategoricalVector{<:Any, UInt32}}
    @test [CategoricalVector([1, missing]),
           CategoricalVector([1, 2])] isa
        Vector{CategoricalVector{Union{Missing, Int}, UInt32, Int,
                                 CategoricalValue{Int, UInt32}, Missing}}
    @test [CategoricalVector([1, missing]),
           CategoricalVector(["a", missing])] isa
        Vector{CategoricalVector{<:Any, UInt32, <:Any, <:Any, Missing}}
    @test [CategoricalVector([Int8(1), missing]),
           CategoricalVector([Int16(2)])] isa
        Vector{CategoricalVector{<:Any, UInt32}}
    @test [CategoricalVector([1, 2]),
           CategoricalMatrix(["a" "b"])] isa
        Vector{CategoricalArray{<:Any, <:Any, UInt32, <:Any, <:Any, Union{}}}
    @test [CategoricalVector([1, 2]),
           CategoricalMatrix([1 2])] isa
        Vector{CategoricalArray{Int, <:Any, UInt32, Int,
                                CategoricalValue{Int, UInt32}, Union{}}}
    @test [CategoricalVector([1, 2]),
           CategoricalMatrix([1 missing])] isa
        Vector{CategoricalArray{<:Any, <:Any, UInt32, Int,
                                CategoricalValue{Int, UInt32}}}
    @test [categorical([1, 2], compress=true),
           CategoricalVector([1, 2])] isa
        Vector{CategoricalVector{Int, UInt32, Int, CategoricalValue{Int, UInt32}, Union{}}}
    @test [categorical([1, 2], compress=true),
           CategoricalVector(["a", "b"])] isa
        Vector{CategoricalVector{<:Any, <:Integer, <:Any, <:Any, Union{}}}
end

@testset "levels with skipmissing argument" begin
    for x in (categorical(["a", "b", "a"], levels=["b", "c", "a"]),
              view(categorical(["c", "b", "a"], levels=["b", "c", "a"]), 2:3))
        @test @inferred(levels(x)) == ["b", "c", "a"]
        @test @inferred(levels(x, skipmissing=true)) == ["b", "c", "a"]
        @test @inferred(levels(x, skipmissing=false)) == ["b", "c", "a"]
    end

    for x in (categorical(Union{String, Missing}["a", "b", "a"], levels=["b", "c", "a"]),
              view(categorical(Union{String, Missing}["c", "b", "a"], levels=["b", "c", "a"]), 2:3),
              view(categorical(Union{String, Missing}[missing, "b", "a"], levels=["b", "c", "a"]), 2:3))
        @test @inferred(levels(x)) == ["b", "c", "a"]
        @test levels(x, skipmissing=true) == ["b", "c", "a"]
        @test levels(x, skipmissing=true) isa Vector{String}
        @test levels(x, skipmissing=false) == ["b", "c", "a"]
        @test levels(x, skipmissing=false) isa Vector{Union{String, Missing}}
    end

    for x in (categorical(Union{String, Missing}["a", "b", missing], levels=["b", "c", "a"]),
              view(categorical(Union{String, Missing}["c", "b", missing], levels=["b", "c", "a"]), 2:3))
        @test @inferred(levels(x)) == ["b", "c", "a"]
        @test levels(x, skipmissing=true) == ["b", "c", "a"]
        @test levels(x, skipmissing=true) isa Vector{String}
        @test levels(x, skipmissing=false) ≅ ["b", "c", "a", missing]
        @test levels(x, skipmissing=false) isa Vector{Union{String, Missing}}
    end
end

end
