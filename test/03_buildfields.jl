module TestBuildFields
    using Base.Test
    using CategoricalData
    using CategoricalData: DefaultRefType

    index = ["b", "a", "c"]

    invindex = Dict(
        "b" => DefaultRefType(1),
        "a" => DefaultRefType(2),
        "c" => DefaultRefType(3),
    )

    order = [
        DefaultRefType(2),
        DefaultRefType(1),
        DefaultRefType(3),
    ]

    for P in (NominalPool, OrdinalPool)
        pool = P(index, invindex)

        ordered = ["c", "a", "b"]

        built_index = CategoricalData.buildindex(invindex)
        @test isa(index, Vector)
        @test built_index == index

        built_invindex = CategoricalData.buildinvindex(index)
        @test isa(invindex, Dict)
        @test built_invindex == invindex

        built_order = CategoricalData.buildorder(index)
        @test isa(order, Vector{DefaultRefType})
        @test built_order == order

        neworder = [
            DefaultRefType(3),
            DefaultRefType(2),
            DefaultRefType(1),
        ]

        built_order = CategoricalData.buildorder(pool.invindex, ordered)
        @test isa(order, Vector{DefaultRefType})
        @test built_order == neworder
    end
end
