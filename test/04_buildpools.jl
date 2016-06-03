# TODO: Delete this functionality?
module TestBuildPools
    using Base.Test
    using CategoricalData

    pool1 = CategoricalData.build(OrdinalPool, [1, 1, 1, 2, 2, 2])
    pool2 = CategoricalData.build(OrdinalPool, [2, 2, 2, 1, 1, 1])

    opool1 = CategoricalData.build(OrdinalPool, [1, 1, 1, 2, 2, 2])
    opool2 = CategoricalData.build(OrdinalPool, [2, 2, 2, 1, 1, 1])
end
