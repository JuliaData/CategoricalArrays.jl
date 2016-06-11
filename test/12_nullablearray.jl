module TestNullableArray

using Base.Test
using CategoricalArrays
using NullableArrays
using CategoricalArrays: DefaultRefType
using Compat

typealias String Compat.ASCIIString

# == currently throws an error for Nullables
(==) = isequal

for (A, V, M) in ((NullableNominalArray, NullableNominalVector, NullableNominalMatrix),
                  (NullableOrdinalArray, NullableOrdinalVector, NullableOrdinalMatrix))
    for R in (CategoricalArrays.DefaultRefType, UInt8, UInt, Int8, Int)
        # Vector with no null values
        for a in (["a", "b", "a"],
                  Nullable{String}["a", "b", "a"],
                  NullableArray(["a", "b", "a"]))
            x = V{String, R}(a)
            na = eltype(a) <: Nullable ? a : convert(Array{Nullable{String}}, a)

            @test x == na
            @test levels(x) == map(get, unique(na))
            @test size(x) === (3,)
            @test length(x) === 3

            @test convert(A, x) === x
            @test convert(A{String}, x) === x
            @test convert(A{String, 1}, x) === x
            @test convert(A{String, 1, R}, x) === x
            @test convert(A{String, 1, DefaultRefType}, x) == x
            @test convert(A{String, 1, UInt8}, x) == x

            @test convert(V, x) === x
            @test convert(V{String}, x) === x
            @test convert(V{String, R}, x) === x
            @test convert(V{String, DefaultRefType}, x) == x
            @test convert(V{String, UInt8}, x) == x

            @test A{String}(x) === x
            @test A{String, 1}(x) === x
            @test A{String, 1, R}(x) === x
            @test A{String, 1, DefaultRefType}(x) == x
            @test A{String, 1, UInt8}(x) == x

            @test V(x) === x
            @test V{String}(x) === x
            @test V{String, R}(x) === x
            @test V{String, DefaultRefType}(x) == x
            @test V{String, UInt8}(x) == x

            @test convert(A, a) == x
            @test convert(A{String}, a) == x
            @test convert(A{String, 1}, a) == x
            @test convert(A{String, 1, R}, a) == x
            @test convert(A{String, 1, DefaultRefType}, a) == x
            @test convert(A{String, 1, UInt8}, a) == x

            @test convert(V, a) == x
            @test convert(V{String}, a) == x
            @test convert(V{String, R}, a) == x
            @test convert(V{String, DefaultRefType}, a) == x
            @test convert(V{String, UInt8}, a) == x

            @test A{String}(a) == x
            @test A{String, 1}(a) == x
            @test A{String, 1, R}(a) == x
            @test A{String, 1, DefaultRefType}(a) == x
            @test A{String, 1, UInt8}(a) == x

            @test V(a) == x
            @test V{String}(a) == x
            @test V{String, R}(a) == x
            @test V{String, DefaultRefType}(a) == x
            @test V{String, UInt8}(a) == x

            @test x[1] === Nullable(x.pool.valindex[1])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test_throws BoundsError x[4]

            @test x[1:2] == Nullable{String}["a", "b"]
            @test typeof(x[1:2]) === typeof(x)

            x[1] = "b"
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[1])

            x[3] = "c"
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[2])
            @test x[3] === Nullable(x.pool.valindex[3])
            @test levels(x) == ["a", "b", "c"]

            x[2:3] = "a"
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[1])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test levels(x) == ["a", "b", "c"]

            droplevels!(x) == ["a", "b"]
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[1])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test levels(x) == ["a", "b"]

            levels!(x, ["b", "a"]) == ["b", "a"]
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[1])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test levels(x) == ["b", "a"]

            @test_throws ArgumentError levels!(x, ["a"])
            @test_throws ArgumentError levels!(x, ["e", "b"])
            @test_throws ArgumentError levels!(x, ["e", "a", "b", "a"])

            @test levels!(x, ["e", "a", "b"]) == ["e", "a", "b"]
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === Nullable(x.pool.valindex[1])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test levels(x) == ["e", "a", "b"]

            x[1] = "c"
            @test x[1] === Nullable(x.pool.valindex[4])
            @test x[2] === Nullable(x.pool.valindex[1])
            @test x[3] === Nullable(x.pool.valindex[1])
            @test levels(x) == ["e", "a", "b", "c"]

            @test_throws ArgumentError levels!(x, ["e", "c"])
            @test levels!(x, ["e", "c"], nullok=true) == ["e", "c"]
            @test x[1] === Nullable(x.pool.valindex[2])
            @test x[2] === eltype(x)()
            @test x[3] === eltype(x)()
            @test levels(x) == ["e", "c"]
        end

        # Vector with null values
        for a in (Nullable{String}["a", "b", Nullable()],
                  NullableArray(Nullable{String}["a", "b", Nullable()]))
            x = V{String, R}(a)

            @test x == a
            @test levels(x) == map(get, filter(x->!isnull(x), unique(a)))
            @test size(x) === (3,)
            @test length(x) === 3

            @test convert(A, x) === x
            @test convert(A{String}, x) === x
            @test convert(A{String, 1}, x) === x
            @test convert(A{String, 1, R}, x) === x
            @test convert(A{String, 1, DefaultRefType}, x) == x
            @test convert(A{String, 1, UInt8}, x) == x

            @test convert(V, x) === x
            @test convert(V{String}, x) === x
            @test convert(V{String, R}, x) === x
            @test convert(V{String, DefaultRefType}, x) == x
            @test convert(V{String, UInt8}, x) == x

            @test A{String}(x) === x
            @test A{String, 1}(x) === x
            @test A{String, 1, R}(x) === x
            @test A{String, 1, DefaultRefType}(x) == x
            @test A{String, 1, UInt8}(x) == x

            @test V(x) === x
            @test V{String}(x) === x
            @test V{String, R}(x) === x
            @test V{String, DefaultRefType}(x) == x
            @test V{String, UInt8}(x) == x

            @test convert(A, a) == x
            @test convert(A{String}, a) == x
            @test convert(A{String, 1}, a) == x
            @test convert(A{String, 1, R}, a) == x
            @test convert(A{String, 1, DefaultRefType}, a) == x
            @test convert(A{String, 1, UInt8}, a) == x

            @test convert(V, a) == x
            @test convert(V{String}, a) == x
            @test convert(V{String, R}, a) == x
            @test convert(V{String, DefaultRefType}, a) == x
            @test convert(V{String, UInt8}, a) == x

            @test A{String}(a) == x
            @test A{String, 1}(a) == x
            @test A{String, 1, R}(a) == x
            @test A{String, 1, DefaultRefType}(a) == x
            @test A{String, 1, UInt8}(a) == x

            @test V(a) == x
            @test V{String}(a) == x
            @test V{String, R}(a) == x
            @test V{String, DefaultRefType}(a) == x
            @test V{String, UInt8}(a) == x

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
        x = V{Float64, R}(a)

        @test x == map(Nullable, a)
        @test levels(x) == unique(a)
        @test size(x) === (4,)
        @test length(x) === 4

        @test convert(A, x) === x
        @test convert(A{Float64}, x) === x
        @test convert(A{Float64, 1}, x) === x
        @test convert(A{Float64, 1, R}, x) === x
        @test convert(A{Float64, 1, DefaultRefType}, x) == x
        @test convert(A{Float64, 1, UInt8}, x) == x

        @test convert(V, x) === x
        @test convert(V{Float64}, x) === x
        @test convert(V{Float64, R}, x) === x
        @test convert(V{Float64, DefaultRefType}, x) == x
        @test convert(V{Float64, UInt8}, x) == x

        @test A{Float64}(x) === x
        @test A{Float64, 1}(x) === x
        @test A{Float64, 1, R}(x) === x
        @test A{Float64, 1, DefaultRefType}(x) == x
        @test A{Float64, 1, UInt8}(x) == x

        @test V(x) === x
        @test V{Float64}(x) === x
        @test V{Float64, R}(x) === x
        @test V{Float64, DefaultRefType}(x) == x
        @test V{Float64, UInt8}(x) == x

        @test convert(A, a) == x
        @test convert(A{Float64}, a) == x
        @test convert(A{Float32}, a) == x
        @test convert(A{Float64, 1}, a) == x
        @test convert(A{Float32, 1}, a) == x
        @test convert(A{Float64, 1, R}, a) == x
        @test convert(A{Float32, 1, R}, a) == x
        @test convert(A{Float64, 1, DefaultRefType}, a) == x
        @test convert(A{Float32, 1, DefaultRefType}, a) == x
        @test convert(A{Float64, 1, UInt8}, a) == x
        @test convert(A{Float32, 1, UInt8}, a) == x

        @test convert(V, a) == x
        @test convert(V{Float64}, a) == x
        @test convert(V{Float32}, a) == x
        @test convert(V{Float64, R}, a) == x
        @test convert(V{Float32, R}, a) == x
        @test convert(V{Float64, DefaultRefType}, a) == x
        @test convert(V{Float32, DefaultRefType}, a) == x
        @test convert(V{Float64, UInt8}, a) == x
        @test convert(V{Float32, UInt8}, a) == x

        @test A{Float64}(a) == x
        @test A{Float32}(a) == x
        @test A{Float64, 1}(a) == x
        @test A{Float32, 1}(a) == x
        @test A{Float64, 1, R}(a) == x
        @test A{Float32, 1, R}(a) == x
        @test A{Float64, 1, DefaultRefType}(a) == x
        @test A{Float32, 1, DefaultRefType}(a) == x

        @test V(a) == x
        @test V{Float64}(a) == x
        @test V{Float32}(a) == x
        @test V{Float64, R}(a) == x
        @test V{Float32, R}(a) == x
        @test V{Float64, DefaultRefType}(a) == x
        @test V{Float32, DefaultRefType}(a) == x

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


        # Matrix with no null values
        for a in (["a" "b" "c"; "b" "a" "c"],
                  Nullable{String}["a" "b" "c"; "b" "a" "c"],
                  NullableArray(["a" "b" "c"; "b" "a" "c"]))
            na = eltype(a) <: Nullable ? a : convert(Array{Nullable{String}}, a)
            x = M{String, R}(a)

            @test x == na
            @test levels(x) == map(get, unique(na))
            @test size(x) === (2, 3)
            @test length(x) === 6

            @test convert(A, x) === x
            @test convert(A{String}, x) === x
            @test convert(A{String, 2}, x) === x
            @test convert(A{String, 2, R}, x) === x
            @test convert(A{String, 2, DefaultRefType}, x) == x
            @test convert(A{String, 2, UInt8}, x) == x

            @test convert(M, x) === x
            @test convert(M{String}, x) === x
            @test convert(M{String, R}, x) === x
            @test convert(M{String, DefaultRefType}, x) == x
            @test convert(M{String, UInt8}, x) == x

            @test A{String}(x) === x
            @test A{String, 2}(x) === x
            @test A{String, 2, R}(x) === x
            @test A{String, 2, DefaultRefType}(x) == x
            @test A{String, 2, UInt8}(x) == x

            @test M(x) === x
            @test M{String}(x) === x
            @test M{String, R}(x) === x
            @test M{String, DefaultRefType}(x) == x
            @test M{String, UInt8}(x) == x

            @test convert(A, a) == x
            @test convert(A{String}, a) == x
            @test convert(A{String, 2, R}, a) == x
            @test convert(A{String, 2, DefaultRefType}, a) == x
            @test convert(A{String, 2, UInt8}, a) == x

            @test convert(M, a) == x
            @test convert(M{String}, a) == x
            @test convert(M{String, R}, a) == x
            @test convert(M{String, DefaultRefType}, a) == x
            @test convert(M{String, UInt8}, a) == x

            @test A{String}(a) == x
            @test A{String, 2}(a) == x
            @test A{String, 2}(a) == x
            @test A{String, 2, R}(a) == x
            @test A{String, 2, DefaultRefType}(a) == x
            @test A{String, 2, UInt8}(a) == x

            @test M(a) == x
            @test M{String}(a) == x
            @test M{String, R}(a) == x
            @test M{String, DefaultRefType}(a) == x
            @test M{String, UInt8}(a) == x

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
            @test typeof(x[1:2,1]) === V{String, R}

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
            x = M{String, R}(a)

            @test x == a
            @test levels(x) == map(get, filter(x->!isnull(x), unique(a)))
            @test size(x) === (2, 3)
            @test length(x) === 6

            @test convert(A, x) === x
            @test convert(A{String}, x) === x
            @test convert(A{String, 2}, x) === x
            @test convert(A{String, 2, R}, x) === x
            @test convert(A{String, 2, DefaultRefType}, x) == x
            @test convert(A{String, 2, UInt8}, x) == x

            @test convert(M, x) === x
            @test convert(M{String}, x) === x
            @test convert(M{String, R}, x) === x
            @test convert(M{String, DefaultRefType}, x) == x
            @test convert(M{String, UInt8}, x) == x

            @test A{String}(x) === x
            @test A{String, 2}(x) === x
            @test A{String, 2, R}(x) === x
            @test A{String, 2, DefaultRefType}(x) == x
            @test A{String, 2, UInt8}(x) == x

            @test M(x) === x
            @test M{String}(x) === x
            @test M{String, R}(x) === x
            @test M{String, DefaultRefType}(x) == x
            @test M{String, UInt8}(x) == x

            @test convert(A, a) == x
            @test convert(A{String}, a) == x
            @test convert(A{String, 2, R}, a) == x
            @test convert(A{String, 2, DefaultRefType}, a) == x
            @test convert(A{String, 2, UInt8}, a) == x

            @test convert(M, a) == x
            @test convert(M{String}, a) == x
            @test convert(M{String, R}, a) == x
            @test convert(M{String, DefaultRefType}, a) == x
            @test convert(M{String, UInt8}, a) == x

            @test A{String}(a) == x
            @test A{String, 2}(a) == x
            @test A{String, 2}(a) == x
            @test A{String, 2, R}(a) == x
            @test A{String, 2, DefaultRefType}(a) == x
            @test A{String, 2, UInt8}(a) == x

            @test M(a) == x
            @test M{String}(a) == x
            @test M{String, R}(a) == x
            @test M{String, DefaultRefType}(a) == x
            @test M{String, UInt8}(a) == x

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
            @test typeof(x[1:2,1]) === V{String, R}

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
        end

        # Uninitialized array
        v = [A(2), A(String, 2),
             A{String}(2), A{String, 1}(2), A{String, 1, R}(2),
             V{String}(2), V{String, R}(2),
             A(2, 3), A(String, 2, 3),
             A{String}(2, 3), A{String, 2}(2, 3), A{String, 2, R}(2, 3),
             M{String}(2, 3), M{String, R}(2, 3)]

        # See conditional definition of constructors in array.jl and nullablearray.jl
        if VERSION >= v"0.5.0-dev"
            push!(v, V(2), V(String, 2), M(2, 3), M(String, 2, 3))
        end

        for x in v
            @test isnull(x[1])
            @test isnull(x[2])
            @test levels(x) == []

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
