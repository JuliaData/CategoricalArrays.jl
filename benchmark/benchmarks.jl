using PkgBenchmark
using CategoricalArrays

@benchgroup "isequal(A, v::String)" begin
    function sumequals(A::AbstractArray, v::Any)
        n = 0
        @inbounds for x in A
            n += isequal(x, v)
        end
        n
    end

    ca = CategoricalArray(repeat(string.('A':'J'), outer=1000))
    nca = NullableCategoricalArray(repeat([Nullable(); string.('A':'J')], outer=1000))
    @bench "CategoricalArray" sumequals(ca, "D")
    @bench "NullableCategoricalArray" sumequals(nca, Nullable("D"))
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
    nca = NullableCategoricalArray(repeat([Nullable(); string.('A':'J')], outer=1000))
    @bench "CategoricalArray" sumequals(ca, ca[1])
    @bench "NullableCategoricalArray" sumequals(nca, nca[1])
end
