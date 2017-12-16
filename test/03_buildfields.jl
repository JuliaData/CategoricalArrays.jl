module TestBuildFields
using Compat
using Compat.Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType

@testset "buildindex(), buildinvindex(), buildorder() for b a c" begin
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

    pool = CategoricalPool(index, invindex)

    levels = ["c", "a", "b"]

    built_index = CategoricalArrays.buildindex(invindex)
    @test isa(index, Vector)
    @test built_index == index

    built_invindex = CategoricalArrays.buildinvindex(index)
    @test isa(invindex, Dict)
    @test built_invindex == invindex

    neworder = [
        DefaultRefType(3),
        DefaultRefType(2),
        DefaultRefType(1),
    ]

    built_order = CategoricalArrays.buildorder(pool.invindex, levels)
    @test isa(order, Vector{DefaultRefType})
    @test built_order == neworder
end

end
