module TestArray

using Base.Test
using CategoricalData


for (A, V, M) in ((CategoricalArray, CategoricalVector, CategoricalMatrix),
                  (OrdinalArray, OrdinalVector, OrdinalMatrix))
    # Vector
    a = ["a", "b", "a"]
    x = A(a)

    @test x == a
    @test levels(x) == unique(a)
    @test size(x) === (3,)
    @test length(x) === 3

    @test convert(A, x) === x
    @test convert(A{String}, x) === x
    @test convert(V, x) === x
    @test convert(V{String}, x) === x
    @test A{String}(x) === x
    @test V(x) === x
    @test V{String}(x) === x

    @test convert(A, a) == x
    @test convert(A{String}, a) == x
    @test convert(V, a) == x
    @test convert(V{String}, a) == x
    @test A{String}(a) == x
    @test V(a) == x
    @test V{String}(a) == x

    @test x[1] === x.pool.valindex[1]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[1]
    @test_throws BoundsError x[4]

    @test x[1:2] == ["a", "b"]
    @test typeof(x[1:2]) === typeof(x)

    x[1] = "b"
    @test x[1] === x.pool.valindex[2]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[1]

    x[3] = "c"
    @test x[1] === x.pool.valindex[2]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[3]
    @test levels(x) == ["a", "b", "c"]

    x[2:3] = "a"
    @test x[1] === x.pool.valindex[2]
    @test x[2] === x.pool.valindex[1]
    @test x[3] === x.pool.valindex[1]
    @test levels(x) == ["a", "b", "c"]

    droplevels!(x)
    @test x[1] === x.pool.valindex[2]
    @test x[2] === x.pool.valindex[1]
    @test x[3] === x.pool.valindex[1]
    @test levels(x) == ["a", "b"]

    @test_throws ArgumentError levels!(x, ["a"])
    @test_throws ArgumentError levels!(x, ["e", "b"])
    @test_throws ArgumentError levels!(x, ["e", "a", "b", "a"])

    @test levels!(x, ["e", "a", "b"]) == ["e", "a", "b"]
    @test x[1] === x.pool.valindex[3]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[2]
    @test levels(x) == ["e", "a", "b"]

    x[1] = "c"
    @test x[1] === x.pool.valindex[4]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[2]
    @test levels(x) == ["e", "a", "b", "c"]


    # Vector created from range (i.e. non-Array AbstractArray),
    # direct conversion to a vector with different eltype
    a = 0.0:0.5:1.5
    x = A(a)

    @test x == collect(a)
    @test levels(x) == unique(a)
    @test size(x) === (4,)
    @test length(x) === 4

    @test convert(A, x) === x
    @test convert(A{Float64}, x) === x
    @test convert(V, x) === x
    @test convert(V{Float64}, x) === x
    @test A{Float64}(x) === x
    @test V(x) === x
    @test V{Float64}(x) === x

    @test convert(A, a) == x
    @test convert(A{Float64}, a) == x
    @test convert(A{Float32}, a) == x
    @test convert(V, a) == x
    @test convert(V{Float64}, a) == x
    @test convert(V{Float32}, a) == x
    @test A{Float64}(a) == x
    @test A{Float32}(a) == x
    @test V(a) == x
    @test V{Float64}(a) == x
    @test V{Float32}(a) == x

    @test x[1] === x.pool.valindex[1]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[3]
    @test x[4] === x.pool.valindex[4]
    @test_throws BoundsError x[5]

    @test x[1:2] == [0.0, 0.5]
    @test typeof(x[1:2]) === typeof(x)

    x[2] = 1
    @test x[1] === x.pool.valindex[1]
    @test x[2] === x.pool.valindex[3]
    @test x[3] === x.pool.valindex[3]
    @test x[4] === x.pool.valindex[4]
    @test levels(x) == unique(a)

    x[1:2] = -1
    @test x[1] === x.pool.valindex[5]
    @test x[2] === x.pool.valindex[5]
    @test x[3] === x.pool.valindex[3]
    @test x[4] === x.pool.valindex[4]
    @test levels(x) == vcat(unique(a), -1)


    # Matrix
    a = ["a" "b" "c"; "b" "a" "c"]
    x = A(a)

    @test x == a
    @test levels(x) == unique(a)
    @test size(x) === (2, 3)
    @test length(x) === 6

    @test convert(A, x) === x
    @test convert(A{String}, x) === x
    @test convert(M, x) === x
    @test convert(M{String}, x) === x
    @test A{String}(x) === x
    @test M(x) === x
    @test M{String}(x) === x

    @test convert(A, a) == x
    @test convert(A{String}, a) == x
    @test convert(M, a) == x
    @test convert(M{String}, a) == x
    @test A{String}(a) == x
    @test M(a) == x
    @test M{String}(a) == x

    @test x[1] === x.pool.valindex[1]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[2]
    @test x[4] === x.pool.valindex[1]
    @test x[5] === x.pool.valindex[3]
    @test x[6] === x.pool.valindex[3]
    @test_throws BoundsError x[7]

    @test x[1,1] === x.pool.valindex[1]
    @test x[2,1] === x.pool.valindex[2]
    @test x[1,2] === x.pool.valindex[2]
    @test x[2,2] === x.pool.valindex[1]
    @test x[1,3] === x.pool.valindex[3]
    @test x[2,3] === x.pool.valindex[3]
    @test_throws BoundsError x[1,4]
    @test_throws BoundsError x[4,1]
    @test_throws BoundsError x[4,4]

    @test x[1:2,:] == x
    @test typeof(x[1:2,:]) === typeof(x)
    @test x[1:2,1] == ["a", "b"]
    @test typeof(x[1:2,1]) === V{String}

    x[1] = "z"
    @test x[1] === x.pool.valindex[4]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[2]
    @test x[4] === x.pool.valindex[1]
    @test x[5] === x.pool.valindex[3]
    @test x[6] === x.pool.valindex[3]
    @test levels(x) == ["a", "b", "c", "z"]

    x[1,:] = "a"
    @test x[1] === x.pool.valindex[1]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[1]
    @test x[4] === x.pool.valindex[1]
    @test x[5] === x.pool.valindex[1]
    @test x[6] === x.pool.valindex[3]
    @test levels(x) == ["a", "b", "c", "z"]

    x[1,1:2] = "z"
    @test x[1] === x.pool.valindex[4]
    @test x[2] === x.pool.valindex[2]
    @test x[3] === x.pool.valindex[4]
    @test x[4] === x.pool.valindex[1]
    @test x[5] === x.pool.valindex[1]
    @test x[6] === x.pool.valindex[3]
    @test levels(x) == ["a", "b", "c", "z"]


    # Uninitialized array
    for x in (A(2), V(2),
              A(String, 2), V(String, 2),
              A(2, 3), M(2, 3),
              A(String, 2), M(String, 2))
        @test !isassigned(x, 1) && isdefined(x, 1)
        @test !isassigned(x, 2) && isdefined(x, 2)
        @test_throws UndefRefError x[1]
        @test_throws UndefRefError x[2]
        @test levels(x) == []

        x[1] = "c"
        @test x[1] === x.pool.valindex[1]
        @test !isassigned(x, 2) && isdefined(x, 2)
        @test_throws UndefRefError x[2]
        @test levels(x) == ["c"]

        x[1] = "a"
        @test x[1] === x.pool.valindex[2]
        @test !isassigned(x, 2) && isdefined(x, 2)
        @test_throws UndefRefError x[2]
        @test levels(x) == ["c", "a"]

        x[2] = "c"
        @test x[1] === x.pool.valindex[2]
        @test x[2] === x.pool.valindex[1]
        @test levels(x) == ["c", "a"]

        x[1] = "b"
        @test x[1] === x.pool.valindex[3]
        @test x[2] === x.pool.valindex[1]
        @test levels(x) == ["c", "a", "b"]
    end
end

end
