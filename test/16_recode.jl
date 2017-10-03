module TestRecode
    using Base.Test
    using CategoricalArrays
    using CategoricalArrays: DefaultRefType
    using Nulls

    const ≅ = isequal

    ## Test recode!, used by recode

    # Test both recoding into x itself and into an uninitialized vector
    # (since for CategoricalVectors possible bugs can happen when working in-place)

    # Recoding from Int to Int
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10)),
        y in (similar(x), Array{Int}(size(x)),
              CategoricalArray{Int}(size(x)), CategoricalArray{Union{Int, Null}}(size(x)), x)
        z = @inferred recode!(y, x, 1=>100, 2:4=>0, [5; 9:10]=>-1)
        @test y === z
        @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
        if isa(y, CategoricalArray)
            @test levels(y) == [6, 7, 8, 100, 0, -1]
            @test !isordered(y)
        end
    end

    # Recoding from Int to Int with duplicate recoded values
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10)),
        y in (similar(x), Array{Int}(size(x)),
              CategoricalArray{Int}(size(x)), CategoricalArray{Union{Int, Null}}(size(x)), x)
        z = @inferred recode!(y, x, 1=>100, 2:4=>100, [5; 9:10]=>-1)
        @test y === z
        @test y == [100, 100, 100, 100, -1, 6, 7, 8, -1, -1]
        if isa(y, CategoricalArray)
            @test levels(y) == [6, 7, 8, 100, -1]
            @test !isordered(y)
        end
    end

    # Recoding from Int to Int with unused level
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10)),
        y in (similar(x), Array{Int}(size(x)),
              CategoricalArray{Int}(size(x)), CategoricalArray{Union{Int, Null}}(size(x)), x)
        z = @inferred recode!(y, x, 1=>100, 2:4=>0, [5; 9:10]=>-1, 100=>1)
        @test y === z
        @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
        if isa(y, CategoricalArray)
            @test levels(y) == [6, 7, 8, 100, 0, -1, 1]
            @test !isordered(y)
        end
    end

    # Recoding from Int to Int with duplicate default
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10)),
        y in (similar(x), Array{Int}(size(x)),
              CategoricalArray{Int}(size(x)), CategoricalArray{Union{Int, Null}}(size(x)), x)
        z = @inferred recode!(y, x, 100, 1=>100, 2:4=>100, [5; 9:10]=>-1)
        @test y === z
        @test y == [100, 100, 100, 100, -1, 100, 100, 100, -1, -1]
        if isa(y, CategoricalArray)
            @test levels(y) == [100, -1]
            @test !isordered(y)
        end
    end

    # Recoding from Int to Int, with default
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10)),
        y in (similar(x), Array{Int}(size(x)),
              CategoricalArray{Int}(size(x)), CategoricalArray{Union{Int, Null}}(size(x)), x)
        z = @inferred recode!(y, x, -10, 1=>100, 2:4=>0, [5; 9:10]=>-1)
        @test y === z
        @test y == [100, 0, 0, 0, -1, -10, -10, -10, -1, -1]
        if isa(y, CategoricalArray)
            @test levels(y) == [100, 0, -1, -10]
            @test !isordered(y)
        end
    end

    # Recoding from Int to Int, with a first value being Float64
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10)),
        y in (similar(x), Array{Int}(size(x)),
              CategoricalArray{Int}(size(x)), CategoricalArray{Union{Int, Null}}(size(x)), x)
        z = @inferred recode!(y, x, 1.0=>100, 2:4=>0, [5; 9:10]=>-1)
        @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
        if isa(y, CategoricalArray)
            @test levels(y) == [6, 7, 8, 100, 0, -1]
            @test !isordered(y)
        end
    end

    # Recoding from Int to Int with overlapping pairs
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10)),
        y in (similar(x), Array{Int}(size(x)),
              CategoricalArray{Int}(size(x)), CategoricalArray{Union{Int, Null}}(size(x)), x)
        z = @inferred recode!(y, x, 1=>100, 2:4=>0, [5; 9:10]=>-1, 1:10=>0)
        @test y === z
        @test y == [100, 0, 0, 0, -1, 0, 0, 0, -1, -1]
        if isa(y, CategoricalArray)
            @test levels(y) == [100, 0, -1]
            @test !isordered(y)
        end
    end

    # Recoding from Int to Int, with changes to levels order
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10)),
        y in (similar(x), Array{Int}(size(x)),
              CategoricalArray{Int}(size(x)), CategoricalArray{Union{Int, Null}}(size(x)), x)
        z = @inferred recode!(y, x, 1=>100, 2:4=>0, [5; 9:10]=>-1)
        @test y === z
        @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
        if isa(y, CategoricalArray)
            @test levels(y) == [6, 7, 8, 100, 0, -1]
            @test !isordered(y)
        end
    end

    # Recoding nullable array to non-nullable categorical array: check that error is thrown
    for x in (["a", null, "c", "d"], CategoricalArray(["a", null, "c", "d"]))
        y = Vector{String}(4)
        @test_throws MethodError recode!(y, x, "a", "c"=>"b")

        y = CategoricalVector{String}(4)
        @test_throws NullException recode!(y, x, "a", "c"=>"b")
    end

    # Recoding nullable array with null value and default
    for x in (["a", null, "c", "d"], CategoricalArray(["a", null, "c", "d"])),
        y in (similar(x), Array{Union{String, Null}}(size(x)),
              CategoricalArray{Union{String, Null}}(size(x)), x)
        z = @inferred recode!(y, x, "a", "c"=>"b")
        @test y === z
        @test y ≅ ["a", null, "b", "a"]
        if isa(y, CategoricalArray)
            @test levels(y) == ["b", "a"]
            @test !isordered(y)
        end
    end

    # Recoding nullable array with null value and no default
    for x in (["a", null, "c", "d"], CategoricalArray(["a", null, "c", "d"])),
        y in (similar(x), Array{Union{String, Null}}(size(x)),
              CategoricalArray{Union{String, Null}}(size(x)), x)
        z = @inferred recode!(y, x, "c"=>"b")
        @test y === z
        @test y ≅ ["a", null, "b", "d"]
        if isa(y, CategoricalArray)
            @test levels(y) == ["a", "d", "b"]
            @test !isordered(y)
        end
    end

    # Recoding nullable array with null value, no default and with null as a key pair
    for x in (["a", null, "c", "d"], CategoricalArray(["a", null, "c", "d"])),
        y in (similar(x), Array{Union{String, Null}}(size(x)),
              CategoricalArray{Union{String, Null}}(size(x)), x)
        z = @inferred recode!(y, x, "a", "c"=>"b", null=>"d")
        @test y === z
        @test y == ["a", "d", "b", "a"]
        if isa(y, CategoricalArray)
            @test levels(y) == ["b", "d", "a"]
            @test !isordered(y)
        end
    end

    # Recoding nullable array with null value, no default and with null as a key pair
    for x in (["a", null, "c", "d"], CategoricalArray(["a", null, "c", "d"])),
        y in (similar(x), Array{Union{String, Null}}(size(x)),
              CategoricalArray{Union{String, Null}}(size(x)), x)
        z = @inferred recode!(y, x, "c"=>"b", null=>"d")
        @test y === z
        @test y == ["a", "d", "b", "d"]
        if isa(y, CategoricalArray)
            @test levels(y) == ["a", "b", "d"]
            @test !isordered(y)
        end
    end

    # Recoding into array with incompatible size
    for x in (["a", null, "c", "d"], CategoricalArray(["a", null, "c", "d"])),
        y in (similar(x, 0), Array{Union{String, Null}}(0),
              CategoricalArray{Union{String, Null}}(0))
        @test_throws DimensionMismatch recode!(y, x, "c"=>"b", null=>"d")
    end

    # Recoding into array with incompatible element type
    for x in ([1:10;], CategoricalArray(1:10)),
        y in (similar(x, String), Array{String}(size(x)), CategoricalArray{String}(size(x)))
        @test_throws ArgumentError recode!(y, x, 1=>"a", 2:4=>"b", [5; 9:10]=>"c")
    end
    for x in ((Union{Int, Null})[1:10;], CategoricalArray{Union{Int, Null}}(1:10)),
        y in (similar(x), Array{Union{Int, Null}}(size(x)), CategoricalArray{Union{Int, Null}}(size(x)))
        res = @test_throws MethodError recode!(y, x, 1=>"a", 2:4=>"b", [5; 9:10]=>"c")
    end


    ## Test in-place recode!()

    # Recoding from Int to Int without default
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10))
        z = @inferred recode!(x, 1=>100, 2:4=>0, [5; 9:10]=>-1)
        @test x === z
        @test x == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
        if isa(x, CategoricalArray)
            @test levels(x) == [6, 7, 8, 100, 0, -1]
            @test !isordered(x)
        end
    end

    # Recoding from Int to Int with default
    for x in ([1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10))
        z = @inferred recode!(x, 1, 1=>100, 2:4=>0, [5; 9:10]=>-1)
        @test x === z
        @test x == [100, 0, 0, 0, -1, 1, 1, 1, -1, -1]
        if isa(x, CategoricalArray)
            @test levels(x) == [100, 0, -1, 1]
            @test !isordered(x)
        end
    end


    ## Test recode() promotion

    for x in (1:10, [1:10;], CategoricalArray(1:10), CategoricalArray{Union{Int, Null}}(1:10))
        T = eltype(x) >: Null ? Null : Union{}

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

        # Recoding from Int to Any
        y = @inferred recode(x, 1=>"a", 2:4=>0, [5; 9:10]=>-1)
        @test y == ["a", 0, 0, 0, -1, 6, 7, 8, -1, -1]
        if isa(x, CategoricalArray)
            @test isa(y, CategoricalVector{Any, DefaultRefType})
            @test levels(y) == [6, 7, 8, "a", 0, -1]
            @test !isordered(y)
        else
            @test typeof(y) === Vector{Any}
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

        # Recoding from Int to Int/String (i.e. Any), with default String and other values Int
        y = @inferred recode(x, "x", 1=>100, 2:4=>0, [5; 9:10]=>-1)
        @test y == [100, 0, 0, 0, -1, "x", "x", "x", -1, -1]
        if isa(x, CategoricalArray)
            @test isa(y, CategoricalVector{Any, DefaultRefType})
            @test levels(y) == [100, 0, -1, "x"]
            @test !isordered(y)
        else
            @test typeof(y) === Vector{Any}
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

        # Recoding from Int to Union{Int, Null} with null default
        y = @inferred recode(x, null, 1=>100, 2:4=>0, [5; 9:10]=>-1)
        @test y ≅ [100, 0, 0, 0, -1, null, null, null, -1, -1]
        if isa(x, CategoricalArray)
            @test isa(y, CategoricalVector{Union{Int, Null}, DefaultRefType})
            @test levels(y) == [100, 0, -1]
            @test !isordered(y)
        else
            @test typeof(y) === Vector{Union{Int, Null}}
        end

        # Recoding from Int to Union{Int, Null} with null RHS
        y = @inferred recode(x, 1=>null, 2:4=>0, [5; 9:10]=>-1)
        @test y ≅ [null, 0, 0, 0, -1, 6, 7, 8, -1, -1]
        if isa(x, CategoricalArray)
            @test isa(y, CategoricalVector{Union{Int, Null}, DefaultRefType})
            @test levels(y) == [6, 7, 8, 0, -1]
            @test !isordered(y)
        else
            @test typeof(y) === Vector{Union{Int, Null}}
        end
    end

    for x in (["a", "c", "b", "a"], CategoricalArray(["a", "c", "b", "a"]))
        # Recoding from String to String
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

    for x in (['a' 'c'; 'b' 'a'], CategoricalArray(['a' 'c'; 'b' 'a']))
        # Recoding a Matrix
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

    for x in (10:-1:1, CategoricalArray(10:-1:1))
        # Recoding from Int to Int/String (i.e. Any), with index and levels in different orders
        y = @inferred recode(x, 0, 1=>"a", 2:4=>"c", [5; 9:10]=>"b")
        @test y == ["b", "b", 0, 0, 0, "b", "c", "c", "c", "a"]
        if isa(x, CategoricalArray)
            @test isa(y, CategoricalVector{Any, DefaultRefType})
            @test levels(y) == ["a", "c", "b", 0]
            @test !isordered(y)
        else
            @test typeof(y) === Vector{Any}
        end

        # Recoding from Int to String via default, with index and levels in different orders
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

    # Recoding CategoricalArray with custom reftype
    x = CategoricalVector{Int, UInt8}(1:10)
    y = @inferred recode(x, 1=>100, 2:4=>0, [5; 9:10]=>-1)
    @test y == [100, 0, 0, 0, -1, 6, 7, 8, -1, -1]
    @test isa(y, CategoricalVector{Int, UInt8})
    @test levels(y) == [6, 7, 8, 100, 0, -1]
    @test !isordered(y)

    # Recoding ordered CategoricalArray and merging two categories
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "c"=>"a")
    @test y == ["a", "a", "b", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["a", "b"]
    @test isordered(y)

    # Recoding ordered CategoricalArray and merging one category into another (contd.)
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "b"=>"c")
    @test y == ["a", "c", "c", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["a", "c"]
    @test isordered(y)

    # Recoding ordered CategoricalArray with new level which cannot be ordered
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "b"=>"d")
    @test y == ["a", "c", "d", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["a", "c", "d"]
    @test !isordered(y)

    # Recoding ordered CategoricalArray with conflicting orders
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "b"=>"b", "a"=>"a")
    @test y == ["a", "c", "b", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["c", "b", "a"]
    @test !isordered(y)

    # Recoding ordered CategoricalArray with default already in levels
    x = CategoricalArray(["a", "c", "b", "a"])
    ordered!(x, true)
    y = @inferred recode(x, "a", "c"=>"b")
    @test y == ["a", "b", "a", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["b", "a"]
    @test !isordered(y)

    # Recoding ordered CategoricalArray with default not in levels
    x = CategoricalArray(["d", "c", "b", "d"])
    ordered!(x, true)
    y = @inferred recode(x, "a", "c"=>"b")
    @test y == ["a", "b", "a", "a"]
    @test isa(y, CategoricalVector{String, DefaultRefType})
    @test levels(y) == ["b", "a"]
    @test !isordered(y)

    # Recoding nullable CategoricalArray with null values and no default
    x = CategoricalArray{Union{String, Null}}(["a", "b", "c", "d"])
    x[2] = null
    y = @inferred recode(x, "c"=>"b")
    @test y ≅ ["a", null, "b", "d"]
    @test isa(y, CategoricalVector{Union{String, Null}, DefaultRefType})
    @test levels(y) == ["a", "b", "d"]
    @test !isordered(y)

    # Recoding nullable CategoricalArray with null values and non-null default
    x = CategoricalArray{Union{String, Null}}(["a", "b", "c", "d"])
    x[2] = null
    y = @inferred recode(x, "a", "c"=>"b")
    @test y ≅ ["a", null, "b", "a"]
    @test isa(y, CategoricalVector{Union{String, Null}, DefaultRefType})
    @test levels(y) == ["b", "a"]
    @test !isordered(y)
end
