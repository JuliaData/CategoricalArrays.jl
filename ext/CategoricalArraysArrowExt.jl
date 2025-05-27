module CategoricalArraysArrowExt

using CategoricalArrays
import Arrow
import Arrow: ArrowTypes

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

for (MV, MT) in ((:V, :T), (:(Union{V,Missing}), :(Union{T,Missing})))
    @eval begin
        function Arrow.DictEncoding{$MV,S,A}(id, data::Arrow.List{U, O, B},
                                             isOrdered, metadata) where
            {T, R, V<:CategoricalValue{T,R}, S, O, A, B, U}
            newdata = Arrow.List{$MT,O,B}(data.arrow, data.validity, data.offsets,
                                          data.data, data.ℓ, data.metadata)
            levels = Missing <: $MT ? collect(skipmissing(newdata)) : newdata
            catdata = CategoricalVector{$MT,R}(newdata, levels=levels)
            return Arrow.DictEncoding{$MV,S,typeof(catdata)}(id, catdata,
                                                             isOrdered, metadata)
        end

        function Arrow.DictEncoding{$MV,S,A}(id, data::Arrow.Primitive{U, B},
                                            isOrdered, metadata) where
            {T, R, V<:CategoricalValue{T,R}, S, A, B, U}
            newdata = Arrow.Primitive{$MT,B}(data.arrow, data.validity, data.data,
                                            data.ℓ, data.metadata)
            levels = Missing <: $MT ? collect(skipmissing(newdata)) : newdata
            catdata = CategoricalVector{$MT,R}(newdata, levels=levels)
            return Arrow.DictEncoding{$MV,S,typeof(catdata)}(id, catdata,
                                                             isOrdered, metadata)
        end
    end
end

function Base.copy(x::Arrow.DictEncoded{V}) where {T, R, V<:CategoricalValue{T, R}}
    pool = CategoricalPool{T,R}(x.encoding.data)
    inds = x.indices
    refs = similar(inds, R)
    refs .= inds .+ one(R)
    return CategoricalVector{T}(refs, pool)
end

function Base.copy(x::Arrow.DictEncoded{Union{Missing,V}}) where
    {T, R, V<:CategoricalValue{T, R}}
    ismissing(x.encoding.data[1]) ||
        throw(ErrorException("`missing` must be the first value in a " *
                             "`CategoricalArray` pool"))
    levels = collect(skipmissing(x.encoding.data))
    pool = CategoricalPool{T,R}(levels)
    inds = x.indices
    refs = similar(inds, R)
    refs .= inds
    return CategoricalVector{Union{T,Missing}}(refs, pool)
end

end
