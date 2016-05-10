module TestConvert
    using Base.Test
    using CategoricalData

    pool = CategoricalPool([1, 2, 3])
    convert(CategoricalPool{Float64}, pool)
    convert(CategoricalPool, pool)
    convert(OrdinalPool{Float64}, pool)
    convert(OrdinalPool, pool)

    opool = OrdinalPool([1, 2, 3], [3, 2, 1])
    convert(CategoricalPool{Float64}, opool)
    convert(CategoricalPool, opool)
    convert(OrdinalPool{Float64}, opool)
    convert(OrdinalPool, opool)

    cv1 = CategoricalValue(1, pool)
    cv2 = CategoricalValue(2, pool)
    cv3 = CategoricalValue(3, pool)

    convert(Int32, cv1)
    convert(Int32, cv2)
    convert(Int32, cv3)

    convert(UInt8, cv1)
    convert(UInt8, cv2)
    convert(UInt8, cv3)

    ov1 = OrdinalValue(1, opool)
    ov2 = OrdinalValue(2, opool)
    ov3 = OrdinalValue(3, opool)

    convert(Int32, ov1)
    convert(Int32, ov2)
    convert(Int32, ov3)

    convert(UInt8, ov1)
    convert(UInt8, ov2)
    convert(UInt8, ov3)
end
