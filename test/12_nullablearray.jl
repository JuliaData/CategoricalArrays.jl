module TestNullableArray

using Base.Test
using Nulls
using CategoricalArrays
using CategoricalArrays: DefaultRefType
using Compat

for ordered in (false, true)
    for R in (CategoricalArrays.DefaultRefType, UInt8, UInt, Int8, Int)
        # Vector with no null values
        for a in (["b", "a", "b"],
                  Union{String, Null}["b", "a", "b"])
            x = NullableCategoricalVector{String, R}(a, ordered=ordered)

            @test x == a
            @test isordered(x) === ordered
            @test levels(x) == sort(unique(a))
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

            @test NullableCategoricalArray{String}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 1}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 1, R}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 1, DefaultRefType}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 1, UInt8}(a, ordered=ordered) == x

            @test NullableCategoricalVector(a, ordered=ordered) == x
            @test NullableCategoricalVector{String}(a, ordered=ordered) == x
            @test NullableCategoricalVector{String, R}(a, ordered=ordered) == x
            @test NullableCategoricalVector{String, DefaultRefType}(a, ordered=ordered) == x
            @test NullableCategoricalVector{String, UInt8}(a, ordered=ordered) == x

            for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                      (a, DefaultRefType, DefaultRefType, false),
                                      (x, R, UInt8, true),
                                      (x, R, R, false))
                x2 = categorical(y, ordered=ordered)
                @test x2 == y
                if eltype(y) >: Null
                    @test isa(x2, NullableCategoricalVector{String, R1})
                else
                    @test isa(x2, CategoricalVector{String, R1})
                end
                @test isordered(x2) === ordered

                x2 = categorical(y, comp, ordered=ordered)
                @test x2 == y
                if eltype(y) >: Null
                    @test isa(x2, NullableCategoricalVector{String, R2})
                else
                    @test isa(x2, CategoricalVector{String, R2})
                end
                @test isordered(x2) === ordered
            end

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalVector{String, UInt8})
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test isordered(x2) === isordered(x)
            @test typeof(x2) === typeof(x)
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

            x2 = x[2:3]
            @test typeof(x2) === typeof(x)
            @test x2 == ["a", "b"]
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

            @test_throws ArgumentError levels!(x, ["e", "c"])
            @test levels!(x, ["e", "c"], nullok=true) === x
            @test levels(x) == ["e", "c"]
            @test x[1] === x.pool.valindex[2]
            @test x[2] === null
            @test x[3] === null
            @test levels(x) == ["e", "c"]

            push!(x, "e")
            @test length(x) == 4
            @test x == ["c", null, null, "e"]
            @test levels(x) == ["e", "c"]

            push!(x, "zz")
            @test length(x) == 5
            @test x == ["c", null, null, "e", "zz"]
            @test levels(x) == ["e", "c", "zz"]

            push!(x, x[1])
            @test length(x) == 6
            @test x == ["c", null, null, "e", "zz", "c"]
            @test levels(x) == ["e", "c", "zz"]

            push!(x, null)
            @test length(x) == 7
            @test x == ["c", null, null, "e", "zz", "c", null]
            @test levels(x) == ["e", "c", "zz"]

            append!(x, x)
            @test x == ["c", null, null, "e", "zz", "c", null, "c", null, null, "e", "zz", "c", null]
            @test levels(x) == ["e", "c", "zz"]
            @test isordered(x) === false
            @test length(x) == 14

            b = ["z","y","x"]
            y = NullableCategoricalVector{String, R}(b)
            append!(x, y)
            @test length(x) == 17
            @test isordered(x) === false
            @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
            @test x == ["c", null, null, "e", "zz", "c", null, "c", null, null, "e", "zz", "c", null, "z", "y", "x"]

            empty!(x)
            @test isordered(x) === false
            @test length(x) == 0
            @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
        end


        # Vector with null values
        let a = ["a", "b", null],
            x = NullableCategoricalVector{String, R}(a, ordered=ordered)

            @test x == a
            @test levels(x) == filter(x->!isnull(x), unique(a))
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

            @test NullableCategoricalArray{String}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 1}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 1, R}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 1, DefaultRefType}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 1, UInt8}(a, ordered=ordered) == x

            @test NullableCategoricalVector(a, ordered=ordered) == x
            @test NullableCategoricalVector{String}(a, ordered=ordered) == x
            @test NullableCategoricalVector{String, R}(a, ordered=ordered) == x
            @test NullableCategoricalVector{String, DefaultRefType}(a, ordered=ordered) == x
            @test NullableCategoricalVector{String, UInt8}(a, ordered=ordered) == x

            for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                      (a, DefaultRefType, DefaultRefType, false),
                                      (x, R, UInt8, true),
                                      (x, R, R, false))
                x2 = categorical(y, ordered=ordered)
                @test x2 == y
                @test isa(x2, NullableCategoricalVector{String, R1})
                @test isordered(x2) === ordered

                x2 = categorical(y, comp, ordered=ordered)
                @test x2 == y
                @test isa(x2, NullableCategoricalVector{String, R2})
                @test isordered(x2) === ordered
            end

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalVector{String, UInt8})
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test levels(x2) == levels(x)

            @test x[1] === x.pool.valindex[1]
            @test x[2] === x.pool.valindex[2]
            @test x[3] === null
            @test_throws BoundsError x[4]

            x2 = x[:]
            @test typeof(x2) === typeof(x)
            @test x2 == x
            @test x2 !== x
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[2:3]
            @test typeof(x2) === typeof(x)
            @test x2 == ["b", null]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[1:1]
            @test typeof(x2) === typeof(x)
            @test x2 == ["a"]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[2:1]
            @test typeof(x2) === typeof(x)
            @test isempty(x2)
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x[1] = "b"
            @test x[1] === x.pool.valindex[2]
            @test x[2] === x.pool.valindex[2]
            @test x[3] === null

            x[3] = "c"
            @test x[1] === x.pool.valindex[2]
            @test x[2] === x.pool.valindex[2]
            @test x[3] === x.pool.valindex[3]
            @test levels(x) == ["a", "b", "c"]

            x[1] = null
            @test x[1] === null
            @test x[2] === x.pool.valindex[2]
            @test x[3] === x.pool.valindex[3]
            @test levels(x) == ["a", "b", "c"]

            x[2:3] = null
            @test x[1] === null
            @test x[2] === null
            @test x[3] === null
            @test levels(x) == ["a", "b", "c"]
        end


        # Vector created from range (i.e. non-Array AbstractArray),
        # direct conversion to a vector with different eltype
        a = 0.0:0.5:1.5
        x = NullableCategoricalVector{Float64, R}(a, ordered=ordered)

        @test x == collect(a)
        @test isordered(x) === ordered
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

        @test NullableCategoricalArray{Float64}(a, ordered=ordered) == x
        @test NullableCategoricalArray{Float32}(a, ordered=ordered) == x
        @test NullableCategoricalArray{Float64, 1}(a, ordered=ordered) == x
        @test NullableCategoricalArray{Float32, 1}(a, ordered=ordered) == x
        @test NullableCategoricalArray{Float64, 1, R}(a, ordered=ordered) == x
        @test NullableCategoricalArray{Float32, 1, R}(a, ordered=ordered) == x
        @test NullableCategoricalArray{Float64, 1, DefaultRefType}(a, ordered=ordered) == x
        @test NullableCategoricalArray{Float32, 1, DefaultRefType}(a, ordered=ordered) == x

        @test NullableCategoricalVector(a, ordered=ordered) == x
        @test NullableCategoricalVector{Float64}(a, ordered=ordered) == x
        @test NullableCategoricalVector{Float32}(a, ordered=ordered) == x
        @test NullableCategoricalVector{Float64, R}(a, ordered=ordered) == x
        @test NullableCategoricalVector{Float32, R}(a, ordered=ordered) == x
        @test NullableCategoricalVector{Float64, DefaultRefType}(a, ordered=ordered) == x
        @test NullableCategoricalVector{Float32, DefaultRefType}(a, ordered=ordered) == x

        for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                  (a, DefaultRefType, DefaultRefType, false),
                                  (x, R, UInt8, true),
                                  (x, R, R, false))
            x2 = categorical(y, ordered=ordered)
            @test x2 == collect(y)
            if eltype(y) >: Null
                @test isa(x2, NullableCategoricalVector{Float64, R1})
            else
                @test isa(x2, CategoricalVector{Float64, R1})
            end
            @test isordered(x2) === ordered

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 == collect(y)
            if eltype(y) >: Null
                @test isa(x2, NullableCategoricalVector{Float64, R2})
            else
                @test isa(x2, CategoricalVector{Float64, R2})
            end
            @test isordered(x2) === ordered
        end

        x2 = compress(x)
        @test x2 == x
        @test isordered(x2) === isordered(x)
        @test isa(x2, NullableCategoricalVector{Float64, UInt8})
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 == x
        @test isordered(x2) === isordered(x)
        @test typeof(x2) === typeof(x)
        @test levels(x2) == levels(x)

        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[3]
        @test x[4] === x.pool.valindex[4]
        @test_throws BoundsError x[5]

        x2 = x[:]
        @test typeof(x2) === typeof(x)
        @test x2 == x
        @test x2 !== x
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
        @test x == [-1.0, -1.0, 1.0, 1.5, 2.0]
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        push!(x, x[1])
        @test length(x) == 6
        @test x == [-1.0, -1.0, 1.0, 1.5, 2.0, -1.0]
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        append!(x, x)
        @test length(x) == 12
        @test x == [-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0]
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        b = [2.5, 3.0, -3.5]
        y = NullableCategoricalVector{Float64, R}(b)
        append!(x, y)
        @test length(x) == 15
        @test x == [-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0, 2.5, 3.0, -3.5]
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        empty!(x)
        @test length(x) == 0
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        # Matrix with no null values
        for a in (["a" "b" "c"; "b" "a" "c"], Union{String, Null}["a" "b" "c"; "b" "a" "c"])
            x = NullableCategoricalMatrix{String, R}(a, ordered=ordered)

            @test x == a
            @test isordered(x) === ordered
            @test levels(x) == unique(a)
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

            @test NullableCategoricalArray{String}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2, R}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2, DefaultRefType}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2, UInt8}(a, ordered=ordered) == x

            @test NullableCategoricalMatrix(a, ordered=ordered) == x
            @test NullableCategoricalMatrix{String}(a, ordered=ordered) == x
            @test NullableCategoricalMatrix{String, R}(a, ordered=ordered) == x
            @test NullableCategoricalMatrix{String, DefaultRefType}(a, ordered=ordered) == x
            @test NullableCategoricalMatrix{String, UInt8}(a, ordered=ordered) == x

            for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                      (a, DefaultRefType, DefaultRefType, false),
                                      (x, R, UInt8, true),
                                      (x, R, R, false))
            x2 = categorical(y, ordered=ordered)
            @test x2 == y
            if eltype(y) >: Null
                @test isa(x2, NullableCategoricalMatrix{String, R1})
            else
                @test isa(x2, CategoricalMatrix{String, R1})
            end
            @test isordered(x2) === ordered

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 == y
            if eltype(y) >: Null
                @test isa(x2, NullableCategoricalMatrix{String, R2})
            else
                @test isa(x2, CategoricalMatrix{String, R2})
            end
            @test isordered(x2) === ordered
            end

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalMatrix{String, UInt8})
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

            @test x[1:2,:] == x
            @test typeof(x[1:2,:]) === typeof(x)
            @test x[1:2,1] == ["a", "b"]
            @test typeof(x[1:2,1]) === NullableCategoricalVector{String, R}

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
        end


        # Matrix with null values
        let a = ["a" null "c"; "b" "a" null]
            x = NullableCategoricalMatrix{String, R}(a, ordered=ordered)

            @test x == a
            @test isordered(x) === ordered
            @test levels(x) == filter(x->!isnull(x), unique(a))
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

            @test NullableCategoricalArray{String}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2, R}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2, DefaultRefType}(a, ordered=ordered) == x
            @test NullableCategoricalArray{String, 2, UInt8}(a, ordered=ordered) == x

            @test NullableCategoricalMatrix(a, ordered=ordered) == x
            @test NullableCategoricalMatrix{String}(a, ordered=ordered) == x
            @test NullableCategoricalMatrix{String, R}(a, ordered=ordered) == x
            @test NullableCategoricalMatrix{String, DefaultRefType}(a, ordered=ordered) == x
            @test NullableCategoricalMatrix{String, UInt8}(a, ordered=ordered) == x

            for (y, R1, R2, comp) in ((a, DefaultRefType, UInt8, true),
                                      (a, DefaultRefType, DefaultRefType, false),
                                      (x, R, UInt8, true),
                                      (x, R, R, false))
                x2 = categorical(y, ordered=ordered)
                @test x2 == y
                @test isa(x2, NullableCategoricalMatrix{String, R1})
                @test isordered(x2) === ordered

                x2 = categorical(y, comp, ordered=ordered)
                @test x2 == y
                @test isa(x2, NullableCategoricalMatrix{String, R2})
                @test isordered(x2) === ordered
            end

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalMatrix{String, UInt8})
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            @test x[1] === x.pool.valindex[1]
            @test x[2] === x.pool.valindex[2]
            @test x[3] === null
            @test x[4] === x.pool.valindex[1]
            @test x[5] === x.pool.valindex[3]
            @test x[6] === null
            @test_throws BoundsError x[7]

            @test x[1,1] === x.pool.valindex[1]
            @test x[2,1] === x.pool.valindex[2]
            @test x[1,2] === null
            @test x[2,2] === x.pool.valindex[1]
            @test x[1,3] === x.pool.valindex[3]
            @test x[2,3] === null
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
            @test x2 == ["a" "c"; "b" null]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[1:1,2]
            @test isa(x2, NullableCategoricalVector{String, R})
            @test x2 == [null]
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
            @test x[3] === null
            @test x[4] === x.pool.valindex[1]
            @test x[5] === x.pool.valindex[3]
            @test x[6] === null
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,:] = "a"
            @test x[1] === x.pool.valindex[1]
            @test x[2] === x.pool.valindex[2]
            @test x[3] === x.pool.valindex[1]
            @test x[4] === x.pool.valindex[1]
            @test x[5] === x.pool.valindex[1]
            @test x[6] === null
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,1:2] = "z"
            @test x[1] === x.pool.valindex[4]
            @test x[2] === x.pool.valindex[2]
            @test x[3] === x.pool.valindex[4]
            @test x[4] === x.pool.valindex[1]
            @test x[5] === x.pool.valindex[1]
            @test x[6] === null
            @test levels(x) == ["a", "b", "c", "z"]

            x[1] = null
            @test x[1] === null
            @test x[2] === x.pool.valindex[2]
            @test x[3] === x.pool.valindex[4]
            @test x[4] === x.pool.valindex[1]
            @test x[5] === x.pool.valindex[1]
            @test x[6] === null
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,1:2] = null
            @test x[1] === null
            @test x[2] === x.pool.valindex[2]
            @test x[3] === null
            @test x[4] === x.pool.valindex[1]
            @test x[5] === x.pool.valindex[1]
            @test x[6] === null
            @test levels(x) == ["a", "b", "c", "z"]

            x[:,2] = null
            @test x[1] === null
            @test x[2] === x.pool.valindex[2]
            @test x[3] === null
            @test x[4] === null
            @test x[5] === x.pool.valindex[1]
            @test x[6] === null
            @test levels(x) == ["a", "b", "c", "z"]

            x[1,2] = "a"
            @test x[1] === null
            @test x[2] === x.pool.valindex[2]
            @test x[3] === x.pool.valindex[1]
            @test x[4] === null
            @test x[5] === x.pool.valindex[1]
            @test x[6] === null
            @test levels(x) == ["a", "b", "c", "z"]

            x[2,1] = null
            @test x[1] === null
            @test x[2] === null
            @test x[3] === x.pool.valindex[1]
            @test x[4] === null
            @test x[5] === x.pool.valindex[1]
            @test x[6] === null
            @test levels(x) == ["a", "b", "c", "z"]

            # Constructor with values plus missingness array
            x = NullableCategoricalArray(1:3, [true, false, true], ordered=ordered)
            @test x == [null, 2, null]
            @test isordered(x) == ordered
            @test levels(x) == [2]

            x = NullableCategoricalVector(1:3, [true, false, true], ordered=ordered)
            @test x == [null, 2, null]
            @test isordered(x) === ordered
            @test levels(x) == [2]

            x = NullableCategoricalMatrix([1 2; 3 4], [true false; false true],
                                          ordered=ordered)
            @test x == [null 2; 3 null]
            @test isordered(x) === ordered
            @test levels(x) == [2, 3]
        end


        # Uninitialized array
        v = Any[NullableCategoricalArray(2, ordered=ordered),
                NullableCategoricalArray{String}(2, ordered=ordered),
                NullableCategoricalArray{String, 1}(2, ordered=ordered),
                NullableCategoricalArray{String, 1, R}(2, ordered=ordered),
                NullableCategoricalVector(2, ordered=ordered),
                NullableCategoricalVector{String}(2, ordered=ordered),
                NullableCategoricalVector{String, R}(2, ordered=ordered),
                NullableCategoricalArray(2, 3, ordered=ordered),
                NullableCategoricalArray{String}(2, 3, ordered=ordered),
                NullableCategoricalArray{String, 2}(2, 3, ordered=ordered),
                NullableCategoricalArray{String, 2, R}(2, 3, ordered=ordered),
                NullableCategoricalMatrix(2, 3, ordered=ordered),
                NullableCategoricalMatrix{String}(2, 3, ordered=ordered),
                NullableCategoricalMatrix{String, R}(2, 3, ordered=ordered)]

        for x in v
            @test isordered(x) === ordered
            @test isnull(x[1])
            @test isnull(x[2])
            @test levels(x) == []

            x2 = compress(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalArray{String, ndims(x), UInt8})
            @test isordered(x2) === isordered(x)
            @test levels(x2) == []

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test isordered(x2) === isordered(x)
            @test levels(x2) == []

            x[1] = "c"
            @test x[1] === x.pool.valindex[1]
            @test isnull(x[2])
            @test levels(x) == ["c"]

            x[1] = "a"
            @test x[1] === x.pool.valindex[2]
            @test isnull(x[2])
            @test levels(x) == ["c", "a"]

            x[2] = null
            @test x[1] === x.pool.valindex[2]
            @test x[2] === null
            @test levels(x) == ["c", "a"]

            x[1] = "b"
            @test x[1] === x.pool.valindex[3]
            @test x[2] === null
            @test levels(x) == ["c", "a", "b"]
        end
    end
