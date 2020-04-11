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
    "text": "The package provides the CategoricalArray type designed to hold categorical data (either unordered/nominal or ordered/ordinal) efficiently and conveniently. CategoricalArray{T} holds values of type T. The CategoricalArray{Union{T, Missing}} variant can also contain missing values (represented as missing, of the Missing type). When indexed, CategoricalArray{T} returns special CategoricalValue{T} objects rather than the original values of type T. CategoricalValue is a simple wrapper around the categorical levels; it allows very efficient retrieval and comparison of actual values. See the PooledArrays.jl and IndirectArrays.jl packages for simpler array types storing data with a small number of values without wrapping them.The main feature of CategoricalArray is that it maintains a pool of the levels which can appear in the data. These levels are stored in a specific order: for unordered arrays, this order is only used for pretty printing (e.g. in cross tables or plots); for ordered arrays, it also allows comparing values using the < and > operators: the comparison is then based on the ordering of levels stored in the array. An ordered CategoricalValue can be also compared with a value that when converted is equal to one of the levels of this CategoricalValue. Whether an array is ordered can be defined either on construction via the ordered argument, or at any time via the ordered! function. The levels function returns all the levels of CategoricalArray, and the levels! function can be used to set the levels and their order. Levels are also automatically extended when setting an array element to a level not encountered before. But they are never removed without manual intervention: use the droplevels! function for this."
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
    "location": "using.html#Basic-usage-1",
    "page": "Using CategoricalArrays",
    "title": "Basic usage",
    "category": "section",
    "text": "Suppose that you have data about four individuals, with three different age groups. Since this variable is clearly ordinal, we mark the array as such via the ordered argument.julia> using CategoricalArrays\n\njulia> x = CategoricalArray([\"Old\", \"Young\", \"Middle\", \"Young\"], ordered=true)\n4-element CategoricalArray{String,1,UInt32}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \nBy default, the levels are lexically sorted, which is clearly not correct in our case and would give incorrect results when testing for order. This is easily fixed using the levels! function to reorder levels:julia> levels(x)\n3-element Array{String,1}:\n \"Middle\"\n \"Old\"   \n \"Young\" \n\njulia> levels!(x, [\"Young\", \"Middle\", \"Old\"])\n4-element CategoricalArray{String,1,UInt32}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \nThanks to this order, we can not only test for equality between two values, but also compare the ages of e.g. individuals 1 and 2:julia> x[1]\nCategoricalValue{String,UInt32} \"Old\" (3/3)\n\njulia> x[2]\nCategoricalValue{String,UInt32} \"Young\" (1/3)\n\njulia> x[2] == x[4]\ntrue\n\njulia> x[1] > x[2]\ntrue\nNow let us imagine the first individual is actually in the \"Young\" group. Let\'s fix this (notice how the string \"Young\" is automatically converted to a CategoricalValue):julia> x[1] = \"Young\"\n\"Young\"\n\njulia> x[1]\nCategoricalValue{String,UInt32} \"Young\" (1/3)\nThe CategoricalArray still considers \"Old\" as a possible level even if it is unused now. This is necessary to allow efficiently accessing the levels and setting values of elements in the array: indeed, dropping unused levels requires iterating over every element in the array, which is expensive. This property can also be useful to keep track of possible levels, even if they do not occur in practice.To get rid of the \"Old\" group, just call the droplevels! function:julia> levels(x)\n3-element Array{String,1}:\n \"Young\" \n \"Middle\"\n \"Old\"   \n\njulia> droplevels!(x)\n4-element CategoricalArray{String,1,UInt32}:\n \"Young\" \n \"Young\" \n \"Middle\"\n \"Young\" \n\njulia> levels(x)\n2-element Array{String,1}:\n \"Young\" \n \"Middle\"\nAnother solution would have been to call levels!(x, [\"Young\", \"Middle\"]) manually. This command is safe too, since it will raise an error when trying to remove levels that are currently used:julia> levels!(x, [\"Young\", \"Midle\"])\nERROR: ArgumentError: cannot remove level \"Middle\" as it is used at position 3. Change the array element type to Union{String, Missing} using convert if you want to transform some levels to missing values.\n[...]\nNote that entries in the x array cannot be treated as strings. Instead, they need to be converted to strings using String(x[i]):julia> lowercase(String(x[3]))\n\"middle\"\n\njulia> replace(String(x[3]), \'M\'=>\'R\')\n\"Riddle\"Note that the call to String does reduce performance compared with working with a Vector{String} as it simply returns the string object which is stored by the pool.droplevels!\nlevels\nlevels!"
},

