module TestHash
using Test
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

    nv1a = CategoricalValue(pool1, 1)
    nv2a = CategoricalValue(pool2, 1)
    nv1b = CategoricalValue(pool1, 2)
    nv2b = CategoricalValue(pool2, 2)

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

    ov1a = CategoricalValue(opool1, 1)
    ov2a = CategoricalValue(opool2, 1)
    ov1b = CategoricalValue(opool1, 2)
    ov2b = CategoricalValue(opool2, 2)

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
