module TestShow
    using Base.Test
    using CategoricalData

    pool = CategoricalPool([1, 2, 3])

    opool = OrdinalPool([1, 2, 3], [3, 2, 1])

    cv1 = CategoricalVariable(1, pool)
    cv2 = CategoricalVariable(2, pool)
    cv3 = CategoricalVariable(3, pool)

    ov1 = OrdinalVariable(1, opool)
    ov2 = OrdinalVariable(2, opool)
    ov3 = OrdinalVariable(3, opool)
end
