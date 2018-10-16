using Documenter, CategoricalArrays

# Workaround for JuliaLang/julia/pull/28625
if Base.HOME_PROJECT[] !== nothing
    Base.HOME_PROJECT[] = abspath(Base.HOME_PROJECT[])
end

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
    julia  = "1.0",
    osname = "linux",
    deps = nothing,
    make = nothing
)
