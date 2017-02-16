module TestArray

using Base.Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType
using Compat

for ordered in (false, true)
    for R in (CategoricalArrays.DefaultRefType, UInt8, UInt, Int8, Int)
        # Vector
        a = ["b", "a", "b"]
        x = CategoricalVector{String, R}(a, ordered=ordered)

        @test x == a
        @test isordered(x) === ordered
        @test levels(x) == sort(unique(a))
        @test size(x) === (3,)
        @test length(x) === 3

        @test convert(CategoricalArray, x) === x
        @test convert(CategoricalArray{String}, x) === x
        @test convert(CategoricalArray{String, 1}, x) === x
        @test convert(CategoricalArray{String, 1, R}, x) === x
        @test convert(CategoricalArray{String, 1, DefaultRefType}, x) == x
        @test convert(CategoricalArray{String, 1, UInt8}, x) == x

        @test convert(CategoricalVector, x) === x
        @test convert(CategoricalVector{String}, x) === x
        @test convert(CategoricalVector{String, R}, x) === x
        @test convert(CategoricalVector{String, DefaultRefType}, x) == x
        @test convert(CategoricalVector{String, UInt8}, x) == x

        for y in (CategoricalArray(x, ordered=ordered),
                  CategoricalArray{String}(x, ordered=ordered),
                  CategoricalArray{String, 1}(x, ordered=ordered),
                  CategoricalArray{String, 1, R}(x, ordered=ordered),
                  CategoricalArray{String, 1, DefaultRefType}(x, ordered=ordered),
                  CategoricalArray{String, 1, UInt8}(x, ordered=ordered),
                  CategoricalVector(x, ordered=ordered),
                  CategoricalVector{String}(x, ordered=ordered),
                  CategoricalVector{String, R}(x, ordered=ordered),
                  CategoricalVector{String, DefaultRefType}(x, ordered=ordered),
                  CategoricalVector{String, UInt8}(x, ordered=ordered),
                  categorical(x, ordered=ordered),
                  categorical(x, false, ordered=ordered),
                  categorical(x, true, ordered=ordered))
            @test isa(y, CategoricalVector{String})
            @test isordered(y) === ordered
            @test y == x
            @test y !== x
            @test y.refs !== x.refs
            @test y.pool !== x.pool
        end

        @test convert(CategoricalArray, a) == x
        @test convert(CategoricalArray{String}, a) == x
        @test convert(CategoricalArray{String, 1}, a) == x
        @test convert(CategoricalArray{String, 1, R}, a) == x
        @test convert(CategoricalArray{String, 1, DefaultRefType}, a) == x
        @test convert(CategoricalArray{String, 1, UInt8}, a) == x

        @test convert(CategoricalVector, a) == x
        @test convert(CategoricalVector{String}, a) == x
        @test convert(CategoricalVector{String, R}, a) == x
        @test convert(CategoricalVector{String, DefaultRefType}, a) == x
        @test convert(CategoricalVector{String, UInt8}, a) == x

        @test CategoricalArray{String}(a, ordered=ordered) == x
        @test CategoricalArray{String, 1}(a, ordered=ordered) == x
        @test CategoricalArray{String, 1, R}(a, ordered=ordered) == x
        @test CategoricalArray{String, 1, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalArray{String, 1, UInt8}(a, ordered=ordered) == x

        @test CategoricalVector(a, ordered=ordered) == x
        @test CategoricalVector{String}(a, ordered=ordered) == x
        @test CategoricalVector{String, R}(a, ordered=ordered) == x
        @test CategoricalVector{String, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalVector{String, UInt8}(a, ordered=ordered) == x

        for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                  (a, DefaultRefType, DefaultRefType, false),
                                  (x, R, UInt8, true),
                                  (x, R, R, false))
            x2 = categorical(y, ordered=ordered)
            @test x2 == x
            @test isa(x2, CategoricalVector{String, R1})
            @test isordered(x2) === ordered

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 == x
            @test isa(x2, CategoricalVector{String, R2})
            @test isordered(x2) === ordered
        end

        x2 = compress(x)
        @test x2 == x
        @test isa(x2, CategoricalVector{String, UInt8})
        @test isordered(x2) === isordered(x)
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 == x
        @test typeof(x2) === typeof(x)
        @test isordered(x2) === isordered(x)
        @test levels(x2) == levels(x)

        if !isordered(x)
            @test ordered!(x, true) === x
            @test isordered(x) === true
        end
        @test x[1] > x[2]
        @test x[3] > x[2]

        @test ordered!(x, false) === x
        @test isordered(x) === false
        @test_throws Exception x[1] > x[2]
        @test_throws Exception x[3] > x[2]

        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[1]
        @test_throws BoundsError x[4]

        x2 = x[:]
        @test typeof(x2) === typeof(x)
        @test x2 == x
        @test x2 !== x
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:2]
        @test typeof(x2) === typeof(x)
        @test x2 == ["b", "a"]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:1]
        @test typeof(x2) === typeof(x)
        @test x2 == ["b"]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[2:1]
        @test typeof(x2) === typeof(x)
        @test isempty(x2)
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x[1] = x[2]
        @test x[1] === x.pool.valindex[2]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[1]

        x[3] = "c"
        @test x[1] === x.pool.valindex[2]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[3]
        @test levels(x) == ["a", "b", "c"]

        x[2:3] = "b"
        @test x[1] === x.pool.valindex[2]
        @test x[2] === x.pool.valindex[1]
        @test x[3] === x.pool.valindex[1]
        @test levels(x) == ["a", "b", "c"]

        @test droplevels!(x) === x
        @test levels(x) == ["a", "b"]
        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[2]
        @test levels(x) == ["a", "b"]

        @test levels!(x, ["b", "a"]) === x
        @test levels(x) == ["b", "a"]
        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[2]
        @test levels(x) == ["b", "a"]

        @test_throws ArgumentError levels!(x, ["a"])
        @test_throws ArgumentError levels!(x, ["e", "b"])
        @test_throws ArgumentError levels!(x, ["e", "a", "b", "a"])

        @test levels!(x, ["e", "a", "b"]) === x
        @test levels(x) == ["e", "a", "b"]
        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[2]
        @test levels(x) == ["e", "a", "b"]

        x[1] = "c"
        @test x[1] === x.pool.valindex[4]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[2]
        @test levels(x) == ["e", "a", "b", "c"]

        push!(x, "a")
        @test length(x) == 4
        @test x[end] == "a"
        @test levels(x) == ["e", "a", "b", "c"]

        push!(x, "zz")
        @test length(x) == 5
        @test x[end] == "zz"
        @test levels(x) == ["e", "a", "b", "c", "zz"]

        push!(x, x[1])
        @test length(x) == 6
        @test x[1] == x[end]
        @test levels(x) == ["e", "a", "b", "c", "zz"]

        append!(x, x)
        @test length(x) == 12
        @test x == ["c", "b", "b", "a", "zz", "c", "c", "b", "b", "a", "zz", "c"]
        @test isordered(x) === false
        @test levels(x) == ["e", "a", "b", "c", "zz"]

        b = ["z","y","x"]
        y = CategoricalVector{String, R}(b)
        append!(x, y)
        @test length(x) == 15
        @test x == ["c", "b", "b", "a", "zz", "c", "c", "b", "b", "a", "zz", "c", "z", "y", "x"]
        @test levels(x) == ["e", "a", "b", "c", "zz", "x", "y", "z"]

        empty!(x)
        @test length(x) == 0
        @test levels(x) == ["e", "a", "b", "c", "zz", "x", "y", "z"]

        # Vector created from range (i.e. non-Array AbstractArray),
        # direct conversion to a vector with different eltype
        a = 0.0:0.5:1.5
        x = CategoricalVector{Float64, R}(a, ordered=ordered)

        @test x == collect(a)
        @test isordered(x) === ordered
        @test levels(x) == unique(a)
        @test size(x) === (4,)
        @test length(x) === 4

        @test convert(CategoricalArray, x) === x
        @test convert(CategoricalArray{Float64}, x) === x
        @test convert(CategoricalArray{Float64, 1}, x) === x
        @test convert(CategoricalArray{Float64, 1, R}, x) === x
        @test convert(CategoricalArray{Float64, 1, DefaultRefType}, x) == x
        @test convert(CategoricalArray{Float64, 1, UInt8}, x) == x

        @test convert(CategoricalVector, x) === x
        @test convert(CategoricalVector{Float64}, x) === x
        @test convert(CategoricalVector{Float64, R}, x) === x
        @test convert(CategoricalVector{Float64, DefaultRefType}, x) == x
        @test convert(CategoricalVector{Float64, UInt8}, x) == x

        for y in (CategoricalArray(x, ordered=ordered),
                  CategoricalArray{Float64}(x, ordered=ordered),
                  CategoricalArray{Float64, 1}(x, ordered=ordered),
                  CategoricalArray{Float64, 1, R}(x, ordered=ordered),
                  CategoricalArray{Float64, 1, DefaultRefType}(x, ordered=ordered),
                  CategoricalArray{Float64, 1, UInt8}(x, ordered=ordered),
                  CategoricalVector(x, ordered=ordered),
                  CategoricalVector{Float64}(x, ordered=ordered),
                  CategoricalVector{Float64, R}(x, ordered=ordered),
                  CategoricalVector{Float64, DefaultRefType}(x, ordered=ordered),
                  CategoricalVector{Float64, UInt8}(x, ordered=ordered),
                  categorical(x, ordered=ordered),
                  categorical(x, false, ordered=ordered),
                  categorical(x, true, ordered=ordered))
            @test isa(y, CategoricalVector{Float64})
            @test isordered(y) === ordered
            @test y == x
            @test y !== x
            @test y.refs !== x.refs
            @test y.pool !== x.pool
        end

        @test convert(CategoricalArray, a) == x
        @test convert(CategoricalArray{Float64}, a) == x
        @test convert(CategoricalArray{Float32}, a) == x
        @test convert(CategoricalArray{Float64, 1}, a) == x
        @test convert(CategoricalArray{Float32, 1}, a) == x
        @test convert(CategoricalArray{Float64, 1, R}, a) == x
        @test convert(CategoricalArray{Float32, 1, R}, a) == x
        @test convert(CategoricalArray{Float64, 1, DefaultRefType}, a) == x
        @test convert(CategoricalArray{Float32, 1, DefaultRefType}, a) == x
        @test convert(CategoricalArray{Float64, 1, UInt8}, a) == x
        @test convert(CategoricalArray{Float32, 1, UInt8}, a) == x

        @test convert(CategoricalVector, a) == x
        @test convert(CategoricalVector{Float64}, a) == x
        @test convert(CategoricalVector{Float32}, a) == x
        @test convert(CategoricalVector{Float64, R}, a) == x
        @test convert(CategoricalVector{Float32, R}, a) == x
        @test convert(CategoricalVector{Float64, DefaultRefType}, a) == x
        @test convert(CategoricalVector{Float32, DefaultRefType}, a) == x
        @test convert(CategoricalVector{Float64, UInt8}, a) == x
        @test convert(CategoricalVector{Float32, UInt8}, a) == x

        @test CategoricalArray{Float64}(a, ordered=ordered) == x
        @test CategoricalArray{Float32}(a, ordered=ordered) == x
        @test CategoricalArray{Float64, 1}(a, ordered=ordered) == x
        @test CategoricalArray{Float32, 1}(a, ordered=ordered) == x
        @test CategoricalArray{Float64, 1, R}(a, ordered=ordered) == x
        @test CategoricalArray{Float32, 1, R}(a, ordered=ordered) == x
        @test CategoricalArray{Float64, 1, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalArray{Float32, 1, DefaultRefType}(a, ordered=ordered) == x

        @test CategoricalVector(a, ordered=ordered) == x
        @test CategoricalVector{Float64}(a, ordered=ordered) == x
        @test CategoricalVector{Float32}(a, ordered=ordered) == x
        @test CategoricalVector{Float64, R}(a, ordered=ordered) == x
        @test CategoricalVector{Float32, R}(a, ordered=ordered) == x
        @test CategoricalVector{Float64, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalVector{Float32, DefaultRefType}(a, ordered=ordered) == x

        for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                  (a, DefaultRefType, DefaultRefType, false),
                                  (x, R, UInt8, true),
                                  (x, R, R, false))
            x2 = categorical(y, ordered=ordered)
            @test x2 == x
            @test isa(x2, CategoricalVector{Float64, R1})
            @test isordered(x2) === ordered

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 == x
            @test isa(x2, CategoricalVector{Float64, R2})
            @test isordered(x2) === ordered
        end

        x2 = copy(x)
        @test x2 == x
        @test typeof(x2) === typeof(x)
        @test isordered(x2) === isordered(x)
        @test levels(x2) == levels(x)

        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[3]
        @test x[4] === x.pool.valindex[4]
        @test_throws BoundsError x[5]

        x2 = x[:]
        @test typeof(x2) === typeof(x)
        @test x2 == x
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:2]
        @test typeof(x2) === typeof(x)
        @test x2 == [0.0, 0.5]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:1]
        @test typeof(x2) === typeof(x)
        @test x2 == [0.0]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[2:1]
        @test typeof(x2) === typeof(x)
        @test isempty(x2)
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

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

        push!(x, 2.0)
        @test length(x) == 5
        @test x[end] == 2.0
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        push!(x, x[1])
        @test length(x) == 6
        @test x[1] == x[end]
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        append!(x, x)
        @test length(x) == 12
        @test x == [-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0]
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        b = [2.5, 3.0, -3.5]
        y = CategoricalVector{Float64, R}(b, ordered=ordered)
        append!(x, y)
        @test length(x) == 15
        @test x == [-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0, 2.5, 3.0, -3.5]
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        empty!(x)
        @test length(x) == 0
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        # Matrix
        a = ["a" "b" "c"; "b" "a" "c"]
        x = CategoricalMatrix{String, R}(a, ordered=ordered)

        @test x == a
        @test isordered(x) === ordered
        @test levels(x) == unique(a)
        @test size(x) === (2, 3)
        @test length(x) === 6

        @test convert(CategoricalArray, x) === x
        @test convert(CategoricalArray{String}, x) === x
        @test convert(CategoricalArray{String, 2}, x) === x
        @test convert(CategoricalArray{String, 2, R}, x) === x
        @test convert(CategoricalArray{String, 2, DefaultRefType}, x) == x
        @test convert(CategoricalArray{String, 2, UInt8}, x) == x

        @test convert(CategoricalMatrix, x) === x
        @test convert(CategoricalMatrix{String}, x) === x
        @test convert(CategoricalMatrix{String, R}, x) === x
        @test convert(CategoricalMatrix{String, DefaultRefType}, x) == x
        @test convert(CategoricalMatrix{String, UInt8}, x) == x

        for y in (CategoricalArray(x, ordered=ordered),
                  CategoricalArray{String}(x, ordered=ordered),
                  CategoricalArray{String, 2}(x, ordered=ordered),
                  CategoricalArray{String, 2, R}(x, ordered=ordered),
                  CategoricalArray{String, 2, DefaultRefType}(x, ordered=ordered),
                  CategoricalArray{String, 2, UInt8}(x, ordered=ordered),
                  CategoricalMatrix(x, ordered=ordered),
                  CategoricalMatrix{String}(x, ordered=ordered),
                  CategoricalMatrix{String, R}(x, ordered=ordered),
                  CategoricalMatrix{String, DefaultRefType}(x, ordered=ordered),
                  CategoricalMatrix{String, UInt8}(x, ordered=ordered),
                  categorical(x, ordered=ordered),
                  categorical(x, false, ordered=ordered),
                  categorical(x, true, ordered=ordered))
            @test isa(y, CategoricalMatrix{String})
            @test isordered(y) === ordered
            @test y == x
            @test y !== x
            @test y.refs !== x.refs
            @test y.pool !== x.pool
        end

        @test convert(CategoricalArray, a) == x
        @test convert(CategoricalArray{String}, a) == x
        @test convert(CategoricalArray{String, 2, R}, a) == x
        @test convert(CategoricalArray{String, 2, DefaultRefType}, a) == x
        @test convert(CategoricalArray{String, 2, UInt8}, a) == x

        @test convert(CategoricalMatrix, a) == x
        @test convert(CategoricalMatrix{String}, a) == x
        @test convert(CategoricalMatrix{String, R}, a) == x
        @test convert(CategoricalMatrix{String, DefaultRefType}, a) == x
        @test convert(CategoricalMatrix{String, UInt8}, a) == x

        @test CategoricalArray{String}(a, ordered=ordered) == x
        @test CategoricalArray{String, 2}(a, ordered=ordered) == x
        @test CategoricalArray{String, 2}(a, ordered=ordered) == x
        @test CategoricalArray{String, 2, R}(a, ordered=ordered) == x
        @test CategoricalArray{String, 2, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalArray{String, 2, UInt8}(a, ordered=ordered) == x

        @test CategoricalMatrix(a, ordered=ordered) == x
        @test CategoricalMatrix{String}(a, ordered=ordered) == x
        @test CategoricalMatrix{String, R}(a, ordered=ordered) == x
        @test CategoricalMatrix{String, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalMatrix{String, UInt8}(a, ordered=ordered) == x

        for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                  (a, DefaultRefType, DefaultRefType, false),
                                  (x, R, UInt8, true),
                                  (x, R, R, false))
            x2 = categorical(y, ordered=ordered)
            @test x2 == x
            @test isa(x2, CategoricalMatrix{String, R1})
            @test isordered(x2) === ordered

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 == x
            @test isa(x2, CategoricalMatrix{String, R2})
            @test isordered(x2) === ordered
        end

        x2 = compress(x)
        @test x2 == x
        @test isa(x2, CategoricalMatrix{String, UInt8})
        @test isordered(x2) === isordered(x)
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 == x
        @test typeof(x2) === typeof(x)
        @test isordered(x2) === isordered(x)
        @test levels(x2) == levels(x)

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

        x2 = x[1:2,:]
        @test typeof(x2) === typeof(x)
        @test x2 == x
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[:,[1, 3]]
        @test typeof(x2) === typeof(x)
        @test x2 == ["a" "c"; "b" "c"]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:1,2]
        @test isa(x2, CategoricalVector{String, R})
        @test x2 == ["b"]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:0,:]
        @test typeof(x2) === typeof(x)
        @test size(x2) == (0,3)
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        @test_throws BoundsError x[1:4, :]
        @test_throws BoundsError x[1:1, -1:1]
        @test_throws BoundsError x[4, :]

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

        x[1,2] = "b"
        @test x[1] === x.pool.valindex[4]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[2]
        @test x[4] === x.pool.valindex[1]
        @test x[5] === x.pool.valindex[1]
        @test x[6] === x.pool.valindex[3]
        @test levels(x) == ["a", "b", "c", "z"]


        # Uninitialized array
        v = Any[CategoricalArray(2, ordered=ordered),
                CategoricalArray{String}(2, ordered=ordered),
                CategoricalArray{String, 1}(2, ordered=ordered),
                CategoricalArray{String, 1, R}(2, ordered=ordered),
                CategoricalVector(2, ordered=ordered),
                CategoricalVector{String}(2, ordered=ordered),
                CategoricalVector{String, R}(2, ordered=ordered),
                CategoricalArray(2, 3, ordered=ordered),
                CategoricalArray{String}(2, 3, ordered=ordered),
                CategoricalArray{String, 2}(2, 3, ordered=ordered),
                CategoricalArray{String, 2, R}(2, 3, ordered=ordered),
                CategoricalMatrix(2, 3, ordered=ordered),
                CategoricalMatrix{String}(2, 3, ordered=ordered),
                CategoricalMatrix{String, R}(2, 3, ordered=ordered)]

        for x in v
            @test !isassigned(x, 1) && isdefined(x, 1)
            @test !isassigned(x, 2) && isdefined(x, 2)
            @test_throws UndefRefError x[1]
            @test_throws UndefRefError x[2]
            @test isordered(x) === ordered
            @test levels(x) == []

            x2 = compress(x)
            @test isa(x2, CategoricalArray{String, ndims(x), UInt8})
            @test !isassigned(x2, 1) && isdefined(x2, 1)
            @test !isassigned(x2, 2) && isdefined(x2, 2)
            @test_throws UndefRefError x2[1]
            @test_throws UndefRefError x2[2]
            @test levels(x2) == []

            x[1] = "c"
            @test x[1] === x.pool.valindex[1]
            @test !isassigned(x, 2) && isdefined(x, 2)
            @test_throws UndefRefError x[2]
            @test levels(x) == ["c"]

            x[1] = "a"
            @test x[1] === x.pool.valindex[2]
            @test !isassigned(x, 2) && isdefined(x, 2)
            @test_throws UndefRefError x[2]
            @test isordered(x) === ordered
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

