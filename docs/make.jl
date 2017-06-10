using Documenter, CategoricalArrays

makedocs(
    modules = [CategoricalArrays],
    format = :html,
    sitename = "CategoricalArrays",
    pages = Any[
        "Overview" => "index.md",
        "Using CategoricalArrays" => "using.md",
        "Implementation details" => "implementation.md",
        "Index" => "functionindex.md"
        ]
    )

deploydocs(
    repo = "github.com/JuliaData/CategoricalArrays.jl.git",
    target = "build",
    julia  = "nightly",
    osname = "linux",
    deps = nothing,
    make = nothing
)
