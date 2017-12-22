module TestHash
using Compat
using Compat.Test
using CategoricalArrays

@testset "hash() for CategoricalPool{Int} and CategoricalPool{Float64} and its values" begin
    pool1 = CategoricalPool([1, 2, 3])
    pool2 = CategoricalPool([2.0, 1.0, 3.0])

    @test (hash(pool1) == hash(pool1)) === true
    @test (hash(pool1) == hash(pool2)) === false
    @test (hash(pool2) == hash(pool2)) === true

    opool1 = CategoricalPool([1, 2, 3], true)
    opool2 = CategoricalPool([2.0, 1.0, 3.0], true)

    @test (hash(opool1) == hash(opool1)) === true
    @test (hash(opool1) == hash(opool2)) === false
    @test (hash(opool2) == hash(opool2)) === true

    nv1a = CategoricalArrays.catvalue(1, pool1)
    nv2a = CategoricalArrays.catvalue(1, pool2)
    nv1b = CategoricalArrays.catvalue(2, pool1)
    nv2b = CategoricalArrays.catvalue(2, pool2)

    @test (hash(nv1a) == hash(nv1a)) === true
    @test (hash(nv1a) == hash(nv2a)) === false
    @test (hash(nv1a) == hash(nv1b)) === false
    @test (hash(nv1a) == hash(nv2b)) === true

    @test (hash(nv1b) == hash(nv1a)) === false
    @test (hash(nv1b) == hash(nv2a)) === true
    @test (hash(nv1b) == hash(nv1b)) === true
    @test (hash(nv1b) == hash(nv2b)) === false

    @test (hash(nv2a) == hash(nv1a)) === false
    @test (hash(nv2a) == hash(nv2a)) === true
    @test (hash(nv2a) == hash(nv1b)) === true
    @test (hash(nv2a) == hash(nv2b)) === false

    @test (hash(nv2b) == hash(nv1a)) === true
    @test (hash(nv2b) == hash(nv2a)) === false
    @test (hash(nv2b) == hash(nv1b)) === false
    @test (hash(nv2b) == hash(nv2b)) === true

    ov1a = CategoricalArrays.catvalue(1, opool1)
    ov2a = CategoricalArrays.catvalue(1, opool2)
    ov1b = CategoricalArrays.catvalue(2, opool1)
    ov2b = CategoricalArrays.catvalue(2, opool2)

    @test (hash(ov1a) == hash(ov1a)) === true
    @test (hash(ov1a) == hash(ov2a)) === false
    @test (hash(ov1a) == hash(ov1b)) === false
    @test (hash(ov1a) == hash(ov2b)) === true

    @test (hash(ov1b) == hash(ov1a)) === false
    @test (hash(ov1b) == hash(ov2a)) === true
    @test (hash(ov1b) == hash(ov1b)) === true
    @test (hash(ov1b) == hash(ov2b)) === false

    @test (hash(ov2a) == hash(ov1a)) === false
    @test (hash(ov2a) == hash(ov2a)) === true
    @test (hash(ov2a) == hash(ov1b)) === true
    @test (hash(ov2a) == hash(ov2b)) === false

    @test (hash(ov2b) == hash(ov1a)) === true
    @test (hash(ov2b) == hash(ov2a)) === false
    @test (hash(ov2b) == hash(ov1b)) === false
    @test (hash(ov2b) == hash(ov2b)) === true

    @testset "ordered and non-ordered values hash equal" begin
    @test (hash(ov1a) == hash(nv1a)) === true
    @test (hash(ov1a) == hash(nv2a)) === false
    @test (hash(ov1a) == hash(nv1b)) === false
    @test (hash(ov1a) == hash(nv2b)) === true

    @test (hash(ov1b) == hash(nv1a)) === false
    @test (hash(ov1b) == hash(nv2a)) === true
    @test (hash(ov1b) == hash(nv1b)) === true
    @test (hash(ov1b) == hash(nv2b)) === false

    @test (hash(ov2a) == hash(nv1a)) === false
    @test (hash(ov2a) == hash(nv2a)) === true
    @test (hash(ov2a) == hash(nv1b)) === true
    @test (hash(ov2a) == hash(nv2b)) === false

    @test (hash(ov2b) == hash(nv1a)) === true
    @test (hash(ov2b) == hash(nv2a)) === false
    @test (hash(ov2b) == hash(nv1b)) === false
    @test (hash(ov2b) == hash(nv2b)) === true
    end
end

end
