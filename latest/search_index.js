var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Overview",
    "title": "Overview",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Overview-1",
    "page": "Overview",
    "title": "Overview",
    "category": "section",
    "text": "This package provides a replacement for DataArrays.jl's PooledDataArray type. Contrary to that type, it supports both non-nullable and nullable arrays (i.e. arrays allowing for missing data), using the Null type. It is also based on a simpler design by only supporting categorical data, which allows offering more specialized features (like ordering of categories). See the IndirectArrays.jl package for a simpler array type storing data with a small number of values.The package provides the CategoricalArray type designed to hold categorical data (either unordered/nominal or ordered/ordinal) efficiently and conveniently. CategoricalArray{T} holds values of type T. CategoricalArray{Union{Null, T}}, either holds values of type T, or missing values (represented as null, of the Null type). When indexed, CategoricalArray{T} returns values of type CategoricalValue{T} rather than of type T (or null for missing values).CategoricalValue objects are simple wrappers around the actual categorical levels which allow for very efficient extraction and equality tests. Indeed, the main feature of categorical arrays types is that they store a pool of the levels which can appear in the variable. These levels are stored in a specific order: for unordered arrays, this order is only used for pretty printing (e.g. in cross tables or plots); for ordered arrays, it also allows comparing values using the < and > operators: the comparison is then based on the ordering of levels stored in the array. Whether an array is ordered can be defined either on construction via the ordered argument, or at any time via the ordered! function.Use the levels function to access the levels of a categorical array, and the levels! function to set and order them. Levels are automatically created when setting an element to a previously unused level. On the other hand, they are never removed without manual intervention: use the droplevels! function for this.CategoricalArray{T} is designed to work with any underlying type T, but the most common use case is to use it with T = String. To make it more convenient to work with such arrays, CategoricalValue elements support all operations which work on strings, and is actually a special type of string (i.e. CategoricalValue <: AbstractString). The only difference from a standard String value is that comparisons like < and > are based on the ordering of levels rather than on the lexicographic ordering."
},

{
    "location": "using.html#",
    "page": "Using CategoricalArrays",
    "title": "Using CategoricalArrays",
    "category": "page",
    "text": ""
},

{
    "location": "using.html#Using-CategoricalArrays-1",
    "page": "Using CategoricalArrays",
    "title": "Using CategoricalArrays",
    "category": "section",
    "text": ""
},

{
    "location": "using.html#CategoricalArrays.droplevels!",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.droplevels!",
    "category": "Function",
    "text": "droplevels!(A::CategoricalArray)\n\nDrop levels which do not appear in categorical array A (so that they will no longer be returned by levels).\n\n\n\n"
},

{
    "location": "using.html#CategoricalArrays.levels",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.levels",
    "category": "Function",
    "text": "levels(A::CategoricalArray)\n\nReturn the levels of categorical array A. This may include levels which do not actually appear in the data (see droplevels!).\n\nAs a special case, null is never included in the levels, even if the array contains missing values.\n\n\n\n"
},

{
    "location": "using.html#CategoricalArrays.levels!",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.levels!",
    "category": "Function",
    "text": "levels!(A::CategoricalArray, newlevels::Vector; nullok::Bool=false)\n\nSet the levels categorical array A. The order of appearance of levels will be respected by levels, which may affect display of results in some operations; if A is ordered (see isordered), it will also be used for order comparisons using <, > and similar operators. Reordering levels will never affect the values of entries in the array.\n\nIf A is nullable (i.e. eltype(A) >: Null) and nullok=true, entries corresponding to missing levels will be set to null. Else, newlevels must include all levels which appear in the data.\n\n\n\n"
},

