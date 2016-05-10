module CategoricalData
    export CategoricalPool, OrdinalPool
    export CategoricalValue, OrdinalValue
    export levels, levels!, add!, order, order!

    # TODO: Make this variable and user-specified?
    # TODO: Make this Int for consistency with other indexing in Julia?
    typealias RefType UInt

    include("updateorder.jl")
    include("buildfields.jl")

    include("typedefs.jl")

    include("categoricalpool.jl")
    include("categoricalvalue.jl")
    include("ordinalpool.jl")
    include("ordinalvalue.jl")

    include("buildpools.jl")
end
