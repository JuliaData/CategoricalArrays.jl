#
# Correctness Tests
#

module TestCategoricalData
    fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"
    quiet = length(ARGS) > 0 && ARGS[1] == "-q"
    anyerrors = false

    using Base.Test
    using CategoricalData

    tests = [
        "01_typedef.jl",
        "02_updateorder.jl",
        "03_buildfields.jl",
        "03_constructors.jl",
        "04_buildpools.jl",
        "05_convert.jl",
        "06_show.jl",
        "06_length.jl",
        "07_levels.jl",
        "07_order.jl",
        "08_equality.jl",
        "09_hash.jl",
        "10_isless.jl",
        "11_array.jl",
        "12_nullablearray.jl"
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
