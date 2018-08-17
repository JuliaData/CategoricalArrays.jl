module TestString
using Compat
using Compat.Test
using Compat.Unicode
using CategoricalArrays

@testset "AbstractString operations on values of CategoricalPool{String}" begin
    pool = CategoricalPool(["", "café"])

    v1 = CategoricalArrays.catvalue(1, pool)
    v2 = CategoricalArrays.catvalue(2, pool)

    @test v1 isa AbstractString
    @test v2 isa AbstractString

    @test typeof(promote("a", v1)) == Tuple{String,String}

    @test String(v1)::String == ""
    @test String(v2)::String == "café"

    @test Symbol(v1) === Symbol("")
    @test Symbol(v2) === :café

    @test v1 == ""
    @test v2 == "café"
    @test v2 != ""

    @test isequal(v1, "")
    @test isequal(v2, "café")
    @test !isequal(v2, "")

    @test isempty(v1)
    @test !isempty(v2)

    @test eltype(v1) === Char
    @test eltype(v2) === Char

    @test length(v1) === 0
    @test length(v2) === 4

    @test sizeof(v1) === 0
    @test sizeof(v2) === 5

    if VERSION >= v"0.7.0-DEV.2949"
        @test_throws BoundsError nextind(v1, 1)
    else
        @test nextind(v1, 1) === 2
    end
    @test nextind(v2, 4) === 6

    @test prevind(v1, 1) === 0
    @test prevind(v2, 6) === 4

    if VERSION >= v"0.7.0-DEV.3583"
        @test firstindex(v1) === 1
        @test firstindex(v2) === 1
    end

    @test lastindex(v1) === 0
    @test lastindex(v2) === 4

    @test collect(v1) == []
    @test collect(v2) == collect("café")

    @test v2[2] === 'a'
    @test v2[4] === 'é'
    @test_throws BoundsError v1[1]
    if VERSION >= v"0.7.0-DEV.2949"
        @test_throws StringIndexError v2[5]
    else
        @test_throws UnicodeError v2[5]
    end

    @test codeunit(v2, 2) === 0x61
    @test codeunit(v2, 5) === 0xa9
    @test_throws BoundsError codeunit(v1, 1)
    @test_throws BoundsError codeunit(v2, 6)

    @test ascii(v1)::String == ""
    @test_throws ArgumentError ascii(v2)

    @test Unicode.normalize(v1) == ""
    @test Unicode.normalize(v2) == "café"
    @test Unicode.normalize(v2, :NFKD) == "café"

    @test isempty(collect(graphemes(v1)))
    @test collect(graphemes(v2)) == collect(graphemes("café"))

    @test isvalid(v1)
    @test isvalid(v2)
    @test !isvalid(v1, 1)
    @test isvalid(v2, 4)
    @test !isvalid(v2, 5)

    if VERSION >= v"0.7.0-DEV.2949"
        @test_throws BoundsError length(v1, 0, 0)
        @test length(v2, 1, 4) === 4

        @test_throws BoundsError nextind(v1, 1, 1)
        @test nextind(v2, 1, 2) === 3
    else
        @test_throws BoundsError ind2chr(v1, 0)
        @test ind2chr(v2, 4) === 4

        @test_throws BoundsError chr2ind(v1, 1)
        @test chr2ind(v2, 2) === 2
    end

    @test string(v1) == ""
    @test string(v2) == "café"
    @test string(v1, "a") == "a"
    @test string(v1, "a", v2) == "acafé"
    @test string(v2, 1) == "café1"

    @test sprint(print, v1) == ""
    @test sprint(print, v2) == "café"

    @test repr(v1) == "\"\""
    @test repr(v2) == "\"café\""

    @test "a" * v1 == "a"
    @test "a" * v1 * "b" == "ab"
    @test "a" * v1 * v2 == "acafé"

    @test v1^1 == ""
    @test v2^1 == "café"
    @test v1^2 == ""
    @test v2^2 == "cafécafé"

    @test repeat(v1, 10) == ""
    @test repeat(v2, 2) == "cafécafé"

    @test isempty(collect(eachmatch(r"af", v1)))
    @test first(eachmatch(r"af", v2)).offset == 2

    @test match(r"af", v1) === nothing
    @test match(r"af", v2).offset === 2
    @test match(r"af", v2, 2).offset === 2
    @test match(r"af", v2, 2, UInt32(0)).offset === 2

    @test collect((m.match for m ∈ eachmatch(r"af", v1))) == []
    @test collect((m.match for m ∈ eachmatch(r"af", v2))) == ["af"]
    if VERSION > v"0.7.0-DEV.3526"
        @test collect((m.match for m ∈ eachmatch(r"af", v2, overlap=true))) == ["af"]
    else
        @test matchall(r"af", v2, overlap=true) == ["af"]
        @test matchall(r"af", v2, true) == ["af"]
    end

    @test lpad(v1, 1) == " "
    @test lpad(v2, 1) == "café"
    @test lpad(v2, 5) == " café"

    @test rpad(v1, 1) == " "
    @test rpad(v2, 1) == "café"
    @test rpad(v2, 5) == "café "

    @test Compat.findfirst("", v1) === 1:0
    @test Compat.findfirst("a", v2) === 2:2
    @test Compat.findfirst(==('a'), v2) === 2
    @test Compat.findnext(==('a'), v2, 3) === nothing

    @test Compat.findlast("a", v1) === nothing
    @test Compat.findlast("a", v2) === 2:2
    @test Compat.findlast(==('a'), v2) === 2
    @test Compat.findprev(==('a'), v2, 1) === nothing

    @test !occursin("a", v1)
    @test occursin("", v1)
    @test occursin("fé", v2)

    @test !occursin(r"af", v1)
    @test occursin(r"af", v2)

    @test startswith(v1, "")
    @test !startswith(v1, "a")
    @test startswith(v2, "caf")

    @test endswith(v1, "")
    @test !endswith(v1, "a")
    @test endswith(v2, "fé")

    @test reverse(v1) == ""
    @test reverse(v2) == "éfac"

    @test replace(v1, "a"=>"b") == ""
    @test replace(v2, 'a'=>'b') == "cbfé"
    @test replace(v2, "ca"=>"b", count=1) == "bfé"

    @test isempty(split(v1))
    @test split(v1, "a") == [""]
    @test split(v2) == ["café"]
    @test split(v2, "f") == ["ca", "é"]

    @test rsplit(v1, "a") == [""]
    @test rsplit(v2, "f") == ["ca", "é"]

    @test strip(v1) == ""
    @test strip(v2) == v2
    @test strip(v2, 'é') == "caf"

    @test lstrip(v1) == ""
    @test lstrip(v2) == v2
    @test lstrip(v2, 'é') == "café"

    @test rstrip(v1) == ""
    @test rstrip(v2) == v2
    @test rstrip(v2, 'é') == "caf"

    @test uppercase(v1) == ""
    @test uppercase(v2) == "CAFÉ"

    @test lowercase(v1) == ""
    @test lowercase(v2) == "café"

    @test titlecase(v1) == ""
    @test titlecase(v2) == "Café"

    @test uppercasefirst(v1) == ""
    @test uppercasefirst(v2) == "Café"

    @test lowercasefirst(v1) == ""
    @test lowercasefirst(v2) == "café"

    @test join([v1, "a"]) == "a"
    @test join([v1, "a"], v2) == "caféa"

    if VERSION >= v"0.7.0-DEV.3688" # Version known to throw an erro
        @test_throws BoundsError chop(v1) == ""
    end
    @test chop(v2) == "caf"

    @test chomp(v1) == ""
    @test chomp(v2) == "café"

    @test textwidth(v1) === 0
    @test textwidth(v2) === 4

    @test isascii(v1)
    @test !isascii(v2)

    @test escape_string(v1) == ""
    @test escape_string(v2) == "café"

    @test collect(v1) == Char[]
    @test collect(v2) == Char['c', 'a', 'f', 'é']
end

end
