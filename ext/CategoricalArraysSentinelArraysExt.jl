module CategoricalArraysSentinelArraysExt

if isdefined(Base, :get_extension)
    using CategoricalArrays
    using SentinelArrays
else
    using ..CategoricalArrays
    using ..SentinelArrays
end

Base.copyto!(dest::CategoricalArrays.CatArrOrSub{<:Any, 1}, src::SentinelArrays.ChainedVector) =
    copyto!(dest, 1, src, 1, length(src))
Base.copyto!(dest::CategoricalArrays.CatArrOrSub{<:Any, 1}, dstart::Union{Signed, Unsigned},
    src::SentinelArrays.ChainedVector, sstart::Union{Signed, Unsigned},
    n::Union{Signed, Unsigned}) =
    invoke(copyto!, Tuple{AbstractArray, Union{Signed, Unsigned},
                        SentinelArrays.ChainedVector,
                        Union{Signed, Unsigned}, Union{Signed, Unsigned}},
        dest, dstart, src, sstart, n)

end