{
    "location": "using.html#Basic-usage-1",
    "page": "Using CategoricalArrays",
    "title": "Basic usage",
    "category": "section",
    "text": "Suppose that you have data about four individuals, with three different age groups. Since this variable is clearly ordinal, we mark the array as such via the ordered argument.julia> using CategoricalArrays\n\njulia> x = CategoricalArray([\"Old\", \"Young\", \"Middle\", \"Young\"], ordered=true)\n4-element CategoricalArrays.CategoricalArray{String,1,UInt32,String,Union{}}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \nBy default, the levels are lexically sorted, which is clearly not correct in our case and would give incorrect results when testing for order. This is easily fixed using the levels! function to reorder levels:julia> levels(x)\n3-element Array{String,1}:\n \"Middle\"\n \"Old\"   \n \"Young\" \n\njulia> levels!(x, [\"Young\", \"Middle\", \"Old\"])\n4-element CategoricalArrays.CategoricalArray{String,1,UInt32,String,Union{}}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \nThanks to this order, we can not only test for equality between two values, but also compare the ages of e.g. individuals 1 and 2:julia> x[1]\nCategoricalArrays.CategoricalValue{String,UInt32} \"Old\" (3/3)\n\njulia> x[2]\nCategoricalArrays.CategoricalValue{String,UInt32} \"Young\" (1/3)\n\njulia> x[2] == x[4]\ntrue\n\njulia> x[1] > x[2]\ntrue\nNow let us imagine the first individual is actually in the \"Young\" group. Let's fix this (notice how the string \"Young\" is automatically converted to a CategoricalValue): julia> x[1] = \"Young\"\n\"Young\"\n\njulia> x[1]\nCategoricalArrays.CategoricalValue{String,UInt32} \"Young\" (1/3)\nThe CategoricalArray still considers \"Old\" as a possible level even if it is unused now. This is necessary to allow efficiently accessing the levels and setting values of elements in the array: indeed, dropping unused levels requires iterating over every element in the array, which is expensive. This property can also be useful to keep track of possible levels, even if they do not occur in practice.To get rid of the \"Old\" group, just call the droplevels! function:julia> levels(x)\n3-element Array{String,1}:\n \"Young\" \n \"Middle\"\n \"Old\"   \n\njulia> droplevels!(x)\n4-element CategoricalArrays.CategoricalArray{String,1,UInt32,String,Union{}}:\n \"Young\" \n \"Young\" \n \"Middle\"\n \"Young\" \n\njulia> levels(x)\n2-element Array{String,1}:\n \"Young\" \n \"Middle\"\nAnother solution would have been to call levels!(x, [\"Young\", \"Middle\"]) manually. This command is safe too, since it will raise an error when trying to remove levels that are currently used:julia> levels!(x, [\"Young\", \"Midle\"]) \nERROR: ArgumentError: cannot remove level \"Middle\" as it is used at position 3. Change the array element type to Union{String, Null} using convert if you want to transform some levels to missing values.\n[...]\nNote that entries in the x array can be treated as strings even though they are CategoricalValue objects:julia> x[3] = lowercase(x[3])\n\"middle\"\n\njulia> x[3]\nCategoricalArrays.CategoricalValue{String,UInt32} \"middle\" (3/3)\n\njulia> droplevels!(x)\n4-element CategoricalArrays.CategoricalArray{String,1,UInt32,String,Union{}}:\n \"Young\" \n \"Young\" \n \"middle\"\n \"Young\" \n\njulia> x[3]\nCategoricalArrays.CategoricalValue{String,UInt32} \"middle\" (2/2)\ndroplevels!\nlevels\nlevels!"
},

{
    "location": "using.html#Handling-Missing-Values-1",
    "page": "Using CategoricalArrays",
    "title": "Handling Missing Values",
    "category": "section",
    "text": "The examples above assumed that the data contained no missing values. This is generally not the case in real data. This is where CategoricalArray{Union{T, Null}} comes into play. It is essentially the categorical-data equivalent of Array{Union{T, Null}}. It behaves exactly the same as CategoricalArray{T} , except that when indexed it returns either a CategoricalValue{T}, or null if a value is missing. See the Nulls package for more information on the Null type.Let's adapt the example developed above to support missing values. Since there are no missing values in the input vector, we need to specify that the array should be able to hold either a String or null:julia> using Nulls\n\njulia> y = CategoricalArray{Union{Null, String}}([\"Old\", \"Young\", \"Middle\", \"Young\"], ordered=true)\n4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \nLevels still need to be reordered manually:julia> levels(y)\n3-element Array{String,1}:\n \"Middle\"\n \"Old\"   \n \"Young\" \n\njulia> levels!(y, [\"Young\", \"Middle\", \"Old\"])\n4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \n At this point, indexing into the array gives exactly the same resultjulia> y[1]\nCategoricalArrays.CategoricalValue{String,UInt32} \"Old\" (3/3)Missing values can be introduced either manually, or by restricting the set of possible levels. Let us imagine this time that we actually do not know the age of the first individual. We can set it to a missing value this way:julia> y[1] = null\nnull\n\njulia> y\n4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:\n null    \n \"Young\" \n \"Middle\"\n \"Young\" \n\njulia> y[1]\nnull\nIt is also possible to transform all values belonging to some levels into missing values, which gives the same result as above in the present case since we have only one individual in the \"Old\" group. Let's first restore the original value for the first element, and then set it to missing again using the nullok argument to levels!:julia> y[1] = \"Old\"\n\"Old\"\n\njulia> y\n4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \n\njulia> levels!(y, [\"Young\", \"Middle\"]; nullok=true)\n4-element CategoricalArrays.CategoricalArray{Union{Nulls.Null, String},1,UInt32,String,Nulls.Null}:\n null    \n \"Young\" \n \"Middle\"\n \"Young\" \n"
},

