module CategoricalData
    export CategoricalPool, OrdinalPool
    export CategoricalVariable, OrdinalVariable
    export levels, levels!, add!, order, order!

    # TODO: Make this variable and user-specified?
    # TODO: Make this Int for consistency with other indexing in Julia?
    typealias RefType Uint

    include("updateorder.jl")
    include("buildfields.jl")

    include(joinpath("CategoricalPool", "01_typedef.jl"))
    include(joinpath("CategoricalVariable", "01_typedef.jl"))
    include(joinpath("OrdinalPool", "01_typedef.jl"))
    include(joinpath("OrdinalVariable", "01_typedef.jl"))

    include(joinpath("CategoricalPool", "02_constructors.jl"))
    include(joinpath("CategoricalVariable", "02_constructors.jl"))
    include(joinpath("OrdinalPool", "02_constructors.jl"))
    include(joinpath("OrdinalVariable", "02_constructors.jl"))

    include(joinpath("CategoricalPool", "03_convert.jl"))
    include(joinpath("CategoricalVariable", "03_convert.jl"))
    include(joinpath("OrdinalPool", "03_convert.jl"))
    include(joinpath("OrdinalVariable", "03_convert.jl"))

    include(joinpath("CategoricalPool", "04_show.jl"))
    include(joinpath("CategoricalVariable", "04_show.jl"))
    include(joinpath("OrdinalPool", "04_show.jl"))
    include(joinpath("OrdinalVariable", "04_show.jl"))

    include(joinpath("CategoricalPool", "05_length.jl"))
    include(joinpath("OrdinalPool", "05_length.jl"))

    include(joinpath("CategoricalPool", "06_levels.jl"))
    include(joinpath("OrdinalPool", "06_levels.jl"))

    include(joinpath("OrdinalPool", "07_order.jl"))

    include(joinpath("CategoricalVariable", "05_isless.jl"))
    include(joinpath("OrdinalVariable", "05_isless.jl"))

    include("buildpools.jl")
end
