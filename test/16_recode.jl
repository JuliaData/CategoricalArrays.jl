module TestRecode
using Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType

if VERSION < v"0.7.0-"
    using CategoricalArrays: replace!
end

const ≅ = isequal

@testset "recode_in" begin
    @testset "collection is a string" begin
        @test !CategoricalArrays.recode_in("a", "ab")
        @test CategoricalArrays.recode_in('a', "ab")
        @test !CategoricalArrays.recode_in('c', "ab")
        @test !CategoricalArrays.recode_in(missing, "b")
    end
    @testset "collection without missing" begin
        @test CategoricalArrays.recode_in(1, [1, 2])
        @test !CategoricalArrays.recode_in(1, [2, 3])
    end
    @testset "collection with missing" begin
        @test CategoricalArrays.recode_in(1, [1, 2, missing])
        @test !CategoricalArrays.recode_in(1, [2, missing])
        @test CategoricalArrays.recode_in(missing, [1, 2, missing])
    end
    @testset "collection is a single value" begin
        @test CategoricalArrays.recode_in(1, 1)
        @test !CategoricalArrays.recode_in(1, missing)
        @test !CategoricalArrays.recode_in(missing, missing)
    end
    @testset "tuple without missing" begin
        @test CategoricalArrays.recode_in(1, (1, 2))
        @test !CategoricalArrays.recode_in(1, (2, 3))
    end
    @testset "tuple with missing" begin
        @test CategoricalArrays.recode_in(1, (1, 2, missing))
        @test !CategoricalArrays.recode_in(1, (2, missing))
        @test CategoricalArrays.recode_in(missing, (1, 2, missing))
    end
    @testset "nested arrays" begin
        @test CategoricalArrays.recode_in([1,2], [[1, 2], [3, 4]])
        @test !CategoricalArrays.recode_in([1, 3], [[1, 2], [3, 4]])
    end
    @testset "NaN in array" begin
        @test CategoricalArrays.recode_in(NaN, [1, 2, NaN])
        @test !CategoricalArrays.recode_in(NaN, [1, 2, 3])
        @test CategoricalArrays.recode_in(2, [1, 2, NaN])
        @test !CategoricalArrays.recode_in(3, [1, 2, NaN])
    end
end

## Test recode!, used by recode

# Test both recoding into x itself and into an uninitialized vector
# (since for CategoricalVectors possible bugs can happen when working in-place)

