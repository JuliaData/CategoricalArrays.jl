module TestShow
    using Base.Test
    using CategoricalData

    pool = CategoricalPool([1, 2, 3])

    opool = OrdinalPool([1, 2, 3], [3, 2, 1])

    cv1 = CategoricalValue(1, pool)
    cv2 = CategoricalValue(2, pool)
    cv3 = CategoricalValue(3, pool)

    ov1 = OrdinalValue(1, opool)
    ov2 = OrdinalValue(2, opool)
    ov3 = OrdinalValue(3, opool)
end
