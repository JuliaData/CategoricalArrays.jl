module CategoricalData
    export CategoricalPool, OrdinalPool
    export CategoricalVariable, OrdinalVariable
    export levels, levels!, add!, order, order!

    # TODO: Make this variable and user-specified?
    # TODO: Make this Int for consistency with other indexing in Julia?
    typealias RefType Uint

    include("updateorder.jl")
    include("buildfields.jl")

    include("typedefs.jl")

    include("categoricalpool.jl")
    include("categoricalvariable.jl")
    include("ordinalpool.jl")
    include("ordinalvariable.jl")

    include("buildpools.jl")
end