@testset "Recoding from $(typeof(x)) to $(typeof(y))" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Int}(undef, size(x)),
          CategoricalArray{Int}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test y === z
    @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    if isa(y, CategoricalArray)
        @test levels(y) == [6, 7, 8, 100, 0, -1]
        @test !isordered(y)
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(y)) using a Set as the first argument in a pair" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Int}(undef, size(x)),
          CategoricalArray{Int}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, 1=>100, 2:4=>0, Set([5; 9:10])=>-1)
    @test y === z
    @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    if isa(y, CategoricalArray)
        @test levels(y) == [6, 7, 8, 100, 0, -1]
        @test !isordered(y)
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(y)) with duplicate recoded values" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Int}(undef, size(x)),
          CategoricalArray{Int}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, 1=>100, 2:4=>100, [5; 9:10]=>-1)
    @test y === z
    @test y == [100, 100, 100, 100, -1, 6, 7, 8, -1, -1]
    if isa(y, CategoricalArray)
        @test levels(y) == [6, 7, 8, 100, -1]
        @test !isordered(y)
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(y)) with unused level" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Int}(undef, size(x)),
          CategoricalArray{Int}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, 1=>100, 2:4=>0, [5; 9:10]=>-1, 100=>1)
    @test y === z
    @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    if isa(y, CategoricalArray)
        @test levels(y) == [6, 7, 8, 100, 0, -1, 1]
        @test !isordered(y)
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(y)) with duplicate default" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Int}(undef, size(x)),
          CategoricalArray{Int}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, 100, 1=>100, 2:4=>100, [5; 9:10]=>-1)
    @test y === z
    @test y == [100, 100, 100, 100, -1, 100, 100, 100, -1, -1]
    if isa(y, CategoricalArray)
        @test levels(y) == [100, -1]
        @test !isordered(y)
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(y)) with default" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Int}(undef, size(x)),
          CategoricalArray{Int}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, -10, 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test y === z
    @test y == [100, 0, 0, 0, -1, -10, -10, -10, -1, -1]
    if isa(y, CategoricalArray)
        @test levels(y) == [100, 0, -1, -10]
        @test !isordered(y)
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(y)) with first value being Float64" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Int}(undef, size(x)),
          CategoricalArray{Int}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, 1.0=>100, 2:4=>0, [5; 9:10]=>-1)
    @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    if isa(y, CategoricalArray)
        @test levels(y) == [6, 7, 8, 100, 0, -1]
        @test !isordered(y)
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(y)) with overlapping pairs" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Int}(undef, size(x)),
          CategoricalArray{Int}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, 1=>100, 2:4=>0, [5; 9:10]=>-1, 1:10=>0)
    @test y === z
    @test y == [100, 0, 0, 0, -1, 0, 0, 0, -1, -1]
    if isa(y, CategoricalArray)
        @test levels(y) == [100, 0, -1]
        @test !isordered(y)
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(y)) with changes to levels order" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Int}(undef, size(x)),
          CategoricalArray{Int}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test y === z
    @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    if isa(y, CategoricalArray)
        @test levels(y) == [6, 7, 8, 100, 0, -1]
        @test !isordered(y)
    end
end

@testset "Recoding from $(typeof(x)) to categorical array with missing values" for
    x in (["a", missing, "c", "d"], CategoricalArray(["a", missing, "c", "d"]))

    # check that error is thrown
    y = Vector{String}(undef, 4)
    @test_throws MissingException recode!(y, x, "a", "c"=>"b")

    y = CategoricalVector{String}(undef, 4)
    @test_throws MissingException recode!(y, x, "a", "c"=>"b")
end