end

# Test vcat with nulls
ca1 = NullableCategoricalArray(["a", "b"], [false, true])
ca2 = NullableCategoricalArray(["b", "a"], [true, false])
r = vcat(ca1, ca2)
@test r == NullableCategoricalArray(["a", "", "", "a"], [false, true, true, false])
@test levels(r) == ["a"]
@test !isordered(r)
ordered!(ca1,true)
@test !isordered(vcat(ca1, ca2))
ordered!(ca2,true)
@test isordered(vcat(ca1, ca2))
ordered!(ca1,false)
@test !isordered(vcat(ca1, ca2))

# vcat with all nulls
ca1 = NullableCategoricalArray(["a", "b"], [false, true])
ca2 = NullableCategoricalArray(["a", "b"], [true, true])
r = vcat(ca1, ca2)
@test isequal(r, NullableCategoricalArray(["a", "", "", ""], [false, true, true, true]))
@test levels(r) == ["a"]
@test !isordered(r)

# vcat with all nulls preserves isordered
# needed for instance when expanding an array with nulls
# such as vcat of DataFrame with missing columns
ordered!(ca1, true)
@test isempty(levels(ca2))
r = vcat(ca1, ca2)
@test isordered(r)

# vcat with all empty array
ca1 = NullableCategoricalArray(0)
ca2 = NullableCategoricalArray(["a", "b"], [true, false])
r = vcat(ca1, ca2)
@test isequal(r, NullableCategoricalArray(["", "b"], [true, false]))
@test levels(r) == ["b"]
@test !isordered(r)