{
    "location": "using.html#Handling-Missing-Values-1",
    "page": "Using CategoricalArrays",
    "title": "Handling Missing Values",
    "category": "section",
    "text": "The examples above assumed that the data contained no missing values. This is generally not the case for real data. This is where CategoricalArray{Union{T, Missing}} comes into play. It is essentially the categorical-data equivalent of Array{Union{T, Missing}}. It behaves exactly as CategoricalArray{T}, except that when indexed it returns either a CategoricalValue{T} object or missing if the value is missing. See the Julia manual for more information on the Missing type.Let\'s adapt the example developed above to support missing values. Since there are no missing values in the input vector, we need to specify that the array should be able to hold either a String or missing:julia> y = CategoricalArray{Union{Missing, String}}([\"Old\", \"Young\", \"Middle\", \"Young\"], ordered=true)\n4-element CategoricalArray{Union{Missing, String},1,UInt32}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \nLevels still need to be reordered manually:julia> levels(y)\n3-element Array{String,1}:\n \"Middle\"\n \"Old\"   \n \"Young\" \n\njulia> levels!(y, [\"Young\", \"Middle\", \"Old\"])\n4-element CategoricalArray{Union{Missing, String},1,UInt32}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \nAt this point, indexing into the array gives exactly the same resultjulia> y[1]\nCategoricalValue{String,UInt32} \"Old\" (3/3)Missing values can be introduced either manually, or by restricting the set of possible levels. Let us imagine this time that we actually do not know the age of the first individual. We can set it to a missing value this way:julia> y[1] = missing\nmissing\n\njulia> y\n4-element CategoricalArray{Union{Missing, String},1,UInt32}:\n missing\n \"Young\" \n \"Middle\"\n \"Young\" \n\njulia> y[1]\nmissing\nIt is also possible to transform all values belonging to some levels into missing values, which gives the same result as above in the present case since we have only one individual in the \"Old\" group. Let\'s first restore the original value for the first element, and then set it to missing again using the allowmissing argument to levels!:julia> y[1] = \"Old\"\n\"Old\"\n\njulia> y\n4-element CategoricalArray{Union{Missing, String},1,UInt32}:\n \"Old\"   \n \"Young\" \n \"Middle\"\n \"Young\" \n\njulia> levels!(y, [\"Young\", \"Middle\"]; allowmissing=true)\n4-element CategoricalArray{Union{Missing, String},1,UInt32}:\n missing\n \"Young\" \n \"Middle\"\n \"Young\" \n"
},

{
    "location": "using.html#Combining-levels-1",
    "page": "Using CategoricalArrays",
    "title": "Combining levels",
    "category": "section",
    "text": "Some operations imply combining levels of two categorical arrays: this is the case when concatenating arrays (vcat, hcat and cat) and when assigning a CategoricalValue from another categorical array.For example, imagine we have two sets of observations, one with only the younger part of the population and one with the older part:julia> x = categorical([\"Middle\", \"Old\", \"Middle\"], ordered=true);\n\njulia> y = categorical([\"Young\", \"Middle\", \"Middle\"], ordered=true);\n\njulia> levels!(y, [\"Young\", \"Middle\"]);If we concatenate the two sets, the levels of the resulting categorical vector are chosen so that the relative orders of levels in x and y are preserved, if possible. In that case, comparisons with < and > are still valid, and resulting vector is marked as ordered:julia> xy = vcat(x, y)\n6-element CategoricalArray{String,1,UInt32}:\n \"Middle\"\n \"Old\"   \n \"Middle\"\n \"Young\" \n \"Middle\"\n \"Middle\"\n\njulia> levels(xy)\n3-element Array{String,1}:\n \"Young\" \n \"Middle\"\n \"Old\"   \n\njulia> isordered(xy)\ntrueLikewise, assigning a CategoricalValue from y to an entry in x expands the levels of x, adding a new level to the front to respect the ordering of levels in both vectors. The new level is added even if the assigned value belongs to another level which is already present in x. Note that adding new levels requires marking x as unordered:julia> x[1] = y[1]\nERROR: cannot add new level Young since ordered pools cannot be extended implicitly. Use the levels! function to set new levels, or the ordered! function to mark the pool as unordered.\nStacktrace:\n[...]\n\njulia> ordered!(x, false);\n\njulia> levels(x)\n2-element Array{String,1}:\n \"Middle\"\n \"Old\"   \n\njulia> x[1] = y[1]\nCategoricalValue{String,UInt32} \"Old\" (3/3)\n\njulia> levels(x)\n3-element Array{String,1}:\n \"Young\" \n \"Middle\"\n \"Old\"   In cases where levels with incompatible orderings are combined, the ordering of the first array wins and the resulting array is marked as unordered:julia> a = categorical([\"a\", \"b\", \"c\"], ordered=true);\n\njulia> b = categorical([\"a\", \"b\", \"c\"], ordered=true);\n\njulia> ab = vcat(a, b)\n6-element CategoricalArray{String,1,UInt32}:\n \"a\"\n \"b\"\n \"c\"\n \"a\"\n \"b\"\n \"c\"\n\njulia> levels(ab)\n3-element Array{String,1}:\n \"a\"\n \"b\"\n \"c\"\n\njulia> isordered(ab)\ntrue\n\njulia> levels!(b, [\"c\", \"b\", \"a\"])\n3-element CategoricalArray{String,1,UInt32}:\n \"a\"\n \"b\"\n \"c\"\n\njulia> ab2 = vcat(a, b)\n6-element CategoricalArray{String,1,UInt32}:\n \"a\"\n \"b\"\n \"c\"\n \"a\"\n \"b\"\n \"c\"\n\njulia> levels(ab2)\n3-element Array{String,1}:\n \"a\"\n \"b\"\n \"c\"\n\njulia> isordered(ab2)\nfalseDo note that in some cases the two sets of levels may have compatible orderings, but it is not possible to determine in what order should levels appear in the merged set. This is the case for example with [\"a, \"b\", \"d\"] and [\"c\", \"d\", \"e\"]: there is no way to detect that \"c\" should be inserted exactly after \"b\" (lexicographic ordering is not relevant here). In such cases, the resulting array is marked as unordered. This situation can only happen when working with data subsets selected based on non-contiguous subsets of levels."
},