@testset "Recoding array with missings and default from $(typeof(x)) to $(typeof(y))" for
    x in (["a", missing, "c", "d"], CategoricalArray(["a", missing, "c", "d"])),
    y in (similar(x), Array{Union{String, Missing}}(undef, size(x)),
          CategoricalArray{Union{String, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, "a", "c"=>"b")
    @test y === z
    @test y ≅ ["a", missing, "b", "a"]
    if isa(y, CategoricalArray)
        @test levels(y) == ["b", "a"]
        @test !isordered(y)
    end
end

@testset "Recoding array with missings and no default from $(typeof(x)) to $(typeof(y))" for
    x in (["a", missing, "c", "d"], CategoricalArray(["a", missing, "c", "d"])),
    y in (similar(x), Array{Union{String, Missing}}(undef, size(x)),
          CategoricalArray{Union{String, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, "c"=>"b")
    @test y === z
    @test y ≅ ["a", missing, "b", "d"]
    if isa(y, CategoricalArray)
        @test levels(y) == ["a", "d", "b"]
        @test !isordered(y)
    end
end

@testset "Collection in LHS recoding array with missings and no default from $(typeof(x)) to $(typeof(y))" for
    x in (["1", missing, "3", "4", "5"], CategoricalArray(["1", missing, "3", "4", "5"])),
    y in (similar(x), Array{Union{String, Missing}}(undef, size(x)),
          CategoricalArray{Union{String, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, ["3","4"]=>"2")
    @test y === z
    @test y ≅ ["1", missing, "2", "2", "5"]
    if isa(y, CategoricalArray)
        @test levels(y) == ["1", "5", "2"]
        @test !isordered(y)
    end
end

@testset "Recoding array with missings, default and with missing as a key pair from $(typeof(x)) to $(typeof(y))" for
    x in (["a", missing, "c", "d"], CategoricalArray(["a", missing, "c", "d"])),
    y in (similar(x), Array{Union{String, Missing}}(undef, size(x)),
          CategoricalArray{Union{String, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, "a", "c"=>"b", missing=>"d")
    @test y === z
    @test y == ["a", "d", "b", "a"]
    if isa(y, CategoricalArray)
        @test levels(y) == ["b", "d", "a"]
        @test !isordered(y)
    end
end

@testset "Collection with missing in LHS recoding array with missings, default from $(typeof(x)) to $(typeof(y))" for
    x in (["a", missing, "c", "d"], CategoricalArray(["a", missing, "c", "d"])),
    y in (similar(x), Array{Union{String, Missing}}(undef, size(x)),
          CategoricalArray{Union{String, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, "a", [missing, "c"]=>"b")
    @test y === z
    @test y == ["a", "b", "b", "a"]
    if isa(y, CategoricalArray)
        @test levels(y) == ["b", "a"]
        @test !isordered(y)
    end
end

@testset "Recoding array with missings, no default and with missing as a key pair from $(typeof(x)) to $(typeof(y))" for
    x in (["a", missing, "c", "d"], CategoricalArray(["a", missing, "c", "d"])),
    y in (similar(x), Array{Union{String, Missing}}(undef, size(x)),
          CategoricalArray{Union{String, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, "c"=>"b", missing=>"d")
    @test y === z
    @test y == ["a", "d", "b", "d"]
    if isa(y, CategoricalArray)
        @test levels(y) == ["a", "b", "d"]
        @test !isordered(y)
    end
end

@testset "Collection with missing in LHS recoding array with missings, no default from $(typeof(x)) to $(typeof(y))" for
    x in (["a", missing, "c", "d"], CategoricalArray(["a", missing, "c", "d"])),
    y in (similar(x), Array{Union{String, Missing}}(undef, size(x)),
          CategoricalArray{Union{String, Missing}}(undef, size(x)), x)

    z = @inferred recode!(y, x, ["c", missing]=>"b")
    @test y === z
    @test y == ["a", "b", "b", "d"]
    if isa(y, CategoricalArray)
        @test levels(y) == ["a", "d", "b"]
        @test !isordered(y)
    end
end

@testset "Recoding into an array of incompatible size from $(typeof(x)) to $(typeof(y))" for
    x in (["a", missing, "c", "d"], CategoricalArray(["a", missing, "c", "d"])),
    y in (similar(x, 0), Array{Union{String, Missing}}(undef, 0),
          CategoricalArray{Union{String, Missing}}(undef, 0))

    @test_throws DimensionMismatch recode!(y, x, "c"=>"b", missing=>"d")
end

@testset "Recoding into an array with incompatible eltype from $(typeof(x)) to $(typeof(y))" for
    x in ([1:10;], CategoricalArray(1:10)),
    y in (similar(x, String), Array{String}(undef, size(x)),
          CategoricalArray{String}(undef, size(x)))

    @test_throws ArgumentError recode!(y, x, 1=>"a", 2:4=>"b", [5; 9:10]=>"c")
end

@testset "Recoding into an array with incompatible eltype from $(typeof(x)) to $(typeof(y))" for
    x in ((Union{Int, Missing})[1:10;], CategoricalArray{Union{Int, Missing}}(1:10)),
    y in (similar(x), Array{Union{Int, Missing}}(undef, size(x)),
          CategoricalArray{Union{Int, Missing}}(undef, size(x)))

    @test_throws MethodError recode!(y, x, 1=>"a", 2:4=>"b", [5; 9:10]=>"c")
end

## Test in-place recode!()

@testset "Recoding from $(typeof(x)) to $(typeof(x)) without default" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10))

    z = @inferred recode!(x, 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test x === z
    @test x == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    if isa(x, CategoricalArray)
        @test levels(x) == [6, 7, 8, 100, 0, -1]
        @test !isordered(x)
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(x)) without default" for
    x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10))

    z = @inferred recode!(x, 1, 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test x === z
    @test x == [100, 0, 0, 0, -1, 1, 1, 1, -1, -1]
    if isa(x, CategoricalArray)
        @test levels(x) == [100, 0, -1, 1]
        @test !isordered(x)
    end
end

@testset "recode() promotion for $(typeof(x))" for
    x in (1:10, [1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Missing}}(1:10))
    T = eltype(x) >: Missing ? Missing : Union{}

    # Recoding from Int to Float64 due to a second value being Float64
    y = @inferred recode(x, 1=>100.0, 2:4=>0, [5; 9:10]=>-1)
    @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{Float64, T}, DefaultRefType})
        @test levels(y) == [6, 7, 8, 100, 0, -1]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{Float64, T}}
    end

    # Recoding from Int to Float64, with Float64 default and all other values Int
    y = @inferred recode(x, -10.0, 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test y == [100, 0, 0, 0, -1, -10, -10, -10, -1, -1]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{Float64, T}, DefaultRefType})
        @test levels(y) == [100, 0, -1, -10]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{Float64, T}}
    end

    # Recoding from Int to Union{Int, String}
    y = @inferred recode(x, 1=>"a", 2:4=>0, [5; 9:10]=>-1)
    @test y == ["a", 0, 0, 0, -1, 6, 7, 8, -1, -1]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{Int, String, T}, DefaultRefType})
        @test levels(y) == [6, 7, 8, "a", 0, -1]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{Int, String, T}}
    end

    # Recoding from Int to String, with String default
    y = @inferred recode(x, "d", 1=>"a", 2:4=>"b", [5; 9:10]=>"c")
    @test y == ["a", "b", "b", "b", "c", "d", "d", "d", "c", "c"]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{String, T}, DefaultRefType})
        @test levels(y) == ["a", "b", "c", "d"]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{String, T}}
    end

    # Recoding from Int to String, with all original levels recoded
    y = @inferred recode(x, 1:4=>"a", [5; 9:10]=>"b", 6:8=>"c")
    @test y == ["a", "a", "a", "a", "b", "c", "c", "c", "b", "b"]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{String, T}, DefaultRefType})
        @test levels(y) == ["a", "b", "c"]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{String, T}}
    end

    # Recoding from Int to Union{Int, String}, with default String and other values Int
    y = @inferred recode(x, "x", 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test y == [100, 0, 0, 0, -1, "x", "x", "x", -1, -1]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{Int, String, T}, DefaultRefType})
        @test levels(y) == [100, 0, -1, "x"]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{Int, String, T}}
    end

    # Recoding from Int to Int/String, without any Int value in pairs
    # and keeping some original Int levels
    # This must fail since we cannot take into account original eltype (whether original
    # levels are kept is only known at run time)
    res = @test_throws ArgumentError recode(x, 1=>"a", 2:4=>"b", [5; 9:10]=>"c")
    @test sprint(showerror, res.value) ==
        "ArgumentError: cannot `convert` value 6 (of type $Int) to type of recoded levels ($(Union{String, T})). " *
        "This will happen with recode() when not all original levels are recoded " *
        "(i.e. some are preserved) and their type is incompatible with that of recoded levels."

    # Recoding from Int to Union{Int, Missing} with missing default
    y = @inferred recode(x, missing, 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test y ≅ [100, 0, 0, 0, -1, missing, missing, missing, -1, -1]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{Int, Missing}, DefaultRefType})
        @test levels(y) == [100, 0, -1]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{Int, Missing}}
    end

    # Recoding from Int to Union{Int, Missing} with missing RHS
    y = @inferred recode(x, 1=>missing, 2:4=>0, [5; 9:10]=>-1)
    @test y ≅ [missing, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{Int, Missing}, DefaultRefType})
        @test levels(y) == [6, 7, 8, 0, -1]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{Int, Missing}}
    end

    # Recoding from Int to Union{Int, Missing} with single missing RHS
    y = @inferred recode(x, 1=>missing)
    @test y ≅ [missing, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{Int, Missing}, DefaultRefType})
        @test levels(y) == collect(2:10)
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{Int, Missing}}
    end
