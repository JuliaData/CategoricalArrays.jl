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

@benchgroup "hash" begin
    function f(X)
        h = zero(UInt)
        index = X.pool.index
        @inbounds for i in X.refs
            h += hash(index[i])
        end
        h
    end

    function g(X)
        h = zero(UInt)
        @inbounds for x in X
            h += hash(x)
        end
        h
    end

    function h(X)
        h = zero(UInt)
        pool = X.pool
        @inbounds for i in X.refs
            h += CategoricalArrays.hash_level(pool, i)
        end
        h
    end

    X = CategoricalArray(repeat(["ABCDEF", "GHIJKL", "MNOPQR", "STUVWX"], inner=100, outer=100))

    using BenchmarkTools
    @bench "hashing strings" f(X)
    @bench "hashing CategoricalValues" g(X)
    @bench "using precomputed hashes" h(X)
end