{
    "location": "using.html#CategoricalArrays.categorical",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.categorical",
    "category": "Function",
    "text": "categorical{T}(A::AbstractArray{T}[, compress::Bool]; ordered::Bool=false)\n\nConstruct a categorical array with the values from A.\n\nIf the element type supports it, levels are sorted in ascending order; else, they are kept in their order of appearance in A. The ordered keyword argument determines whether the array values can be compared according to the ordering of levels or not (see isordered).\n\nIf compress is provided and set to true, the smallest reference type able to hold the number of unique values in A will be used. While this will reduce memory use, passing this parameter will also introduce a type instability which can affect performance inside the function where the call is made. Therefore, use this option with caution (the one-argument version does not suffer from this problem).\n\ncategorical{T}(A::CategoricalArray{T}[, compress::Bool]; ordered::Bool=isordered(A))\n\nIf A is already a CategoricalArray, its levels are preserved; the same applies to the ordered property, and to the reference type unless compress is passed.\n\n\n\n"
},

{
    "location": "using.html#CategoricalArrays.compress",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.compress",
    "category": "Function",
    "text": "compress(A::CategoricalArray)\n\nReturn a copy of categorical array A using the smallest reference type able to hold the number of levels of A.\n\nWhile this will reduce memory use, this function is type-unstable, which can affect performance inside the function where the call is made. Therefore, use it with caution.\n\n\n\n"
},

{
    "location": "using.html#CategoricalArrays.cut",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.cut",
    "category": "Function",
    "text": "cut(x::AbstractArray, breaks::AbstractVector;\n    extend::Bool=false, labels::AbstractVector=[], nullok::Bool=false)\n\nCut a numeric array into intervals and return an ordered CategoricalArray indicating the interval into which each entry falls. Intervals are of the form [lower, upper), i.e. the lower bound is included and the upper bound is excluded.\n\nIf x is nullable (i.e. eltype(x) >: Null), a nullable CategoricalArray is returned.\n\nArguments\n\nextend::Bool=false: when false, an error is raised if some values in x fall outside of the breaks; when true, breaks are automatically added to include all values in x, and the upper bound is included in the last interval.\nlabels::AbstractVector=[]: a vector of strings giving the names to use for the intervals; if empty, default labels are used.\nnullok::Bool=true: when true, values outside of breaks result in null values. only supported when x is nullable.\n\n\n\ncut(x::AbstractArray, ngroups::Integer;\n    labels::AbstractVector=String[])\n\nCut a numeric array into ngroups quantiles, determined using quantile.\n\n\n\n"
},

{
    "location": "using.html#CategoricalArrays.decompress",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.decompress",
    "category": "Function",
    "text": "decompress(A::CategoricalArray)\n\nReturn a copy of categorical array A using the default reference type (UInt32). If A is using a small reference type (such as UInt8 or UInt16) the decompressed array will have room for more levels.\n\nTo avoid the need to call decompress, ensure compress is not called when creating the categorical array.\n\n\n\n"
},

{
    "location": "using.html#CategoricalArrays.isordered",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.isordered",
    "category": "Function",
    "text": "isordered(A::CategoricalArray)\n\nTest whether entries in A can be compared using <, > and similar operators, using the ordering of levels.\n\n\n\n"
},

{
    "location": "using.html#CategoricalArrays.ordered!",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.ordered!",
    "category": "Function",
    "text": "ordered!(A::CategoricalArray, ordered::Bool)\n\nSet whether entries in A can be compared using <, > and similar operators, using the ordering of levels. Return the modified A.\n\n\n\n"
},

{
    "location": "using.html#CategoricalArrays.recode",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.recode",
    "category": "Function",
    "text": "recode(a::AbstractArray[, default::Any], pairs::Pair...)\n\nReturn a copy of a, replacing elements matching a key of pairs with the corresponding value. The type of the array is chosen so that it can hold all recoded elements (but not necessarily original elements from a).\n\nFor each Pair in pairs, if the element is equal to (according to ==) or in the key (first item of the pair), then the corresponding value (second item) is used. If the element matches no key and default is not provided or nothing, it is copied as-is; if default is specified, it is used in place of the original element. If an element matches more than one key, the first match is used.\n\nExamples\n\njulia> using CategoricalArrays\n\njulia> recode(1:10, 1=>100, 2:4=>0, [5; 9:10]=>-1)\n10-element Array{Int64,1}:\n 100\n   0\n   0\n   0\n  -1\n   6\n   7\n   8\n  -1\n  -1\n\n\n recode(a::AbstractArray{>:Null}[, default::Any], pairs::Pair...)\n\nFor a nullable array a, null values are never replaced with default: use null in a pair to recode them. If that's not the case, the returned array will be nullable.\n\nExamples\n\njulia> using CategoricalArrays, Nulls\n\njulia> recode(1:10, 1=>100, 2:4=>0, [5; 9:10]=>-1, 6=>null)\n10-element Array{Union{Int64, Nulls.Null},1}:\n 100    \n   0    \n   0    \n   0    \n  -1    \n    null\n   7    \n   8    \n  -1    \n  -1    \n\n\n\n\n"
},

