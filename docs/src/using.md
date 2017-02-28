# Using CategoricalArrays

## Basic usage

Suppose that you have data about four individuals, with three different age groups. Since this variable is clearly ordinal, we mark the array as such via the `ordered` argument.

```julia
julia> using CategoricalArrays

julia> x = CategoricalArray(["Old", "Young", "Middle", "Young"], ordered=true)
4-element CategoricalArrays.CategoricalArray{String,1,UInt32}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

```

By default, the levels are lexically sorted, which is clearly not correct in our case and would give incorrect results when testing for order. This is easily fixed using the `levels!` function to reorder levels:

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

Thanks to this order, we can not only test for equality between two values, but also compare the ages of e.g. individuals 1 and 2:

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

Now let us imagine the first individual is actually in the "Young" group. Let's fix this (notice how the string `"Young"` is automatically converted to a `CategoricalValue`): 

```julia
julia> x[1] = "Young"
"Young"

julia> x[1]
CategoricalArrays.CategoricalValue{String,UInt32} "Young" (1/3)

```

The `CategoricalArray` still considers `"Old"` as a possible level even if it is unused now. This is necessary to allow efficiently accessing the levels and setting values of elements in the array: indeed, dropping unused levels requires iterating over every element in the array, which is expensive. This property can also be useful to keep track of possible levels, even if they do not occur in practice.

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

Another solution would have been to call `levels!(x, ["Young", "Middle"])` manually. This command is safe too, since it will raise an error when trying to remove levels that are currently used:

```julia
julia> levels!(x, ["Young", "Midle"]) # Note the typo in "Middle"
ERROR: ArgumentError: cannot remove level "Middle" as it is used at position 1. Convert array to a NullableCategoricalArray if you want to transform some levels to missing values.
 in #_levels!#5(::Bool, ::Function, ::CategoricalArrays.CategoricalArray{String,1,UInt32}, ::Array{String,1}) at ~/.julia/CategoricalArrays/src/array.jl:132
 in levels!(::CategoricalArrays.CategoricalArray{String,1,UInt32}, ::Array{String,1}) at ~/.julia/CategoricalArrays/src/array.jl:164
 in eval(::Module, ::Any) at ./boot.jl:225
 in macro expansion at ./REPL.jl:92 [inlined]
 in (::Base.REPL.##1#2{Base.REPL.REPLBackend})() at ./event.jl:46
```

```@docs
droplevels!
levels
levels!
```

## Handling Missing Values: NullableCategoricalArray

The examples above assumed that the data contained no missing values. This is generally not the case in real data. This is where `NullableCategoricalArray` comes into play. It is essentially the categorical-data equivalent of [NullableArrays](https://github.com/JuliaStats/NullableArrays.jl). It behaves exactly the same as `CategoricalArray` , except that it returns `Nullable{CategoricalValue}` elements when indexed. See [the Julia manual](http://docs.julialang.org/en/stable/manual/types/?highlight=nullable#nullable-types-representing-missing-values) for more information on the `Nullable` type.

Let's adapt the example developed above to support missing values. At first sight, not much changes: 

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

A first difference from the previous example is that indexing the array returns a `Nullable` value: 

```julia
julia> y[1]
Nullable{CategoricalArrays.CategoricalValue{String,UInt32}}("Old")

julia> get(y[1])
CategoricalArrays.CategoricalValue{String,UInt32} "Old" (3/3)
```

`Nullable` objects currently require the [NullableArrays](https://github.com/JuliaStats/NullableArrays.jl) package to be compared: 

```julia
julia> using NullableArrays

julia> get(y[2] == y[4])
true

julia> get(y[2] > y[4])
false

```

Missing values can be introduced either manually, or by restricting the set of possible levels. Let us imagine this time that we actually do not know the age of the first individual. We can set it to a missing value this way:

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

It is also possible to transform all values belonging to some levels into missing values, which gives the same result as above in the present case since we have only one individual in the `"Old"` group. Let's first restore the original value for the first element, and then set it to missing again using the `nullok` argument to `levels!`:

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

## Working with categorical arrays

`categorical(A)` - Construct a categorical array with values from `A`

`compress(A)` - Return a copy of categorical array `A` using the smallest possible reference type

`cut(x)` - Cut a numeric array into intervals and return an ordered `CategoricalArray`

`decompress(A)` - Return a copy of categorical array `A` using the default reference type

`isordered(A)` - Test whether entries in `A` can be compared using `<`, `>` and similar operators

`ordered!(A)` - Set whether entries in `A` can be compared using `<`, `>` and similar operators

```@docs
categorical
compress
cut
decompress
isordered
ordered!
```