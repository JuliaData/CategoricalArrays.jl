module TestExtras
using Test
using CategoricalArrays

const ≅ = isequal

@testset "categorical" begin
    for ord in (false, true)
        x = categorical(["a"], true; ordered=ord)
        @test x isa CategoricalVector{String, UInt8}
        @test x == ["a"]
        @test isordered(x) === ord

        x = categorical(["a"], false; ordered=ord)
        @test x isa CategoricalVector{String, UInt32}
        @test x == ["a"]
        @test isordered(x) === ord
    end
end

@testset "allow_missing argument" begin
    x = categorical(["a", "b", missing])
    levels!(x, ["a"], allow_missing=true)
    @test x ≅ ["a", missing, missing]

    x = cut([1, missing, 100], [1, 2], allow_missing=true)
    @test x ≅ ["[1, 2)", missing, missing]
end

end