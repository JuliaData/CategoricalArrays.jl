# Implementation details

`CategoricalArray` and `NullableCategoricalArray` share a common implementation for the most part, with the main differences being their element types. They are based on the `CategoricalPool` type, which keeps track of the levels and associates them with an integer reference (for internal use). They offer methods to set levels, change their order while preserving the references, and efficiently get the integer index corresponding to a level and vice-versa. They are also parameterized on the type used to store the references, so that small pools can use as little memory as possible. Finally, they keep a vector of value objects (`CategoricalValue`), so that `getindex` can return the existing object instead of allocating a new one.

Array types are made of two fields:

- `refs`: an integer vector giving the index of the level in the pool for each element. For `NullableCategoricalArray`, `0` indicates a missing value.
- `pool`: the `CategoricalPool` object keeping the levels of the array.

Whether an array (and its values) are ordered or not is stored as a property of the pool.

`CategoricalPool` is designed to limit the need to go over all elements of the vector, either for reading or for writing. This is why unused levels are not dropped automatically (this would force checking all elements on every modification or keeping a counts table), but only when `droplevels!` is called. `levels` is a (very fast) O(1) operation since it merely returns the (ordered) vector of levels without accessing the data at all. 

Another useful property is that integer indices referring to levels are preserved when adding or reordering levels: the order of levels exposed to the user by the `levels` function does not necessarily match these internal indices, which are stored in the `index` field of the pool. This means a reordering of the levels is also an O(1) operation. On the other hand, deleting levels may change the indices and therefore requires iterating over all elements in the array to update the references.
