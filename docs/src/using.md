# Using CategoricalArrays

## Basic usage

Suppose that you have data about four individuals, with three different age groups. Since this variable is clearly ordinal, we mark the array as such via the `ordered` argument.

```jldoctest using
julia> using CategoricalArrays

julia> x = CategoricalArray(["Old", "Young", "Middle", "Young"], ordered=true)
4-element CategoricalArrays.CategoricalArray{String,1,UInt32,String,Union{}}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

```

By default, the levels are lexically sorted, which is clearly not correct in our case and would give incorrect results when testing for order. This is easily fixed using the `levels!` function to reorder levels:

```jldoctest using
julia> levels(x)
3-element Array{String,1}:
 "Middle"
 "Old"   
 "Young" 

julia> levels!(x, ["Young", "Middle", "Old"])
4-element CategoricalArrays.CategoricalArray{String,1,UInt32,String,Union{}}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

```

Thanks to this order, we can not only test for equality between two values, but also compare the ages of e.g. individuals 1 and 2:

```jldoctest using
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

```jldoctest using
julia> x[1] = "Young"
"Young"

julia> x[1]
CategoricalArrays.CategoricalValue{String,UInt32} "Young" (1/3)

```

The `CategoricalArray` still considers `"Old"` as a possible level even if it is unused now. This is necessary to allow efficiently accessing the levels and setting values of elements in the array: indeed, dropping unused levels requires iterating over every element in the array, which is expensive. This property can also be useful to keep track of possible levels, even if they do not occur in practice.

To get rid of the `"Old"` group, just call the `droplevels!` function:

```jldoctest using
julia> levels(x)
3-element Array{String,1}:
 "Young" 
 "Middle"
 "Old"   

julia> droplevels!(x)
4-element CategoricalArrays.CategoricalArray{String,1,UInt32,String,Union{}}:
 "Young" 
 "Young" 
 "Middle"
 "Young" 

julia> levels(x)
2-element Array{String,1}:
 "Young" 
 "Middle"

```

Another solution would have been to call `levels!(x, ["Young", "Middle"])` manually. This command is safe too, since it will raise an error when trying to remove levels that are currently used:

```jldoctest using
julia> levels!(x, ["Young", "Midle"]) 
ERROR: ArgumentError: cannot remove level "Middle" as it is used at position 3. Change the array element type to ?String using convert if you want to transform some levels to missing values.
[...]

```

```@docs
droplevels!
levels
levels!
```

## Handling Missing Values

The examples above assumed that the data contained no missing values. This is generally not the case in real data. This is where `CategoricalArray{?T}` comes into play. It is essentially the categorical-data equivalent of `Array{?T}`. It behaves exactly the same as `CategoricalArray{T}` , except that when indexed it returns either a `CategoricalValue{T}`, or `null` if a value is missing. See [the Nulls package](https://github.com/JuliaData/Nulls.jl) for more information on the `Null` type.

Let's adapt the example developed above to support missing values. Since there are no missing values in the input vector, we need to specify that the array should be able to hold eithera `String` or `null`. Here, `?String` is a shorthand for `Union{Null, String}`:

```jldoctest using
julia> using Nulls

julia> y = CategoricalArray{?String}(["Old", "Young", "Middle", "Young"], ordered=true)
4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

```

Levels still need to be reordered manually:

```jldoctest using
julia> levels(y)
3-element Array{String,1}:
 "Middle"
 "Old"   
 "Young" 

julia> levels!(y, ["Young", "Middle", "Old"])
4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 
 
```

At this point, indexing into the array gives exactly the same result

```jldoctest using
julia> y[1]
CategoricalArrays.CategoricalValue{String,UInt32} "Old" (3/3)
```

Missing values can be introduced either manually, or by restricting the set of possible levels. Let us imagine this time that we actually do not know the age of the first individual. We can set it to a missing value this way:

```jldoctest using
julia> y[1] = null
null

julia> y
4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:
 null    
 "Young" 
 "Middle"
 "Young" 

julia> y[1]
null

```

It is also possible to transform all values belonging to some levels into missing values, which gives the same result as above in the present case since we have only one individual in the `"Old"` group. Let's first restore the original value for the first element, and then set it to missing again using the `nullok` argument to `levels!`:

```jldoctest using
julia> y[1] = "Old"
"Old"

julia> y
4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:
 "Old"   
 "Young" 
 "Middle"
 "Young" 

julia> levels!(y, ["Young", "Middle"]; nullok=true)
4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:
 null    
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

`recode(a[, default], pairs...)` - Return a copy of `a` after replacing one or more values

`recode!(a[, default], pairs...)` - Replace one or more values in `a` in-place

```@docs
categorical
compress
cut
decompress
isordered
ordered!
recode
recode!
```
