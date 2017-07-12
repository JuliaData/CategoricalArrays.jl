__precompile__()
module CategoricalArrays
    export CategoricalPool, CategoricalValue
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export AbstractNullableCategoricalArray, AbstractNullableCategoricalVector,
           AbstractNullableCategoricalMatrix,
           NullableCategoricalArray, NullableCategoricalVector, NullableCategoricalMatrix
    export LevelsException

    export categorical, compress, decompress, droplevels!, levels, levels!, isordered, ordered!, reftype
    export cut, recode, recode!

    using Compat, NullableArrays

    import NullableArrays: unsafe_getindex_notnull, unsafe_getvalue_notnull

    using NullableArrays
    import NullableArrays: unsafe_getindex_notnull, unsafe_getvalue_notnull

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
