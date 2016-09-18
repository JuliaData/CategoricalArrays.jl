module TestArray

using Base.Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType
using Compat

typealias String Compat.ASCIIString

for isordered in (false, true)
    for R in (CategoricalArrays.DefaultRefType, UInt8, UInt, Int8, Int)
        # Vector
        a = ["b", "a", "b"]
        x = CategoricalVector{String, R}(a, ordered=isordered)

        @test x == a
        @test ordered(x) === isordered
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

        for y in (CategoricalArray(x, ordered=isordered),
                  CategoricalArray{String}(x, ordered=isordered),
                  CategoricalArray{String, 1}(x, ordered=isordered),
                  CategoricalArray{String, 1, R}(x, ordered=isordered),
                  CategoricalArray{String, 1, DefaultRefType}(x, ordered=isordered),
                  CategoricalArray{String, 1, UInt8}(x, ordered=isordered),
                  CategoricalVector(x, ordered=isordered),
                  CategoricalVector{String}(x, ordered=isordered),
                  CategoricalVector{String, R}(x, ordered=isordered),
                  CategoricalVector{String, DefaultRefType}(x, ordered=isordered),
                  CategoricalVector{String, UInt8}(x, ordered=isordered))
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

        @test CategoricalArray{String}(a, ordered=isordered) == x
        @test CategoricalArray{String, 1}(a, ordered=isordered) == x
        @test CategoricalArray{String, 1, R}(a, ordered=isordered) == x
        @test CategoricalArray{String, 1, DefaultRefType}(a, ordered=isordered) == x
        @test CategoricalArray{String, 1, UInt8}(a, ordered=isordered) == x

        @test CategoricalVector(a, ordered=isordered) == x
        @test CategoricalVector{String}(a, ordered=isordered) == x
        @test CategoricalVector{String, R}(a, ordered=isordered) == x
        @test CategoricalVector{String, DefaultRefType}(a, ordered=isordered) == x
        @test CategoricalVector{String, UInt8}(a, ordered=isordered) == x

        x2 = compact(x)
        @test x2 == x
        @test isa(x2, CategoricalVector{String, UInt8})
        @test ordered(x2) === ordered(x)
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 == x
        @test typeof(x2) === typeof(x)
        @test ordered(x2) === ordered(x)
        @test levels(x2) == levels(x)

        if !ordered(x)
            @test ordered!(x, true) === true
        end
        @test x[1] > x[2]
        @test x[3] > x[2]

        @test ordered!(x, false) === false
        @test ordered(x) === false
        @test_throws Exception x[1] > x[2]
        @test_throws Exception x[3] > x[2]

        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[1]
        @test_throws BoundsError x[4]

        @test x[1:2] == ["b", "a"]
        @test typeof(x[1:2]) === typeof(x)

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

        droplevels!(x) == ["a", "b"]
        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[2]
        @test levels(x) == ["a", "b"]

        levels!(x, ["b", "a"]) == ["b", "a"]
        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[2]
        @test levels(x) == ["b", "a"]

        @test_throws ArgumentError levels!(x, ["a"])
        @test_throws ArgumentError levels!(x, ["e", "b"])
        @test_throws ArgumentError levels!(x, ["e", "a", "b", "a"])

        @test levels!(x, ["e", "a", "b"]) == ["e", "a", "b"]
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
        @test ordered(x) === false
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
        x = CategoricalVector{Float64, R}(a, ordered=isordered)

        @test x == collect(a)
        @test ordered(x) === isordered
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

        for y in (CategoricalArray(x, ordered=isordered),
                  CategoricalArray{Float64}(x, ordered=isordered),
                  CategoricalArray{Float64, 1}(x, ordered=isordered),
                  CategoricalArray{Float64, 1, R}(x, ordered=isordered),
                  CategoricalArray{Float64, 1, DefaultRefType}(x, ordered=isordered),
                  CategoricalArray{Float64, 1, UInt8}(x, ordered=isordered),
                  CategoricalVector(x, ordered=isordered),
                  CategoricalVector{Float64}(x, ordered=isordered),
                  CategoricalVector{Float64, R}(x, ordered=isordered),
                  CategoricalVector{Float64, DefaultRefType}(x, ordered=isordered),
                  CategoricalVector{Float64, UInt8}(x, ordered=isordered))
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

        @test CategoricalArray{Float64}(a, ordered=isordered) == x
        @test CategoricalArray{Float32}(a, ordered=isordered) == x
        @test CategoricalArray{Float64, 1}(a, ordered=isordered) == x
        @test CategoricalArray{Float32, 1}(a, ordered=isordered) == x
        @test CategoricalArray{Float64, 1, R}(a, ordered=isordered) == x
        @test CategoricalArray{Float32, 1, R}(a, ordered=isordered) == x
        @test CategoricalArray{Float64, 1, DefaultRefType}(a, ordered=isordered) == x
        @test CategoricalArray{Float32, 1, DefaultRefType}(a, ordered=isordered) == x

        @test CategoricalVector(a, ordered=isordered) == x
        @test CategoricalVector{Float64}(a, ordered=isordered) == x
        @test CategoricalVector{Float32}(a, ordered=isordered) == x
        @test CategoricalVector{Float64, R}(a, ordered=isordered) == x
        @test CategoricalVector{Float32, R}(a, ordered=isordered) == x
        @test CategoricalVector{Float64, DefaultRefType}(a, ordered=isordered) == x
        @test CategoricalVector{Float32, DefaultRefType}(a, ordered=isordered) == x

        x2 = compact(x)
        @test x2 == x
        @test isa(x2, CategoricalVector{Float64, UInt8})
        @test ordered(x2) === ordered(x)
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 == x
        @test typeof(x2) === typeof(x)
        @test ordered(x2) === ordered(x)
        @test levels(x2) == levels(x)

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

        push!(x, 2.0)
        @test length(x) == 5
        @test x[end] == 2.0
        @test ordered(x) === isordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        push!(x, x[1])
        @test length(x) == 6
        @test x[1] == x[end]
        @test ordered(x) === isordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        append!(x, x)
        @test length(x) == 12
        @test x == [-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0]
        @test ordered(x) === isordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        b = [2.5, 3.0, -3.5]
        y = CategoricalVector{Float64, R}(b, ordered=isordered)
        append!(x, y)
        @test length(x) == 15
        @test x == [-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0, 2.5, 3.0, -3.5]
        @test ordered(x) === isordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        empty!(x)
        @test length(x) == 0
        @test ordered(x) === isordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        # Matrix
        a = ["a" "b" "c"; "b" "a" "c"]
        x = CategoricalMatrix{String, R}(a, ordered=isordered)

        @test x == a
        @test ordered(x) === isordered
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

        for y in (CategoricalArray(x, ordered=isordered),
                  CategoricalArray{String}(x, ordered=isordered),
                  CategoricalArray{String, 2}(x, ordered=isordered),
                  CategoricalArray{String, 2, R}(x, ordered=isordered),
                  CategoricalArray{String, 2, DefaultRefType}(x, ordered=isordered),
                  CategoricalArray{String, 2, UInt8}(x, ordered=isordered),
                  CategoricalMatrix(x, ordered=isordered),
                  CategoricalMatrix{String}(x, ordered=isordered),
                  CategoricalMatrix{String, R}(x, ordered=isordered),
                  CategoricalMatrix{String, DefaultRefType}(x, ordered=isordered),
                  CategoricalMatrix{String, UInt8}(x, ordered=isordered))
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

        @test CategoricalArray{String}(a, ordered=isordered) == x
        @test CategoricalArray{String, 2}(a, ordered=isordered) == x
        @test CategoricalArray{String, 2}(a, ordered=isordered) == x
        @test CategoricalArray{String, 2, R}(a, ordered=isordered) == x
        @test CategoricalArray{String, 2, DefaultRefType}(a, ordered=isordered) == x
        @test CategoricalArray{String, 2, UInt8}(a, ordered=isordered) == x

        @test CategoricalMatrix(a, ordered=isordered) == x
        @test CategoricalMatrix{String}(a, ordered=isordered) == x
        @test CategoricalMatrix{String, R}(a, ordered=isordered) == x
        @test CategoricalMatrix{String, DefaultRefType}(a, ordered=isordered) == x
        @test CategoricalMatrix{String, UInt8}(a, ordered=isordered) == x

        x2 = compact(x)
        @test x2 == x
        @test isa(x2, CategoricalMatrix{String, UInt8})
        @test ordered(x2) === ordered(x)
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 == x
        @test typeof(x2) === typeof(x)
        @test ordered(x2) === ordered(x)
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

        @test x[1:2,:] == x
        @test typeof(x[1:2,:]) === typeof(x)
        @test x[1:2,1] == ["a", "b"]
        @test typeof(x[1:2,1]) === CategoricalVector{String, R}

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
        v = Any[CategoricalArray(2, ordered=isordered),
                CategoricalArray(String, 2, ordered=isordered),
                CategoricalArray{String}(2, ordered=isordered),
                CategoricalArray{String, 1}(2, ordered=isordered),
                CategoricalArray{String, 1, R}(2, ordered=isordered),
                CategoricalVector{String}(2, ordered=isordered),
                CategoricalVector{String, R}(2, ordered=isordered),
                CategoricalArray(2, 3, ordered=isordered),
                CategoricalArray(String, 2, 3, ordered=isordered),
                CategoricalArray{String}(2, 3, ordered=isordered),
                CategoricalArray{String, 2}(2, 3, ordered=isordered),
                CategoricalArray{String, 2, R}(2, 3, ordered=isordered),
                CategoricalMatrix{String}(2, 3, ordered=isordered),
                CategoricalMatrix{String, R}(2, 3, ordered=isordered)]

        # See conditional definition of constructors in array.jl
        if VERSION >= v"0.5.0-dev"
            push!(v, CategoricalVector(2, ordered=isordered),
                     CategoricalVector(String, 2, ordered=isordered),
                     CategoricalMatrix(2, 3, ordered=isordered),
                     CategoricalMatrix(String, 2, 3, ordered=isordered))
        end

        for x in v
            @test !isassigned(x, 1) && isdefined(x, 1)
            @test !isassigned(x, 2) && isdefined(x, 2)
            @test_throws UndefRefError x[1]
            @test_throws UndefRefError x[2]
            @test ordered(x) === isordered
            @test levels(x) == []

            x2 = compact(x)
            if VERSION >= v"0.5.0-dev"
                @test isa(x2, CategoricalArray{String, ndims(x), UInt8})
            else
                @test isa(x2, CategoricalArray{typeof(x).parameters[1], ndims(x), UInt8})
            end
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
            @test ordered(x) === isordered
            @test levels(x) == ["c", "a"]

            x[2] = "c"
            @test x[1] === x.pool.valindex[2]
            @test x[2] === x.pool.valindex[1]
            @test levels(x) == ["c", "a"]

            x[1] = "b"
            @test x[1] === x.pool.valindex[3]
            @test x[2] === x.pool.valindex[1]
            @test levels(x) == ["c", "a", "b"]

            a1 = 3:200
            a2 = 300:-1:100
            ca1 = CategoricalArray(a1)
            ca2 = CategoricalArray(a2)
            cca1 = compact(ca1)
            cca2 = compact(ca2)
            r = vcat(cca1, cca2)
            @test r == vcat(a1, a2)
            @test isa(r, CategoricalArray{Int,1,CategoricalArrays.DefaultRefType})
            @test isa(vcat(cca1, ca2), CategoricalArray{Int,1,CategoricalArrays.DefaultRefType})

            a1 = Array{Int}(2,3,4,5)
            a2 = Array{Int}(3,3,4,5)
            a1[1:end] = (length(a1):-1:1) + 2
            a2[1:end] = (1:length(a2)) + 10
            ca1 = CategoricalArray(a1)
            ca2 = CategoricalArray(a2)
            cca1 = compact(ca1)
            cca2 = compact(ca2)
            r = vcat(cca1, cca2)
            @test r == vcat(a1, a2)
            @test isa(r, CategoricalArray{Int,4,CategoricalArrays.DefaultRefType})

            # All levels has to be present in the first argument to vcat to preserve ordering
            a1 = ["Old", "Young", "Young"]
            a2 = ["Old", "Young", "Middle", "Young"]
            ca1 = CategoricalArray(a1, ordered=true)
            ca2 = CategoricalArray(a2)
            levels!(ca1, ["Young", "Middle", "Old"])
            r = vcat(ca1, ca2)
            @test r == vcat(a1, a2)
            @test isa(r, CategoricalArray{ASCIIString,1,CategoricalArrays.DefaultRefType})
            @test levels(r) == ["Young", "Middle", "Old"]
            @test ordered(r) == true

            #=
            # Test concatenation of ambiguous ordering. This prints a warning about
            # mixing ordering and returns a categorical array with ordered=false.
            levels!(ca1, ["Young", "Old"])
            levels!(ca2, ["Old", "Young", "Middle"])
            ordered!(ca1,true)
            ordered!(ca2,true)
            println("Expect warning: Failed to preserve order of levels. Define all levels in the first argument.")
            r = vcat(ca1, ca2)
            @test r == vcat(a1, a2)
            @test ordered(r) == false

            println("Expect warning: Failed to preserve order of levels. The first argument defines the levels and their order.")
            r = vcat(ca2, ca1)
            @test r == vcat(a2, a1)
            @test ordered(r) == false
            =#
        end
    end
end

end
