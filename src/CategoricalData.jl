module CategoricalData
    export CategoricalPool, OrdinalPool
    export CategoricalValue, OrdinalValue
    export CategoricalArray, CategoricalVector, CategoricalMatrix
    export OrdinalArray, OrdinalVector, OrdinalMatrix
    export NullableCategoricalArray, NullableCategoricalVector, NullableCategoricalMatrix
    export NullableOrdinalArray, NullableOrdinalVector, NullableOrdinalMatrix
    export droplevels!, levels, levels!, order, order!

    # TODO: Make this variable and user-specified?
    # TODO: Make this Int for consistency with other indexing in Julia?
    typealias RefType UInt

    include("typedefs.jl")

    include("updateorder.jl")
    include("buildfields.jl")

    include("categoricalpool.jl")
    include("categoricalvalue.jl")
    include("ordinalpool.jl")
    include("ordinalvalue.jl")

    include("buildpools.jl")

    include("array.jl")
    include("nullablearray.jl")
end
