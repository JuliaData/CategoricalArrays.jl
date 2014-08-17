module TestIsLess
    using Base.Test
    using CategoricalData

    pool = CategoricalPool([1, 2, 3])
    opool = OrdinalPool([1, 2, 3], [3, 2, 1])

    cv1 = CategoricalVariable(1, pool)
    cv2 = CategoricalVariable(2, pool)
    cv3 = CategoricalVariable(3, pool)

    @test_throws Exception cv1 < cv1
    @test_throws Exception cv1 < cv2
    @test_throws Exception cv1 < cv3
    @test_throws Exception cv2 < cv1
    @test_throws Exception cv2 < cv2
    @test_throws Exception cv2 < cv3
    @test_throws Exception cv3 < cv1
    @test_throws Exception cv3 < cv2
    @test_throws Exception cv3 < cv3

    @test_throws Exception cv1 <= cv1
    @test_throws Exception cv1 <= cv2
    @test_throws Exception cv1 <= cv3
    @test_throws Exception cv2 <= cv1
    @test_throws Exception cv2 <= cv2
    @test_throws Exception cv2 <= cv3
    @test_throws Exception cv3 <= cv1
    @test_throws Exception cv3 <= cv2
    @test_throws Exception cv3 <= cv3

    @test_throws Exception cv1 > cv1
    @test_throws Exception cv1 > cv2
    @test_throws Exception cv1 > cv3
    @test_throws Exception cv2 > cv1
    @test_throws Exception cv2 > cv2
    @test_throws Exception cv2 > cv3
    @test_throws Exception cv3 > cv1
    @test_throws Exception cv3 > cv2
    @test_throws Exception cv3 > cv3

    @test_throws Exception cv1 >= cv1
    @test_throws Exception cv1 >= cv2
    @test_throws Exception cv1 >= cv3
    @test_throws Exception cv2 >= cv1
    @test_throws Exception cv2 >= cv2
    @test_throws Exception cv2 >= cv3
    @test_throws Exception cv3 >= cv1
    @test_throws Exception cv3 >= cv2
    @test_throws Exception cv3 >= cv3

    ov1 = OrdinalVariable(1, opool)
    ov2 = OrdinalVariable(2, opool)
    ov3 = OrdinalVariable(3, opool)

    @test (ov1 < ov1) == false
    @test (ov1 < ov2) == false
    @test (ov1 < ov3) == false
    @test (ov2 < ov1) == true
    @test (ov2 < ov2) == false
    @test (ov2 < ov3) == false
    @test (ov3 < ov1) == true
    @test (ov3 < ov2) == true
    @test (ov3 < ov3) == false

    @test (ov1 <= ov1) == true
    @test (ov1 <= ov2) == false
    @test (ov1 <= ov3) == false
    @test (ov2 <= ov1) == true
    @test (ov2 <= ov2) == true
    @test (ov2 <= ov3) == false
    @test (ov3 <= ov1) == true
    @test (ov3 <= ov2) == true
    @test (ov3 <= ov3) == true

    @test (ov1 > ov1) == false
    @test (ov1 > ov2) == true
    @test (ov1 > ov3) == true
    @test (ov2 > ov1) == false
    @test (ov2 > ov2) == false
    @test (ov2 > ov3) == true
    @test (ov3 > ov1) == false
    @test (ov3 > ov2) == false
    @test (ov3 > ov3) == false

    @test (ov1 >= ov1) == true
    @test (ov1 >= ov2) == true
    @test (ov1 >= ov3) == true
    @test (ov2 >= ov1) == false
    @test (ov2 >= ov2) == true
    @test (ov2 >= ov3) == true
    @test (ov3 >= ov1) == false
    @test (ov3 >= ov2) == false
    @test (ov3 >= ov3) == true

    order!(opool, [2, 3, 1])

    ov1 = OrdinalVariable(1, opool)
    ov2 = OrdinalVariable(2, opool)
    ov3 = OrdinalVariable(3, opool)

    @test (ov1 < ov1) == false
    @test (ov1 < ov2) == false
    @test (ov1 < ov3) == false
    @test (ov2 < ov1) == true
    @test (ov2 < ov2) == false
    @test (ov2 < ov3) == true
    @test (ov3 < ov1) == true
    @test (ov3 < ov2) == false
    @test (ov3 < ov3) == false

    @test (ov1 <= ov1) == true
    @test (ov1 <= ov2) == false
    @test (ov1 <= ov3) == false
    @test (ov2 <= ov1) == true
    @test (ov2 <= ov2) == true
    @test (ov2 <= ov3) == true
    @test (ov3 <= ov1) == true
    @test (ov3 <= ov2) == false
    @test (ov3 <= ov3) == true

    @test (ov1 > ov1) == false
    @test (ov1 > ov2) == true
    @test (ov1 > ov3) == true
    @test (ov2 > ov1) == false
    @test (ov2 > ov2) == false
    @test (ov2 > ov3) == false
    @test (ov3 > ov1) == false
    @test (ov3 > ov2) == true
    @test (ov3 > ov3) == false

    @test (ov1 >= ov1) == true
    @test (ov1 >= ov2) == true
    @test (ov1 >= ov3) == true
    @test (ov2 >= ov1) == false
    @test (ov2 >= ov2) == true
    @test (ov2 >= ov3) == false
    @test (ov3 >= ov1) == false
    @test (ov3 >= ov2) == true
    @test (ov3 >= ov3) == true
end
