#
# Correctness Tests
#

module TestCategoricalArrays
    fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"
    quiet = length(ARGS) > 0 && ARGS[1] == "-q"
    anyerrors = false

    using Base.Test
    using CategoricalArrays

    tests = [
        "01_typedef.jl",
        "02_buildorder.jl",
        "03_buildfields.jl",
        "03_constructors.jl",
        "05_convert.jl",
        "06_show.jl",
        "06_length.jl",
        "07_levels.jl",
        "08_equality.jl",
        "09_hash.jl",
        "10_isless.jl",
        "11_array.jl",
        "12_nullablearray.jl",
        "13_arraycommon.jl",
        "14_view.jl"
    ]

    println("Running tests:")

    for test in tests
        try
            include(test)
            println("\t\033[1m\033[32mPASSED\033[0m: $(test)")
        catch e
            anyerrors = true
            println("\t\033[1m\033[31mFAILED\033[0m: $(test)")
            if fatalerrors
                rethrow(e)
            elseif !quiet
                showerror(STDOUT, e, backtrace())
                println()
            end
        end
    end

    if anyerrors
        throw("Tests failed")
    end
end
