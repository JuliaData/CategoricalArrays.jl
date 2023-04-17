module CategoricalArraysRecipesBaseExt

if isdefined(Base, :get_extension)
    using CategoricalArrays
    using RecipesBase
else
    using ..CategoricalArrays
    using ..RecipesBase
end

RecipesBase.@recipe function f(::Type{T}, v::T) where T <: CategoricalValue
    level_strings = [map(string, levels(v)); missing]
    ticks --> eachindex(level_strings)
    v -> ismissing(v) ? length(level_strings) : Int(CategoricalArrays.refcode(v)),
    i -> level_strings[Int(i)]
end

end
