module TestShow
    using Base.Test
    using CategoricalArrays

    pool = CategoricalPool(["c", "b", "a"])

    opool = CategoricalPool(["c", "b", "a"], ["a", "b", "c"], true)

    nv1 = catvalue(1, pool)
    nv2 = catvalue(2, pool)
    nv3 = catvalue(3, pool)

    ov1 = catvalue(1, opool)
    ov2 = catvalue(2, opool)
    ov3 = catvalue(3, opool)

    @test sprint(show, pool) == "CategoricalArrays.CategoricalPool{String,UInt32}([\"c\",\"b\",\"a\"])"
    @test sprint(show, opool) == "CategoricalArrays.CategoricalPool{String,UInt32}([\"a\",\"b\",\"c\"]) with ordered levels"

    @test sprint(show, nv1) == "CategoricalArrays.CategoricalString{UInt32} \"c\""
    @test sprint(show, nv2) == "CategoricalArrays.CategoricalString{UInt32} \"b\""
    @test sprint(show, nv3) == "CategoricalArrays.CategoricalString{UInt32} \"a\""

    @test sprint(show, ov1) == "CategoricalArrays.CategoricalString{UInt32} \"c\" (3/3)"
    @test sprint(show, ov2) == "CategoricalArrays.CategoricalString{UInt32} \"b\" (2/3)"
    @test sprint(show, ov3) == "CategoricalArrays.CategoricalString{UInt32} \"a\" (1/3)"

    @test sprint(showcompact, nv1) == sprint(showcompact, ov1) == "\"c\""
    @test sprint(showcompact, nv2) == sprint(showcompact, ov2) == "\"b\""
    @test sprint(showcompact, nv3) == sprint(showcompact, ov3) == "\"a\""

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
