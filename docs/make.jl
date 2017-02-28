using Documenter, CategoricalArrays

makedocs(
    modules = [CategoricalArrays],
    format = :html,
    sitename = "CategoricalArrays",
    pages = Any[
        "Overview" => "overview.md",
        "Using CategoricalArrays" => "using.md",
        "Implementation details" => "implementation.md",
        "Index" => "functionindex.md"
        ]
    )

deploydocs(
    repo = "github.com/JuliaData/CategoricalArrays.jl.git",
    target = "build",
    julia  = "0.5",
    osname = "linux",
    deps = nothing,
    make = nothing
)
