#
# Correctness Tests
#

module TestCategoricalArrays
    fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"
    quiet = length(ARGS) > 0 && ARGS[1] == "-q"
    anyerrors = false

    using Test
    using CategoricalArrays

    tests = [
        "01_value.jl",
        "04_constructors.jl",
        "05_convert.jl",
        "05_copy.jl",
        "06_show.jl",
        "07_levels.jl",
        "08_equality.jl",
        "09_hash.jl",
        "10_isless.jl",
        "11_array.jl",
        "12_missingarray.jl",
        "13_arraycommon.jl",
        "14_view.jl",
        "15_extras.jl",
        "16_recode.jl",
        "17_deprecated.jl"
    ]

    @testset "$test" for test in tests
        include(test)
    end
end
