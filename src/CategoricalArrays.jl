module CategoricalArrays
    export CategoricalPool, CategoricalValue
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export AbstractNullableCategoricalArray, AbstractNullableCategoricalVector,
           AbstractNullableCategoricalMatrix,
           NullableCategoricalArray, NullableCategoricalVector, NullableCategoricalMatrix
    export LevelsException

    export categorical, compress, decompress, droplevels!, levels, levels!, isordered, ordered!
    export cut

    using Compat

    include("typedefs.jl")

    include("buildfields.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("nullablearray.jl")
    include("subarray.jl")

    include("extras.jl")

    include("deprecated.jl")
end