{
    "location": "using.html#CategoricalArrays.recode!",
    "page": "Using CategoricalArrays",
    "title": "CategoricalArrays.recode!",
    "category": "Function",
    "text": "recode!(dest::AbstractArray, src::AbstractArray[, default::Any], pairs::Pair...)\n\nFill dest with elements from src, replacing those matching a key of pairs with the corresponding value.\n\nFor each Pair in pairs, if the element is equal to (according to ==) or in the key (first item of the pair), then the corresponding value (second item) is copied to dest. If the element matches no key and default is not provided or nothing, it is copied as-is; if default is specified, it is used in place of the original element. dest and src must be of the same length, but not necessarily of the same type. Elements of src as well as values from pairs will be converted when possible on assignment. If an element matches more than one key, the first match is used.\n\nrecode!(dest::AbstractArray, src::AbstractArray{>:Null}[, default::Any], pairs::Pair...)\n\nFor a nullable array a, null values are never replaced with default: use null in a pair to recode them. If that's not the case, the returned array will be nullable.\n\n\n\n"
},

{
    "location": "using.html#Working-with-categorical-arrays-1",
    "page": "Using CategoricalArrays",
    "title": "Working with categorical arrays",
    "category": "section",
    "text": "categorical(A) - Construct a categorical array with values from Acompress(A) - Return a copy of categorical array A using the smallest possible reference typecut(x) - Cut a numeric array into intervals and return an ordered CategoricalArraydecompress(A) - Return a copy of categorical array A using the default reference typeisordered(A) - Test whether entries in A can be compared using <, > and similar operatorsordered!(A) - Set whether entries in A can be compared using <, > and similar operatorsrecode(a[, default], pairs...) - Return a copy of a after replacing one or more valuesrecode!(a[, default], pairs...) - Replace one or more values in a in-placecategorical\ncompress\ncut\ndecompress\nisordered\nordered!\nrecode\nrecode!"
},

{
    "location": "implementation.html#",
    "page": "Implementation details",
    "title": "Implementation details",
    "category": "page",
    "text": ""
},

{
    "location": "implementation.html#Implementation-details-1",
    "page": "Implementation details",
    "title": "Implementation details",
    "category": "section",
    "text": "CategoricalArray is based on the CategoricalPool type, which keeps track of the levels and associates them with an integer reference (for internal use). It offers methods to set levels, change their order while preserving the references, and efficiently get the integer index corresponding to a level and vice-versa. It is also parameterized on the type used to store the references, so that small pools can use as little memory as possible. Finally, it keeps a vector of value objects (CategoricalValue), so that getindex can return the existing object instead of allocating a new one.CategoricalArray is made of two fields:refs: an integer vector giving the index of the level in the pool for each element; if the array is nullable, 0 indicates a missing value.\npool: the CategoricalPool object keeping the levels of the array.Whether an array (and its values) are ordered or not is stored as a property of the pool.The type parameters of CategoricalArray{T, N, R <: Integer, U, V} are a bit complex. T corresponds to the element type of the array, ignoring the CategoricalValue wrapper; if T >: Null, then the array is nullable. N corresponds to the number of dimensions of the array. R is the reference type, i.e. the element type of the refs field. V corresponds to the type of the levels, which is equal to T for non-nullable arrays; for nullable arrays, T = Union{Null, V}. Finally, U is equal to Union{} for non-nullable arrays, and to Null for nullable arrays. The two last types are redundant with T, but are needed for the definition of the type, in particular so that it inherits from AbstractArray{Union{CategoricalValue{V, R}, U}, N} (which is equivalent to AbstractArray{CategoricalValue{T, R}, N} for non-nullable arrays, and to AbstractArray{Union{CategoricalValue{T, R}, Null}, N} for nullable arrays).CategoricalPool is designed to limit the need to go over all elements of the vector, either for reading or for writing. This is why unused levels are not dropped automatically (this would force checking all elements on every modification or keeping a counts table), but only when droplevels! is called. levels is a (very fast) O(1) operation since it merely returns the (ordered) vector of levels without accessing the data at all.Another useful property is that integer indices referring to levels are preserved when adding or reordering levels: the order of levels exposed to the user by the levels function does not necessarily match these internal indices, which are stored in the index field of the pool. This means a reordering of the levels is also an O(1) operation. On the other hand, deleting levels may change the indices and therefore requires iterating over all elements in the array to update the references."
},

{
    "location": "functionindex.html#",
    "page": "Index",
    "title": "Index",
    "category": "page",
    "text": ""
},

{
    "location": "functionindex.html#Index-1",
    "page": "Index",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
