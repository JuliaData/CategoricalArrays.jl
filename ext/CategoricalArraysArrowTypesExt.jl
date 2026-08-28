module CategoricalArraysArrowTypesExt

using CategoricalArrays
import ArrowTypes

# ArrowTypes mappings for CategoricalValue. These are version-agnostic: they
# serve both Arrow.jl 2.x and 3.x (which share the ArrowTypes 2.x interface),
# as well as any other ArrowTypes-based producer/consumer.

const CATARRAY_ARROWNAME = Symbol("JuliaLang.CategoricalArrays.CategoricalArray")
ArrowTypes.arrowname(::Type{<:CategoricalValue}) = CATARRAY_ARROWNAME
ArrowTypes.arrowmetadata(::Type{CategoricalValue{T, R}}) where {T, R} = string(R)
ArrowTypes.ArrowType(::Type{<:CategoricalValue{T}}) where {T} = T
ArrowTypes.toarrow(x::CategoricalValue) = unwrap(x)

ArrowTypes.arrowname(::Type{Union{<:CategoricalValue, Missing}}) = CATARRAY_ARROWNAME
ArrowTypes.arrowmetadata(::Type{Union{CategoricalValue{T, R}, Missing}}) where {T, R} =
    string(R)

const REFTYPES = Dict(string(T) => T for T in (Int128, Int16, Int32, Int64, Int8, UInt128,
                                               UInt16, UInt32, UInt64, UInt8))
function ArrowTypes.JuliaType(::Val{CATARRAY_ARROWNAME},
                              ::Type{S}, meta::String) where S
    R = REFTYPES[meta]
    return CategoricalValue{S, R}
end

# Reconstruct a `CategoricalValue` from a deserialized level. Arrow 3.x calls
# this for each value of a column tagged with our extension name; collecting
# the results into a `CategoricalValue`-eltype array (see `Base.similar`
# overrides in CategoricalArrays) merges the single-level pools into one
# shared pool, so `Arrow.Table` columns materialize as `CategoricalArray`s.
# Arrow 2.x also reaches this method when reading a plain (non-dict-encoded)
# column written by Arrow 3.x.
function ArrowTypes.fromarrow(::Type{CategoricalValue{T, R}}, x) where {T, R}
    pool = CategoricalPool{T, R}(T[convert(T, x)])
    return CategoricalValue(pool, 1)
end
# Disambiguate against `ArrowTypes.fromarrow(::Type{T}, x::T)`: a value that
# is already a `CategoricalValue` (e.g. from the CategoricalVector pool that
# CategoricalArraysArrowExt builds on Arrow 2.x) passes through unchanged.
ArrowTypes.fromarrow(::Type{CategoricalValue{T, R}},
                     x::CategoricalValue{T, R}) where {T, R} = x

end
