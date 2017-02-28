# Overview

This package provides a replacement for [DataArrays.jl](https://github.com/JuliaStats/DataArrays.jl)'s `PooledDataArray` type.

It offers better performance by getting rid of type instability thanks to the `Nullable` type, which is used to represent missing data. It is also based on a simpler design by only supporting categorical data, which allows offering more specialized features (like ordering of categories). See the [IndirectArrays.jl](https://github.com/JuliaArrays/IndirectArrays.jl) package for a simpler array type storing data with a small number of values.

The package provides two array types designed to hold categorical data efficiently and conveniently:

- `CategoricalArray` can hold both unordered and ordered categorical data

- `NullableCategoricalArray` supports the same features as the first type, also accepts missing data

These arrays behave just like standard Julia `Array`s, but they return special types when indexed:

- `CategoricalArray` returns a `CategoricalValue` object

- `NullableCategoricalArray` returns a `Nullable{CategoricalValue}` object

`CategoricalValue` objects are simple wrappers around the actual categorical levels which allow for very efficient extraction and equality tests. Indeed, the main feature of categorical arrays types is that they store a pool of the levels which can appear in the variable. These levels are stored in a specific order: for unordered arrays, this order is only used for pretty printing (e.g. in cross tables or plots); for ordered arrays, it also allows comparing values using the `<` and `>` operators: the comparison is then based on the ordering of levels stored in the array. Whether an array is ordered can be defined either on construction via the `ordered` argument, or at any time via the `ordered!` function.

Use the `levels` function to access the levels of a categorical array, and the `levels!` function to set and order them. Levels are automatically created when setting an element to a previously unused level. On the other hand, they are never removed without manual intervention: use the `droplevels!` function for this.