end

@testset "Recoding from $(typeof(x)) to $(typeof(x))" for
    x in (["a", "c", "b", "a"], CategoricalArray(["a", "c", "b", "a"]))

    y = @inferred recode(x, "c"=>"x", "b"=>"y", "a"=>"z")
    @test y == ["z", "x", "y", "z"]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{String, DefaultRefType})
        @test levels(y) == ["x", "y", "z"]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{String}
    end
end

@testset "Recoding a matrix $(typeof(x))" for
    x in (['a' 'c'; 'b' 'a'], CategoricalArray(['a' 'c'; 'b' 'a']))

    y = @inferred recode(x, 'c'=>'x', 'b'=>'y', 'a'=>'z')
    @test y == ['z' 'x'; 'y' 'z']
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalMatrix{Char, DefaultRefType})
        @test levels(y) == ['x', 'y', 'z']
        @test !isordered(y)
    else
        @test typeof(y) === Matrix{Char}
    end
end

@testset "Recoding from $(typeof(x)) to Union{Int, String}, with levels in custom order" for
    x in (10:-1:1, CategoricalArray(10:-1:1))

    y = @inferred recode(x, 0, 1=>"a", 2:4=>"c", [5; 9:10]=>"b")
    @test y == ["b", "b", 0, 0, 0, "b", "c", "c", "c", "a"]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{Union{Int, String}, DefaultRefType})
        @test levels(y) == ["a", "c", "b", 0]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{Union{Int, String}}
    end

    # Recoding from Int to String via default, with levels in custom order
    y = @inferred recode(x, "x", 1=>"a", 2:4=>"c", [5; 9:10]=>"b")
    @test y == ["b", "b", "x", "x", "x", "b", "c", "c", "c", "a"]
    if isa(x, CategoricalArray)
        @test isa(y, CategoricalVector{String, DefaultRefType})
        @test levels(y) == ["a", "c", "b", "x"]
        @test !isordered(y)
    else
        @test typeof(y) === Vector{String}
    end
