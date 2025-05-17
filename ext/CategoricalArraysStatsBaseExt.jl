module CategoricalArraysStatsBaseExt

if isdefined(Base, :get_extension)
    import CategoricalArrays: _wquantile
    using StatsBase
else
    import ..CategoricalArrays: _wquantile
    using ..StatsBase
end

_wquantile(x::AbstractArray, w::AbstractWeights, p::AbstractVector) = quantile(x, w, p)

end
