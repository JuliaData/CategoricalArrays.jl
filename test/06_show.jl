module TestShow
using Test
using Dates
using CategoricalArrays

@testset "show() for CategoricalPool{String} and its values" begin
    pool = CategoricalPool(["c", "b", "a"])
    opool = CategoricalPool(["c", "b", "a"], true)

    nv1 = CategoricalValue(1, pool)
    nv2 = CategoricalValue(2, pool)
    nv3 = CategoricalValue(3, pool)

    ov1 = CategoricalValue(1, opool)
    ov2 = CategoricalValue(2, opool)
    ov3 = CategoricalValue(3, opool)

    @test sprint(show, pool) == "$CategoricalPool{String,UInt32}([\"c\", \"b\", \"a\"])"
    @test sprint(show, opool) == "$CategoricalPool{String,UInt32}([\"c\", \"b\", \"a\"]) with ordered levels"

    @test sprint(show, nv1) == repr(nv1) == "$CategoricalValue{String,UInt32} \"c\""
    @test sprint(show, nv2) == repr(nv2) == "$CategoricalValue{String,UInt32} \"b\""
    @test sprint(show, nv3) == repr(nv3) == "$CategoricalValue{String,UInt32} \"a\""

    @test sprint(show, ov1) == repr(ov1) =="$CategoricalValue{String,UInt32} \"c\" (1/3)"
    @test sprint(show, ov2) == repr(ov2) == "$CategoricalValue{String,UInt32} \"b\" (2/3)"
    @test sprint(show, ov3) == repr(ov3) =="$CategoricalValue{String,UInt32} \"a\" (3/3)"

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

using JSON
@testset "JSON.lower" for pool in (CategoricalPool(["a"]),
                                   CategoricalPool([1]),
                                   CategoricalPool([1.0]))
    v = CategoricalValue(1, pool)
    @test JSON.lower(v) == JSON.lower(get(v))
    @test typeof(JSON.lower(v)) == typeof(JSON.lower(get(v)))
end

using JSON3
using StructTypes
@testset "JSON3.write" begin
    v = CategoricalValue(1, CategoricalPool(["a"]))
    @test JSON3.write(v) === "\"a\""

    v = CategoricalValue(1, CategoricalPool([1]))
    @test JSON3.write(v) === "1"
    @test StructTypes.numbertype(typeof(v)) === Int

    v = CategoricalValue(1, CategoricalPool([2.0]))
    @test JSON3.write(v) === "2.0"
    @test StructTypes.numbertype(typeof(v)) === Float64

    v = CategoricalValue(1, CategoricalPool([BigFloat(3.0,10)]))
    @test JSON3.write(v) === "3.0"
    @test StructTypes.numbertype(typeof(v)) === BigFloat

    v = CategoricalValue(2, CategoricalPool([true,false]))
    @test JSON3.write(v) == "false"
    @test StructTypes.numbertype(typeof(v)) === Bool
end

end
