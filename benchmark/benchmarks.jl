using PkgBenchmark
using CategoricalArrays
using Printf

@benchgroup "isequal(A, v::String)" begin
    function sumequals(A::AbstractArray, v::Any)
        n = 0
        @inbounds for x in A
            n += isequal(x, v)
        end
        n
    end

    ca = CategoricalArray(repeat(string.('A':'J'), outer=1000))
    nca = CategoricalArray(repeat([missing; string.('A':'J')], outer=1000))
    @bench "CategoricalArray{String}" sumequals(ca, "D")
    @bench "CategoricalArray{Union{String, Missing}}" sumequals(nca, "D")
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
    nca = CategoricalArray(repeat([missing; string.('A':'J')], outer=1000))
    @bench "CategoricalArray{String}" sumequals(ca, ca[1])
    @bench "CategoricalArray{Union{String, Missing}}" sumequals(nca, nca[1])
end

# With many levels, checking whether some levels have been dropped can be very slow (#93)
@benchgroup "CategoricalArray{String} with many levels" begin
    a = rand([@sprintf("id%010d", k) for k in 1:1000], 10000)
    @bench "CategoricalArray(::Vector{String})" CategoricalArray(a)

    a = rand([@sprintf("id%010d", k) for k in 1:1000], 10000)
    ca = CategoricalArray(a)
    levs = levels(ca)
    @bench "levels! with original levels" levels!(ca, levs)

    levs = reverse(levels(ca))
    @bench "levels! with resorted levels" levels!(ca, levs)

    levs = [levels(ca); [@sprintf("id2%010d", k) for k in 1:1000]]
    @bench "levels! with many additional levels" levels!(ca, levs)
end

@benchgroup "repeated assignment" begin
    function mycopy!(dest, src)
        @inbounds for i in eachindex(dest, src)
            dest[i] = src[i]
        end
    end

    a = categorical(rand([@sprintf("id%010d", k) for k in 1:1000], 10000))
    b = CategoricalArray{String}(undef, 10000)
    c = categorical(rand([@sprintf("id%010d", k) for k in 1:1000], 10000))
    d = categorical(rand([@sprintf("id%010d", k) for k in 1001:2000], 10000))

    @bench "empty dest" mycopy!(b2, a) setup = b2=copy(b)
    @bench "same levels dest" mycopy!(c2, a) setup = c2=copy(c)
    @bench "many levels dest" mycopy!(d2, a) setup = d2=copy(d)
end