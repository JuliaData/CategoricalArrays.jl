module CategoricalArrays
    export CategoricalPool, CategoricalValue
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export LevelsException

    export categorical, compress, decompress, droplevels!, levels, levels!, levelcode,
           isordered, ordered!
    export cut, recode, recode!

    import DataAPI: unwrap
    export unwrap

    using Compat
    @compat public default_formatter, numbered_formatter

    using DataAPI
    using Missings
    using Printf

    # JuliaLang/julia#36810
    if VERSION < v"1.5.2"
        Base.OrderStyle(::Type{Union{}}) = Base.Ordered()
    end

    include("typedefs.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("missingarray.jl")
    include("subarray.jl")

    include("extras.jl")
    include("recode.jl")

    if !isdefined(Base, :get_extension)
        using Requires: @require
    end

    @static if !isdefined(Base, :get_extension)
        function __init__()
            @require Arrow="69666777-d1a9-59fb-9406-91d4454c9d45" include("../ext/CategoricalArraysArrowExt.jl")
            @require JSON="682c06a0-de6a-54ab-a142-c8b1cf79cde6" include("../ext/CategoricalArraysJSONExt.jl")
            @require RecipesBase="3cdcf5f2-1ef4-517c-9805-6587b60abb01" include("../ext/CategoricalArraysRecipesBaseExt.jl")
            @require SentinelArrays="91c51154-3ec4-41a3-a24f-3f23e20d615c" include("../ext/CategoricalArraysSentinelArraysExt.jl")
            @require StatsBase="2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91" include("../ext/CategoricalArraysStatsBaseExt.jl")
            @require StructTypes="856f2bd8-1eba-4b0a-8007-ebc267875bd4" include("../ext/CategoricalArraysStructTypesExt.jl")
        end
    end
end
