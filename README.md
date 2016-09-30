CategoricalArrays.jl
==================

[![Build Status](https://travis-ci.org/nalimilan/CategoricalArrays.jl.svg?branch=master)](https://travis-ci.org/nalimilan/CategoricalArrays.jl)
[![Julia 0.5 Status](http://pkg.julialang.org/badges/CategoricalArrays_0.5.svg)](http://pkg.julialang.org/?pkg=CategoricalArrays&ver=0.5)
[![Julia 0.6 Status](http://pkg.julialang.org/badges/CategoricalArrays_0.6.svg)](http://pkg.julialang.org/?pkg=CategoricalArrays&ver=0.6)
[![Coveralls](https://coveralls.io/repos/github/nalimilan/CategoricalArrays.jl/badge.svg)](https://coveralls.io/github/nalimilan/CategoricalArrays.jl)
[![Codecov](https://codecov.io/gh/nalimilan/CategoricalArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/nalimilan/CategoricalArrays.jl)

Tools for working with categorical variables, both with unordered (nominal variables)
and ordered categories (ordinal variables). This package provides a replacement for
[DataArrays.jl](https://github.com/JuliaStats/DataArrays.jl)'s `PooledDataArray` type.
It offers better performance by getting rid of type instability thanks to the `Nullable`
type, which is used to represent missing data. It is also based on a simpler design by
only supporting categorical data, which allows offering more specialized features
(like ordering of categories). See the [IndirectArrays.jl](https://github.com/JuliaArrays/IndirectArrays.jl)
package for a simpler array type storing data with a small number of values.

The package provides two array types designed to hold categorical data efficiently and
conveniently:
- `CategoricalArray` can hold both unordered and ordered categorical data
- `NullableCategoricalArray` supports the same features as the first type, also accepts
missing data

These arrays behave just like standard Julia `Array`s, but they return special types
when indexed:
- `CategoricalArray` returns a `CategoricalValue` object
- `NullableCategoricalArray` returns a `Nullable{CategoricalValue}` object

`CategoricalValue` objects are simple wrappers around the actual categorical levels
which allow for very efficient extraction and equality tests. Indeed, the main feature of
categorical arrays types is that they store a pool of the levels which can appear in the
variable. These levels are stored in a specific order: for unordered arrays, this order
is only used for pretty printing (e.g. in cross tables or plots); for ordered arrays, it
also allows comparing values using the `<` and `>` operators: the comparison is then based
on the ordering of levels stored in the array. Whether an array is ordered can be defined
either on construction via the `ordered` argument, or at any time via the `ordered!`
function.

Use the `levels` function to access the levels of a categorical array, and the `levels!`
function to set and order them. Levels are automatically created when setting an element
to a previously unused level. On the other hand, they are never removed without manual
intervention: use the `droplevels!` function for this.

# Using CategoricalArray

Suppose that you have data about four individuals, with three different age groups.
Since this variable is clearly ordinal, we mark the array as such via the `ordered`
argument.

```julia
julia> using CategoricalArrays

julia> x = CategoricalArray(["Old", "Young", "Middle", "Young"], ordered=true)
4-element CategoricalArrays.CategoricalArray{String,1,UInt32}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

```

By default, the levels are lexically sorted, which is cleary not correct in our case
and would give incorrect results when testing for order. This is easily fixed using
the `levels!` function to reorder levels:
```julia
julia> levels(x)
3-element Array{String,1}:
 "Middle"
 "Old"   
 "Young" 

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
CategoricalArrays.CategoricalValue{String,UInt32} "Old" (3/3)

julia> x[2]
CategoricalArrays.CategoricalValue{String,UInt32} "Young" (1/3)

julia> x[2] == x[4]
true

julia> x[1] > x[2]
true

```

Now let us imagine the first individual is actually in the "Young" group. Let's fix this
(notice how the string `"Young"` is automatically converted to a `CategoricalValue`):
```julia
julia> x[1] = "Young"
"Young"

julia> x[1]
CategoricalArrays.CategoricalValue{String,UInt32} "Young" (1/3)

```

The `CategoricalArray` still considers `"Old"` as a possible level even if it is unused now.
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
ERROR: ArgumentError: cannot remove level "Middle" as it is used at position 1. Convert array to a NullableCategoricalArray if you want to transform some levels to missing values.
 in #_levels!#5(::Bool, ::Function, ::CategoricalArrays.CategoricalArray{String,1,UInt32}, ::Array{String,1}) at ~/.julia/CategoricalArrays/src/array.jl:132
 in levels!(::CategoricalArrays.CategoricalArray{String,1,UInt32}, ::Array{String,1}) at ~/.julia/CategoricalArrays/src/array.jl:164
 in eval(::Module, ::Any) at ./boot.jl:225
 in macro expansion at ./REPL.jl:92 [inlined]
 in (::Base.REPL.##1#2{Base.REPL.REPLBackend})() at ./event.jl:46
```

### Handling Missing Values: NullableCategoricalArray

The examples above assumed that the data contained no missing values. This is
generally not the case in real data. This is where `NullableCategoricalArray`
comes into play. It is essentially the categorical-data equivalent of
[NullableArrays](https://github.com/JuliaStats/NullableArrays.jl).
It behaves exactly the same as `CategoricalArray` , except that it returns
`Nullable{CategoricalValue}` elements when indexed.
See [the Julia manual](http://docs.julialang.org/en/stable/manual/types/?highlight=nullable#nullable-types-representing-missing-values)
for more information on the `Nullable` type.

Let's adapt the example developed above to support missing values. At first sight,
not much changes:
```julia
julia> y = NullableCategoricalArray(["Old", "Young", "Middle", "Young"], ordered=true)
4-element CategoricalArrays.NullableCategoricalArray{String,1,UInt32}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

```

Levels still need to be reordered manually:
```julia
julia> levels(y)
3-element Array{String,1}:
 "Middle"
 "Old"   
 "Young" 

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
Nullable{CategoricalArrays.CategoricalValue{String,UInt32}}("Old")

julia> get(y[1])
CategoricalArrays.CategoricalValue{String,UInt32} "Old" (3/3)
```

`Nullable` objects currenty require the [NullableArrays](https://github.com/JuliaStats/NullableArrays.jl)
package to be compared:
```julia
julia> using NullableArrays

julia> get(y[2] == y[4])
true

julia> get(y[2] > y[4])
false

```

Missing values can be introduced either manually, or by restricting the set of possible
levels. Let us imagine this time that we actually do not know the age of the first
individual. We can set it to a missing value this way:
```julia
julia> y[1] = Nullable()
Nullable{Union{}}()

julia> y
4-element CategoricalArrays.NullableCategoricalArray{String,1,UInt32}:
 #NULL   
 "Young" 
 "Middle"
 "Young" 

julia> y[1]
Nullable{CategoricalArrays.CategoricalValue{String,UInt32}}()

```

It is also possible to transform all values belonging to some levels into missing values, which
gives the same result as above in the present case since we have only one individual in the
`"Old"` group. Let's first restore the original value for the first element, and then set it
to missing again using the `nullok` argument to `levels!`:
```julia
julia> y[1] = "Old"
"Old"

julia> y
4-element CategoricalArrays.NullableCategoricalArray{String,1,UInt32}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

julia> levels!(y, ["Young", "Middle"]; nullok=true)
2-element Array{String,1}:
 "Young" 
 "Middle"

julia> y
4-element CategoricalArrays.NullableCategoricalArray{String,1,UInt32}:
 #NULL   
 "Young" 
 "Middle"
 "Young" 

```


# Implementation details

`CategoricalArray` and `NullableCategoricalArray` share a
common implementation for the most part, with the main differences being their element
types. They are based on the `CategoricalPool` type, which keeps track of the
levels and associates them with an integer reference (for internal use). They offer
methods to set levels, change their order while preserving the references, and efficiently
get the integer index corresponding to a level and vice-versa. They are also
parameterized on the type used to store the references, so that small pools can use as little
memory as possible. Finally, they keep a vector of value objects (`CategoricalValue`),
so that `getindex` can return the existing object instead of allocating a new one.

Array types are made of two fields:
- `refs`: an integer vector giving the index of the level in the pool for each element.
For `NullableCategoricalArray`, `0` indicates a missing value.
- `pool`: the `CategoricalPool` object keeping the levels of the array.

Whether an array (and its values) are ordered or not is stored as a property of the pool.

`CategoricalPool` is designed to limit the need to go over all elements of
the vector, either for reading or for writing. This is why unused levels are not dropped
automatically (this would force checking all elements on every modification or keeping a
counts table), but only when `droplevels!` is called.
`levels` is a (very fast) O(1) operation since it merely returns the (ordered) vector of
levels, without accessing the data at all. Another useful property is that integer indices
referring to levels are preserved when adding or reordering levels: the order of levels
exposed to the user by the `levels` function does not necessarily match these internal
indices, which are stored in the `index` field of the pool.
This means a reordering of the levels is also an O(1) operation. On the other
hand, deleting levels may change the indices and therefore requires iterating over all
elements in the array to update the references.
