CategoricalArrays.jl
==================

[![Build Status](https://travis-ci.org/nalimilan/CategoricalArrays.jl.svg?branch=master)](https://travis-ci.org/nalimilan/CategoricalArrays.jl)
[![Julia 0.4 Status](http://pkg.julialang.org/badges/CategoricalArrays_0.4.svg)](http://pkg.julialang.org/?pkg=CategoricalArrays&ver=0.4)
[![Julia 0.5 Status](http://pkg.julialang.org/badges/CategoricalArrays_0.5.svg)](http://pkg.julialang.org/?pkg=CategoricalArrays&ver=0.5)
[![Coveralls](https://coveralls.io/repos/github/nalimilan/CategoricalArrays.jl/badge.svg)](https://coveralls.io/github/nalimilan/CategoricalArrays.jl)
[![Codecov](https://codecov.io/gh/nalimilan/CategoricalArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/nalimilan/CategoricalArrays.jl)

Tools for working with categorical variables, both with unordered (nominal variables)
and ordered categories (ordinal variables). This package provides a replacement for
[DataArrays.jl](https://github.com/JuliaStats/DataArrays.jl)'s `PooledDataArray` type.
It offers better performance by getting rid of type instability thanks to the `Nullable`
type, which is used to represent missing data. It is also based on a simpler design by
only supporting categorical data, which allows offering more specialized features
(like ordering of categories).

The package provides four array types designed to hold categorical data:
- `NominalArray` can hold any type of *unordered* categorical data, storing them in a
space-efficient fashion
- `OrdinalArray` is the equivalent type for storing *ordered* data
- `NullableNominalArray` works like a `NominalArray` but also supports missing data
- `NullableOrdinalArray` works like a `OrdinalArray` but also supports missing data

These arrays behave just like standard Julia `Array`s, but they return special types
when indexed:
- `NominalArray` returns a `CategoricalValue` object, and `NullableNominalArray` a
`Nullable{CategoricalValue}` object
- `OrdinalArray` returns an `OrdinalValue` object, and `NullableOrdinalArray` a
`Nullable{OrdinalValue}` object

These two kinds of objects are simple wrappers around the actual categorical levels
which allow for very efficient extraction and equality tests. `OrdinalValue` offers
the additional property that two such values can be compared using the `<` and `>`
operators. The comparison is based on the ordering of levels stored in the array.

Indeed, the last peculiarity of these four categorical arrays types is that they
store a pool of the levels that can appear in the variable. These levels appear
in a specific order: for nominal variables, the order is only used for pretty printing
(e.g. in cross tables); for ordinal variables, it is used in comparisons mentioned above.

Use the `levels` function to access the levels of a categorical array, and the `levels!`
function to set them. Levels are automatically created when setting an element to a
previously unused level. On the other hand, they are never removed without manual intervention:
use the `droplevels!` function for this.

# Using OrdinalArray and NominalArray

Suppose that you have data about four individuals, with three different age groups.
This kind of data is best handled as an ordinal variable, i.e. `OrdinalArray`. Note
everything would work the same with `NominalArray`, except for the comparison using `<`.

```julia
julia> using CategoricalArrays

julia> x = OrdinalArray(["Old", "Young", "Middle", "Young"])
4-element CategoricalArrays.OrdinalArray{String,1,UInt32}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

```

By default, the levels are sorted in their order of appearance in the data, which is
cleary not correct in our case. But this is easily fixed using the `levels!` function:
```julia
julia> levels(x)
3-element Array{String,1}:
 "Old"   
 "Young" 
 "Middle"

julia> levels!(x, ["Young", "Middle", "Old"])
3-element Array{String,1}:
 "Young" 
 "Middle"
 "Old"   

```

Thanks to this order, we can not only test for equality between two values, but also
compare the ages of e.g. individuals 1 and 2:
```julia
julia> x[1]
CategoricalArrays.OrdinalValue{String,UInt32} "Old" (3/3)

julia> x[2]
CategoricalArrays.OrdinalValue{String,UInt32} "Young" (1/3)

julia> x[2] == x[4]
true

julia> x[1] > x[2]
true

```

Now let us imagine the first individual is actually in the "Young" group. Let's fix this
(notice how the string `"Young"` is automatically converted to an `OrdinalValue`):
```julia
julia> x[1] = "Young"
"Young"

julia> x[1]
CategoricalArrays.OrdinalValue{String,UInt32} "Young" (1/3)

```

The `OrdinalArray` still considers `"Old"` as a possible level even if it is unused now.
This is necessary to allow efficiently accessing the levels and setting values of elements
in the array: indeed, dropping unused levels requires iterating over every element in the
array, which is expensive. This property can also be useful to keep track of possible
levels, even if they do not occur in practice.

To get rid of the `"Old"` group, just call the `droplevels!` function:
```julia
julia> levels(x)
3-element Array{String,1}:
 "Young" 
 "Middle"
 "Old"   

julia> droplevels!(x)
2-element Array{String,1}:
 "Young" 
 "Middle"

julia> levels(x)
2-element Array{String,1}:
 "Young" 
 "Middle"

```

Another solution would have been to call `levels!(x, ["Young", "Middle"])` manually.
This command is safe too, since it will raise an error when trying to remove levels
that are currently used:
```julia
julia> levels!(x, ["Young", "Midle"]) # Note the typo in "Middle"
ERROR: ArgumentError: cannot remove level "Middle" as it is used at position 1. Convert array to a NullableOrdinalArray if you want to transform some levels to missing values.
 in #_levels!#5(::Bool, ::Function, ::CategoricalArrays.OrdinalArray{String,1,UInt32}, ::Array{String,1}) at /home/milan/.julia/CategoricalArrays/src/array.jl:132
 in levels!(::CategoricalArrays.OrdinalArray{String,1,UInt32}, ::Array{String,1}) at /home/milan/.julia/CategoricalArrays/src/array.jl:164
 in eval(::Module, ::Any) at ./boot.jl:225
 in macro expansion at ./REPL.jl:92 [inlined]
 in (::Base.REPL.##1#2{Base.REPL.REPLBackend})() at ./event.jl:46
```

### Handling Missing Values: NullableNominalArray and NullableOrdinalArray

The examples above assumed that the data contained no missing values. This is
generally not the case in real data. This is where `NullableNominalArray` and
`NullableOrdinalArray` come into play. They are essentially the categorical-data
equivalent of [NullableArrays](https://github.com/JuliaStats/NullableArrays.jl).
They behave exactly the same as `NominalArray` and `OrdinalArray`, except that
they return respectively `Nullable{NominalValue}` and `Nullable{OrdinalValue}` elements.
See [the Julia manual](http://docs.julialang.org/en/stable/manual/types/?highlight=nullable#nullable-types-representing-missing-values)
for more information on the `Nullable` type.

Let's adapt the example developed above to support missing values. At first sight,
not much changes:
```julia
julia> y = NullableOrdinalArray(["Old", "Young", "Middle", "Young"])
4-element CategoricalArrays.NullableOrdinalArray{String,1,UInt32}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

```

Levels still need to be reordered manually:
```julia
julia> levels(y)
3-element Array{String,1}:
 "Old"   
 "Young" 
 "Middle"

julia> levels!(y, ["Young", "Middle", "Old"])
3-element Array{String,1}:
 "Young" 
 "Middle"
 "Old"   
 
```

A first difference from the previous example is that indexing the array returns a
`Nullable` value:
```julia
julia> y[1]
Nullable{CategoricalArrays.OrdinalValue{String,UInt32}}("Old")

julia> get(y[1])
CategoricalArrays.OrdinalValue{String,UInt32} "Old" (3/3)
```

Currently, comparison between two `Nullable` objects requires extracting their values using
`get`, which throws an error in the presence of missing values. This should hopefully be fixed
soon.

Missing values can be introduced either manually, or by restricting the set of possible
levels. Let us imagine this time that we actually do not know the age of the first
individual. We can set it to a missing value this way:
```julia
julia> y[1] = Nullable()
Nullable{Union{}}()

julia> y
4-element CategoricalArrays.NullableOrdinalArray{String,1,UInt32}:
 #NULL   
 "Young" 
 "Middle"
 "Young" 

julia> y[1]
Nullable{CategoricalArrays.OrdinalValue{String,UInt32}}()

```

It is also possible to transform all values belonging to some levels into missing values, which
gives the same result as above in the present case since we have only one individual in the
`"Old"` group. Let's first restore the original value for the first element, and then set it
to missing again using the `nullok` argument to `levels!`:
```julia
julia> y[1] = "Old"
"Old"

julia> y
4-element CategoricalArrays.NullableOrdinalArray{String,1,UInt32}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

julia> levels!(y, ["Young", "Middle"]; nullok=true)
2-element Array{String,1}:
 "Young" 
 "Middle"

julia> y
4-element CategoricalArrays.NullableOrdinalArray{String,1,UInt32}:
 #NULL   
 "Young" 
 "Middle"
 "Young" 

```


# Implementation details

`NominalArray`, `OrdinalArray`, `NullableNominalArray` and `NullableOrdinalArray` share a
common implementation for the most part, with the main differences being their element
types. They are based on the `NominalPool` and `OrdinalPool` types, which keep track of the
levels and associates them with an integer reference (for internal use). They offer
methods to set levels, change their order while preserving the references, and efficiently
get the integer index corresponding to a level and vice-versa. They are also
parameterized on the type used to store the references, so that small pools can use as little
memory as possible. Finally, they keep a vector of value objects (`NominalValue` or
`CategoricalValue`), so that `getindex` can return the existing object instead of allocating
a new one.

Array types are made of two fields:
- `refs`: an integer vector giving the index of the level in the pool for each element.
For `NullableNominalArray` and `NullableOrdinalArray`, `0` indicates a missing value.
- `pool`: the `NominalPool` or `OrdinalPool` object keeping the levels of the array.

`NominalPool` and `OrdinalPool` are designed to limit the need to go over all elements of
the vector, either for reading or for writing. This is why unused levels are not dropped
automatically (this would force checking all elements on every modification or keeping a
counts table), but only when `droplevels!` is called.
`levels` is a (very fast) O(1) operation since it merely returns the (ordered) vector of
levels, without accessing the data at all. Another useful property is that integer indices
referring to levels are preserved when adding or reordering levels: the order of levels
exposed to the user by the `levels` function does not necessarily match these internal
indices. This means a reordering of the levels is also an O(1) operation. On the other
hand, deleting levels may change the indices and therefore require iterating over all
elements in the array to update the references.