{
    "location": "using.html#Exported-functions-1",
    "page": "Using CategoricalArrays",
    "title": "Exported functions",
    "category": "section",
    "text": "categorical(A) - Construct a categorical array with values from Acompress(A) - Return a copy of categorical array A using the smallest possible reference typecut(x) - Cut a numeric array into intervals and return an ordered CategoricalArraydecompress(A) - Return a copy of categorical array A using the default reference typeisordered(A) - Test whether entries in A can be compared using <, > and similar operatorsordered!(A, ordered) - Set whether entries in A can be compared using <, > and similar operatorsrecode(a[, default], pairs...) - Return a copy of a after replacing one or more valuesrecode!(a[, default], pairs...) - Replace one or more values in a in-placecategorical\ncompress\ncut\ndecompress\nisordered\nordered!\nrecode\nrecode!"
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
    "text": "CategoricalArray is made of the two fields:refs: an integer array that stores the position of the category level in the levels field of CategoricalPool for each CategoricalArray element; 0 denotes a missing value (for CategoricalArray{Union{T, Missing}} only).\npool: the CategoricalPool object that maintains the levels of the array.The CategoricalPool{V,R,C} type keeps track of the levels of type V and associates them with an integer reference code of type R (for internal use). It offers methods to add new levels, and efficiently get the integer index corresponding to a level and vice-versa. Whether the values of CategoricalArray are ordered or not is defined by an ordered field of the pool. Finally, CategoricalPool{V,R,C} keeps a valindex vector of value objects of type C == CategoricalValue{V, R}, so that getindex can return the existing object instead of allocating a new one.Do note that CategoricalPool levels are semi-mutable: it is only allowed to add new levels, but never to remove or reorder existing ones. This ensures existing CategoricalValue objects remain valid and always point to the same level as when they were created. Therefore, CategoricalArrays create a new pool each time some of their levels are removed or reordered. This happens when calling levels!, but also when assigning a CategoricalValue via setindex!, push!, append!, copy! or copyto! (as new levels may be added to the front to preserve relative order of both source and destination levels). Doing so requires updating all reference codes to point to the new pool, and makes it impossible to compare existing ordered CategoricalValue objects with values from the array using < and >.The type parameters of CategoricalArray{T, N, R <: Integer, V, C, U} are a bit complex:T is the type of array elements without CategoricalValue wrappers; if T >: Missing, then the array supports missing values.\nN is the number of array dimensions.\nR is the reference type, the element type of the refs field; it allows optimizing memory usage depending on the number of levels (i.e. CategoricalArray with less than 256 levels can use R = UInt8).\nV is the type of the levels, it is equal to T for arrays which do not support missing values; for arrays which support missing values, T = Union{V, Missing}\nC is the type of categorical values, i.e. of the objects returned when indexing non-missing elements of CategoricalArray. It is always equal to CategoricalValue{V, R}, and only present for technical reasons (to break the recursive dependency between CategoricalArray and CategoricalValue).\nU can be either Union{} for arrays which do not support missing values, or Missing for those which support them.Only T, N and R could be specified upon construction. The last three parameters are chosen automatically, but are needed for the definition of the type. In particular, U allows expressing that CategoricalArray{T, N} inherits from AbstractArray{Union{C, U}, N} (which is equivalent to AbstractArray{C, N} for arrays which do not support missing values, and to AbstractArray{Union{C, Missing}, N} for those which support them).The CategoricalPool type is designed to limit the need to go over all elements of the vector, either for reading or for writing. This is why unused levels are not dropped automatically (this would force checking all elements on every modification or keeping a counts table), but only when droplevels! is called. levels is a (very fast) O(1) operation since it merely returns the (ordered) vector of levels without accessing the data at all."
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