end

@testset "Recoding CategoricalArray with custom reftype" begin
    x = CategoricalVector{Int, UInt8}(1:10)
    y = @inferred recode(x, 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    @test isa(y, CategoricalVector{Int, UInt8})
    @test levels(y) == [6, 7, 8, 100, 0, -1]
    @test !isordered(y)
end

@testset "Recoding ordered CategoricalArray and merging two categories" begin
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "c"=>"a")
    @test y == ["a", "a", "b", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["a", "b"]
    @test isordered(y)
end

@testset "Recoding ordered CategoricalArray and merging one category into another (contd.)" begin
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "b"=>"c")
    @test y == ["a", "c", "c", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["a", "c"]
    @test isordered(y)
end

@testset "Recoding ordered CategoricalArray with new level which cannot be ordered" begin
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "b"=>"d")
    @test y == ["a", "c", "d", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["a", "c", "d"]
    @test !isordered(y)
end

@testset "Recoding ordered CategoricalArray with conflicting orders" begin
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "b"=>"b", "a"=>"a")
    @test y == ["a", "c", "b", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["c", "b", "a"]
    @test !isordered(y)
end

@testset "Recoding ordered CategoricalArray with default already in levels" begin
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "a", "c"=>"b")
    @test y == ["a", "b", "a", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["b", "a"]
    @test !isordered(y)
end

@testset "Recoding ordered CategoricalArray with default not in levels" begin
    x = CategoricalArray(["d", "c", "b", "d"])
    ordered!(x, true)
    y = @inferred recode(x, "a", "c"=>"b")
    @test y == ["a", "b", "a", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["b", "a"]
    @test !isordered(y)
end

@testset "Recoding CategoricalArray with missings and no default" begin
    x = CategoricalArray{Union{String, Missing}}(["a", "b", "c", "d"])
    x[2] = missing
    y = @inferred recode(x, "c"=>"b")
    @test y ≅ ["a", missing, "b", "d"]
    @test isa(y, CategoricalVector{Union{String, Missing}, DefaultRefType})
    @test levels(y) == ["a", "b", "d"]
    @test !isordered(y)
end

@testset "Recoding CategoricalArray with missings and non-missing default" begin
    x = CategoricalArray{Union{String, Missing}}(["a", "b", "c", "d"])
    x[2] = missing
    y = @inferred recode(x, "a", "c"=>"b")
    @test y ≅ ["a", missing, "b", "a"]
    @test isa(y, CategoricalVector{Union{String, Missing}, DefaultRefType})
    @test levels(y) == ["b", "a"]
    @test !isordered(y)
end

@testset "replace with CategoricalArray" begin
    function testf(replacef, T, x::CategoricalArray{S,R}, pairs::Pair...) where {S, R}
        ca = replacef(x, pairs...)
        @test ca isa CategoricalArray{T, R}

        if VERSION >= v"0.7.0-"
            a = replacef(Array(x), pairs...)
            @test ca ≅ a
        end

        ca
    end

    @testset "strings with missings" begin
        x = categorical(["a", "b", missing, "a"])

        testf(replace, String, x, missing => "")
        testf(replace, Union{String, Missing}, x, "b" => "c")
        testf(replace, Union{Int, String, Missing}, x, "a" => 1, "b" => 2)
        testf(replace, Union{Int, String}, x, "a" => 1, "b" => 2, missing => 3)
        y = testf(replace!, Union{String, Missing}, x, "b" => "c")
        @test y === x

        y = testf(replace!, Union{String, Missing}, x, missing => "")
        @test y === x
    end

    @testset "strings without missings" begin
        x = categorical(["a", "b", "", "a"])
        testf(replace, Union{String, Missing}, x, "" => missing)
        @test_throws MethodError replace!(x, "" => missing)

        x = categorical(Union{String, Missing}["a", "b", "", "a"])
        testf(replace!, Union{String, Missing}, x, "" => missing)
    end

    @testset "int to float" begin
        x = categorical([0, 2, 0])

        @testset "replace" begin
            testf(replace, Float64, x, 2 => 1.5, 0 => 0.5)
            testf(replace, Float64, x, 2 => 1.0)
        end

        @testset "replace!" begin
            @test_throws InexactError replace!(x, 2 => 1.5)

            y = testf(replace!, Int, x, 2 => 1.0)
            @test y === x
        end
    end

    @testset "float to int" begin
        x = categorical([0.5, 2.0, 0.5])

        @testset "replace" begin
            testf(replace, Float64, x, 2 => 1)
            testf(replace, Float64, x, 0.5 => 3)
        end

        @testset "replace!" begin
            y = testf(replace!, Float64, x, 2 => 1)
            @test x === y

            y = testf(replace!, Float64, x, 0.5 => 3)
            @test x === x
        end
    end
end

# TODO: move struct definition inside @testset block after 1.6 becomes LTS
struct UnorderedFoo0 <: Number
    a::String
end

@testset "recode AbstractVector with unordered eltype" begin
    x0 = [UnorderedFoo0("s$i") for i in 1:10]
    x = CategoricalArray{UnorderedFoo0}(undef, size(x0))
    recode!(x, x0, UnorderedFoo0("s3") => UnorderedFoo0("xxx"))

    @test x[3] == UnorderedFoo0("xxx")
    @test x[(1:end) .!= 3] == x0[(1:end) .!= 3]
    @test levels(x)[1:(end-1)] == x0[(1:end) .!= 3]

    x = CategoricalArray{UnorderedFoo0}(undef, size(x0))
    Base.isless(::UnorderedFoo0, ::UnorderedFoo0) = throw(ArgumentError("Blah"))
    @test_throws ArgumentError sort(x0)
    @test_throws ArgumentError recode!(x, x0, UnorderedFoo0("s4") => UnorderedFoo0("xxxx"))
end

end
