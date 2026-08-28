module CategoricalArraysArrowExt

using CategoricalArrays
import Arrow

# The ArrowTypes mappings for CategoricalValue live in
# CategoricalArraysArrowTypesExt (triggered by ArrowTypes, which Arrow
# re-exports). This extension only carries integrations with Arrow.jl 2.x
# internal array types (`Arrow.DictEncoding`, `Arrow.List`, `Arrow.Primitive`,
# `Arrow.DictEncoded`), which no longer exist in Arrow.jl 3.0: there,
# `Arrow.Table` materializes extension columns through the recursive
# ArrowTypes path, so the mappings extension alone suffices.
@static if isdefined(Arrow, :DictEncoding)

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

end # @static if isdefined(Arrow, :DictEncoding)

end
