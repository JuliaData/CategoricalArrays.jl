module TestShow
    using Base.Test
    using CategoricalData

    pool = CategoricalPool(["c", "b", "a"])

    opool = OrdinalPool(["c", "b", "a"], ["a", "b", "c"])

    cv1 = CategoricalValue(1, pool)
    cv2 = CategoricalValue(2, pool)
    cv3 = CategoricalValue(3, pool)

    ov1 = OrdinalValue(1, opool)
    ov2 = OrdinalValue(2, opool)
    ov3 = OrdinalValue(3, opool)

    @test string(pool) == "CategoricalPool{String}([\"c\",\"b\",\"a\"])"
    @test string(opool) == "OrdinalPool{String}([\"a\",\"b\",\"c\"])"

    @test string(cv1) == "CategoricalValue{String} \"c\""
    @test string(cv2) == "CategoricalValue{String} \"b\""
    @test string(cv3) == "CategoricalValue{String} \"a\""

    @test string(ov1) == "OrdinalValue{String} \"c\" (3/3)"
    @test string(ov2) == "OrdinalValue{String} \"b\" (2/3)"
    @test string(ov3) == "OrdinalValue{String} \"a\" (1/3)"

    b = IOBuffer()
    showcompact(b, cv1)
    @test takebuf_string(b) == "\"c\""
    showcompact(b, cv2)
    @test takebuf_string(b) == "\"b\""
    showcompact(b, cv3)
    @test takebuf_string(b) == "\"a\""

    showcompact(b, ov1)
    @test takebuf_string(b) == "\"c\""
    showcompact(b, ov2)
    @test takebuf_string(b) == "\"b\""
    showcompact(b, ov3)
    @test takebuf_string(b) == "\"a\""
end
