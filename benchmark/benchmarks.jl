using PkgBenchmark
using CategoricalArrays
using Nulls

@benchgroup "isequal(A, v::String)" begin
    function sumequals(A::AbstractArray, v::Any)
        n = 0
        @inbounds for x in A
            n += isequal(x, v)
        end
        n
    end

    ca = CategoricalArray(repeat(string.('A':'J'), outer=1000))
    nca = CategoricalArray(repeat([null; string.('A':'J')], outer=1000))
    @bench "CategoricalArray{String}" sumequals(ca, "D")
    @bench "CategoricalArray{Union{String, Null}}" sumequals(nca, "D")
end

@benchgroup "isequal(A, v::CategoricalValue)" begin
    function sumequals(A::AbstractArray, v::CategoricalValue)
        n = 0
        @inbounds for x in A
            n += isequal(x, v)
        end
        n
    end

    ca = CategoricalArray(repeat(string.('A':'J'), outer=1000))
    nca = CategoricalArray(repeat([null; string.('A':'J')], outer=1000))
    @bench "CategoricalArray{String}" sumequals(ca, ca[1])
    @bench "CategoricalArray{Union{String, Null}}" sumequals(nca, nca[1])
end
