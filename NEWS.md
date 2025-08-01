# CategoricalArrays.jl v1.0.1 Release Notes

## Bug fixes

* Fix `Array{<:CategoricalValue}` constructors and `convert` to return an `Array`
  rather than a `CategoricalArray`
  ([#427](https://github.com/JuliaData/CategoricalArrays.jl/pull/427)).


# CategoricalArrays.jl v1.0.0 Release Notes

## Breaking changes

* `unique(::CategoricalArray)` and `levels(::CategoricalArray)` return
  a `CategoricalArray` instead of unwrapping values, consistent with
  `unique(::AbstractArray)` in Base and `levels(::AbstractArray)` in DataAPI
  ([#358](https://github.com/JuliaData/CategoricalArrays.jl/pull/358),
  [#425](https://github.com/JuliaData/CategoricalArrays.jl/pull/425)).

* `cut` always closes the last interval on the right
  ([#409](https://github.com/JuliaData/CategoricalArrays.jl/pull/409)).

* `cut(x, breaks)` rounds breaks to generate shorter labels
 ([#422](https://github.com/JuliaData/CategoricalArrays.jl/pull/422)).

* `cut(x, ngroups)` takes breaks from actual values instead of using
  quantile estimates which are generally longer
  ([#416](https://github.com/JuliaData/CategoricalArrays.jl/pull/416))
  This only changes group labels, not their contents.

* `T(::CategoricalArray{U})` and `convert(T, ::CategoricalArray{U})`
  now consistently return an `Array{U}` for `T` in `Array`, `Vector`, `Matrix`.
  This avoids creating `Array{<:CategoricalValue}` objects unless explicitly requested
  ([#420](https://github.com/JuliaData/CategoricalArrays.jl/pull/420)).


* All deprecations have been removed
  ([#419](https://github.com/JuliaData/CategoricalArrays.jl/pull/419)).

## New features

* Support reading from and writing to Arrow files
  ([#415](https://github.com/JuliaData/CategoricalArrays.jl/pull/415)).

* Improve performance of `recode`
  ([#407](https://github.com/JuliaData/CategoricalArrays.jl/pull/407)).

* Support weighted quantiles in `cut`
  ([#423](https://github.com/JuliaData/CategoricalArrays.jl/pull/423)).

## Bug fixes

* Fix performance regression on Julia 1.11 and above
  ([#418](https://github.com/JuliaData/CategoricalArrays.jl/pull/418)).

* Fix `cut` corner cases with duplicated breaks
  ([#410](https://github.com/JuliaData/CategoricalArrays.jl/pull/410)).
