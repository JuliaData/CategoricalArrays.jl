module CategoricalArrays
    export CategoricalPool, CategoricalValue
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export AbstractMissingCategoricalArray, AbstractMissingCategoricalVector,
           AbstractMissingCategoricalMatrix,
           MissingCategoricalArray, MissingCategoricalVector, MissingCategoricalMatrix
    export LevelsException, OrderedLevelsException

    export categorical, compress, decompress, droplevels!, levels, levels!, isordered, ordered!
    export cut, recode, recode!

    using Compat
    using JSON
    using DataAPI
    using Reexport

    # TODO: cannot @reexport in conditional, the below should be removed when 0.6 is deprecated
    @reexport using Missings

    if VERSION >= v"0.7.0-DEV.3052"
        using Printf
    end

    include("typedefs.jl")

    include("buildfields.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("missingarray.jl")
    include("subarray.jl")

    include("extras.jl")
    include("recode.jl")

    include("deprecated.jl")
end
