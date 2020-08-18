module CategoricalArrays
    export CategoricalPool, CategoricalValue
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export LevelsException, OrderedLevelsException

    export categorical, compress, decompress, droplevels!, levels, levels!, levelcode,
           isordered, ordered!
    export cut, recode, recode!

    using JSON
    using DataAPI
    using Missings
    using Printf

    # JuliaLang/julia#36810 
    if VERSION < v"1.5.1"
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

    include("deprecated.jl")
end
