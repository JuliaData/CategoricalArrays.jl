__precompile__()
module CategoricalArrays
    export CategoricalPool, CategoricalValue, CategoricalString
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export AbstractMissingCategoricalArray, AbstractMissingCategoricalVector,
           AbstractMissingCategoricalMatrix,
           MissingCategoricalArray, MissingCategoricalVector, MissingCategoricalMatrix
    export LevelsException, OrderedLevelsException

    export categorical, compress, decompress, droplevels!, levels, levels!, isordered, ordered!
    export cut, recode, recode!

    using Compat
    using Reexport

    # TODO: cannot @reexport in conditional, the below should be removed when 0.6 is deprecated
    @reexport using Missings

    if VERSION >= v"0.7.0-DEV.3052"
        using Printf
    end

    using JSON # FIXME make JSON optional dependency when core Julia will support that

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