# vcat with all nulls and empty
ca1 = NullableCategoricalArray(0)
ca2 = NullableCategoricalArray(["a", "b"], [true, true])
r = vcat(ca1, ca2)
@test isequal(r, NullableCategoricalArray(["", ""], [true, true]))
@test levels(r) == String[]
@test !isordered(r)

ordered!(ca1, true)
@test isempty(levels(ca2))
r = vcat(ca1, ca2)
@test isordered(r)

ca1 = NullableCategoricalArray(["a", "b"], [false, true])
ca2 = NullableCategoricalArray{String}(2)
ordered!(ca1, true)
@test isempty(levels(ca2))
r = vcat(ca1, ca2)
@test isequal(r, NullableCategoricalArray(["a", "", "", ""], [false, true, true, true]))
@test isordered(r)


# Test unique() and levels()

x = NullableCategoricalArray(["Old", "Young", "Middle", null, "Young"])
@test levels(x) == ["Middle", "Old", "Young"]
@test unique(x) == ["Middle", "Old", "Young", null]
@test levels!(x, ["Young", "Middle", "Old"]) === x
@test levels(x) == ["Young", "Middle", "Old"]
@test unique(x) == ["Young", "Middle", "Old", null]
@test levels!(x, ["Young", "Middle", "Old", "Unused"]) === x
@test levels(x) == ["Young", "Middle", "Old", "Unused"]
@test unique(x) == ["Young", "Middle", "Old", null]
@test levels!(x, ["Unused1", "Young", "Middle", "Old", "Unused2"]) === x
@test levels(x) == ["Unused1", "Young", "Middle", "Old", "Unused2"]
@test unique(x) == ["Young", "Middle", "Old", null]

x = NullableCategoricalArray(Union{String, Null}[null])
@test isa(levels(x), Vector{String}) && isempty(levels(x))
@test unique(x) == [null]
@test levels!(x, ["Young", "Middle", "Old"]) === x
@test levels(x) == ["Young", "Middle", "Old"]
@test unique(x) == [null]

# To test short-circuit after 1000 elements
x = NullableCategoricalArray(repeat(1:1500, inner=10))
@test levels(x) == collect(1:1500)
@test unique(x) == collect(1:1500)
@test levels!(x, [1600:-1:1; 2000]) === x
x[3] = null
@test levels(x) == [1600:-1:1; 2000]
@test unique(x) == [1500:-1:3; 2; 1; null]

end
