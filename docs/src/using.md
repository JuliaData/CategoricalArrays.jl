# Using CategoricalArrays

## Basic usage

Suppose that you have data about four individuals, with three different age groups. Since this variable is clearly ordinal, we mark the array as such via the `ordered` argument.

```jldoctest using
julia> using CategoricalArrays

julia> x = CategoricalArray(["Old", "Young", "Middle", "Young"], ordered=true)
4-element CategoricalArray{String,1,UInt32}:
 "Old"
 "Young"
 "Middle"
 "Young"

```

By default, the levels are lexically sorted, which is clearly not correct in our case and would give incorrect results when testing for order. This is easily fixed using the `levels!` function to reorder levels:

```jldoctest using
julia> levels(x)
3-element Vector{String}:
 "Middle"
 "Old"
 "Young"

julia> levels!(x, ["Young", "Middle", "Old"])
4-element CategoricalArray{String,1,UInt32}:
 "Old"
 "Young"
 "Middle"
 "Young"

```

Thanks to this order, we can not only test for equality between two values, but also compare the ages of e.g. individuals 1 and 2:

```jldoctest using
julia> x[1]
CategoricalValue{String, UInt32} "Old" (3/3)

julia> x[2]
CategoricalValue{String, UInt32} "Young" (1/3)

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
CategoricalValue{String, UInt32} "Young" (1/3)

```

The `CategoricalArray` still considers `"Old"` as a possible level even if it is unused now. This is necessary to allow efficiently accessing the levels and setting values of elements in the array: indeed, dropping unused levels requires iterating over every element in the array, which is expensive. This property can also be useful to keep track of possible levels, even if they do not occur in practice.

To get rid of the `"Old"` group, just call the [`droplevels!`](@ref) function:

```jldoctest using
julia> levels(x)
3-element Vector{String}:
 "Young"
 "Middle"
 "Old"

julia> droplevels!(x)
4-element CategoricalArray{String,1,UInt32}:
 "Young"
 "Young"
 "Middle"
 "Young"

julia> levels(x)
2-element Vector{String}:
 "Young"
 "Middle"

```

Another solution would have been to call `levels!(x, ["Young", "Middle"])` manually. This command is safe too, since it will raise an error when trying to remove levels that are currently used:

```jldoctest using
julia> levels!(x, ["Young", "Midle"])
ERROR: ArgumentError: cannot remove level "Middle" as it is used at position 3. Change the array element type to Union{String, Missing} using convert if you want to transform some levels to missing values.
[...]

```

Note that entries in the `x` array cannot be treated as strings. Instead, they need to be converted to strings using `String(x[i])`:
```jldoctest using
julia> lowercase(String(x[3]))
"middle"

julia> replace(String(x[3]), 'M'=>'R')
"Riddle"
```
Note that the call to `String` does not reduce performance compared with working with a `Vector{String}` as it simply returns the string object which is stored by the pool.

Integer codes giving the index of each value in the levels can be obtained using the [`levelcode`](@ref) function:
```jldoctest using
julia> levelcode(x[1])
1

julia> levelcode.(x)
4-element Vector{Int64}:
 1
 1
 2
 1
```

## Handling Missing Values

