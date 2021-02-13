module TestCopy
using Test
using CategoricalArrays
using CategoricalArrays: CategoricalPool

@testset "copy" begin
    pool = CategoricalPool(["d", "c", "b"])
    ordered!(pool, true)
    pool2 = copy(pool)

    @test length(pool2) == 3
    @test pool2.levels == ["d", "c", "b"]
    @test pool2.invindex == Dict("d"=>1, "c"=>2, "b"=>3)
    @test pool2.ordered

    levels!(pool2, ["d", "c", "b", "e"])
    ordered!(pool2, false)

    @test length(pool) == 3
    @test pool.levels == ["d", "c", "b"]
    @test pool.invindex == Dict("d"=>1, "c"=>2, "b"=>3)
    @test pool.ordered
end

end