using PkgBenchmark
using CategoricalArrays

@benchgroup "isequal" begin
    function sumequals(A::AbstractArray, v::Any)
        n = 0
        @inbounds for x in A
            n += isequal(x, v)
        end
        n
    end

    ca = CategoricalArray(repeat(string.('A':'J'), outer=1000))
    nca = NullableCategoricalArray(repeat(string.([Nullable(); 'A':'J']), outer=1000))
    @bench "CategoricalArray" sumequals(ca, "D")
    @bench "NullableCategoricalArray" sumequals(nca, Nullable("D"))
end
