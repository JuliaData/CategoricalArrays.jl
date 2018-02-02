module TestMissingArray
using Compat
using Compat.Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType, catvaluetype, leveltype

const ≅ = isequal

@testset "conversion ordered=$ordered" for ordered in (false, true)
    @testset "conversion reftype=$R" for R in (CategoricalArrays.DefaultRefType, UInt8, UInt, Int8, Int)
        @testset "conversion of $(typeof(a))" for a in (["b", "a", "b"], Union{String, Missing}["b", "a", "b"])
            @testset "Vector with no missing values" begin
                x = CategoricalVector{Union{String, Missing}, R}(a, ordered=ordered)

                @test x == a
                @test leveltype(typeof(x)) === String
                @test leveltype(x) === String
                @test catvaluetype(typeof(x)) === CategoricalArrays.CategoricalString{R}
                @test catvaluetype(x) === CategoricalArrays.CategoricalString{R}
                @test isordered(x) === ordered
                @test levels(x) == sort(unique(a))
                @test size(x) === (3,)
                @test length(x) === 3

                @test convert(CategoricalArray, x) === x
                @test convert(CategoricalArray{Union{String, Missing}}, x) === x
                @test convert(CategoricalArray{Union{String, Missing}, 1}, x) === x
                @test convert(CategoricalArray{Union{String, Missing}, 1, R}, x) === x
                @test convert(CategoricalArray{Union{String, Missing}, 1, DefaultRefType}, x) == x
                @test convert(CategoricalArray{Union{String, Missing}, 1, UInt8}, x) == x

                @test convert(CategoricalVector, x) === x
                @test convert(CategoricalVector{Union{String, Missing}}, x) === x
                @test convert(CategoricalVector{Union{String, Missing}, R}, x) === x
                @test convert(CategoricalVector{Union{String, Missing}, DefaultRefType}, x) == x
                @test convert(CategoricalVector{Union{String, Missing}, UInt8}, x) == x

                @test convert(CategoricalArray, a) == x
                @test convert(CategoricalArray{Union{String, Missing}}, a) == x
                @test convert(CategoricalArray{Union{String, Missing}, 1}, a) == x
                @test convert(CategoricalArray{Union{String, Missing}, 1, R}, a) == x
                @test convert(CategoricalArray{Union{String, Missing}, 1, DefaultRefType}, a) == x
                @test convert(CategoricalArray{Union{String, Missing}, 1, UInt8}, a) == x

                @test convert(CategoricalVector, a) == x
                @test convert(CategoricalVector{Union{String, Missing}}, a) == x
                @test convert(CategoricalVector{Union{String, Missing}, R}, a) == x
                @test convert(CategoricalVector{Union{String, Missing}, DefaultRefType}, a) == x
                @test convert(CategoricalVector{Union{String, Missing}, UInt8}, a) == x

                @test CategoricalArray{Union{String, Missing}}(a, ordered=ordered) == x
                @test CategoricalArray{Union{String, Missing}, 1}(a, ordered=ordered) == x
                @test CategoricalArray{Union{String, Missing}, 1, R}(a, ordered=ordered) == x
                @test CategoricalArray{Union{String, Missing}, 1, DefaultRefType}(a, ordered=ordered) == x
                @test CategoricalArray{Union{String, Missing}, 1, UInt8}(a, ordered=ordered) == x

                @test CategoricalVector(a, ordered=ordered) == x
                @test CategoricalVector{Union{String, Missing}}(a, ordered=ordered) == x
                @test CategoricalVector{Union{String, Missing}, R}(a, ordered=ordered) == x
                @test CategoricalVector{Union{String, Missing}, DefaultRefType}(a, ordered=ordered) == x
                @test CategoricalVector{Union{String, Missing}, UInt8}(a, ordered=ordered) == x

                @testset "categorical($(typeof(y)), compress=$comp) R1=$R1 R2=$R2" for (y, R1, R2, comp) in
                    ((a, DefaultRefType, UInt8, true),
                     (a, DefaultRefType, DefaultRefType, false),
                     (x, R, UInt8, true),
                     (x, R, R, false))

                    x2 = categorical(y, ordered=ordered)
                    @test leveltype(x2) === String
                    @test catvaluetype(x2) === CategoricalArrays.CategoricalString{R1}
                    @test x2 == y
                    if eltype(y) >: Missing
                        @test isa(x2, CategoricalVector{Union{String, Missing}, R1})
                    else
                        @test isa(x2, CategoricalVector{String, R1})
                    end
                    @test isordered(x2) === ordered

                    x2 = categorical(y, comp, ordered=ordered)
                    @test x2 == y
                    @test leveltype(x2) === String
                    @test catvaluetype(x2) === CategoricalArrays.CategoricalString{R2}
                    if eltype(y) >: Missing
                        @test isa(x2, CategoricalVector{Union{String, Missing}, R2})
                    else
                        @test isa(x2, CategoricalVector{String, R2})
                    end
                    @test isordered(x2) === ordered
                end

                x2 = compress(x)
                @test x2 == x
                @test isa(x2, CategoricalVector{Union{String, Missing}, UInt8})
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
                @test levels!(x, ["e", "c"], allow_missing=true) === x
                @test levels(x) == ["e", "c"]
                @test x[1] === x.pool.valindex[2]
                @test x[2] === missing
                @test x[3] === missing
                @test levels(x) == ["e", "c"]

                push!(x, "e")
                @test length(x) == 4
                @test x ≅ ["c", missing, missing, "e"]
                @test levels(x) == ["e", "c"]

                push!(x, "zz")
                @test length(x) == 5
                @test x ≅ ["c", missing, missing, "e", "zz"]
                @test levels(x) == ["e", "c", "zz"]

                push!(x, x[1])
                @test length(x) == 6
                @test x ≅ ["c", missing, missing, "e", "zz", "c"]
                @test levels(x) == ["e", "c", "zz"]

                push!(x, missing)
                @test length(x) == 7
                @test x ≅ ["c", missing, missing, "e", "zz", "c", missing]
                @test levels(x) == ["e", "c", "zz"]

                append!(x, x)
                @test x ≅ ["c", missing, missing, "e", "zz", "c", missing, "c", missing, missing, "e", "zz", "c", missing]
                @test levels(x) == ["e", "c", "zz"]
                @test isordered(x) === false
                @test length(x) == 14

                b = ["z","y","x"]
                y = CategoricalVector{Union{String, Missing}, R}(b)
                append!(x, y)
                @test length(x) == 17
                @test isordered(x) === false
                @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
                @test x ≅ ["c", missing, missing, "e", "zz", "c", missing, "c", missing, missing, "e", "zz", "c", missing, "z", "y", "x"]

                empty!(x)
                @test isordered(x) === false
                @test length(x) == 0
                @test levels(x) == ["e", "c", "zz", "x", "y", "z"]
            end
        end

        @testset "Vector with missing values" begin
            a = ["a", "b", missing]
            x = CategoricalVector{Union{String, Missing}, R}(a, ordered=ordered)

            @test x ≅ a
            @test levels(x) == filter(x->!ismissing(x), unique(a))
            @test size(x) === (3,)
            @test length(x) === 3

            @test convert(CategoricalArray, x) === x
            @test convert(CategoricalArray{Union{String, Missing}}, x) === x
            @test convert(CategoricalArray{Union{String, Missing}, 1}, x) === x
            @test convert(CategoricalArray{Union{String, Missing}, 1, R}, x) === x
            @test convert(CategoricalArray{Union{String, Missing}, 1, DefaultRefType}, x) ≅ x
            @test convert(CategoricalArray{Union{String, Missing}, 1, UInt8}, x) ≅ x

            @test convert(CategoricalVector, x) === x
            @test convert(CategoricalVector{Union{String, Missing}}, x) === x
            @test convert(CategoricalVector{Union{String, Missing}, R}, x) === x
            @test convert(CategoricalVector{Union{String, Missing}, DefaultRefType}, x) ≅ x
            @test convert(CategoricalVector{Union{String, Missing}, UInt8}, x) ≅ x

            @test convert(CategoricalArray, a) ≅ x
            @test convert(CategoricalArray{Union{String, Missing}}, a) ≅ x
            @test convert(CategoricalArray{Union{String, Missing}, 1}, a) ≅ x
            @test convert(CategoricalArray{Union{String, Missing}, 1, R}, a) ≅ x
            @test convert(CategoricalArray{Union{String, Missing}, 1, DefaultRefType}, a) ≅ x
            @test convert(CategoricalArray{Union{String, Missing}, 1, UInt8}, a) ≅ x

            @test convert(CategoricalVector, a) ≅ x
            @test convert(CategoricalVector{Union{String, Missing}}, a) ≅ x
            @test convert(CategoricalVector{Union{String, Missing}, R}, a) ≅ x
            @test convert(CategoricalVector{Union{String, Missing}, DefaultRefType}, a) ≅ x
            @test convert(CategoricalVector{Union{String, Missing}, UInt8}, a) ≅ x

            @test CategoricalArray{Union{String, Missing}}(a, ordered=ordered) ≅ x
            @test CategoricalArray{Union{String, Missing}, 1}(a, ordered=ordered) ≅ x
            @test CategoricalArray{Union{String, Missing}, 1, R}(a, ordered=ordered) ≅ x
            @test CategoricalArray{Union{String, Missing}, 1, DefaultRefType}(a, ordered=ordered) ≅ x
            @test CategoricalArray{Union{String, Missing}, 1, UInt8}(a, ordered=ordered) ≅ x

            @test CategoricalVector(a, ordered=ordered) ≅ x
            @test CategoricalVector{Union{String, Missing}}(a, ordered=ordered) ≅ x
            @test CategoricalVector{Union{String, Missing}, R}(a, ordered=ordered) ≅ x
            @test CategoricalVector{Union{String, Missing}, DefaultRefType}(a, ordered=ordered) ≅ x
            @test CategoricalVector{Union{String, Missing}, UInt8}(a, ordered=ordered) ≅ x

            @testset "categorical($(typeof(y)), compress=$comp) R1=$R1 R2=$R2" for (y, R1, R2, comp) in
                ((a, DefaultRefType, UInt8, true),
                 (a, DefaultRefType, DefaultRefType, false),
                 (x, R, UInt8, true),
                 (x, R, R, false))

                x2 = categorical(y, ordered=ordered)
                @test x2 ≅ y
                if eltype(y) >: Missing
                    @test isa(x2, CategoricalVector{Union{String, Missing}, R1})
                else
                    @test isa(x2, CategoricalVector{String, R1})
                end
                @test isordered(x2) === ordered

                x2 = categorical(y, comp, ordered=ordered)
                @test x2 ≅ y
                if eltype(y) >: Missing
                    @test isa(x2, CategoricalVector{Union{String, Missing}, R2})
                else
                    @test isa(x2, CategoricalVector{String, R2})
                end
                @test isordered(x2) === ordered
            end

            x2 = compress(x)
            @test x2 ≅ x
            @test isa(x2, CategoricalVector{Union{String, Missing}, UInt8})
            @test levels(x2) == levels(x)

            x2 = copy(x)
            @test x2 ≅ x
            @test typeof(x2) === typeof(x)
            @test levels(x2) == levels(x)

            @test x[1] === x.pool.valindex[1]
            @test x[2] === x.pool.valindex[2]
            @test x[3] === missing
            @test_throws BoundsError x[4]

            x2 = x[:]
            @test typeof(x2) === typeof(x)
            @test x2 ≅ x
            @test x2 !== x
            @test levels(x2) == levels(x)
            @test levels(x2) !== levels(x)
            @test isordered(x2) == isordered(x)

            x2 = x[2:3]
            @test typeof(x2) === typeof(x)
            @test x2 ≅ ["b", missing]
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
            @test x[3] === missing

            x[3] = "c"
            @test x[1] === x.pool.valindex[2]
            @test x[2] === x.pool.valindex[2]
            @test x[3] === x.pool.valindex[3]
            @test levels(x) == ["a", "b", "c"]

            x[1] = missing
            @test x[1] === missing
            @test x[2] === x.pool.valindex[2]
            @test x[3] === x.pool.valindex[3]
            @test levels(x) == ["a", "b", "c"]

            x[2:3] = missing
            @test x[1] === missing
            @test x[2] === missing
            @test x[3] === missing
            @test levels(x) == ["a", "b", "c"]
        end

        @testset "Vector created from range" begin
        # (i.e. non-Array AbstractArray),
        # direct conversion to a vector with different eltype
        a = 0.0:0.5:1.5
        x = CategoricalVector{Union{Float64, Missing}, R}(a, ordered=ordered)

        @test x == collect(a)
        @test isordered(x) === ordered
        @test levels(x) == unique(a)
        @test size(x) === (4,)
        @test length(x) === 4
        @test leveltype(x) === Float64
        @test catvaluetype(x) <: CategoricalArrays.CategoricalValue{Float64}

        @test convert(CategoricalArray, x) === x
        @test convert(CategoricalArray{Union{Float64, Missing}}, x) === x
        @test convert(CategoricalArray{Union{Float64, Missing}, 1}, x) === x
        @test convert(CategoricalArray{Union{Float64, Missing}, 1, R}, x) === x
        @test convert(CategoricalArray{Union{Float64, Missing}, 1, DefaultRefType}, x) == x
        @test convert(CategoricalArray{Union{Float64, Missing}, 1, UInt8}, x) == x

        @test convert(CategoricalVector, x) === x
        @test convert(CategoricalVector{Union{Float64, Missing}}, x) === x
        @test convert(CategoricalVector{Union{Float64, Missing}, R}, x) === x
        @test convert(CategoricalVector{Union{Float64, Missing}, DefaultRefType}, x) == x
        @test convert(CategoricalVector{Union{Float64, Missing}, UInt8}, x) == x

        @test convert(CategoricalArray, a) == x
        @test convert(CategoricalArray{Union{Float64, Missing}}, a) == x
        @test convert(CategoricalArray{Union{Float32, Missing}}, a) == x
        @test convert(CategoricalArray{Union{Float64, Missing}, 1}, a) == x
        @test convert(CategoricalArray{Union{Float32, Missing}, 1}, a) == x
        @test convert(CategoricalArray{Union{Float64, Missing}, 1, R}, a) == x
        @test convert(CategoricalArray{Union{Float32, Missing}, 1, R}, a) == x
        @test convert(CategoricalArray{Union{Float64, Missing}, 1, DefaultRefType}, a) == x
        @test convert(CategoricalArray{Union{Float32, Missing}, 1, DefaultRefType}, a) == x
        @test convert(CategoricalArray{Union{Float64, Missing}, 1, UInt8}, a) == x
        @test convert(CategoricalArray{Union{Float32, Missing}, 1, UInt8}, a) == x

        @test convert(CategoricalVector, a) == x
        @test convert(CategoricalVector{Union{Float64, Missing}}, a) == x
        @test convert(CategoricalVector{Union{Float32, Missing}}, a) == x
        @test convert(CategoricalVector{Union{Float64, Missing}, R}, a) == x
        @test convert(CategoricalVector{Union{Float32, Missing}, R}, a) == x
        @test convert(CategoricalVector{Union{Float64, Missing}, DefaultRefType}, a) == x
        @test convert(CategoricalVector{Union{Float32, Missing}, DefaultRefType}, a) == x
        @test convert(CategoricalVector{Union{Float64, Missing}, UInt8}, a) == x
        @test convert(CategoricalVector{Union{Float32, Missing}, UInt8}, a) == x

        @test CategoricalArray{Union{Float64, Missing}}(a, ordered=ordered) == x
        @test CategoricalArray{Union{Float32, Missing}}(a, ordered=ordered) == x
        @test CategoricalArray{Union{Float64, Missing}, 1}(a, ordered=ordered) == x
        @test CategoricalArray{Union{Float32, Missing}, 1}(a, ordered=ordered) == x
        @test CategoricalArray{Union{Float64, Missing}, 1, R}(a, ordered=ordered) == x
        @test CategoricalArray{Union{Float32, Missing}, 1, R}(a, ordered=ordered) == x
        @test CategoricalArray{Union{Float64, Missing}, 1, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalArray{Union{Float32, Missing}, 1, DefaultRefType}(a, ordered=ordered) == x

        @test CategoricalVector(a, ordered=ordered) == x
        @test CategoricalVector{Union{Float64, Missing}}(a, ordered=ordered) == x
        @test CategoricalVector{Union{Float32, Missing}}(a, ordered=ordered) == x
        @test CategoricalVector{Union{Float64, Missing}, R}(a, ordered=ordered) == x
        @test CategoricalVector{Union{Float32, Missing}, R}(a, ordered=ordered) == x
        @test CategoricalVector{Union{Float64, Missing}, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalVector{Union{Float32, Missing}, DefaultRefType}(a, ordered=ordered) == x

        @testset "categorical($(typeof(y)), compress=$comp) R1=$R1 R2=$R2" for (y, R1, R2, comp) in
            ((a, DefaultRefType, UInt8, true),
             (a, DefaultRefType, DefaultRefType, false),
             (x, R, UInt8, true),
             (x, R, R, false))

            x2 = categorical(y, ordered=ordered)
            @test x2 == collect(y)
            if eltype(y) >: Missing
                @test isa(x2, CategoricalVector{Union{Float64, Missing}, R1})
            else
                @test isa(x2, CategoricalVector{Float64, R1})
            end
            @test isordered(x2) === ordered
            @test leveltype(x2) === Float64
            @test catvaluetype(x2) === CategoricalArrays.CategoricalValue{Float64, R1}

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 == collect(y)
            if eltype(y) >: Missing
                @test isa(x2, CategoricalVector{Union{Float64, Missing}, R2})
            else
                @test isa(x2, CategoricalVector{Float64, R2})
            end
            @test isordered(x2) === ordered
            @test leveltype(x2) === Float64
            @test catvaluetype(x2) === CategoricalArrays.CategoricalValue{Float64, R2}
        end

        x2 = compress(x)
        @test x2 == x
        @test isordered(x2) === isordered(x)
        @test isa(x2, CategoricalVector{Union{Float64, Missing}, UInt8})
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
        y = CategoricalVector{Union{Float64, Missing}, R}(b)
        append!(x, y)
        @test length(x) == 15
        @test x == [-1.0, -1.0, 1.0, 1.5, 2.0, -1.0, -1.0, -1.0, 1.0, 1.5, 2.0, -1.0, 2.5, 3.0, -3.5]
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]

        empty!(x)
        @test length(x) == 0
        @test isordered(x) === ordered
        @test levels(x) == [0.0, 0.5, 1.0, 1.5, -1.0, 2.0, -3.5, 2.5, 3.0]
    end

    @testset "Matrix $(typeof(a)) with no missing values" for a in
        (["a" "b" "c"; "b" "a" "c"],
         Union{String, Missing}["a" "b" "c"; "b" "a" "c"])

        x = CategoricalMatrix{Union{String, Missing}, R}(a, ordered=ordered)

        @test x == a
        @test isordered(x) === ordered
        @test levels(x) == unique(a)
        @test size(x) === (2, 3)
        @test length(x) === 6

        @test convert(CategoricalArray, x) === x
        @test convert(CategoricalArray{Union{String, Missing}}, x) === x
        @test convert(CategoricalArray{Union{String, Missing}, 2}, x) === x
        @test convert(CategoricalArray{Union{String, Missing}, 2, R}, x) === x
        @test convert(CategoricalArray{Union{String, Missing}, 2, DefaultRefType}, x) == x
        @test convert(CategoricalArray{Union{String, Missing}, 2, UInt8}, x) == x

        @test convert(CategoricalMatrix, x) === x
        @test convert(CategoricalMatrix{Union{String, Missing}}, x) === x
        @test convert(CategoricalMatrix{Union{String, Missing}, R}, x) === x
        @test convert(CategoricalMatrix{Union{String, Missing}, DefaultRefType}, x) == x
        @test convert(CategoricalMatrix{Union{String, Missing}, UInt8}, x) == x

        @test convert(CategoricalArray, a) == x
        @test convert(CategoricalArray{Union{String, Missing}}, a) == x
        @test convert(CategoricalArray{Union{String, Missing}, 2, R}, a) == x
        @test convert(CategoricalArray{Union{String, Missing}, 2, DefaultRefType}, a) == x
        @test convert(CategoricalArray{Union{String, Missing}, 2, UInt8}, a) == x

        @test convert(CategoricalMatrix, a) == x
        @test convert(CategoricalMatrix{Union{String, Missing}}, a) == x
        @test convert(CategoricalMatrix{Union{String, Missing}, R}, a) == x
        @test convert(CategoricalMatrix{Union{String, Missing}, DefaultRefType}, a) == x
        @test convert(CategoricalMatrix{Union{String, Missing}, UInt8}, a) == x

        @test CategoricalArray{Union{String, Missing}}(a, ordered=ordered) == x
        @test CategoricalArray{Union{String, Missing}, 2}(a, ordered=ordered) == x
        @test CategoricalArray{Union{String, Missing}, 2}(a, ordered=ordered) == x
        @test CategoricalArray{Union{String, Missing}, 2, R}(a, ordered=ordered) == x
        @test CategoricalArray{Union{String, Missing}, 2, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalArray{Union{String, Missing}, 2, UInt8}(a, ordered=ordered) == x

        @test CategoricalMatrix(a, ordered=ordered) == x
        @test CategoricalMatrix{Union{String, Missing}}(a, ordered=ordered) == x
        @test CategoricalMatrix{Union{String, Missing}, R}(a, ordered=ordered) == x
        @test CategoricalMatrix{Union{String, Missing}, DefaultRefType}(a, ordered=ordered) == x
        @test CategoricalMatrix{Union{String, Missing}, UInt8}(a, ordered=ordered) == x

        @testset "categorical($(typeof(y)), compress=$comp) R1=$R1 R2=$R2" for (y, R1, R2, comp) in
            ((a, DefaultRefType, UInt8, true),
             (a, DefaultRefType, DefaultRefType, false),
             (x, R, UInt8, true),
             (x, R, R, false))

            x2 = categorical(y, ordered=ordered)
            @test x2 == y
            if eltype(y) >: Missing
                @test isa(x2, CategoricalMatrix{Union{String, Missing}, R1})
            else
                @test isa(x2, CategoricalMatrix{String, R1})
            end
            @test isordered(x2) === ordered

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 == y
            if eltype(y) >: Missing
                @test isa(x2, CategoricalMatrix{Union{String, Missing}, R2})
            else
                @test isa(x2, CategoricalMatrix{String, R2})
            end
            @test isordered(x2) === ordered
        end

        x2 = compress(x)
        @test x2 == x
        @test isa(x2, CategoricalMatrix{Union{String, Missing}, UInt8})
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
        @test isa(x[1:2,1], CategoricalVector{Union{String, Missing}, R})

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

        @testset "Matrix with missing values" begin
        a = ["a" missing "c"; "b" "a" missing]
        x = CategoricalMatrix{Union{String, Missing}, R}(a, ordered=ordered)

        @test x ≅ a
        @test isordered(x) === ordered
        @test levels(x) == filter(x->!ismissing(x), unique(a))
        @test size(x) === (2, 3)
        @test length(x) === 6

        @test convert(CategoricalArray, x) === x
        @test convert(CategoricalArray{Union{String, Missing}}, x) === x
        @test convert(CategoricalArray{Union{String, Missing}, 2}, x) === x
        @test convert(CategoricalArray{Union{String, Missing}, 2, R}, x) === x
        @test convert(CategoricalArray{Union{String, Missing}, 2, DefaultRefType}, x) ≅ x
        @test convert(CategoricalArray{Union{String, Missing}, 2, UInt8}, x) ≅ x

        @test convert(CategoricalMatrix, x) === x
        @test convert(CategoricalMatrix{Union{String, Missing}}, x) === x
        @test convert(CategoricalMatrix{Union{String, Missing}, R}, x) === x
        @test convert(CategoricalMatrix{Union{String, Missing}, DefaultRefType}, x) ≅ x
        @test convert(CategoricalMatrix{Union{String, Missing}, UInt8}, x) ≅ x

        @test convert(CategoricalArray, a) ≅ x
        @test convert(CategoricalArray{Union{String, Missing}}, a) ≅ x
        @test convert(CategoricalArray{Union{String, Missing}, 2, R}, a) ≅ x
        @test convert(CategoricalArray{Union{String, Missing}, 2, DefaultRefType}, a) ≅ x
        @test convert(CategoricalArray{Union{String, Missing}, 2, UInt8}, a) ≅ x

        @test convert(CategoricalMatrix, a) ≅ x
        @test convert(CategoricalMatrix{Union{String, Missing}}, a) ≅ x
        @test convert(CategoricalMatrix{Union{String, Missing}, R}, a) ≅ x
        @test convert(CategoricalMatrix{Union{String, Missing}, DefaultRefType}, a) ≅ x
        @test convert(CategoricalMatrix{Union{String, Missing}, UInt8}, a) ≅ x

        @test CategoricalArray{Union{String, Missing}}(a, ordered=ordered) ≅ x
        @test CategoricalArray{Union{String, Missing}, 2}(a, ordered=ordered) ≅ x
        @test CategoricalArray{Union{String, Missing}, 2}(a, ordered=ordered) ≅ x
        @test CategoricalArray{Union{String, Missing}, 2, R}(a, ordered=ordered) ≅ x
        @test CategoricalArray{Union{String, Missing}, 2, DefaultRefType}(a, ordered=ordered) ≅ x
        @test CategoricalArray{Union{String, Missing}, 2, UInt8}(a, ordered=ordered) ≅ x

        @test CategoricalMatrix(a, ordered=ordered) ≅ x
        @test CategoricalMatrix{Union{String, Missing}}(a, ordered=ordered) ≅ x
        @test CategoricalMatrix{Union{String, Missing}, R}(a, ordered=ordered) ≅ x
        @test CategoricalMatrix{Union{String, Missing}, DefaultRefType}(a, ordered=ordered) ≅ x
        @test CategoricalMatrix{Union{String, Missing}, UInt8}(a, ordered=ordered) ≅ x

        @testset "categorical($(typeof(y)), compress=$comp) R1=$R1 R2=$R2" for (y, R1, R2, comp) in
            ((a, DefaultRefType, UInt8, true),
             (a, DefaultRefType, DefaultRefType, false),
             (x, R, UInt8, true),
             (x, R, R, false))

            x2 = categorical(y, ordered=ordered)
            @test x2 ≅ y
            @test isa(x2, CategoricalMatrix{Union{String, Missing}, R1})
            @test isordered(x2) === ordered

            x2 = categorical(y, comp, ordered=ordered)
            @test x2 ≅ y
            @test isa(x2, CategoricalMatrix{Union{String, Missing}, R2})
            @test isordered(x2) === ordered
        end

        x2 = compress(x)
        @test x2 ≅ x
        @test isa(x2, CategoricalMatrix{Union{String, Missing}, UInt8})
        @test isordered(x2) === isordered(x)
        @test levels(x2) == levels(x)

        x2 = copy(x)
        @test x2 ≅ x
        @test typeof(x2) === typeof(x)
        @test isordered(x2) === isordered(x)
        @test levels(x2) == levels(x)

        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === missing
        @test x[4] === x.pool.valindex[1]
        @test x[5] === x.pool.valindex[3]
        @test x[6] === missing
        @test_throws BoundsError x[7]

        @test x[1,1] === x.pool.valindex[1]
        @test x[2,1] === x.pool.valindex[2]
        @test x[1,2] === missing
        @test x[2,2] === x.pool.valindex[1]
        @test x[1,3] === x.pool.valindex[3]
        @test x[2,3] === missing
        @test_throws BoundsError x[1,4]
        @test_throws BoundsError x[4,1]
        @test_throws BoundsError x[4,4]

        x2 = x[1:2,:]
        @test typeof(x2) === typeof(x)
        @test x2 ≅ x
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[:,[1, 3]]
        @test typeof(x2) === typeof(x)
        @test x2 ≅ ["a" "c"; "b" missing]
        @test levels(x2) == levels(x)
        @test levels(x2) !== levels(x)
        @test isordered(x2) == isordered(x)

        x2 = x[1:1,2]
        @test isa(x2, CategoricalVector{Union{String, Missing}, R})
        @test x2 ≅ [missing]
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
        @test x[3] === missing
        @test x[4] === x.pool.valindex[1]
        @test x[5] === x.pool.valindex[3]
        @test x[6] === missing
        @test levels(x) == ["a", "b", "c", "z"]

        x[1,:] = "a"
        @test x[1] === x.pool.valindex[1]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[1]
        @test x[4] === x.pool.valindex[1]
        @test x[5] === x.pool.valindex[1]
        @test x[6] === missing
        @test levels(x) == ["a", "b", "c", "z"]

        x[1,1:2] = "z"
        @test x[1] === x.pool.valindex[4]
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[4]
        @test x[4] === x.pool.valindex[1]
        @test x[5] === x.pool.valindex[1]
        @test x[6] === missing
        @test levels(x) == ["a", "b", "c", "z"]

        x[1] = missing
        @test x[1] === missing
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[4]
        @test x[4] === x.pool.valindex[1]
        @test x[5] === x.pool.valindex[1]
        @test x[6] === missing
        @test levels(x) == ["a", "b", "c", "z"]

        x[1,1:2] = missing
        @test x[1] === missing
        @test x[2] === x.pool.valindex[2]
        @test x[3] === missing
        @test x[4] === x.pool.valindex[1]
        @test x[5] === x.pool.valindex[1]
        @test x[6] === missing
        @test levels(x) == ["a", "b", "c", "z"]

        x[:,2] = missing
        @test x[1] === missing
        @test x[2] === x.pool.valindex[2]
        @test x[3] === missing
        @test x[4] === missing
        @test x[5] === x.pool.valindex[1]
        @test x[6] === missing
        @test levels(x) == ["a", "b", "c", "z"]

        x[1,2] = "a"
        @test x[1] === missing
        @test x[2] === x.pool.valindex[2]
        @test x[3] === x.pool.valindex[1]
        @test x[4] === missing
        @test x[5] === x.pool.valindex[1]
        @test x[6] === missing
        @test levels(x) == ["a", "b", "c", "z"]

        x[2,1] = missing
        @test x[1] === missing
        @test x[2] === missing
        @test x[3] === x.pool.valindex[1]
        @test x[4] === missing
        @test x[5] === x.pool.valindex[1]
        @test x[6] === missing
        @test levels(x) == ["a", "b", "c", "z"]
        end

        # Uninitialized array
        v = Any[CategoricalArray{Union{String, Missing}}(2, ordered=ordered),
                CategoricalArray{Union{String, Missing}, 1}(2, ordered=ordered),
                CategoricalArray{Union{String, Missing}, 1, R}(2, ordered=ordered),
                CategoricalVector{Union{String, Missing}}(2, ordered=ordered),
                CategoricalVector{Union{String, Missing}, R}(2, ordered=ordered),
                CategoricalArray{Union{String, Missing}}(2, 3, ordered=ordered),
                CategoricalArray{Union{String, Missing}, 2}(2, 3, ordered=ordered),
                CategoricalArray{Union{String, Missing}, 2, R}(2, 3, ordered=ordered),
                CategoricalMatrix{Union{String, Missing}}(2, 3, ordered=ordered),
                CategoricalMatrix{Union{String, Missing}, R}(2, 3, ordered=ordered)]

        @testset "Uninitialized $(typeof(x))" for x in v
        @test isordered(x) === ordered
        @test ismissing(x[1])
        @test ismissing(x[2])
        @test levels(x) == []

        x2 = compress(x)
        @test x2 ≅ x
        @test isa(x2, CategoricalArray{Union{leveltype(x), Missing}, ndims(x), UInt8})
        @test isordered(x2) === isordered(x)
        @test levels(x2) == []

        x2 = copy(x)
        @test x2 ≅ x
        @test typeof(x2) === typeof(x)
        @test isordered(x2) === isordered(x)
        @test levels(x2) == []

        x[1] = "c"
        @test x[1] === x.pool.valindex[1]
        @test ismissing(x[2])
        @test levels(x) == ["c"]

        x[1] = "a"
        @test x[1] === x.pool.valindex[2]
        @test ismissing(x[2])
        @test levels(x) == ["c", "a"]

        x[2] = missing
        @test x[1] === x.pool.valindex[2]
        @test x[2] === missing
        @test levels(x) == ["c", "a"]

        x[1] = "b"
        @test x[1] === x.pool.valindex[3]
        @test x[2] === missing
        @test levels(x) == ["c", "a", "b"]
        end
    end
end

@testset "vcat with missings" begin
    ca1 = CategoricalArray(["a", missing])
    ca2 = CategoricalArray([missing, "a"])
    r = vcat(ca1, ca2)
    @test r ≅ CategoricalArray(["a", missing, missing, "a"])
    @test levels(r) == ["a"]
    @test !isordered(r)
    ordered!(ca1,true)
    @test !isordered(vcat(ca1, ca2))
    ordered!(ca2,true)
    @test isordered(vcat(ca1, ca2))
    ordered!(ca1,false)
    @test !isordered(vcat(ca1, ca2))
end

@testset "vcat with all missings" begin
    ca1 = CategoricalArray(["a", missing])
    ca2 = CategoricalArray([missing, missing])
    r = vcat(ca1, ca2)
    @test r ≅ ["a", missing, missing, missing]
    @test levels(r) == ["a"]
    @test !isordered(r)

    @testset "preserves isordered" begin
    # needed for instance when expanding an array with missings
    # such as vcat of DataFrame with missing columns
    ordered!(ca1, true)
    @test isempty(levels(ca2))
    r = vcat(ca1, ca2)
    @test isordered(r)
    end
end

@testset "vcat with all empty array" begin
    ca1 = CategoricalArray(0)
    ca2 = CategoricalArray([missing, "b"])
    r = vcat(ca1, ca2)
    @test r ≅ [missing, "b"]
    @test levels(r) == ["b"]
    @test !isordered(r)
end

@testset "vcat with all missings and empty" begin
    ca1 = CategoricalArray(0)
    ca2 = CategoricalArray([missing, missing])
    r = vcat(ca1, ca2)
    @test r ≅ [missing, missing]
    @test levels(r) == String[]
    @test !isordered(r)

    ordered!(ca1, true)
    @test isempty(levels(ca2))
    r = vcat(ca1, ca2)
    @test isordered(r)

    ca1 = CategoricalArray(["a", missing])
    ca2 = CategoricalArray{Union{String, Missing}}(2)
    ordered!(ca1, true)
    @test isempty(levels(ca2))
    r = vcat(ca1, ca2)
    @test r ≅ ["a", missing, missing, missing]
    @test isordered(r)
end

@testset "unique() and levels()" begin
    x = CategoricalArray(["Old", "Young", "Middle", missing, "Young"])
    @test levels(x) == ["Middle", "Old", "Young"]
    @test unique(x) ≅ ["Middle", "Old", "Young", missing]
    @test levels!(x, ["Young", "Middle", "Old"]) === x
    @test levels(x) == ["Young", "Middle", "Old"]
    @test unique(x) ≅ ["Young", "Middle", "Old", missing]
    @test levels!(x, ["Young", "Middle", "Old", "Unused"]) === x
    @test levels(x) == ["Young", "Middle", "Old", "Unused"]
    @test unique(x) ≅ ["Young", "Middle", "Old", missing]
    @test levels!(x, ["Unused1", "Young", "Middle", "Old", "Unused2"]) === x
    @test levels(x) == ["Unused1", "Young", "Middle", "Old", "Unused2"]
    @test unique(x) ≅["Young", "Middle", "Old", missing]

    x = CategoricalArray((Union{String, Missing})[missing])
    @test isa(levels(x), Vector{String}) && isempty(levels(x))
    @test unique(x) ≅ [missing]
    @test levels!(x, ["Young", "Middle", "Old"]) === x
    @test levels(x) == ["Young", "Middle", "Old"]
    @test unique(x) ≅ [missing]

    # To test short-circuit after 1000 elements
    x = CategoricalArray{Union{Int, Missing}}(repeat(1:1500, inner=10))
    @test levels(x) == collect(1:1500)
    @test unique(x) == collect(1:1500)
    @test levels!(x, [1600:-1:1; 2000]) === x
    x[3] = missing
    @test levels(x) == [1600:-1:1; 2000]
    @test unique(x) ≅ [1500:-1:3; 2; 1; missing]

    # in
    x = CategoricalArray{Int}(repeat(1:1500, inner=10))
    @test !(missing in x)

    x = CategoricalArray{Union{Int, Missing}}(repeat(1:1500, inner=10))
    x[1] = missing
    @test missing in x
end

@testset "Missings.replace should work on CategoricalArrays" begin
    x = categorical(["a", "b", missing, "a"])
    y = ["a", "b", "", "a"]
    r = Missings.replace(x, "")
    @test isa(r, Missings.EachReplaceMissing)
    a = collect(r)
    @test isa(a, CategoricalVector{String})
    @test y == a
    @test levels(x) == ["a", "b"]
    @test levels(a) == ["a", "b", ""]

    r = Missings.replace(x, "b")
    y = ["a", "b", "b", "a"]
    @test isa(r, Missings.EachReplaceMissing)
    a = collect(r)
    @test isa(a, CategoricalVector{String})
    @test y == a
    @test levels(x) == ["a", "b"]
    @test levels(a) == ["a", "b"]

    @test_throws MethodError Missings.replace(x, 1)
end

@testset "Missings.replace should work on CategoricalArrays without missing values" begin
    x = categorical(["a", "b", "", "a"])
    y = ["a", "b", "", "a"]
    r = Missings.replace(x, "dummy")
    @test isa(r, Missings.EachReplaceMissing)
    a = collect(r)
    @test isa(a, CategoricalVector{String})
    @test y == a
    @test levels(x) == ["", "a", "b"]
    @test levels(a) == ["", "a", "b", "dummy"]

    r = Missings.replace(x, "")
    @test isa(r, Missings.EachReplaceMissing)
    a = collect(r)
    @test isa(a, CategoricalVector{String})
    @test y == a
    @test levels(x) == ["", "a", "b"]
    @test levels(a) == ["", "a", "b"]
end

@testset "Missings.replace should work on CategoricalArrays with empty pools" begin
    x = categorical(Union{String,Missing}[missing])
    y = [""]
    r = Missings.replace(x, "")
    @test isa(r, Missings.EachReplaceMissing)
    a = collect(r)
    @test isa(a, CategoricalVector{String})
    @test y == a
end

@testset "Missings.replace should work on empty CategoricalArrays" begin
    x = categorical(Union{String,Missing}[])
    y = String[]
    r = Missings.replace(x, "")
    @test isa(r, Missings.EachReplaceMissing)
    a = collect(r)
    @test isa(a, CategoricalVector{String})
    @test y == a
end

end
