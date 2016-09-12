module TestNullableArray

using Base.Test
using CategoricalArrays
using NullableArrays
using CategoricalArrays: DefaultRefType
using Compat

typealias String Compat.ASCIIString

# == currently throws an error for Nullables
(==) = isequal

for isordered in (false, true)
    for R in (CategoricalArrays.DefaultRefType, UInt8, UInt, Int8, Int)
        # Vector with no null values
        for a in (["b", "a", "b"],
                  Nullable{String}["b", "a", "b"],
                  NullableArray(["b", "a", "b"]))
            x = NullableCategoricalVector{String, R}(a, ordered=isordered)
            na = eltype(a) <: Nullable ? a : convert(Array{Nullable{String}}, a)

            @test x == na
            @test ordered(x) === isordered
            @test levels(x) == sort(map(get, unique(na)))
            @test size(x) === (3,)
            @test length(x) === 3

            @test convert(NullableCategoricalArray, x) === x
            @test convert(NullableCategoricalArray{String}, x) === x
            @test convert(NullableCategoricalArray{String, 1}, x) === x
            @test convert(NullableCategoricalArray{String, 1, R}, x) === x
            @test convert(NullableCategoricalArray{String, 1, DefaultRefType}, x) == x
            @test convert(NullableCategoricalArray{String, 1, UInt8}, x) == x

            @test convert(NullableCategoricalVector, x) === x
            @test convert(NullableCategoricalVector{String}, x) === x
            @test convert(NullableCategoricalVector{String, R}, x) === x
            @test convert(NullableCategoricalVector{String, DefaultRefType}, x) == x
            @test convert(NullableCategoricalVector{String, UInt8}, x) == x

            for y in (NullableCategoricalArray(x, ordered=isordered),
                      NullableCategoricalArray{String}(x, ordered=isordered),
                      NullableCategoricalArray{String, 1}(x, ordered=isordered),
                      NullableCategoricalArray{String, 1, R}(x, ordered=isordered),
                      NullableCategoricalArray{String, 1, DefaultRefType}(x, ordered=isordered),
                      NullableCategoricalArray{String, 1, UInt8}(x, ordered=isordered),
                      NullableCategoricalVector(x, ordered=isordered),
                      NullableCategoricalVector{String}(x, ordered=isordered),
                      NullableCategoricalVector{String, R}(x, ordered=isordered),
                      NullableCategoricalVector{String, DefaultRefType}(x, ordered=isordered),
                      NullableCategoricalVector{String, UInt8}(x, ordered=isordered))
                @test y == x
                @test y !== x
                @test y.refs !== x.refs
                @test y.pool !== x.pool
            end

            @test convert(NullableCategoricalArray, a) == x
            @test convert(NullableCategoricalArray{String}, a) == x
            @test convert(NullableCategoricalArray{String, 1}, a) == x
            @test convert(NullableCategoricalArray{String, 1, R}, a) == x
            @test convert(NullableCategoricalArray{String, 1, DefaultRefType}, a) == x
            @test convert(NullableCategoricalArray{String, 1, UInt8}, a) == x

            @test convert(NullableCategoricalVector, a) == x
            @test convert(NullableCategoricalVector{String}, a) == x
            @test convert(NullableCategoricalVector{String, R}, a) == x
            @test convert(NullableCategoricalVector{String, DefaultRefType}, a) == x
            @test convert(NullableCategoricalVector{String, UInt8}, a) == x

            @test NullableCategoricalArray{String}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 1}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 1, R}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 1, DefaultRefType}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 1, UInt8}(a, ordered=isordered) == x

            @test NullableCategoricalVector(a, ordered=isordered) == x
            @test NullableCategoricalVector{String}(a, ordered=isordered) == x
            @test NullableCategoricalVector{String, R}(a, ordered=isordered) == x
            @test NullableCategoricalVector{String, DefaultRefType}(a, ordered=isordered) == x
            @test NullableCategoricalVector{String, UInt8}(a, ordered=isordered) == x

            x2 = compact(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalVector{String, UInt8})
            @test ordered(x2) === ordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test ordered(x2) === ordered(x)
            @test typeof(x2) === typeof(x)
            @test levels(x2) == levels(x)

            if !ordered(x)
                @test ordered!(x, true) === true
            end
            @test get(x[1] > x[2])
            @test get(x[3] > x[2])

            @test ordered!(x, false) === false
            @test ordered(x) === false
            @test_throws Exception x[1] > x[2]
            @test_throws Exception x[3] > x[2]

            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test_throws BoundsError x[4]

            @test x[1:2] == Nullable{String}["b", "a"]
            @test typeof(x[1:2]) === typeof(x)

            x[1] = x[2]
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[1])

            x[3] = "c"
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c"]

            x[2:3] = "b"
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[1])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test levels(x) == ["a", "b", "c"]

            droplevels!(x) == ["a", "b"]
            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[2])
            @test levels(x) == ["a", "b"]

            levels!(x, ["b", "a"]) == ["b", "a"]
            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[2])
            @test levels(x) == ["b", "a"]

            @test_throws ArgumentError levels!(x, ["a"])
            @test_throws ArgumentError levels!(x, ["e", "b"])
            @test_throws ArgumentError levels!(x, ["e", "a", "b", "a"])

            @test levels!(x, ["e", "a", "b"]) == ["e", "a", "b"]
            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[2])
            @test levels(x) == ["e", "a", "b"]

            x[1] = "c"
            @test x[1] === Nullable(x.pool.valindex[4])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[2])
            @test levels(x) == ["e", "a", "b", "c"]

            @test_throws ArgumentError levels!(x, ["e", "c"])
            @test levels!(x, ["e", "c"], nullok=true) == ["e", "c"]
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === eltype(x)()
            @test x[3] === eltype(x)()
            @test levels(x) == ["e", "c"]

            push!(x, "e")
            @test length(x) == 4
            @test isequal(x, NullableArray(["c", "", "", "e"], [false, true, true, false]))
            @test levels(x) == ["e", "c"]

            push!(x, "zz")
            @test length(x) == 5
            @test isequal(x, NullableArray(["c", "", "", "e", "zz"], [false, true, true, false, false]))
            @test levels(x) == ["e", "c", "zz"]

            push!(x, x[1])
            @test length(x) == 6
            @test isequal(x, NullableArray(["c", "", "", "e", "zz", "c"], [false, true, true, false, false, false]))
            @test levels(x) == ["e", "c", "zz"]

            push!(x, eltype(x)())
            @test length(x) == 7
            @test isequal(x, NullableArray(["c", "", "", "e", "zz", "c", ""], [false, true, true, false, false, false, true]))
            @test isnull(x[end])
            @test levels(x) == ["e", "c", "zz"]

            append!(x, x)
            @test isequal(x, NullableArray(["c", "", "", "e", "zz", "c", "", "c", "", "", "e", "zz", "c", ""], [false, true, true, false, false, false, true, false, true, true, false, false, false, true]))
            @test levels(x) == ["e", "c", "zz"]
            @test ordered(x) === false
            @test length(x) == 14

            b = ["z","y","x"]
            y = NullableCategoricalVector{String, R}(b)
            append!(x, y)
            @test length(x) == 17
            @test ordered(x) === false
            @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
            @test isequal(x, NullableArray(["c", "", "", "e", "zz", "c", "", "c", "", "", "e", "zz", "c", "", "z", "y", "x"], [false, true, true, false, false, false, true, false, true, true, false, false, false, true, false, false, false]))

            empty!(x)
            @test ordered(x) === false
            @test length(x) == 0
            @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
        end


        # Vector with null values
        for a in (Nullable{String}["a", "b", Nullable()],
                  NullableArray(Nullable{String}["a", "b", Nullable()]))
            x = NullableCategoricalVector{String, R}(a, ordered=isordered)

            @test x == a
            @test levels(x) == map(get, filter(x->!isnull(x), unique(a)))
            @test size(x) === (3,)
            @test length(x) === 3

            @test convert(NullableCategoricalArray, x) === x
            @test convert(NullableCategoricalArray{String}, x) === x
            @test convert(NullableCategoricalArray{String, 1}, x) === x
            @test convert(NullableCategoricalArray{String, 1, R}, x) === x
            @test convert(NullableCategoricalArray{String, 1, DefaultRefType}, x) == x
            @test convert(NullableCategoricalArray{String, 1, UInt8}, x) == x

            @test convert(NullableCategoricalVector, x) === x
            @test convert(NullableCategoricalVector{String}, x) === x
            @test convert(NullableCategoricalVector{String, R}, x) === x
            @test convert(NullableCategoricalVector{String, DefaultRefType}, x) == x
            @test convert(NullableCategoricalVector{String, UInt8}, x) == x

            for y in (NullableCategoricalArray(x, ordered=isordered),
                      NullableCategoricalArray{String}(x, ordered=isordered),
                      NullableCategoricalArray{String, 1}(x, ordered=isordered),
                      NullableCategoricalArray{String, 1, R}(x, ordered=isordered),
                      NullableCategoricalArray{String, 1, DefaultRefType}(x, ordered=isordered),
                      NullableCategoricalArray{String, 1, UInt8}(x, ordered=isordered),
                      NullableCategoricalVector(x, ordered=isordered),
                      NullableCategoricalVector{String}(x, ordered=isordered),
                      NullableCategoricalVector{String, R}(x, ordered=isordered),
                      NullableCategoricalVector{String, DefaultRefType}(x, ordered=isordered),
                      NullableCategoricalVector{String, UInt8}(x, ordered=isordered))
                @test y == x
                @test y !== x
                @test y.refs !== x.refs
                @test y.pool !== x.pool
            end

            @test convert(NullableCategoricalArray, a) == x
            @test convert(NullableCategoricalArray{String}, a) == x
            @test convert(NullableCategoricalArray{String, 1}, a) == x
            @test convert(NullableCategoricalArray{String, 1, R}, a) == x
            @test convert(NullableCategoricalArray{String, 1, DefaultRefType}, a) == x
            @test convert(NullableCategoricalArray{String, 1, UInt8}, a) == x

            @test convert(NullableCategoricalVector, a) == x
            @test convert(NullableCategoricalVector{String}, a) == x
            @test convert(NullableCategoricalVector{String, R}, a) == x
            @test convert(NullableCategoricalVector{String, DefaultRefType}, a) == x
            @test convert(NullableCategoricalVector{String, UInt8}, a) == x

            @test NullableCategoricalArray{String}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 1}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 1, R}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 1, DefaultRefType}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 1, UInt8}(a, ordered=isordered) == x

            @test NullableCategoricalVector(a, ordered=isordered) == x
            @test NullableCategoricalVector{String}(a, ordered=isordered) == x
            @test NullableCategoricalVector{String, R}(a, ordered=isordered) == x
            @test NullableCategoricalVector{String, DefaultRefType}(a, ordered=isordered) == x
            @test NullableCategoricalVector{String, UInt8}(a, ordered=isordered) == x

            x2 = compact(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalVector{String, UInt8})
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test levels(x2) == levels(x)

            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test_throws BoundsError x[4]

            @test x[1:2] == Nullable{String}["a", "b"]
            @test typeof(x[1:2]) === typeof(x)

            @test x[2:3] == Nullable{String}["b", Nullable()]
            @test typeof(x[2:3]) === typeof(x)

            x[1] = "b"
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === eltype(x)()

            x[3] = "c"
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c"]

            x[1] = Nullable()
            @test x[1] === eltype(x)()
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c"]

            x[2:3] = Nullable()
            @test x[1] === eltype(x)()
            @test x[2] === eltype(x)()
            @test x[3] === eltype(x)()
            @test levels(x) == ["a", "b", "c"]
        end


        # Vector created from range (i.e. non-Array AbstractArray),
        # direct conversion to a vector with different eltype
        a = 0.0:0.5:1.5
        x = NullableCategoricalVector{Float64, R}(a, ordered=isordered)

        @test x == map(Nullable, a)
        @test ordered(x) === isordered
        @test levels(x) == unique(a)
        @test size(x) === (4,)
        @test length(x) === 4

        @test convert(NullableCategoricalArray, x) === x
        @test convert(NullableCategoricalArray{Float64}, x) === x
        @test convert(NullableCategoricalArray{Float64, 1}, x) === x
        @test convert(NullableCategoricalArray{Float64, 1, R}, x) === x
        @test convert(NullableCategoricalArray{Float64, 1, DefaultRefType}, x) == x
        @test convert(NullableCategoricalArray{Float64, 1, UInt8}, x) == x

        @test convert(NullableCategoricalVector, x) === x
        @test convert(NullableCategoricalVector{Float64}, x) === x
        @test convert(NullableCategoricalVector{Float64, R}, x) === x
        @test convert(NullableCategoricalVector{Float64, DefaultRefType}, x) == x
        @test convert(NullableCategoricalVector{Float64, UInt8}, x) == x

        for y in (NullableCategoricalArray(x, ordered=isordered),
                  NullableCategoricalArray{Float64}(x, ordered=isordered),
                  NullableCategoricalArray{Float64, 1}(x, ordered=isordered),
                  NullableCategoricalArray{Float64, 1, R}(x, ordered=isordered),
                  NullableCategoricalArray{Float64, 1, DefaultRefType}(x, ordered=isordered),
                  NullableCategoricalArray{Float64, 1, UInt8}(x, ordered=isordered),
                  NullableCategoricalVector(x, ordered=isordered),
                  NullableCategoricalVector{Float64}(x, ordered=isordered),
                  NullableCategoricalVector{Float64, R}(x, ordered=isordered),
                  NullableCategoricalVector{Float64, DefaultRefType}(x, ordered=isordered),
                  NullableCategoricalVector{Float64, UInt8}(x, ordered=isordered))
            @test y == x
            @test y !== x
            @test y.refs !== x.refs
            @test y.pool !== x.pool
        end

        @test convert(NullableCategoricalArray, a) == x
        @test convert(NullableCategoricalArray{Float64}, a) == x
        @test convert(NullableCategoricalArray{Float32}, a) == x
        @test convert(NullableCategoricalArray{Float64, 1}, a) == x
        @test convert(NullableCategoricalArray{Float32, 1}, a) == x
        @test convert(NullableCategoricalArray{Float64, 1, R}, a) == x
        @test convert(NullableCategoricalArray{Float32, 1, R}, a) == x
        @test convert(NullableCategoricalArray{Float64, 1, DefaultRefType}, a) == x
        @test convert(NullableCategoricalArray{Float32, 1, DefaultRefType}, a) == x
        @test convert(NullableCategoricalArray{Float64, 1, UInt8}, a) == x
        @test convert(NullableCategoricalArray{Float32, 1, UInt8}, a) == x

        @test convert(NullableCategoricalVector, a) == x
        @test convert(NullableCategoricalVector{Float64}, a) == x
        @test convert(NullableCategoricalVector{Float32}, a) == x
        @test convert(NullableCategoricalVector{Float64, R}, a) == x
        @test convert(NullableCategoricalVector{Float32, R}, a) == x
        @test convert(NullableCategoricalVector{Float64, DefaultRefType}, a) == x
        @test convert(NullableCategoricalVector{Float32, DefaultRefType}, a) == x
        @test convert(NullableCategoricalVector{Float64, UInt8}, a) == x
        @test convert(NullableCategoricalVector{Float32, UInt8}, a) == x

        @test NullableCategoricalArray{Float64}(a, ordered=isordered) == x
        @test NullableCategoricalArray{Float32}(a, ordered=isordered) == x
        @test NullableCategoricalArray{Float64, 1}(a, ordered=isordered) == x
        @test NullableCategoricalArray{Float32, 1}(a, ordered=isordered) == x
        @test NullableCategoricalArray{Float64, 1, R}(a, ordered=isordered) == x
        @test NullableCategoricalArray{Float32, 1, R}(a, ordered=isordered) == x
        @test NullableCategoricalArray{Float64, 1, DefaultRefType}(a, ordered=isordered) == x
        @test NullableCategoricalArray{Float32, 1, DefaultRefType}(a, ordered=isordered) == x

        @test NullableCategoricalVector(a, ordered=isordered) == x
        @test NullableCategoricalVector{Float64}(a, ordered=isordered) == x
        @test NullableCategoricalVector{Float32}(a, ordered=isordered) == x
        @test NullableCategoricalVector{Float64, R}(a, ordered=isordered) == x
        @test NullableCategoricalVector{Float32, R}(a, ordered=isordered) == x
        @test NullableCategoricalVector{Float64, DefaultRefType}(a, ordered=isordered) == x
        @test NullableCategoricalVector{Float32, DefaultRefType}(a, ordered=isordered) == x

        x2 = compact(x)
        @test x2 == x
        @test ordered(x2) === ordered(x)
        @test isa(x2, NullableCategoricalVector{Float64, UInt8})
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 == x
        @test ordered(x2) === ordered(x)
        @test typeof(x2) === typeof(x)
        @test levels(x2) == levels(x)

        @test x[1] === Nullable(x.pool.valindex[1])
        @test x[2] === Nullable(x.pool.valindex[2])
        @test x[3] === Nullable(x.pool.valindex[3])
        @test x[4] === Nullable(x.pool.valindex[4])
        @test_throws BoundsError x[5]

        @test x[1:2] == Nullable{Float64}[0.0, 0.5]
        @test typeof(x[1:2]) === typeof(x)

        x[2] = 1
        @test x[1] === Nullable(x.pool.valindex[1])
        @test x[2] === Nullable(x.pool.valindex[3])
        @test x[3] === Nullable(x.pool.valindex[3])
        @test x[4] === Nullable(x.pool.valindex[4])
        @test levels(x) == unique(a)

        x[1:2] = -1
        @test x[1] === Nullable(x.pool.valindex[5])
        @test x[2] === Nullable(x.pool.valindex[5])
        @test x[3] === Nullable(x.pool.valindex[3])
        @test x[4] === Nullable(x.pool.valindex[4])
        @test levels(x) == vcat(unique(a), -1)

        push!(x, 2.0)
        @test length(x) == 5
        @test isequal(x, NullableArray([-1.0, -1.0, 1.0, 1.5, 2.0]))
        @test ordered(x) === isordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        push!(x, x[1])
        @test length(x) == 6
        @test isequal(x, NullableArray([-1.0, -1.0, 1.0, 1.5, 2.0, -1.0]))
        @test ordered(x) === isordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        append!(x, x)
        @test length(x) == 12
        @test isequal(x, NullableArray([-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0]))
        @test ordered(x) === isordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        b = [2.5, 3.0, -3.5]
        y = NullableCategoricalVector{Float64, R}(b)
        append!(x, y)
        @test length(x) == 15
        @test isequal(x, NullableArray([-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0, 2.5, 3.0, -3.5]))
        @test ordered(x) === isordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        empty!(x)
        @test length(x) == 0
        @test ordered(x) === isordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        # Matrix with no null values
        for a in (["a" "b" "c"; "b" "a" "c"],
                  Nullable{String}["a" "b" "c"; "b" "a" "c"],
                  NullableArray(["a" "b" "c"; "b" "a" "c"]))
            na = eltype(a) <: Nullable ? a : convert(Array{Nullable{String}}, a)
            x = NullableCategoricalMatrix{String, R}(a, ordered=isordered)

            @test x == na
            @test ordered(x) === isordered
            @test levels(x) == map(get, unique(na))
            @test size(x) === (2, 3)
            @test length(x) === 6

            @test convert(NullableCategoricalArray, x) === x
            @test convert(NullableCategoricalArray{String}, x) === x
            @test convert(NullableCategoricalArray{String, 2}, x) === x
            @test convert(NullableCategoricalArray{String, 2, R}, x) === x
            @test convert(NullableCategoricalArray{String, 2, DefaultRefType}, x) == x
            @test convert(NullableCategoricalArray{String, 2, UInt8}, x) == x

            @test convert(NullableCategoricalMatrix, x) === x
            @test convert(NullableCategoricalMatrix{String}, x) === x
            @test convert(NullableCategoricalMatrix{String, R}, x) === x
            @test convert(NullableCategoricalMatrix{String, DefaultRefType}, x) == x
            @test convert(NullableCategoricalMatrix{String, UInt8}, x) == x

            for y in (NullableCategoricalArray(x, ordered=isordered),
                      NullableCategoricalArray{String}(x, ordered=isordered),
                      NullableCategoricalArray{String, 2}(x, ordered=isordered),
                      NullableCategoricalArray{String, 2, R}(x, ordered=isordered),
                      NullableCategoricalArray{String, 2, DefaultRefType}(x, ordered=isordered),
                      NullableCategoricalArray{String, 2, UInt8}(x, ordered=isordered),
                      NullableCategoricalMatrix(x, ordered=isordered),
                      NullableCategoricalMatrix{String}(x, ordered=isordered),
                      NullableCategoricalMatrix{String, R}(x, ordered=isordered),
                      NullableCategoricalMatrix{String, DefaultRefType}(x, ordered=isordered),
                      NullableCategoricalMatrix{String, UInt8}(x, ordered=isordered))
                @test y == x
                @test y !== x
                @test y.refs !== x.refs
                @test y.pool !== x.pool
            end

            @test convert(NullableCategoricalArray, a) == x
            @test convert(NullableCategoricalArray{String}, a) == x
            @test convert(NullableCategoricalArray{String, 2, R}, a) == x
            @test convert(NullableCategoricalArray{String, 2, DefaultRefType}, a) == x
            @test convert(NullableCategoricalArray{String, 2, UInt8}, a) == x

            @test convert(NullableCategoricalMatrix, a) == x
            @test convert(NullableCategoricalMatrix{String}, a) == x
            @test convert(NullableCategoricalMatrix{String, R}, a) == x
            @test convert(NullableCategoricalMatrix{String, DefaultRefType}, a) == x
            @test convert(NullableCategoricalMatrix{String, UInt8}, a) == x

            @test NullableCategoricalArray{String}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2, R}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2, DefaultRefType}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2, UInt8}(a, ordered=isordered) == x

            @test NullableCategoricalMatrix(a, ordered=isordered) == x
            @test NullableCategoricalMatrix{String}(a, ordered=isordered) == x
            @test NullableCategoricalMatrix{String, R}(a, ordered=isordered) == x
            @test NullableCategoricalMatrix{String, DefaultRefType}(a, ordered=isordered) == x
            @test NullableCategoricalMatrix{String, UInt8}(a, ordered=isordered) == x

            x2 = compact(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalMatrix{String, UInt8})
            @test ordered(x2) === ordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test ordered(x2) === ordered(x)
            @test levels(x2) == levels(x)

            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[2])
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[3])
            @test x[6] === Nullable(x.pool.valindex[3])
            @test_throws BoundsError x[7]

            @test x[1,1] === Nullable(x.pool.valindex[1])
            @test x[2,1] === Nullable(x.pool.valindex[2])
            @test x[1,2] === Nullable(x.pool.valindex[2])
            @test x[2,2] === Nullable(x.pool.valindex[1])
            @test x[1,3] === Nullable(x.pool.valindex[3])
            @test x[2,3] === Nullable(x.pool.valindex[3])
            @test_throws BoundsError x[1,4]
            @test_throws BoundsError x[4,1]
            @test_throws BoundsError x[4,4]

            @test x[1:2,:] == x
            @test typeof(x[1:2,:]) === typeof(x)
            @test x[1:2,1] == Nullable{String}["a", "b"]
            @test typeof(x[1:2,1]) === NullableCategoricalVector{String, R}

            x[1] = "z"
            @test x[1] === Nullable(x.pool.valindex[4])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[2])
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[3])
            @test x[6] === Nullable(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,:] = "a"
            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[1])
            @test x[6] === Nullable(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,1:2] = "z"
            @test x[1] === Nullable(x.pool.valindex[4])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[4])
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[1])
            @test x[6] === Nullable(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c", "z"]
        end


        # Matrix with null values
        for a in (Nullable{String}["a" Nullable() "c"; "b" "a" Nullable()],
                  NullableArray(Nullable{String}["a" Nullable() "c"; "b" "a" Nullable()]))
            x = NullableCategoricalMatrix{String, R}(a, ordered=isordered)

            @test x == a
            @test ordered(x) === isordered
            @test levels(x) == map(get, filter(x->!isnull(x), unique(a)))
            @test size(x) === (2, 3)
            @test length(x) === 6

            @test convert(NullableCategoricalArray, x) === x
            @test convert(NullableCategoricalArray{String}, x) === x
            @test convert(NullableCategoricalArray{String, 2}, x) === x
            @test convert(NullableCategoricalArray{String, 2, R}, x) === x
            @test convert(NullableCategoricalArray{String, 2, DefaultRefType}, x) == x
            @test convert(NullableCategoricalArray{String, 2, UInt8}, x) == x

            @test convert(NullableCategoricalMatrix, x) === x
            @test convert(NullableCategoricalMatrix{String}, x) === x
            @test convert(NullableCategoricalMatrix{String, R}, x) === x
            @test convert(NullableCategoricalMatrix{String, DefaultRefType}, x) == x
            @test convert(NullableCategoricalMatrix{String, UInt8}, x) == x

            for y in (NullableCategoricalArray(x, ordered=isordered),
                      NullableCategoricalArray{String}(x, ordered=isordered),
                      NullableCategoricalArray{String, 2}(x, ordered=isordered),
                      NullableCategoricalArray{String, 2, R}(x, ordered=isordered),
                      NullableCategoricalArray{String, 2, DefaultRefType}(x, ordered=isordered),
                      NullableCategoricalArray{String, 2, UInt8}(x, ordered=isordered),
                      NullableCategoricalMatrix(x, ordered=isordered),
                      NullableCategoricalMatrix{String}(x, ordered=isordered),
                      NullableCategoricalMatrix{String, R}(x, ordered=isordered),
                      NullableCategoricalMatrix{String, DefaultRefType}(x, ordered=isordered),
                      NullableCategoricalMatrix{String, UInt8}(x, ordered=isordered))
                @test y == x
                @test y !== x
                @test y.refs !== x.refs
                @test y.pool !== x.pool
            end

            @test convert(NullableCategoricalArray, a) == x
            @test convert(NullableCategoricalArray{String}, a) == x
            @test convert(NullableCategoricalArray{String, 2, R}, a) == x
            @test convert(NullableCategoricalArray{String, 2, DefaultRefType}, a) == x
            @test convert(NullableCategoricalArray{String, 2, UInt8}, a) == x

            @test convert(NullableCategoricalMatrix, a) == x
            @test convert(NullableCategoricalMatrix{String}, a) == x
            @test convert(NullableCategoricalMatrix{String, R}, a) == x
            @test convert(NullableCategoricalMatrix{String, DefaultRefType}, a) == x
            @test convert(NullableCategoricalMatrix{String, UInt8}, a) == x

            @test NullableCategoricalArray{String}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2, R}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2, DefaultRefType}(a, ordered=isordered) == x
            @test NullableCategoricalArray{String, 2, UInt8}(a, ordered=isordered) == x

            @test NullableCategoricalMatrix(a, ordered=isordered) == x
            @test NullableCategoricalMatrix{String}(a, ordered=isordered) == x
            @test NullableCategoricalMatrix{String, R}(a, ordered=isordered) == x
            @test NullableCategoricalMatrix{String, DefaultRefType}(a, ordered=isordered) == x
            @test NullableCategoricalMatrix{String, UInt8}(a, ordered=isordered) == x

            x2 = compact(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalMatrix{String, UInt8})
            @test ordered(x2) === ordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test ordered(x2) === ordered(x)
            @test levels(x2) == levels(x)

            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[3])
            @test x[6] === eltype(x)()
            @test_throws BoundsError x[7]

            @test x[1,1] === Nullable(x.pool.valindex[1])
            @test x[2,1] === Nullable(x.pool.valindex[2])
            @test x[1,2] === eltype(x)()
            @test x[2,2] === Nullable(x.pool.valindex[1])
            @test x[1,3] === Nullable(x.pool.valindex[3])
            @test x[2,3] === eltype(x)()
            @test_throws BoundsError x[1,4]
            @test_throws BoundsError x[4,1]
            @test_throws BoundsError x[4,4]

            @test x[1:2,:] == x
            @test typeof(x[1:2,:]) === typeof(x)
            @test x[1:2,1] == Nullable{String}["a", "b"]
            @test typeof(x[1:2,1]) === NullableCategoricalVector{String, R}

            x[1] = "z"
            @test x[1] === Nullable(x.pool.valindex[4])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[3])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,:] = "a"
            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,1:2] = Nullable("z")
            @test x[1] === Nullable(x.pool.valindex[4])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[4])
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[1] = Nullable()
            @test x[1] === eltype(x)()
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[4])
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,1:2] = Nullable()
            @test x[1] === eltype(x)()
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test x[4] === Nullable(x.pool.valindex[1])
            @test x[5] === Nullable(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[:,2] = Nullable()
            @test x[1] === eltype(x)()
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === eltype(x)()
            @test x[4] === eltype(x)()
            @test x[5] === Nullable(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]


            # Constructor with values plus missingness array
            x = NullableCategoricalArray(1:3, [true, false, true], ordered=isordered)
            @test x == Nullable{Int}[Nullable(), 2, Nullable()]
            @test ordered(x) == isordered
            @test levels(x) == [2]

            if VERSION >= v"0.5.0-dev"
                x = NullableCategoricalVector(1:3, [true, false, true], ordered=isordered)
                @test x == Nullable{Int}[Nullable(), 2, Nullable()]
                @test ordered(x) === isordered
                @test levels(x) == [2]

                x = NullableCategoricalMatrix([1 2; 3 4], [true false; false true],
                                              ordered=isordered)
                @test x == Nullable{Int}[Nullable() 2; 3 Nullable()]
                @test ordered(x) === isordered
                @test levels(x) == [2, 3]
            end
        end


        # Uninitialized array
        v = Any[NullableCategoricalArray(2, ordered=isordered),
                NullableCategoricalArray(String, 2, ordered=isordered),
                NullableCategoricalArray{String}(2, ordered=isordered),
                NullableCategoricalArray{String, 1}(2, ordered=isordered),
                NullableCategoricalArray{String, 1, R}(2, ordered=isordered),
                NullableCategoricalVector{String}(2, ordered=isordered),
                NullableCategoricalVector{String, R}(2, ordered=isordered),
                NullableCategoricalArray(2, 3, ordered=isordered),
                NullableCategoricalArray(String, 2, 3, ordered=isordered),
                NullableCategoricalArray{String}(2, 3, ordered=isordered),
                NullableCategoricalArray{String, 2}(2, 3, ordered=isordered),
                NullableCategoricalArray{String, 2, R}(2, 3, ordered=isordered),
                NullableCategoricalMatrix{String}(2, 3, ordered=isordered),
                NullableCategoricalMatrix{String, R}(2, 3, ordered=isordered)]

        # See conditional definition of constructors in array.jl and nullablearray.jl
        if VERSION >= v"0.5.0-dev"
            push!(v, NullableCategoricalVector(2, ordered=isordered),
                     NullableCategoricalVector(String, 2, ordered=isordered),
                     NullableCategoricalMatrix(2, 3, ordered=isordered),
                     NullableCategoricalMatrix(String, 2, 3, ordered=isordered))
        end

        for x in v
            @test ordered(x) === isordered
            @test isnull(x[1])
            @test isnull(x[2])
            @test levels(x) == []

            x2 = compact(x)
            @test x2 == x
            if VERSION >= v"0.5.0-dev"
                @test isa(x2, NullableCategoricalArray{String, ndims(x), UInt8})
            else
                @test isa(x2, NullableCategoricalArray{typeof(x).parameters[1], ndims(x), UInt8})
            end
            @test ordered(x2) === ordered(x)
            @test levels(x2) == []

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test ordered(x2) === ordered(x)
            @test levels(x2) == []

            x[1] = "c"
            @test x[1] === Nullable(x.pool.valindex[1])
            @test isnull(x[2])
            @test levels(x) == ["c"]

            x[1] = "a"
            @test x[1] === Nullable(x.pool.valindex[2])
            @test isnull(x[2])
            @test levels(x) == ["c", "a"]

            x[2] = Nullable()
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === eltype(x)()
            @test levels(x) == ["c", "a"]

            x[1] = Nullable("b")
            @test x[1] === Nullable(x.pool.valindex[3])
            @test x[2] === eltype(x)()
            @test levels(x) == ["c", "a", "b"]
        end
    end
end

end
