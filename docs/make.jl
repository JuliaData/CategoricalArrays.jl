using Documenter, CategoricalArrays

# Workaround for JuliaLang/julia/pull/28625
if Base.HOME_PROJECT[] !== nothing
    Base.HOME_PROJECT[] = abspath(Base.HOME_PROJECT[])
end

makedocs(
    modules = [CategoricalArrays],
    sitename = "CategoricalArrays",
    format = Documenter.HTML(canonical = "https://juliadata.github.io/CategoricalArrays.jl/stable/"),
    pages = Any[
        "Overview" => "index.md",
        "Using CategoricalArrays" => "using.md",
        "Implementation details" => "implementation.md",
        "API index" => "apiindex.md"
        ],
    checkdocs = :exports,
    strict=true
)

deploydocs(
    repo = "github.com/JuliaData/CategoricalArrays.jl.git"
)