# Test unique() and levels()

x = CategoricalArray(["Old", "Young", "Middle", "Young"])
@test levels!(x, ["Young", "Middle", "Old"]) === x
@test levels(x) == ["Young", "Middle", "Old"]
@test unique(x) == levels(x) == ["Young", "Middle", "Old"]
@test levels!(x, ["Young", "Middle", "Old", "Unused"]) === x
@test levels(x) == ["Young", "Middle", "Old", "Unused"]
@test unique(x) == ["Young", "Middle", "Old"]
@test levels!(x, ["Unused1", "Young", "Middle", "Old", "Unused2"]) === x
@test levels(x) == ["Unused1", "Young", "Middle", "Old", "Unused2"]
@test unique(x) == ["Young", "Middle", "Old"]

x = CategoricalArray(String[])
@test isa(levels(x), Vector{String}) && isempty(levels(x))
@test isa(unique(x), Vector{String}) && isempty(unique(x))
@test levels!(x, ["Young", "Middle", "Old"]) === x
@test levels(x) == ["Young", "Middle", "Old"]
@test isa(unique(x), Vector{String}) && isempty(unique(x))

# To test short-circuit after 1000 elements
x = CategoricalArray(repeat(1:1500, inner=10))
@test levels(x) == collect(1:1500)
@test unique(x) == collect(1:1500)
@test levels!(x, [1600:-1:1; 2000]) === x
@test levels(x) == [1600:-1:1; 2000]
@test unique(x) == collect(1500:-1:1)

end
