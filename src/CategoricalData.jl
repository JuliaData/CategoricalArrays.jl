module CategoricalData
    export CategoricalPool
    export NominalValue, OrdinalValue
    export NominalArray, NominalVector, NominalMatrix
    export OrdinalArray, OrdinalVector, OrdinalMatrix
    export NullableNominalArray, NullableNominalVector, NullableNominalMatrix
    export NullableOrdinalArray, NullableOrdinalVector, NullableOrdinalMatrix
    export droplevels!, levels, levels!, order, order!

    # TODO: Make this variable and user-specified?
    # TODO: Make this Int for consistency with other indexing in Julia?
    typealias RefType UInt

    include("typedefs.jl")

    include("updateorder.jl")
    include("buildfields.jl")

    include("categoricalpool.jl")
    include("nominalvalue.jl")
    include("ordinalvalue.jl")

    include("array.jl")
    include("nullablearray.jl")
end
