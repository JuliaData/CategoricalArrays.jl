module TestArrayCommon

using Base.Test
using CategoricalArrays
using NullableArrays
using CategoricalArrays: DefaultRefType
using Compat

typealias String Compat.ASCIIString

# == currently throws an error for Nullables
(==) = isequal


# Tests of vcat of CategoricalArray amd NullableCategoricalArray

# Test that mergelevels handles mutually compatible ordering
@test CategoricalArrays.mergelevels([6, 3, 4, 7], [2, 3, 5, 4], [2, 4, 8]) == ([6, 2, 3, 5, 4, 7, 8], true)
@test CategoricalArrays.mergelevels([6, 3, 4, 7], [2, 3, 6, 5, 4], [2, 4, 8]) == ([6, 3, 4, 7, 2, 5, 8], false)

for (CA, A) in ((CategoricalArray, Array), (NullableCategoricalArray, NullableArray))
    # Test that vcat of compact arrays use a reftype that doesn't overflow
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
    @test ordered(r) == false
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
    @test ordered(r) == false
    @test levels(r) == collect(3:length(a2)+10)

    # Test concatenation of mutually compatible levels
    a1 = ["Young", "Middle"]
    a2 = ["Middle", "Old"]
    ca1 = CA(a1, ordered=true)
    ca2 = CA(a2, ordered=true)
    levels!(ca1, ["Young", "Middle"])
    levels!(ca2, ["Middle", "Old"])
    r = vcat(ca1, ca2)
    @test r == A(vcat(a1, a2))
    @test levels(r) == ["Young", "Middle", "Old"]
    @test ordered(r) == true

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
    @test ordered(r) == false
end

end
