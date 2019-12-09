module TestView
using Test
using CategoricalArrays

const ≅ = isequal

@testset "view($(CategoricalArray{Union{T, eltype(a)}}), $inds), ordered=$order construction" for
    T in (Union{}, Missing), order in (true, false),
    a in (1:10, 10:-1:1, ["a", "c", "b", "b", "a"]),
    inds in [1:2, :, 1, []]

    x = CategoricalArray{Union{T, eltype(a)}}(a, ordered=order)
    v = view(x, inds)
    @test levels(v) === levels(x)
    @test unique(v) == (ndims(v) > 0 ? unique(a[inds]) : [a[inds]])
    @test isordered(v) === isordered(x)
end

@testset "views comparison" begin
    ca1 = CategoricalArray([1, 2, 3])
    ca2 = CategoricalArray{Union{Int, Missing}}([1, 2, 3])
    ca3 = CategoricalArray([1, 2, missing])
    ca4 = CategoricalArray([4, 3, 2])
    ca5 = CategoricalArray([1 2; 3 4])

    @test view(ca1, 1:2) == view(ca1, 1:2)
    @test view(ca2, 1:2) == view(ca2, 1:2)
    @test view(ca1, 1:2) == view(ca2, 1:2)
    @test view(ca1, 1:2) == view(ca3, 1:2)
    @test view(ca1, 1:2) != view(ca2, 1:3)
    @test view(ca1, 1:2) != view(ca5, 1:2, 1:1)
end

@testset "fill! on view" for
    a in (categorical(["c", "a", "b"]), categorical(["c", "a", missing]))
    v = view(a, 1:2)
    @test fill!(v, a[1]) == ["c", "c"]
    @test fill!(v, "a") == ["a", "a"]
    @test fill!(v, "d") == ["d", "d"]
    if eltype(a) >: Missing
        @test fill!(v, missing) ≅ [missing, missing]
    else
        @test_throws MethodError fill!(v, missing)
    end
end

end
