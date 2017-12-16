module TestEquality
using Compat
using Compat.Test
using CategoricalArrays

@testset "== and isequal() for CategoricalPool{Int} and CategoricalPool{Float64}" begin
    pool1 = CategoricalPool([1, 2, 3])
    pool2 = CategoricalPool([2.0, 1.0, 3.0])

    @test isequal(pool1, pool1) === true
    @test isequal(pool1, pool2) === false
    @test isequal(pool2, pool2) === true

    @test (pool1 == pool1) === true
    @test (pool1 == pool2) === false
    @test (pool2 == pool2) === true

    @test (pool1 === pool1) === true
    @test (pool1 === pool2) === false
    @test (pool2 === pool2) === true

    opool1 = CategoricalPool([1, 2, 3], true)
    opool2 = CategoricalPool([2.0, 1.0, 3.0], true)

    @test isequal(opool1, opool1) === true
    @test isequal(opool1, opool2) === false
    @test isequal(opool2, opool2) === true

    @test (opool1 == opool1) === true
    @test (opool1 == opool2) === false
    @test (opool2 == opool2) === true

    @test (opool1 === opool1) === true
    @test (opool1 === opool2) === false
    @test (opool2 === opool2) === true

    nv1a = CategoricalArrays.catvalue(1, pool1)
    nv2a = CategoricalArrays.catvalue(1, pool2)
    nv1b = CategoricalArrays.catvalue(2, pool1)
    nv2b = CategoricalArrays.catvalue(2, pool2)

    @test isequal(nv1a, nv1a) == true
    @test isequal(nv1a, nv2a) == false
    @test isequal(nv1a, nv1b) == false
    @test isequal(nv1a, nv2b) == true

    @test isequal(nv1b, nv1a) == false
    @test isequal(nv1b, nv2a) == true
    @test isequal(nv1b, nv1b) == true
    @test isequal(nv1b, nv2b) == false

    @test isequal(nv2a, nv1a) == false
    @test isequal(nv2a, nv2a) == true
    @test isequal(nv2a, nv1b) == true
    @test isequal(nv2a, nv2b) == false

    @test isequal(nv2b, nv1a) == true
    @test isequal(nv2b, nv2a) == false
    @test isequal(nv2b, nv1b) == false
    @test isequal(nv2b, nv2b) == true

    @test isequal(1, nv1a) == true
    @test isequal(1, nv2a) == false
    @test isequal(1, nv1b) == false
    @test isequal(1, nv2b) == true

    @test isequal(nv1a, 2) == false
    @test isequal(nv2a, 2) == true
    @test isequal(nv1b, 2) == true
    @test isequal(nv2b, 2) == false

    ov1a = CategoricalArrays.catvalue(1, opool1)
    ov2a = CategoricalArrays.catvalue(1, opool2)
    ov1b = CategoricalArrays.catvalue(2, opool1)
    ov2b = CategoricalArrays.catvalue(2, opool2)

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

    @testset "ordered and non-ordered values are equal" begin
    @test (ov1a == nv1a) === true
    @test (ov1a == nv2a) === false
    @test (ov1a == nv1b) === false
    @test (ov1a == nv2b) === true

    @test (ov1b == nv1a) === false
    @test (ov1b == nv2a) === true
    @test (ov1b == nv1b) === true
    @test (ov1b == nv2b) === false

    @test (ov2a == nv1a) === false
    @test (ov2a == nv2a) === true
    @test (ov2a == nv1b) === true
    @test (ov2a == nv2b) === false

    @test (ov2b == nv1a) === true
    @test (ov2b == nv2a) === false
    @test (ov2b == nv1b) === false
    @test (ov2b == nv2b) === true
    end

    @testset "non-equality with missing" begin
    @test ismissing(nv1a == missing)
    @test ismissing(ov1a == missing)
    @test ismissing(missing == nv1a)
    @test ismissing(missing == ov1a)

    @test isequal(nv1a, missing) == false
    @test isequal(ov1a, missing) == false
    @test isequal(missing, nv1a) == false
    @test isequal(missing, ov1a) == false
    end
end

@testset "in()" begin
    pool = CategoricalPool([5, 1, 3])
    nv = CategoricalArrays.catvalue(2, pool)

    @test (nv in 1:3) === true
    @test (nv in [1, 2, 3]) === true
    @test (nv in 2:3) === false
    @test (nv in [2, 3]) === false
end

end
