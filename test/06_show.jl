module TestShow
    using Base.Test
    using CategoricalArrays

    pool = CategoricalPool(["c", "b", "a"])

    opool = CategoricalPool(["c", "b", "a"], ["a", "b", "c"], true)

    nv1 = CategoricalValue(1, pool)
    nv2 = CategoricalValue(2, pool)
    nv3 = CategoricalValue(3, pool)

    ov1 = CategoricalValue(1, opool)
    ov2 = CategoricalValue(2, opool)
    ov3 = CategoricalValue(3, opool)

    if isdefined(Core, :String) && isdefined(Core, :AbstractString) # Julia >= 0.5
        @test string(pool) == "CategoricalArrays.CategoricalPool{String,UInt32}([\"c\",\"b\",\"a\"])"
        @test string(opool) == "CategoricalArrays.CategoricalPool{String,UInt32}([\"a\",\"b\",\"c\"]) with ordered levels"

        @test string(nv1) == "CategoricalArrays.CategoricalValue{String,UInt32} \"c\""
        @test string(nv2) == "CategoricalArrays.CategoricalValue{String,UInt32} \"b\""
        @test string(nv3) == "CategoricalArrays.CategoricalValue{String,UInt32} \"a\""

        @test string(ov1) == "CategoricalArrays.CategoricalValue{String,UInt32} \"c\" (3/3)"
        @test string(ov2) == "CategoricalArrays.CategoricalValue{String,UInt32} \"b\" (2/3)"
        @test string(ov3) == "CategoricalArrays.CategoricalValue{String,UInt32} \"a\" (1/3)"
    else
        @test string(pool) == "CategoricalArrays.CategoricalPool{ASCIIString,UInt32}([\"c\",\"b\",\"a\"])"
        @test string(opool) == "CategoricalArrays.CategoricalPool{ASCIIString,UInt32}([\"a\",\"b\",\"c\"]) with ordered levels"

        @test string(nv1) == "CategoricalArrays.CategoricalValue{ASCIIString,UInt32} \"c\""
        @test string(nv2) == "CategoricalArrays.CategoricalValue{ASCIIString,UInt32} \"b\""
        @test string(nv3) == "CategoricalArrays.CategoricalValue{ASCIIString,UInt32} \"a\""

        @test string(ov1) == "CategoricalArrays.CategoricalValue{ASCIIString,UInt32} \"c\" (3/3)"
        @test string(ov2) == "CategoricalArrays.CategoricalValue{ASCIIString,UInt32} \"b\" (2/3)"
        @test string(ov3) == "CategoricalArrays.CategoricalValue{ASCIIString,UInt32} \"a\" (1/3)"
    end

    b = IOBuffer()
    showcompact(b, nv1)
    @test String(take!(b)) == "\"c\""
    showcompact(b, nv2)
    @test String(take!(b)) == "\"b\""
    showcompact(b, nv3)
    @test String(take!(b)) == "\"a\""

    showcompact(b, ov1)
    @test String(take!(b)) == "\"c\""
    showcompact(b, ov2)
    @test String(take!(b)) == "\"b\""
    showcompact(b, ov3)
    @test String(take!(b)) == "\"a\""
end
