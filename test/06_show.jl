module TestShow
using Test
import Dates
using CategoricalArrays

@testset "show() for CategoricalPool{String} and its values" begin
    pool = CategoricalPool(["c", "b", "a"])

    opool = CategoricalPool(["c", "b", "a"], ["a", "b", "c"], true)

    nv1 = CategoricalValue(1, pool)
    nv2 = CategoricalValue(2, pool)
    nv3 = CategoricalValue(3, pool)

    ov1 = CategoricalValue(1, opool)
    ov2 = CategoricalValue(2, opool)
    ov3 = CategoricalValue(3, opool)

    @test sprint(show, pool) == "$CategoricalPool{String,UInt32}([\"c\",\"b\",\"a\"])"
    @test sprint(show, opool) == "$CategoricalPool{String,UInt32}([\"a\",\"b\",\"c\"]) with ordered levels"

    @test sprint(show, nv1) == "$CategoricalValue{String,UInt32} \"c\""
    @test sprint(show, nv2) == "$CategoricalValue{String,UInt32} \"b\""
    @test sprint(show, nv3) == "$CategoricalValue{String,UInt32} \"a\""

    @test sprint(show, ov1) == "$CategoricalValue{String,UInt32} \"c\" (3/3)"
    @test sprint(show, ov2) == "$CategoricalValue{String,UInt32} \"b\" (2/3)"
    @test sprint(show, ov3) == "$CategoricalValue{String,UInt32} \"a\" (1/3)"

    @test sprint(show, nv1, context=:typeinfo=>typeof(nv1)) == "\"c\""
    @test sprint(show, nv2, context=:typeinfo=>typeof(nv2)) == "\"b\""
    @test sprint(show, nv3, context=:typeinfo=>typeof(nv3)) == "\"a\""

    @test sprint(show, ov1, context=:typeinfo=>typeof(ov1)) == "\"c\""
    @test sprint(show, ov2, context=:typeinfo=>typeof(ov2)) == "\"b\""
    @test sprint(show, ov3, context=:typeinfo=>typeof(ov3)) == "\"a\""

    @test sprint(print, nv1) == sprint(print, ov1) == "c"
    @test sprint(print, nv2) == sprint(print, ov2) == "b"
    @test sprint(print, nv3) == sprint(print, ov3) == "a"

    @test string(nv1) == string(ov1) == "c"
    @test string(nv2) == string(ov2) == "b"
    @test string(nv3) == string(ov3) == "a"

    @test String(nv1) == String(ov1) == "c"
    @test String(nv2) == String(ov2) == "b"
    @test String(nv3) == String(ov3) == "a"

    @test repr(nv1) == repr(ov1) == "\"c\""
    @test repr(nv2) == repr(ov2) == "\"b\""
    @test repr(nv3) == repr(ov3) == "\"a\""

    b = IOBuffer()
    @test write(b, nv1) == 1
    @test String(take!(b)) == "c"
    @test write(b, nv2) == 1
    @test String(take!(b)) == "b"
    @test write(b, nv3) == 1
    @test String(take!(b)) == "a"
    @test write(b, ov1) == 1
    @test String(take!(b)) == "c"
    @test write(b, ov2) == 1
    @test String(take!(b)) == "b"
    @test write(b, ov3) == 1
    @test String(take!(b)) == "a"
end

