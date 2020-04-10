module TestExtras
using Test
using CategoricalArrays

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

end