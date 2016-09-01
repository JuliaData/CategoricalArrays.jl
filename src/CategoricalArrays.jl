__precompile__(true)
module CategoricalArrays
    export CategoricalPool, CategoricalValue

    export CategoricalArray, CategoricalVector, CategoricalMatrix

    export NullableCategoricalArray, NullableCategoricalVector, NullableCategoricalMatrix

    export compact, droplevels!, levels, levels!

    using Compat

    if VERSION < v"0.5.0-dev"
        Base.convert{T,n,S}(::Type{Array{T}}, x::AbstractArray{S, n}) = convert(Array{T, n}, x)
        Base.convert{T,n,S}(::Type{Array{T,n}}, x::AbstractArray{S,n}) = copy!(Array{T}(size(x)), x)

        Base.convert{T}(::Type{Nullable   }, x::T) = Nullable{T}(x)
    end

    include("typedefs.jl")

    include("buildfields.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("nullablearray.jl")
end
