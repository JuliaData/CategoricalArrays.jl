module TestBuildFields
    using Base.Test
    using CategoricalData

    index = ["b", "a", "c"]

    invindex = Dict(
        "b" => convert(CategoricalData.RefType, 1),
        "a" => convert(CategoricalData.RefType, 2),
        "c" => convert(CategoricalData.RefType, 3),
    )

    order = [
        convert(CategoricalData.RefType, 2),
        convert(CategoricalData.RefType, 1),
        convert(CategoricalData.RefType, 3),
    ]

    pool = CategoricalPool(index, invindex)

    ordered = ["c", "a", "b"]

    built_index = CategoricalData.buildindex(invindex)
    @test isa(index, Vector)
    @test built_index == index

    built_invindex = CategoricalData.buildinvindex(index)
    @test isa(invindex, Dict)
    @test built_invindex == invindex

    built_order = CategoricalData.buildorder(index)
    @test isa(order, Vector{CategoricalData.RefType})
    @test built_order == order

    neworder = [
        convert(CategoricalData.RefType, 3),
        convert(CategoricalData.RefType, 2),
        convert(CategoricalData.RefType, 1),
    ]

    built_order = CategoricalData.buildorder(pool.invindex, ordered)
    @test isa(order, Vector{CategoricalData.RefType})
    @test built_order == neworder
end
