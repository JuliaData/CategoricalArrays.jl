module TestHash
    using Base.Test
    using CategoricalData

    pool1 = CategoricalPool([1, 2, 3])
    pool2 = CategoricalPool([2, 1, 3])

    @test (hash(pool1) == hash(pool1)) === true
    @test (hash(pool1) == hash(pool2)) === false
    @test (hash(pool2) == hash(pool2)) === true

    opool1 = OrdinalPool([1, 2, 3])
    opool2 = OrdinalPool([2, 1, 3])

    @test (hash(opool1) == hash(opool1)) === true
    @test (hash(opool1) == hash(opool2)) === false
    @test (hash(opool2) == hash(opool2)) === true

    cv1a = CategoricalValue(1, pool1)
    cv2a = CategoricalValue(1, pool2)
    cv1b = CategoricalValue(2, pool1)
    cv2b = CategoricalValue(2, pool2)

    @test (hash(cv1a) == hash(cv1a)) == true
    @test (hash(cv1a) == hash(cv2a)) == false
    @test (hash(cv1a) == hash(cv1b)) == false
    @test (hash(cv1a) == hash(cv2b)) == false

    @test (hash(cv1b) == hash(cv1a)) == false
    @test (hash(cv1b) == hash(cv2a)) == false
    @test (hash(cv1b) == hash(cv1b)) == true
    @test (hash(cv1b) == hash(cv2b)) == false

    @test (hash(cv2a) == hash(cv1a)) == false
    @test (hash(cv2a) == hash(cv2a)) == true
    @test (hash(cv2a) == hash(cv1b)) == false
    @test (hash(cv2a) == hash(cv2b)) == false

    @test (hash(cv2b) == hash(cv1a)) == false
    @test (hash(cv2b) == hash(cv2a)) == false
    @test (hash(cv2b) == hash(cv1b)) == false
    @test (hash(cv2b) == hash(cv2b)) == true

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
