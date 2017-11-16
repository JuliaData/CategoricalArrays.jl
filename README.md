CategoricalArrays.jl
==================

[![Build Status](https://travis-ci.org/JuliaData/CategoricalArrays.jl.svg?branch=master)](https://travis-ci.org/JuliaData/CategoricalArrays.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/jq64i3656pwi18pg?svg=true)](https://ci.appveyor.com/project/nalimilan/categoricalarrays-jl)
[![Julia 0.5 Status](http://pkg.julialang.org/badges/CategoricalArrays_0.5.svg)](http://pkg.julialang.org/?pkg=CategoricalArrays&ver=0.5)
[![Julia 0.6 Status](http://pkg.julialang.org/badges/CategoricalArrays_0.6.svg)](http://pkg.julialang.org/?pkg=CategoricalArrays&ver=0.6)
[![Coveralls](https://coveralls.io/repos/github/JuliaData/CategoricalArrays.jl/badge.svg)](https://coveralls.io/github/JuliaData/CategoricalArrays.jl)
[![Codecov](https://codecov.io/gh/JuliaData/CategoricalArrays.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaData/CategoricalArrays.jl)

Documentation:

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliadata.github.io/CategoricalArrays.jl/stable)

[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://juliadata.github.io/CategoricalArrays.jl/latest)

This package provides tools for working with categorical variables, both with unordered (nominal variables) and ordered categories (ordinal variables). It provides a replacement for [DataArrays.jl](https://github.com/JuliaStats/DataArrays.jl)'s `PooledDataArray` type. Contrary to that type, it supports both arrays without missing values and arrays that allow for the presence of missing values, using the [`Missing`](https://github.com/JuliaData/Missings.jl) type. It is also based on a simpler design by only supporting categorical data, which allows offering more specialized features (like ordering of categories). See the [IndirectArrays.jl](https://github.com/JuliaArrays/IndirectArrays.jl) package for a simpler array type storing data with a small number of values.
