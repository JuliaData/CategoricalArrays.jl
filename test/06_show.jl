module TestShow
using Compat
using Compat.Test
using Compat.Dates
using CategoricalArrays

# The type is prefixed after Dates moved to the stdlib
if VERSION >= v"0.7.0-DEV.2575"
    const DateStr = "Dates.Date"
else
    const DateStr = "Date"
end

@testset "show() for CategoricalPool{String} and its values" begin
    pool = CategoricalPool(["c", "b", "a"])

    opool = CategoricalPool(["c", "b", "a"], ["a", "b", "c"], true)

    nv1 = CategoricalArrays.catvalue(1, pool)
    nv2 = CategoricalArrays.catvalue(2, pool)
    nv3 = CategoricalArrays.catvalue(3, pool)

    ov1 = CategoricalArrays.catvalue(1, opool)
    ov2 = CategoricalArrays.catvalue(2, opool)
    ov3 = CategoricalArrays.catvalue(3, opool)

    @test sprint(show, pool) == "$CategoricalPool{String,UInt32}([\"c\",\"b\",\"a\"])"
    @test sprint(show, opool) == "$CategoricalPool{String,UInt32}([\"a\",\"b\",\"c\"]) with ordered levels"

    @test sprint(show, nv1) == "$CategoricalString{UInt32} \"c\""
    @test sprint(show, nv2) == "$CategoricalString{UInt32} \"b\""
    @test sprint(show, nv3) == "$CategoricalString{UInt32} \"a\""

    @test sprint(show, ov1) == "$CategoricalString{UInt32} \"c\" (3/3)"
    @test sprint(show, ov2) == "$CategoricalString{UInt32} \"b\" (2/3)"
    @test sprint(show, ov3) == "$CategoricalString{UInt32} \"a\" (1/3)"

    if VERSION >= v"0.7.0-DEV.4524"
        @test sprint(show, nv1, context=:typeinfo=>typeof(nv1)) == "\"c\""
        @test sprint(show, nv2, context=:typeinfo=>typeof(nv2)) == "\"b\""
        @test sprint(show, nv3, context=:typeinfo=>typeof(nv3)) == "\"a\""

        @test sprint(show, ov1, context=:typeinfo=>typeof(ov1)) == "\"c\""
        @test sprint(show, ov2, context=:typeinfo=>typeof(ov2)) == "\"b\""
        @test sprint(show, ov3, context=:typeinfo=>typeof(ov3)) == "\"a\""
    else
        @test sprint(showcompact, nv1) == sprint(showcompact, ov1) == "\"c\""
        @test sprint(showcompact, nv2) == sprint(showcompact, ov2) == "\"b\""
        @test sprint(showcompact, nv3) == sprint(showcompact, ov3) == "\"a\""
    end

    @test sprint(print, nv1) == sprint(print, ov1) == "c"
    @test sprint(print, nv2) == sprint(print, ov2) == "b"
    @test sprint(print, nv3) == sprint(print, ov3) == "a"

    @test string(nv1) == string(ov1) == "c"
    @test string(nv2) == string(ov2) == "b"
    @test string(nv3) == string(ov3) == "a"

    @test repr(nv1) == repr(ov1) == "\"c\""
    @test repr(nv2) == repr(ov2) == "\"b\""
    @test repr(nv3) == repr(ov3) == "\"a\""
end

@testset "show() for CategoricalPool{Date} and its values" begin
    pool = CategoricalPool([Date(1999, 12), Date(1991, 8), Date(1993, 10)])

    opool = CategoricalPool([Date(1999, 12), Date(1991, 8), Date(1993, 10)],
                            [Date(1991, 8), Date(1993, 10), Date(1999, 12)], true)

    nv1 = CategoricalArrays.catvalue(1, pool)
    nv2 = CategoricalArrays.catvalue(2, pool)
    nv3 = CategoricalArrays.catvalue(3, pool)

    ov1 = CategoricalArrays.catvalue(1, opool)
    ov2 = CategoricalArrays.catvalue(2, opool)
    ov3 = CategoricalArrays.catvalue(3, opool)

    @test sprint(show, pool) == "$CategoricalPool{$DateStr,UInt32}([1999-12-01,1991-08-01,1993-10-01])"
    @test sprint(show, opool) == "$CategoricalPool{$DateStr,UInt32}([1991-08-01,1993-10-01,1999-12-01]) with ordered levels"

    @test sprint(show, nv1) == "$CategoricalValue{$DateStr,UInt32} 1999-12-01"
    @test sprint(show, nv2) == "$CategoricalValue{$DateStr,UInt32} 1991-08-01"
    @test sprint(show, nv3) == "$CategoricalValue{$DateStr,UInt32} 1993-10-01"

    @test sprint(show, ov1) == "$CategoricalValue{$DateStr,UInt32} 1999-12-01 (3/3)"
    @test sprint(show, ov2) == "$CategoricalValue{$DateStr,UInt32} 1991-08-01 (1/3)"
    @test sprint(show, ov3) == "$CategoricalValue{$DateStr,UInt32} 1993-10-01 (2/3)"

    if VERSION >= v"0.7.0-DEV.4524"
        @test sprint(show, nv1, context=:typeinfo=>typeof(nv1)) == "1999-12-01"
        @test sprint(show, nv2, context=:typeinfo=>typeof(nv2)) == "1991-08-01"
        @test sprint(show, nv3, context=:typeinfo=>typeof(nv3)) == "1993-10-01"

        @test sprint(show, ov1, context=:typeinfo=>typeof(ov1)) == "1999-12-01"
        @test sprint(show, ov2, context=:typeinfo=>typeof(ov2)) == "1991-08-01"
        @test sprint(show, ov3, context=:typeinfo=>typeof(ov3)) == "1993-10-01"
    else
        @test sprint(showcompact, nv1) == sprint(showcompact, ov1) == "1999-12-01"
        @test sprint(showcompact, nv2) == sprint(showcompact, ov2) == "1991-08-01"
        @test sprint(showcompact, nv3) == sprint(showcompact, ov3) == "1993-10-01"
    end

    @test sprint(print, nv1) == sprint(print, ov1) == "1999-12-01"
    @test sprint(print, nv2) == sprint(print, ov2) == "1991-08-01"
    @test sprint(print, nv3) == sprint(print, ov3) == "1993-10-01"

    @test string(nv1) == string(ov1) == "1999-12-01"
    @test string(nv2) == string(ov2) == "1991-08-01"
    @test string(nv3) == string(ov3) == "1993-10-01"

    @test repr(nv1) == repr(ov1) == "1999-12-01"
    @test repr(nv2) == repr(ov2) == "1991-08-01"
    @test repr(nv3) == repr(ov3) == "1993-10-01"
end

using JSON
@testset "JSON.lower" for pool in (CategoricalPool(["a"]),
                                   CategoricalPool([1]),
                                   CategoricalPool([1.0]))
    v = CategoricalArrays.catvalue(1, pool)
    @test JSON.lower(v) == JSON.lower(get(v))
    @test typeof(JSON.lower(v)) == typeof(JSON.lower(get(v)))
end

end
