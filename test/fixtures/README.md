`arrow2-categorical.arrow` was written with Arrow 2.8.1 and CategoricalArrays
1.1.1. It contains a nullable categorical column with one unused level.
Regenerate it in an environment with those package versions:

```julia
using Arrow, CategoricalArrays
x = categorical(Union{String,Missing}["high", missing, "low", "high"];
                levels=["low", "medium", "high"])
Arrow.write("arrow2-categorical.arrow", (; x))
```
