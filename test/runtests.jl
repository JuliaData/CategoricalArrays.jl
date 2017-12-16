#
# Correctness Tests
#

module TestCategoricalArrays
    fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"
    quiet = length(ARGS) > 0 && ARGS[1] == "-q"
    anyerrors = false

    using Compat
    using Compat.Test
    using CategoricalArrays

    tests = [
        "01_typedef.jl",
        "02_buildorder.jl",
        "03_buildfields.jl",
        "04_constructors.jl",
        "05_convert.jl",
        "06_show.jl",
        "06_length.jl",
        "07_levels.jl",
        "08_equality.jl",
        "08_string.jl",
        "09_hash.jl",
        "10_isless.jl",
        "11_array.jl",
        "12_missingarray.jl",
        "13_arraycommon.jl",
        "14_view.jl",
        "15_extras.jl",
        "16_recode.jl"
    ]

    @testset "$test" for test in tests
        include(test)
    end
end
