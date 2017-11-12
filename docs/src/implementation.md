# Implementation details

`CategoricalArray` is made of the two fields:

- `refs`: an integer array that stores the position of the category level in the `index` field of `CategoricalPool` for each `CategoricalArray` element; `0` denotes a missing value (for `CategoricalArray{Union{T, Missing}}` only).
- `pool`: the `CategoricalPool` object that maintains the levels of the array.

The `CategoricalPool{V,R,C}` type keeps track of the levels of type `V` and associates them with an integer reference code of type `R` (for internal use). It offers methods to set the levels, change their order while preserving the references, and efficiently get the integer index corresponding to a level and vice-versa. Whether the values of `CategoricalArray` are ordered or not is defined by an `ordered` field of the pool. Finally, `CategoricalPool` keeps a `valindex` vector of value objects of type `C` (`CategoricalString{R}` or `CategoricalValue{V, R}`), so that `getindex` can return the existing object instead of allocating a new one.

The type parameters of `CategoricalArray{T, N, R <: Integer, V, C, U}` are a bit complex:
 - `T` is the type of array elements without `CategoricalString`/`CategoricalValue` wrappers; if `T >: Missing`, then the array supports missing values.
 - `N` is the number of array dimensions.
 - `R` is the reference type, the element type of the `refs` field; it allows optimizing memory usage depending on the number of levels (i.e. `CategoricalArray` with less than 256 levels can use `R = UInt8`).
 - `V` is the type of the levels, it is equal to `T` for arrays which do not support missing values; for arrays which support missing values, `T = Union{V, Missing}`
 - `C` is the type of categorical values, i.e. the objects returned when indexing non-missing elements of `CategoricalArray`. `C` is `CategoricalString{R}` if `V = String` and `CategoricalValue{V, R}` for any other `V`.
 - `U` can be either `Union{}` for arrays which do not support missing values, or `Missing` for those which support them.

Only `T`, `N` and `R` could be specified upon construction. The last three parameters are chosen automatically, but are needed for the definition of the type. In particular, `U` allows expressing that `CategoricalArray{T, N}` inherits from `AbstractArray{Union{C, U}, N}` (which is equivalent to `AbstractArray{C, N}` for arrays which do not support missing values, and to `AbstractArray{Union{C, Missing}, N}` for those which support them).

The `CategoricalPool` type is designed to limit the need to go over all elements of the vector, either for reading or for writing. This is why unused levels are not dropped automatically (this would force checking all elements on every modification or keeping a counts table), but only when `droplevels!` is called. `levels` is a (very fast) O(1) operation since it merely returns the (ordered) vector of levels without accessing the data at all.

Another useful feature is that integer indices referring to levels are preserved when adding or reordering levels: the order of levels exposed to the user by the `levels` function does not necessarily match these internal indices, which are stored in the `index` field of the pool. This means a reordering of the levels is also an O(1) operation. On the other hand, deleting levels may change the indices and therefore requires iterating over all elements in the array to update the references.
