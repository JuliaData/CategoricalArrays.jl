module CategoricalArrays
    export CategoricalPool, NominalPool, OrdinalPool
    export NominalValue, OrdinalValue
    export NominalArray, NominalVector, NominalMatrix
    export OrdinalArray, OrdinalVector, OrdinalMatrix
    export NullableNominalArray, NullableNominalVector, NullableNominalMatrix
    export NullableOrdinalArray, NullableOrdinalVector, NullableOrdinalMatrix
    export droplevels!, levels, levels!

    include("typedefs.jl")

    include("buildfields.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("nullablearray.jl")
end
