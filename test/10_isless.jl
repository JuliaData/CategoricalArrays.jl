module TestIsLess
    using Base.Test
    using CategoricalData

    pool = NominalPool([1, 2, 3])
    opool = OrdinalPool([1, 2, 3], [3, 2, 1])

    nv1 = NominalValue(1, pool)
    nv2 = NominalValue(2, pool)
    nv3 = NominalValue(3, pool)

    @test_throws Exception nv1 < nv1
    @test_throws Exception nv1 < nv2
    @test_throws Exception nv1 < nv3
    @test_throws Exception nv2 < nv1
    @test_throws Exception nv2 < nv2
    @test_throws Exception nv2 < nv3
    @test_throws Exception nv3 < nv1
    @test_throws Exception nv3 < nv2
    @test_throws Exception nv3 < nv3

    @test_throws Exception nv1 <= nv1
    @test_throws Exception nv1 <= nv2
    @test_throws Exception nv1 <= nv3
    @test_throws Exception nv2 <= nv1
    @test_throws Exception nv2 <= nv2
    @test_throws Exception nv2 <= nv3
    @test_throws Exception nv3 <= nv1
    @test_throws Exception nv3 <= nv2
    @test_throws Exception nv3 <= nv3

    @test_throws Exception nv1 > nv1
    @test_throws Exception nv1 > nv2
    @test_throws Exception nv1 > nv3
    @test_throws Exception nv2 > nv1
    @test_throws Exception nv2 > nv2
    @test_throws Exception nv2 > nv3
    @test_throws Exception nv3 > nv1
    @test_throws Exception nv3 > nv2
    @test_throws Exception nv3 > nv3

    @test_throws Exception nv1 >= nv1
    @test_throws Exception nv1 >= nv2
    @test_throws Exception nv1 >= nv3
    @test_throws Exception nv2 >= nv1
    @test_throws Exception nv2 >= nv2
    @test_throws Exception nv2 >= nv3
    @test_throws Exception nv3 >= nv1
    @test_throws Exception nv3 >= nv2
    @test_throws Exception nv3 >= nv3

    ov1 = OrdinalValue(1, opool)
    ov2 = OrdinalValue(2, opool)
    ov3 = OrdinalValue(3, opool)

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

    ov1 = OrdinalValue(1, opool)
    ov2 = OrdinalValue(2, opool)
    ov3 = OrdinalValue(3, opool)

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
