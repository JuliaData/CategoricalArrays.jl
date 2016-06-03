module TestEquality
    using Base.Test
    using CategoricalData

    pool1 = OrdinalPool([1, 2, 3])
    pool2 = OrdinalPool([2.0, 1.0, 3.0])

    @test isequal(pool1, pool1) === true
    @test isequal(pool1, pool2) === false
    @test isequal(pool2, pool2) === true

    @test (pool1 == pool1) === true
    @test (pool1 == pool2) === false
    @test (pool2 == pool2) === true

    @test (pool1 === pool1) === true
    @test (pool1 === pool2) === false
    @test (pool2 === pool2) === true

    opool1 = OrdinalPool([1, 2, 3])
    opool2 = OrdinalPool([2.0, 1.0, 3.0])

    @test isequal(opool1, opool1) === true
    @test isequal(opool1, opool2) === false
    @test isequal(opool2, opool2) === true

    @test (opool1 == opool1) === true
    @test (opool1 == opool2) === false
    @test (opool2 == opool2) === true

    @test (opool1 === opool1) === true
    @test (opool1 === opool2) === false
    @test (opool2 === opool2) === true

    cv1a = OrdinalValue(1, pool1)
    cv2a = OrdinalValue(1, pool2)
    cv1b = OrdinalValue(2, pool1)
    cv2b = OrdinalValue(2, pool2)

    @test isequal(cv1a, cv1a) == true
    @test isequal(cv1a, cv2a) == false
    @test isequal(cv1a, cv1b) == false
    @test isequal(cv1a, cv2b) == true

    @test isequal(cv1b, cv1a) == false
    @test isequal(cv1b, cv2a) == true
    @test isequal(cv1b, cv1b) == true
    @test isequal(cv1b, cv2b) == false

    @test isequal(cv2a, cv1a) == false
    @test isequal(cv2a, cv2a) == true
    @test isequal(cv2a, cv1b) == true
    @test isequal(cv2a, cv2b) == false

    @test isequal(cv2b, cv1a) == true
    @test isequal(cv2b, cv2a) == false
    @test isequal(cv2b, cv1b) == false
    @test isequal(cv2b, cv2b) == true

    @test isequal(1, cv1a) == true
    @test isequal(1, cv2a) == false
    @test isequal(1, cv1b) == false
    @test isequal(1, cv2b) == true

    @test isequal(cv1a, 2) == false
    @test isequal(cv2a, 2) == true
    @test isequal(cv1b, 2) == true
    @test isequal(cv2b, 2) == false

    @test (cv1a == cv1a) == true
    @test (cv1a == cv2a) == false
    @test (cv1a == cv1b) == false
    @test (cv1a == cv2b) == true

    @test (cv1b == cv1a) == false
    @test (cv1b == cv2a) == true
    @test (cv1b == cv1b) == true
    @test (cv1b == cv2b) == false

    @test (cv2a == cv1a) == false
    @test (cv2a == cv2a) == true
    @test (cv2a == cv1b) == true
    @test (cv2a == cv2b) == false

    @test (cv2b == cv1a) == true
    @test (cv2b == cv2a) == false
    @test (cv2b == cv1b) == false
    @test (cv2b == cv2b) == true

    @test (cv1a === cv1a) == true
    @test (cv1a === cv2a) == false
    @test (cv1a === cv1b) == false
    @test (cv1a === cv2b) == false

    @test (cv1b === cv1a) == false
    @test (cv1b === cv2a) == false
    @test (cv1b === cv1b) == true
    @test (cv1b === cv2b) == false

    @test (cv2a === cv1a) == false
    @test (cv2a === cv2a) == true
    @test (cv2a === cv1b) == false
    @test (cv2a === cv2b) == false

    @test (cv2b === cv1a) == false
    @test (cv2b === cv2a) == false
    @test (cv2b === cv1b) == false
    @test (cv2b === cv2b) == true

    @test (1 == cv1a) == true
    @test (1 == cv2a) == false
    @test (1 == cv1b) == false
    @test (1 == cv2b) == true

    @test (cv1a == 2) == false
    @test (cv2a == 2) == true
    @test (cv1b == 2) == true
    @test (cv2b == 2) == false

    ov1a = OrdinalValue(1, opool1)
    ov2a = OrdinalValue(1, opool2)
    ov1b = OrdinalValue(2, opool1)
    ov2b = OrdinalValue(2, opool2)

    @test isequal(ov1a, ov1a) == true
    @test isequal(ov1a, ov2a) == false
    @test isequal(ov1a, ov1b) == false
    @test isequal(ov1a, ov2b) == true

    @test isequal(ov1b, ov1a) == false
    @test isequal(ov1b, ov2a) == true
    @test isequal(ov1b, ov1b) == true
    @test isequal(ov1b, ov2b) == false

    @test isequal(ov2a, ov1a) == false
    @test isequal(ov2a, ov2a) == true
    @test isequal(ov2a, ov1b) == true
    @test isequal(ov2a, ov2b) == false

    @test isequal(ov2b, ov1a) == true
    @test isequal(ov2b, ov2a) == false
    @test isequal(ov2b, ov1b) == false
    @test isequal(ov2b, ov2b) == true

    @test isequal(1, ov1a) == true
    @test isequal(1, ov2a) == false
    @test isequal(1, ov1b) == false
    @test isequal(1, ov2b) == true

    @test isequal(ov1a, 2) == false
    @test isequal(ov2a, 2) == true
    @test isequal(ov1b, 2) == true
    @test isequal(ov2b, 2) == false

    @test (ov1a == ov1a) == true
    @test (ov1a == ov2a) == false
    @test (ov1a == ov1b) == false
    @test (ov1a == ov2b) == true

    @test (ov1b == ov1a) == false
    @test (ov1b == ov2a) == true
    @test (ov1b == ov1b) == true
    @test (ov1b == ov2b) == false

    @test (ov2a == ov1a) == false
    @test (ov2a == ov2a) == true
    @test (ov2a == ov1b) == true
    @test (ov2a == ov2b) == false

    @test (ov2b == ov1a) == true
    @test (ov2b == ov2a) == false
    @test (ov2b == ov1b) == false
    @test (ov2b == ov2b) == true

    @test (ov1a === ov1a) == true
    @test (ov1a === ov2a) == false
    @test (ov1a === ov1b) == false
    @test (ov1a === ov2b) == false

    @test (ov1b === ov1a) == false
    @test (ov1b === ov2a) == false
    @test (ov1b === ov1b) == true
    @test (ov1b === ov2b) == false

    @test (ov2a === ov1a) == false
    @test (ov2a === ov2a) == true
    @test (ov2a === ov1b) == false
    @test (ov2a === ov2b) == false

    @test (ov2b === ov1a) == false
    @test (ov2b === ov2a) == false
    @test (ov2b === ov1b) == false
    @test (ov2b === ov2b) == true

    @test (1 == ov1a) == true
    @test (1 == ov2a) == false
    @test (1 == ov1b) == false
    @test (1 == ov2b) == true

    @test (ov1a == 2) == false
    @test (ov2a == 2) == true
    @test (ov1b == 2) == true
    @test (ov2b == 2) == false
end
