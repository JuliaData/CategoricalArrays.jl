module TestHash
    using Base.Test
    using CategoricalData

    pool1 = NominalPool([1, 2, 3])
    pool2 = NominalPool([2, 1, 3])

    @test (hash(pool1) == hash(pool1)) === true
    @test (hash(pool1) == hash(pool2)) === false
    @test (hash(pool2) == hash(pool2)) === true

    opool1 = OrdinalPool([1, 2, 3])
    opool2 = OrdinalPool([2, 1, 3])

    @test (hash(opool1) == hash(opool1)) === true
    @test (hash(opool1) == hash(opool2)) === false
    @test (hash(opool2) == hash(opool2)) === true

    nv1a = NominalValue(1, pool1)
    nv2a = NominalValue(1, pool2)
    nv1b = NominalValue(2, pool1)
    nv2b = NominalValue(2, pool2)

    @test (hash(nv1a) == hash(nv1a)) == true
    @test (hash(nv1a) == hash(nv2a)) == false
    @test (hash(nv1a) == hash(nv1b)) == false
    @test (hash(nv1a) == hash(nv2b)) == false

    @test (hash(nv1b) == hash(nv1a)) == false
    @test (hash(nv1b) == hash(nv2a)) == false
    @test (hash(nv1b) == hash(nv1b)) == true
    @test (hash(nv1b) == hash(nv2b)) == false

    @test (hash(nv2a) == hash(nv1a)) == false
    @test (hash(nv2a) == hash(nv2a)) == true
    @test (hash(nv2a) == hash(nv1b)) == false
    @test (hash(nv2a) == hash(nv2b)) == false

    @test (hash(nv2b) == hash(nv1a)) == false
    @test (hash(nv2b) == hash(nv2a)) == false
    @test (hash(nv2b) == hash(nv1b)) == false
    @test (hash(nv2b) == hash(nv2b)) == true

    ov1a = OrdinalValue(1, opool1)
    ov2a = OrdinalValue(1, opool2)
    ov1b = OrdinalValue(2, opool1)
    ov2b = OrdinalValue(2, opool2)

    @test (hash(ov1a) == hash(ov1a)) == true
    @test (hash(ov1a) == hash(ov2a)) == false
    @test (hash(ov1a) == hash(ov1b)) == false
    @test (hash(ov1a) == hash(ov2b)) == false

    @test (hash(ov1b) == hash(ov1a)) == false
    @test (hash(ov1b) == hash(ov2a)) == false
    @test (hash(ov1b) == hash(ov1b)) == true
    @test (hash(ov1b) == hash(ov2b)) == false

    @test (hash(ov2a) == hash(ov1a)) == false
    @test (hash(ov2a) == hash(ov2a)) == true
    @test (hash(ov2a) == hash(ov1b)) == false
    @test (hash(ov2a) == hash(ov2b)) == false

    @test (hash(ov2b) == hash(ov1a)) == false
    @test (hash(ov2b) == hash(ov2a)) == false
    @test (hash(ov2b) == hash(ov1b)) == false
    @test (hash(ov2b) == hash(ov2b)) == true
end
