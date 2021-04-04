# Implementation details

`CategoricalArray` is made of the two fields:

- `refs`: an integer array that stores the position of the category level in the `levels` field of `CategoricalPool` for each `CategoricalArray` element; `0` denotes a missing value (for `CategoricalArray{Union{T, Missing}}` only).
- `pool`: the `CategoricalPool` object that maintains the levels of the array.

The `CategoricalPool{V,R,C}` type keeps track of the levels of type `V` and associates them with an integer reference code of type `R` (for internal use). It offers methods to add new levels, and efficiently get the integer index corresponding to a level and vice-versa. Whether the values of `CategoricalArray` are ordered or not is defined by an `ordered` field of the pool.

Do note that `CategoricalPool` levels are semi-mutable: it is only allowed to add new levels, but never to remove or reorder existing ones. This ensures existing `CategoricalValue` objects remain valid and always point to the same level as when they were created. Therefore, `CategoricalArray`s create a new pool each time some of their levels are removed or reordered. This happens when calling `levels!`, but also when assigning a `CategoricalValue` via `setindex!`, `push!`, `append!`, `copy!` or `copyto!` (as new levels may be added to the front to preserve relative order of both source and destination levels). Doing so requires updating all reference codes to point to the new pool, and makes it impossible to compare existing ordered `CategoricalValue` objects with values from the array using `<` and `>`.

The type parameters of `CategoricalArray{T, N, R <: Integer, V, C, U}` are a bit complex:
 - `T` is the type of array elements without `CategoricalValue` wrappers; if `T >: Missing`, then the array supports missing values.
 - `N` is the number of array dimensions.
 - `R` is the reference type, the element type of the `refs` field; it allows optimizing memory usage depending on the number of levels (i.e. `CategoricalArray` with less than 256 levels can use `R = UInt8`).
 - `V` is the type of the levels, it is equal to `T` for arrays which do not support missing values; for arrays which support missing values, `T = Union{V, Missing}`
 - `C` is the type of categorical values, i.e. of the objects returned when indexing non-missing elements of `CategoricalArray`. It is always equal to `CategoricalValue{V, R}`, and only present for technical reasons (to break the recursive dependency between `CategoricalArray` and `CategoricalValue`).
 - `U` can be either `Union{}` for arrays which do not support missing values, or `Missing` for those which support them.

Only `T`, `N` and `R` could be specified upon construction. The last three parameters are chosen automatically, but are needed for the definition of the type. In particular, `U` allows expressing that `CategoricalArray{T, N}` inherits from `AbstractArray{Union{C, U}, N}` (which is equivalent to `AbstractArray{C, N}` for arrays which do not support missing values, and to `AbstractArray{Union{C, Missing}, N}` for those which support them).

The `CategoricalPool` type is designed to limit the need to go over all elements of the vector, either for reading or for writing. This is why unused levels are not dropped automatically (this would force checking all elements on every modification or keeping a counts table), but only when `droplevels!` is called. `levels` is a (very fast) O(1) operation since it merely returns the (ordered) vector of levels without accessing the data at all.

Scalar operations between `CategoricalValue` objects or between a `CategoricalValue` and a `CategoricalArray` generally require checking whether pools are equal or whether one is a superset of the other. In order to make these operations efficient, `CategoricalPool` stores a pointer to the last encountered equal pool in the `equalto` field, and a pointer to the last encountered strict superset pool in `subsetof` field. The hash of the levels is computed the first time it is needed and stored in the `hash` field. These optimizations mean that when looping over values in an array, the cost of comparing pools only has to be paid once.