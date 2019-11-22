module TestCopy
using Test
using CategoricalArrays
using CategoricalArrays: CategoricalPool, catvalue

@testset "copy" begin
    pool = CategoricalPool(["d", "c", "b"])
    ordered!(pool, true)
    pool2 = copy(pool)

    @test length(pool2) == 3
    @test pool2.levels == pool2.index == ["d", "c", "b"]
    @test pool2.invindex == Dict("d"=>1, "c"=>2, "b"=>3)
    @test pool2.order == 1:3
    @test pool2.valindex == [catvalue(i, pool2) for i in 1:3]
    @test all(v -> v.pool === pool2, pool2.valindex)
    @test pool2.ordered

    levels!(pool2, ["a", "b", "c", "d"])
    ordered!(pool2, false)

    @test length(pool) == 3
    @test pool.levels == pool.index == ["d", "c", "b"]
    @test pool.invindex == Dict("d"=>1, "c"=>2, "b"=>3)
    @test pool.order == 1:3
    @test pool.valindex == [catvalue(i, pool) for i in 1:3]
    @test all(v -> v.pool === pool, pool.valindex)
    @test pool.ordered
end

end