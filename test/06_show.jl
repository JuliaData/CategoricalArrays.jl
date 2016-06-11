module TestShow
    using Base.Test
    using CategoricalArrays

    pool = NominalPool(["c", "b", "a"])

    opool = OrdinalPool(["c", "b", "a"], ["a", "b", "c"])

    nv1 = NominalValue(1, pool)
    nv2 = NominalValue(2, pool)
    nv3 = NominalValue(3, pool)

    ov1 = OrdinalValue(1, opool)
    ov2 = OrdinalValue(2, opool)
    ov3 = OrdinalValue(3, opool)

    if isdefined(Core, :String) && isdefined(Core, :AbstractString) # Julia >= 0.5
        @test string(pool) == "CategoricalArrays.NominalPool{String,UInt32}([\"c\",\"b\",\"a\"])"
        @test string(opool) == "CategoricalArrays.OrdinalPool{String,UInt32}([\"a\",\"b\",\"c\"])"

        @test string(nv1) == "CategoricalArrays.NominalValue{String,UInt32} \"c\""
        @test string(nv2) == "CategoricalArrays.NominalValue{String,UInt32} \"b\""
        @test string(nv3) == "CategoricalArrays.NominalValue{String,UInt32} \"a\""

        @test string(ov1) == "CategoricalArrays.OrdinalValue{String,UInt32} \"c\" (3/3)"
        @test string(ov2) == "CategoricalArrays.OrdinalValue{String,UInt32} \"b\" (2/3)"
        @test string(ov3) == "CategoricalArrays.OrdinalValue{String,UInt32} \"a\" (1/3)"
    else
        @test string(pool) == "CategoricalArrays.NominalPool{ASCIIString,UInt32}([\"c\",\"b\",\"a\"])"
        @test string(opool) == "CategoricalArrays.OrdinalPool{ASCIIString,UInt32}([\"a\",\"b\",\"c\"])"

        @test string(nv1) == "CategoricalArrays.NominalValue{ASCIIString,UInt32} \"c\""
        @test string(nv2) == "CategoricalArrays.NominalValue{ASCIIString,UInt32} \"b\""
        @test string(nv3) == "CategoricalArrays.NominalValue{ASCIIString,UInt32} \"a\""

        @test string(ov1) == "CategoricalArrays.OrdinalValue{ASCIIString,UInt32} \"c\" (3/3)"
        @test string(ov2) == "CategoricalArrays.OrdinalValue{ASCIIString,UInt32} \"b\" (2/3)"
        @test string(ov3) == "CategoricalArrays.OrdinalValue{ASCIIString,UInt32} \"a\" (1/3)"
    end

    b = IOBuffer()
    showcompact(b, nv1)
    @test takebuf_string(b) == "\"c\""
    showcompact(b, nv2)
    @test takebuf_string(b) == "\"b\""
    showcompact(b, nv3)
    @test takebuf_string(b) == "\"a\""

    showcompact(b, ov1)
    @test takebuf_string(b) == "\"c\""
    showcompact(b, ov2)
    @test takebuf_string(b) == "\"b\""
    showcompact(b, ov3)
    @test takebuf_string(b) == "\"a\""
end