The examples above assumed that the data contained no missing values. This is generally not the case for real data. This is where `CategoricalArray{Union{T, Missing}}` comes into play. It is essentially the categorical-data equivalent of `Array{Union{T, Missing}}`. It behaves exactly as `CategoricalArray{T}`, except that when indexed it returns either a `CategoricalValue{T}` object or `missing` if the value is missing. See [the Julia manual](https://docs.julialang.org/en/stable/manual/missing/) for more information on the `Missing` type.

Let's adapt the example developed above to support missing values. Since there are no missing values in the input vector, we need to specify that the array should be able to hold either a `String` or `missing`:

```jldoctest using
julia> y = CategoricalArray{Union{Missing, String}}(["Old", "Young", "Middle", "Young"], ordered=true)
4-element CategoricalArray{Union{Missing, String},1,UInt32}:
 "Old"
 "Young"
 "Middle"
 "Young"

```

Levels still need to be reordered manually:

```jldoctest using
julia> levels(y)
3-element Vector{String}:
 "Middle"
 "Old"
 "Young"

julia> levels!(y, ["Young", "Middle", "Old"])
4-element CategoricalArray{Union{Missing, String},1,UInt32}:
 "Old"
 "Young"
 "Middle"
 "Young"

```

At this point, indexing into the array gives exactly the same result

```jldoctest using
julia> y[1]
CategoricalValue{String, UInt32} "Old" (3/3)
```

Missing values can be introduced either manually, or by restricting the set of possible levels. Let us imagine this time that we actually do not know the age of the first individual. We can set it to a missing value this way:

```jldoctest using
julia> y[1] = missing
missing

julia> y
4-element CategoricalArray{Union{Missing, String},1,UInt32}:
 missing
 "Young"
 "Middle"
 "Young"

julia> y[1]
missing

```

It is also possible to transform all values belonging to some levels into missing values, which gives the same result as above in the present case since we have only one individual in the `"Old"` group. Let's first restore the original value for the first element, and then set it to missing again using the `allowmissing` argument to `levels!`:

```jldoctest using
julia> y[1] = "Old"
"Old"

julia> y
4-element CategoricalArray{Union{Missing, String},1,UInt32}:
 "Old"
 "Young"
 "Middle"
 "Young"

julia> levels!(y, ["Young", "Middle"]; allowmissing=true)
4-element CategoricalArray{Union{Missing, String},1,UInt32}:
 missing
 "Young"
 "Middle"
 "Young"

```

Conversely, all missing values can be turned into a "normal" value using `replace`
(or `recode`, whose syntax is identical for this operation):
```jldoctest using
julia> replace(y, missing => "missing value")
4-element CategoricalArray{String,1,UInt32}:
 "missing value"
 "Young"
 "Middle"
 "Young"
```
Note that the returned array no longer allows for missing values (which is usually what is expected).
This syntax works for array types other than `CategoricalArray`.

An in-place variant `replace!` (respectively `recode!`) is also provided. Note that `y` still allows
for missing values (since the type of an object cannot be changed).
```jldoctest using
julia> replace!(y, missing => "missing value");

julia> y
4-element CategoricalArray{Union{Missing, String},1,UInt32}:
 "missing value"
 "Young"
 "Middle"
 "Young"
```

## Combining levels

Some operations imply combining levels of two categorical arrays: this is the case when concatenating arrays (`vcat`, `hcat` and `cat`) and when assigning a `CategoricalValue` from another categorical array.

For example, imagine we have two sets of observations, one with only the younger part of the population and one with the older part:
```jldoctest using
julia> x = categorical(["Middle", "Old", "Middle"], ordered=true);

julia> y = categorical(["Young", "Middle", "Middle"], ordered=true);

julia> levels!(y, ["Young", "Middle"]);
```

If we concatenate the two sets, the levels of the resulting categorical vector are chosen so that the relative orders of levels in `x` and `y` are preserved, if possible. In that case, comparisons with `<` and `>` are still valid, and resulting vector is marked as ordered:
```jldoctest using
julia> xy = vcat(x, y)
6-element CategoricalArray{String,1,UInt32}:
 "Middle"
 "Old"
 "Middle"
 "Young"
 "Middle"
 "Middle"

julia> levels(xy)
3-element Vector{String}:
 "Young"
 "Middle"
 "Old"

julia> isordered(xy)
true
```

Likewise, assigning a `CategoricalValue` from `y` to an entry in `x` expands the levels of `x` with all levels from `y`, *respecting the ordering of levels of both vectors if possible*:
```jldoctest using
julia> levels(x)
2-element Vector{String}:
 "Middle"
 "Old"

julia> x[1] = y[1]
CategoricalValue{String, UInt32} "Young" (1/2)

julia> levels(x)
3-element Vector{String}:
 "Young"
 "Middle"
 "Old"

julia> x[1]
CategoricalValue{String, UInt32} "Young" (1/3)
```

In cases where levels with incompatible orderings are combined, the ordering of the destination array wins and the destination array is marked as unordered. The same happens when concatenating arrays, and the ordering of the first array wins in case of conflict:
```jldoctest using
julia> a = categorical(["a", "b", "c"], ordered=true);

julia> b = categorical(["a", "b", "c"], ordered=true);

julia> ab = vcat(a, b)
6-element CategoricalArray{String,1,UInt32}:
 "a"
 "b"
 "c"
 "a"
 "b"
 "c"

julia> levels(ab)
3-element Vector{String}:
 "a"
 "b"
 "c"

julia> isordered(ab)
true

julia> levels!(b, ["c", "b", "a"])
3-element CategoricalArray{String,1,UInt32}:
 "a"
 "b"
 "c"

julia> ab2 = vcat(a, b)
6-element CategoricalArray{String,1,UInt32}:
 "a"
 "b"
 "c"
 "a"
 "b"
 "c"

julia> levels(ab2)
3-element Vector{String}:
 "a"
 "b"
 "c"

julia> isordered(ab2)
false
```

The resulting array is marked as ordered only if all the source array(s) are ordered, with the exception that unordered arrays with no levels do not prompt the result to be marked as unordered. In particular, this allows assignment of a `CategoricalValue` to an empty `CategoricalArray` via `setindex!` to copy the levels of the source value and to mark the result as ordered.

Do note that in some cases the two sets of levels may have compatible orderings, but it is not possible to determine in what order should levels appear in the merged set. This is the case for example with `["a, "b", "d"]` and `["c", "d", "e"]`: there is no way to detect that `"c"` should be inserted exactly after `"b"` (lexicographic ordering is not relevant here). In such cases, the resulting array is marked as unordered. This situation can only happen when working with data subsets selected based on non-contiguous subsets of levels.

## Exported functions

`categorical(A)` - Construct a categorical array with values from `A`

`compress(A)` - Return a copy of categorical array `A` using the smallest possible reference type

`cut(x)` - Cut a numeric array into intervals and return an ordered `CategoricalArray`

`decompress(A)` - Return a copy of categorical array `A` using the default reference type

`isordered(A)` - Test whether entries in `A` can be compared using `<`, `>` and similar operators

`ordered!(A, ordered)` - Set whether entries in `A` can be compared using `<`, `>` and similar operators

`recode(a[, default], pairs...)` - Return a copy of `a` after replacing one or more values

`recode!(a[, default], pairs...)` - Replace one or more values in `a` in-place

`unwrap(x)` - Return the value contained in categorical value `x`; if `x` is `Missing`
              return `missing`

`levelcode(x)` - Return the code of categorical value `x`, i.e. its index
                  in the set of possible values returned by `levels(x)`.

See [API Index](@ref) for more details.
