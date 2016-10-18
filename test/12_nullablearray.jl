module TestNullableArray

using Base.Test
using CategoricalArrays
using NullableArrays
using CategoricalArrays: DefaultRefType
using Compat

typealias String Compat.ASCIIString

# == currently throws an error for Nullables
(==) = isequal

for ordered in (false, true)
    for R in (CategoricalArrays.DefaultRefType, UInt8, UInt, Int8, Int)
        # Vector with no null values
        for a in (["b", "a", "b"],
                  Nullable{String}["b", "a", "b"],
                  NullableArray(["b", "a", "b"]))
            x = NullableCategoricalVector{String, R}(a, ordered=ordered)
            na = eltype(a) <: Nullable ? a : convert(Array{Nullable{String}}, a)

            @test x == na
            @test isordered(x) === ordered
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

            for y in (NullableCategoricalArray(x, ordered=ordered),
                      NullableCategoricalArray{String}(x, ordered=ordered),
                      NullableCategoricalArray{String, 1}(x, ordered=ordered),
                      NullableCategoricalArray{String, 1, R}(x, ordered=ordered),
                      NullableCategoricalArray{String, 1, DefaultRefType}(x, ordered=ordered),
                      NullableCategoricalArray{String, 1, UInt8}(x, ordered=ordered),
                      NullableCategoricalVector(x, ordered=ordered),
                      NullableCategoricalVector{String}(x, ordered=ordered),
                      NullableCategoricalVector{String, R}(x, ordered=ordered),
                      NullableCategoricalVector{String, DefaultRefType}(x, ordered=ordered),
                      NullableCategoricalVector{String, UInt8}(x, ordered=ordered),
                      categorical(x, ordered=ordered),
                      categorical(x, false, ordered=ordered),
                      categorical(x, true, ordered=ordered))
                @test isa(y, NullableCategoricalVector{String})
                @test isordered(y) === ordered
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

            for (y, R1, R2, compact) in ((a, DefaultRefType, UInt8, true),
                                         (a, DefaultRefType, DefaultRefType, false),
                                         (x, R, UInt8, true),
                                         (x, R, R, false))
                x2 = categorical(y, ordered=ordered)
                @test x2 == y
                if eltype(y) <: Nullable
                    @test isa(x2, NullableCategoricalVector{String, R1})
                else
                    @test isa(x2, CategoricalVector{String, R1})
                end
                @test isordered(x2) === ordered

                x2 = categorical(y, compact, ordered=ordered)
                @test x2 == y
                if eltype(y) <: Nullable
                    @test isa(x2, NullableCategoricalVector{String, R2})
                else
                    @test isa(x2, CategoricalVector{String, R2})
                end
                @test isordered(x2) === ordered
            end

            x2 = compact(x)
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
            @test get(x[1] > x[2])
            @test get(x[3] > x[2])

            @test ordered!(x, false) === x
            @test isordered(x) === false
            @test_throws Exception x[1] > x[2]
            @test_throws Exception x[3] > x[2]

            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[1])
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
            @test x2 == Nullable{String}["a", "b"]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[1:1]
            @test typeof(x2) === typeof(x)
            @test x2 == Nullable{String}["b"]
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

            @test droplevels!(x) === x
            @test levels(x) == ["a", "b"]
            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[2])
            @test levels(x) == ["a", "b"]

            @test levels!(x, ["b", "a"]) === x
            @test levels(x) == ["b", "a"]
            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[2])
            @test levels(x) == ["b", "a"]

            @test_throws ArgumentError levels!(x, ["a"])
            @test_throws ArgumentError levels!(x, ["e", "b"])
            @test_throws ArgumentError levels!(x, ["e", "a", "b", "a"])

            @test levels!(x, ["e", "a", "b"]) === x
            @test levels(x) == ["e", "a", "b"]
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
            @test levels!(x, ["e", "c"], nullok=true) === x
            @test levels(x) == ["e", "c"]
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
            @test isordered(x) === false
            @test length(x) == 14

            b = ["z","y","x"]
            y = NullableCategoricalVector{String, R}(b)
            append!(x, y)
            @test length(x) == 17
            @test isordered(x) === false
            @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
            @test isequal(x, NullableArray(["c", "", "", "e", "zz", "c", "", "c", "", "", "e", "zz", "c", "", "z", "y", "x"], [false, true, true, false, false, false, true, false, true, true, false, false, false, true, false, false, false]))

            empty!(x)
            @test isordered(x) === false
            @test length(x) == 0
            @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
        end


        # Vector with null values
        for a in (Nullable{String}["a", "b", Nullable()],
                  NullableArray(Nullable{String}["a", "b", Nullable()]))
            x = NullableCategoricalVector{String, R}(a, ordered=ordered)

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

            for y in (NullableCategoricalArray(x, ordered=ordered),
                      NullableCategoricalArray{String}(x, ordered=ordered),
                      NullableCategoricalArray{String, 1}(x, ordered=ordered),
                      NullableCategoricalArray{String, 1, R}(x, ordered=ordered),
                      NullableCategoricalArray{String, 1, DefaultRefType}(x, ordered=ordered),
                      NullableCategoricalArray{String, 1, UInt8}(x, ordered=ordered),
                      NullableCategoricalVector(x, ordered=ordered),
                      NullableCategoricalVector{String}(x, ordered=ordered),
                      NullableCategoricalVector{String, R}(x, ordered=ordered),
                      NullableCategoricalVector{String, DefaultRefType}(x, ordered=ordered),
                      NullableCategoricalVector{String, UInt8}(x, ordered=ordered),
                      categorical(x, ordered=ordered),
                      categorical(x, false, ordered=ordered),
                      categorical(x, true, ordered=ordered))
                @test isa(y, NullableCategoricalVector{String})
                @test isordered(y) === ordered
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

            for (y, R1, R2, compact) in ((a, DefaultRefType, UInt8, true),
                                         (a, DefaultRefType, DefaultRefType, false),
                                         (x, R, UInt8, true),
                                         (x, R, R, false))
                x2 = categorical(y, ordered=ordered)
                @test x2 == y
                @test isa(x2, NullableCategoricalVector{String, R1})
                @test isordered(x2) === ordered

                x2 = categorical(y, compact, ordered=ordered)
                @test x2 == y
                @test isa(x2, NullableCategoricalVector{String, R2})
                @test isordered(x2) === ordered
            end

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

            x2 = x[:]
            @test typeof(x2) === typeof(x)
            @test x2 == x
            @test x2 !== x
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[2:3]
            @test typeof(x2) === typeof(x)
            @test x2 == Nullable{String}["b", Nullable()]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[1:1]
            @test typeof(x2) === typeof(x)
            @test x2 == Nullable{String}["a"]
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
        x = NullableCategoricalVector{Float64, R}(a, ordered=ordered)

        @test x == map(Nullable, a)
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

        for y in (NullableCategoricalArray(x, ordered=ordered),
                  NullableCategoricalArray{Float64}(x, ordered=ordered),
                  NullableCategoricalArray{Float64, 1}(x, ordered=ordered),
                  NullableCategoricalArray{Float64, 1, R}(x, ordered=ordered),
                  NullableCategoricalArray{Float64, 1, DefaultRefType}(x, ordered=ordered),
                  NullableCategoricalArray{Float64, 1, UInt8}(x, ordered=ordered),
                  NullableCategoricalVector(x, ordered=ordered),
                  NullableCategoricalVector{Float64}(x, ordered=ordered),
                  NullableCategoricalVector{Float64, R}(x, ordered=ordered),
                  NullableCategoricalVector{Float64, DefaultRefType}(x, ordered=ordered),
                  NullableCategoricalVector{Float64, UInt8}(x, ordered=ordered),
                  categorical(x, ordered=ordered),
                  categorical(x, false, ordered=ordered),
                  categorical(x, true, ordered=ordered))
            @test isa(y, NullableCategoricalVector{Float64})
            @test isordered(y) === ordered
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

        for (y, R1, R2, compact) in ((a, DefaultRefType, UInt8, true),
                                     (a, DefaultRefType, DefaultRefType, false),
                                     (x, R, UInt8, true),
                                     (x, R, R, false))
            x2 = categorical(y, ordered=ordered)
            @test x2 == collect(y)
            if eltype(y) <: Nullable
                @test isa(x2, NullableCategoricalVector{Float64, R1})
            else
                @test isa(x2, CategoricalVector{Float64, R1})
            end
            @test isordered(x2) === ordered

            x2 = categorical(y, compact, ordered=ordered)
            @test x2 == collect(y)
            if eltype(y) <: Nullable
                @test isa(x2, NullableCategoricalVector{Float64, R2})
            else
                @test isa(x2, CategoricalVector{Float64, R2})
            end
            @test isordered(x2) === ordered
        end

        x2 = compact(x)
        @test x2 == x
        @test isordered(x2) === isordered(x)
        @test isa(x2, NullableCategoricalVector{Float64, UInt8})
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 == x
        @test isordered(x2) === isordered(x)
        @test typeof(x2) === typeof(x)
        @test levels(x2) == levels(x)

        @test x[1] === Nullable(x.pool.valindex[1])
        @test x[2] === Nullable(x.pool.valindex[2])
        @test x[3] === Nullable(x.pool.valindex[3])
        @test x[4] === Nullable(x.pool.valindex[4])
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
        @test x2 == Nullable{Float64}[0.0, 0.5]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:1]
        @test typeof(x2) === typeof(x)
        @test x2 == Nullable{Float64}[0.0]
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
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        push!(x, x[1])
        @test length(x) == 6
        @test isequal(x, NullableArray([-1.0, -1.0, 1.0, 1.5, 2.0, -1.0]))
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        append!(x, x)
        @test length(x) == 12
        @test isequal(x, NullableArray([-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0]))
        @test isordered(x) === ordered
        @test levels(x) == [0.0,  0.5,  1.0,  1.5, -1.0,  2.0]

        b = [2.5, 3.0, -3.5]
        y = NullableCategoricalVector{Float64, R}(b)
        append!(x, y)
        @test length(x) == 15
        @test isequal(x, NullableArray([-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0, 2.5, 3.0, -3.5]))
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        empty!(x)
        @test length(x) == 0
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        # Matrix with no null values
        for a in (["a" "b" "c"; "b" "a" "c"],
                  Nullable{String}["a" "b" "c"; "b" "a" "c"],
                  NullableArray(["a" "b" "c"; "b" "a" "c"]))
            na = eltype(a) <: Nullable ? a : convert(Array{Nullable{String}}, a)
            x = NullableCategoricalMatrix{String, R}(a, ordered=ordered)

            @test x == na
            @test isordered(x) === ordered
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

            for y in (NullableCategoricalArray(x, ordered=ordered),
                      NullableCategoricalArray{String}(x, ordered=ordered),
                      NullableCategoricalArray{String, 2}(x, ordered=ordered),
                      NullableCategoricalArray{String, 2, R}(x, ordered=ordered),
                      NullableCategoricalArray{String, 2, DefaultRefType}(x, ordered=ordered),
                      NullableCategoricalArray{String, 2, UInt8}(x, ordered=ordered),
                      NullableCategoricalMatrix(x, ordered=ordered),
                      NullableCategoricalMatrix{String}(x, ordered=ordered),
                      NullableCategoricalMatrix{String, R}(x, ordered=ordered),
                      NullableCategoricalMatrix{String, DefaultRefType}(x, ordered=ordered),
                      NullableCategoricalMatrix{String, UInt8}(x, ordered=ordered),
                      categorical(x, ordered=ordered),
                      categorical(x, false, ordered=ordered),
                      categorical(x, true, ordered=ordered))
                @test isa(y, NullableCategoricalMatrix{String})
                @test isordered(y) === ordered
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

            for (y, R1, R2, compact) in ((a, DefaultRefType, UInt8, true),
                                         (a, DefaultRefType, DefaultRefType, false),
                                         (x, R, UInt8, true),
                                         (x, R, R, false))
            x2 = categorical(y, ordered=ordered)
            @test x2 == y
            if eltype(y) <: Nullable
                @test isa(x2, NullableCategoricalMatrix{String, R1})
            else
                @test isa(x2, CategoricalMatrix{String, R1})
            end
            @test isordered(x2) === ordered

            x2 = categorical(y, compact, ordered=ordered)
            @test x2 == y
            if eltype(y) <: Nullable
                @test isa(x2, NullableCategoricalMatrix{String, R2})
            else
                @test isa(x2, CategoricalMatrix{String, R2})
            end
            @test isordered(x2) === ordered
            end

            x2 = compact(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalMatrix{String, UInt8})
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test isordered(x2) === isordered(x)
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
            x = NullableCategoricalMatrix{String, R}(a, ordered=ordered)

            @test x == a
            @test isordered(x) === ordered
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

            for y in (NullableCategoricalArray(x, ordered=ordered),
                      NullableCategoricalArray{String}(x, ordered=ordered),
                      NullableCategoricalArray{String, 2}(x, ordered=ordered),
                      NullableCategoricalArray{String, 2, R}(x, ordered=ordered),
                      NullableCategoricalArray{String, 2, DefaultRefType}(x, ordered=ordered),
                      NullableCategoricalArray{String, 2, UInt8}(x, ordered=ordered),
                      NullableCategoricalMatrix(x, ordered=ordered),
                      NullableCategoricalMatrix{String}(x, ordered=ordered),
                      NullableCategoricalMatrix{String, R}(x, ordered=ordered),
                      NullableCategoricalMatrix{String, DefaultRefType}(x, ordered=ordered),
                      NullableCategoricalMatrix{String, UInt8}(x, ordered=ordered),
                      categorical(x, ordered=ordered),
                      categorical(x, false, ordered=ordered),
                      categorical(x, true, ordered=ordered))
                @test isa(y, NullableCategoricalMatrix{String})
                @test isordered(y) === ordered
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

            for (y, R1, R2, compact) in ((a, DefaultRefType, UInt8, true),
                                         (a, DefaultRefType, DefaultRefType, false),
                                         (x, R, UInt8, true),
                                         (x, R, R, false))
                x2 = categorical(y, ordered=ordered)
                @test x2 == y
                @test isa(x2, NullableCategoricalMatrix{String, R1})
                @test isordered(x2) === ordered

                x2 = categorical(y, compact, ordered=ordered)
                @test x2 == y
                @test isa(x2, NullableCategoricalMatrix{String, R2})
                @test isordered(x2) === ordered
            end

            x2 = compact(x)
            @test x2 == x
            @test isa(x2, NullableCategoricalMatrix{String, UInt8})
            @test isordered(x2) === isordered(x)
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test isordered(x2) === isordered(x)
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

            x2 = x[1:2,:]
            @test typeof(x2) === typeof(x)
            @test x2 == x
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[:,[1, 3]]
            @test typeof(x2) === typeof(x)
            @test x2 == Nullable{String}["a" "c"; "b" Nullable()]
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[1:1,2]
            @test isa(x2, NullableCategoricalVector{String, R})
            @test x2 == [Nullable()]
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

            x[1,2] = Nullable("a")
            @test x[1] === eltype(x)()
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test x[4] === eltype(x)()
            @test x[5] === Nullable(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            x[2,1] = Nullable()
            @test x[1] === eltype(x)()
            @test x[2] === eltype(x)()
            @test x[3] === Nullable(x.pool.valindex[1])
            @test x[4] === eltype(x)()
            @test x[5] === Nullable(x.pool.valindex[1])
            @test x[6] === eltype(x)()
            @test levels(x) == ["a", "b", "c", "z"]

            # Constructor with values plus missingness array
            x = NullableCategoricalArray(1:3, [true, false, true], ordered=ordered)
            @test x == Nullable{Int}[Nullable(), 2, Nullable()]
            @test isordered(x) == ordered
            @test levels(x) == [2]

            if VERSION >= v"0.5.0-dev"
                x = NullableCategoricalVector(1:3, [true, false, true], ordered=ordered)
                @test x == Nullable{Int}[Nullable(), 2, Nullable()]
                @test isordered(x) === ordered
                @test levels(x) == [2]

                x = NullableCategoricalMatrix([1 2; 3 4], [true false; false true],
                                              ordered=ordered)
                @test x == Nullable{Int}[Nullable() 2; 3 Nullable()]
                @test isordered(x) === ordered
                @test levels(x) == [2, 3]
            end
        end


        # Uninitialized array
        v = Any[NullableCategoricalArray(2, ordered=ordered),
                NullableCategoricalArray(String, 2, ordered=ordered),
                NullableCategoricalArray{String}(2, ordered=ordered),
                NullableCategoricalArray{String, 1}(2, ordered=ordered),
                NullableCategoricalArray{String, 1, R}(2, ordered=ordered),
                NullableCategoricalVector{String}(2, ordered=ordered),
                NullableCategoricalVector{String, R}(2, ordered=ordered),
                NullableCategoricalArray(2, 3, ordered=ordered),
                NullableCategoricalArray(String, 2, 3, ordered=ordered),
                NullableCategoricalArray{String}(2, 3, ordered=ordered),
                NullableCategoricalArray{String, 2}(2, 3, ordered=ordered),
                NullableCategoricalArray{String, 2, R}(2, 3, ordered=ordered),
                NullableCategoricalMatrix{String}(2, 3, ordered=ordered),
                NullableCategoricalMatrix{String, R}(2, 3, ordered=ordered)]

        # See conditional definition of constructors in array.jl and nullablearray.jl
        if VERSION >= v"0.5.0-dev"
            push!(v, NullableCategoricalVector(2, ordered=ordered),
                     NullableCategoricalVector(String, 2, ordered=ordered),
                     NullableCategoricalMatrix(2, 3, ordered=ordered),
                     NullableCategoricalMatrix(String, 2, 3, ordered=ordered))
        end

        for x in v
            @test isordered(x) === ordered
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
            @test isordered(x2) === isordered(x)
            @test levels(x2) == []

            x2 = copy(x)
            @test x2 == x
            @test typeof(x2) === typeof(x)
            @test isordered(x2) === isordered(x)
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

# Test vcat with nulls

@test vcat(NullableCategoricalArray(["a", "b"], [false, true]),
           NullableCategoricalArray(["b", "a"], [true, false])) ==
           NullableCategoricalArray(["a", "", "", "a"], [false, true, true, false])

# vcat with all nulls
ca1 = NullableCategoricalArray(["a", "b"], [false, true])
ca2 = NullableCategoricalArray(["a", "b"], [true, true])
r = vcat(ca1, ca2)
@test isequal(r, NullableCategoricalArray(["a", "", "", ""], [false, true, true, true]))
@test levels(r) == ["a"]
@test !isordered(r)

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

ordered!(ca1,true)
ordered!(ca2,false)
r = vcat(ca1, ca2)
@test !isordered(r)

ordered!(ca2,true)
r = vcat(ca1, ca2)
@test isordered(r)


# Test unique() and levels()

x = NullableCategoricalArray(["Old", "Young", "Middle", Nullable(), "Young"])
@test levels(x) == ["Middle", "Old", "Young"]
@test unique(x) == NullableArray(["Middle", "Old", "Young", Nullable()])
@test levels!(x, ["Young", "Middle", "Old"]) === x
@test levels(x) == ["Young", "Middle", "Old"]
@test unique(x) == NullableArray(["Young", "Middle", "Old", Nullable()])
@test levels!(x, ["Young", "Middle", "Old", "Unused"]) === x
@test levels(x) == ["Young", "Middle", "Old", "Unused"]
@test unique(x) == NullableArray(["Young", "Middle", "Old", Nullable()])
@test levels!(x, ["Unused1", "Young", "Middle", "Old", "Unused2"]) === x
@test levels(x) == ["Unused1", "Young", "Middle", "Old", "Unused2"]
@test unique(x) == NullableArray(["Young", "Middle", "Old", Nullable()])

x = NullableCategoricalArray([Nullable{String}()])
@test isa(levels(x), Vector{String}) && isempty(levels(x))
@test unique(x) == NullableArray{String}(1)
@test levels!(x, ["Young", "Middle", "Old"]) === x
@test levels(x) == ["Young", "Middle", "Old"]
@test unique(x) == NullableArray{String}(1)

# To test short-circuit after 1000 elements
x = NullableCategoricalArray(repeat(1:1500, inner=10))
@test levels(x) == collect(1:1500)
@test unique(x) == NullableArray(1:1500)
@test levels!(x, [1600:-1:1; 2000]) === x
x[3] = Nullable()
@test levels(x) == [1600:-1:1; 2000]
@test unique(x) == NullableArray([1500:-1:3; 2; 1; Nullable()])

end
