module TestExtras
using Test
using CategoricalArrays

const ≅ = isequal

@testset "allow_missing argument" begin
    x = categorical(["a", "b", missing])
    levels!(x, ["a"], allow_missing=true)
    @test x ≅ ["a", missing, missing]

    x = cut([1, missing, 100], [1, 2], allow_missing=true)
    @test x ≅ ["[1, 2)", missing, missing]
end

@testset "level" begin
    x = categorical(["a", "b", missing])
    @test CategoricalArrays.level(x[1]) === CategoricalArrays.refcode(x[1])
end

end