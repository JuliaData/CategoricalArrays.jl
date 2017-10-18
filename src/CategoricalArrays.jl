__precompile__()
module CategoricalArrays
    export CategoricalPool, CategoricalValue, CategoricalString
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export AbstractNullableCategoricalArray, AbstractNullableCategoricalVector,
           AbstractNullableCategoricalMatrix,
           NullableCategoricalArray, NullableCategoricalVector, NullableCategoricalMatrix
    export LevelsException

    export categorical, compress, decompress, droplevels!, levels, levels!, isordered, ordered!, iscatvalue
    export cut, recode, recode!

    using Compat
    using Reexport
    @reexport using Nulls

    include("typedefs.jl")

    include("buildfields.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("nullablearray.jl")
    include("subarray.jl")

    include("extras.jl")
    include("recode.jl")

    include("deprecated.jl")
end