@testset "show() for CategoricalPool{Date} and its values" begin
    pool = CategoricalPool([Dates.Date(1999, 12), Dates.Date(1991, 8), Dates.Date(1993, 10)])

    opool = CategoricalPool([Dates.Date(1999, 12), Dates.Date(1991, 8), Dates.Date(1993, 10)],
                            [Dates.Date(1991, 8), Dates.Date(1993, 10), Dates.Date(1999, 12)], true)

    nv1 = CategoricalValue(1, pool)
    nv2 = CategoricalValue(2, pool)
    nv3 = CategoricalValue(3, pool)

    ov1 = CategoricalValue(1, opool)
    ov2 = CategoricalValue(2, opool)
    ov3 = CategoricalValue(3, opool)
    
    if Base.VERSION >= v"1.4.0-DEV.591"
        @test sprint(show, pool) == "$CategoricalPool{Dates.Date,UInt32}([1999-12-01,1991-08-01,1993-10-01])"
        @test sprint(show, opool) == "$CategoricalPool{Dates.Date,UInt32}([1991-08-01,1993-10-01,1999-12-01]) with ordered levels"

        @test sprint(show, nv1) == "$CategoricalValue{Dates.Date,UInt32} 1999-12-01"
        @test sprint(show, nv2) == "$CategoricalValue{Dates.Date,UInt32} 1991-08-01"
        @test sprint(show, nv3) == "$CategoricalValue{Dates.Date,UInt32} 1993-10-01"

        @test sprint(show, ov1) == "$CategoricalValue{Dates.Date,UInt32} 1999-12-01 (3/3)"
        @test sprint(show, ov2) == "$CategoricalValue{Dates.Date,UInt32} 1991-08-01 (1/3)"
        @test sprint(show, ov3) == "$CategoricalValue{Dates.Date,UInt32} 1993-10-01 (2/3)"

        @test sprint(show, nv1, context=:typeinfo=>typeof(nv1)) == "1999-12-01"
        @test sprint(show, nv2, context=:typeinfo=>typeof(nv2)) == "1991-08-01"
        @test sprint(show, nv3, context=:typeinfo=>typeof(nv3)) == "1993-10-01"

        @test sprint(show, ov1, context=:typeinfo=>typeof(ov1)) == "1999-12-01"
        @test sprint(show, ov2, context=:typeinfo=>typeof(ov2)) == "1991-08-01"
        @test sprint(show, ov3, context=:typeinfo=>typeof(ov3)) == "1993-10-01"

        @test (sprint(print, nv1) == sprint(print, ov1) == "1999-12-01") || (sprint(print, nv1) == sprint(print, ov1) == "Dates.Date(1999, 12, 1)")
        @test (sprint(print, nv2) == sprint(print, ov2) == "1991-08-01") || (sprint(print, nv2) == sprint(print, ov2) == "Dates.Date(1991, 8, 1)")
        @test (sprint(print, nv3) == sprint(print, ov3) == "1993-10-01") || (sprint(print, nv3) == sprint(print, ov3) == "Dates.Date(1993, 10, 1)")

        @test (string(nv1) == string(ov1) == "1999-12-01") || (string(nv1) == string(ov1) == "Dates.Date(1999, 12, 1)")
        @test (string(nv2) == string(ov2) == "1991-08-01") || (string(nv2) == string(ov2) == "Dates.Date(1991, 8, 1)")
        @test (string(nv3) == string(ov3) == "1993-10-01") || (string(nv3) == string(ov3) == "Dates.Date(1993, 10, 1)")

        @test repr(nv1) == repr(ov1) == "1999-12-01"
        @test repr(nv2) == repr(ov2) == "1991-08-01"
        @test repr(nv3) == repr(ov3) == "1993-10-01"
    else
        @test sprint(show, pool) == "$CategoricalPool{Dates.Date,UInt32}([Dates.Date(1999, 12, 1),Dates.Date(1991, 8, 1),Dates.Date(1993, 10, 1)])"
        @test sprint(show, opool) == "$CategoricalPool{Dates.Date,UInt32}([Dates.Date(1991, 8, 1),Dates.Date(1993, 10, 1),Dates.Date(1999, 12, 1)]) with ordered levels"

        @test sprint(show, nv1) == "$CategoricalValue{Dates.Date,UInt32} Dates.Date(1999, 12, 1)"
        @test sprint(show, nv2) == "$CategoricalValue{Dates.Date,UInt32} Dates.Date(1991, 8, 1)"
        @test sprint(show, nv3) == "$CategoricalValue{Dates.Date,UInt32} Dates.Date(1993, 10, 1)"

        @test sprint(show, ov1) == "$CategoricalValue{Dates.Date,UInt32} Dates.Date(1999, 12, 1) (3/3)"
        @test sprint(show, ov2) == "$CategoricalValue{Dates.Date,UInt32} Dates.Date(1991, 8, 1) (1/3)"
        @test sprint(show, ov3) == "$CategoricalValue{Dates.Date,UInt32} Dates.Date(1993, 10, 1) (2/3)"

        @test sprint(show, nv1, context=:typeinfo=>typeof(nv1)) == "Dates.Date(1999, 12, 1)"
        @test sprint(show, nv2, context=:typeinfo=>typeof(nv2)) == "Dates.Date(1991, 8, 1)"
        @test sprint(show, nv3, context=:typeinfo=>typeof(nv3)) == "Dates.Date(1993, 10, 1)"

        @test sprint(show, ov1, context=:typeinfo=>typeof(ov1)) == "Dates.Date(1999, 12, 1)"
        @test sprint(show, ov2, context=:typeinfo=>typeof(ov2)) == "Dates.Date(1991, 8, 1)"
        @test sprint(show, ov3, context=:typeinfo=>typeof(ov3)) == "Dates.Date(1993, 10, 1)"

        @test (sprint(print, nv1) == sprint(print, ov1) == "1999-12-01") || (sprint(print, nv1) == sprint(print, ov1) == "Dates.Date(1999, 12, 1)")
        @test (sprint(print, nv2) == sprint(print, ov2) == "1991-08-01") || (sprint(print, nv2) == sprint(print, ov2) == "Dates.Date(1991, 8, 1)")
        @test (sprint(print, nv3) == sprint(print, ov3) == "1993-10-01") || (sprint(print, nv3) == sprint(print, ov3) == "Dates.Date(1993, 10, 1)")

        @test (string(nv1) == string(ov1) == "1999-12-01") || (string(nv1) == string(ov1) == "Dates.Date(1999, 12, 1)")
        @test (string(nv2) == string(ov2) == "1991-08-01") || (string(nv2) == string(ov2) == "Dates.Date(1991, 8, 1)")
        @test (string(nv3) == string(ov3) == "1993-10-01") || (string(nv3) == string(ov3) == "Dates.Date(1993, 10, 1)")

        @test repr(nv1) == repr(ov1) == "Dates.Date(1999, 12, 1)"
        @test repr(nv2) == repr(ov2) == "Dates.Date(1991, 8, 1)"
        @test repr(nv3) == repr(ov3) == "Dates.Date(1993, 10, 1)"
    end


end

using JSON
@testset "JSON.lower" for pool in (CategoricalPool(["a"]),
                                   CategoricalPool([1]),
                                   CategoricalPool([1.0]))
    v = CategoricalValue(1, pool)
    @test JSON.lower(v) == JSON.lower(get(v))
    @test typeof(JSON.lower(v)) == typeof(JSON.lower(get(v)))
end

end
