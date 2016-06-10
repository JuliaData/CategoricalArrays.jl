module TestConvert
    using Base.Test
    using CategoricalArrays

    for (P, V) in ((NominalPool, NominalValue), (OrdinalPool, OrdinalValue))
        pool = P([1, 2, 3])
        convert(P{Float64}, pool)
        convert(P, pool)
        convert(P{Float64}, pool)
        convert(P, pool)

        v1 = V(1, pool)
        v2 = V(2, pool)
        v3 = V(3, pool)

        convert(Int32, v1)
        convert(Int32, v2)
        convert(Int32, v3)

        convert(UInt8, v1)
        convert(UInt8, v2)
        convert(UInt8, v3)
    end
end
