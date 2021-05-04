using BenchmarkTools
using CategoricalArrays
using Printf

const SUITE = BenchmarkGroup()

SUITE["isequal"] = BenchmarkGroup()

function sumequals(A::AbstractArray, v::Any)
    n = 0
    @inbounds for x in A
        n += isequal(x, v)
    end
    n
end

ca = CategoricalArray(repeat(string.('A':'J'), outer=1000))
nca = CategoricalArray(repeat([missing; string.('A':'J')], outer=1000))

SUITE["isequal"]["CategoricalArray{String}", "String"] =
    @benchmarkable  sumequals(ca, "D")
SUITE["isequal"]["CategoricalArray{Union{String, Missing}}", "String"] =
    @benchmarkable sumequals(nca, "D")

function sumequals(A::AbstractArray, v::CategoricalValue)
    n = 0
    @inbounds for x in A
        n += isequal(x, v)
    end
    n
end

ca = CategoricalArray(repeat(string.('A':'J'), outer=1000))
nca = CategoricalArray(repeat([missing; string.('A':'J')], outer=1000))

SUITE["isequal"]["CategoricalArray{String}", "CategoricalValue"] =
    @benchmarkable sumequals(ca, ca[1])
SUITE["isequal"]["CategoricalArray{Union{String, Missing}}", "CategoricalValue"] =
    @benchmarkable sumequals(nca, nca[1])

SUITE["isequal"]["CategoricalArray{String}", "CategoricalValue different pool"] =
    @benchmarkable sumequals(ca, nca[1])
SUITE["isequal"]["CategoricalArray{Union{String, Missing}}", "CategoricalValue  different pool"] =
    @benchmarkable sumequals(nca, ca[1])


# With many levels, checking whether some levels have been dropped can be very slow (#93)
SUITE["many levels"] = BenchmarkGroup()

a = rand([@sprintf("id%010d", k) for k in 1:1000], 10000)

SUITE["many levels"]["CategoricalArray(::Vector{String})"] =
    @benchmarkable CategoricalArray(a)

a = rand([@sprintf("id%010d", k) for k in 1:1000], 10000)
ca = CategoricalArray(a)

levs = levels(ca)
SUITE["many levels"]["levels! with original levels"] =
    @benchmarkable levels!(ca, levs)

levs = reverse(levels(ca))
SUITE["many levels"]["levels! with resorted levels"] =
    @benchmarkable levels!(ca, levs)

levs = [levels(ca); [@sprintf("id2%010d", k) for k in 1:1000]]
SUITE["many levels"]["levels! with many additional levels"] =
    @benchmarkable levels!(ca, levs)


SUITE["repeated assignment"] = BenchmarkGroup()

function mycopy!(dest, src)
    @inbounds for i in eachindex(dest, src)
        dest[i] = src[i]
    end
end

a = categorical(rand([@sprintf("id%010d", k) for k in 1:1000], 10000))
b = CategoricalArray{String}(undef, 10000)
c = categorical(rand([@sprintf("id%010d", k) for k in 1:1000], 10000))
d = categorical(rand([@sprintf("id%010d", k) for k in 1001:2000], 10000))

SUITE["repeated assignment"]["empty dest"] =
    @benchmarkable mycopy!(b2, a) setup = b2=copy(b)
SUITE["repeated assignment"]["same levels dest"] =
    @benchmarkable mycopy!(c2, a) setup = c2=copy(c)
SUITE["repeated assignment"]["many levels dest"] =
    @benchmarkable mycopy!(d2, a) setup = d2=copy(d)

orig_vec = (x -> repeat(x, 32)).(string.([x % 1000 for x in 1:1000000]))
cat2merge_vec = (x -> repeat(x, 32)).(string.([x % 1000 for x in 1:100000]))
SUITE["recode"] = BenchmarkGroup()
SUITE["recode"]["vectors"] = @benchmarkable recode(orig_vec, cat2merge_vec => "None")
SUITE["recode"]["categorical_vectors"] = @benchmarkable recode(categorical(orig_vec), cat2merge_vec => "None")
SUITE["recode"]["matrices"] = @benchmarkable recode(reshape(orig_vec, :, 1), reshape(cat2merge_vec, :, 1) => "None")
SUITE["recode"]["categorical_matrices"] = @benchmarkable recode(categorical(reshape(orig_vec, :, 1)), reshape(cat2merge_vec, :, 1) => "None")
