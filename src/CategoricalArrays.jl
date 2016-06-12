module CategoricalArrays
    export CategoricalPool, NominalPool, OrdinalPool
    export NominalValue, OrdinalValue

    export CategoricalArray, CategoricalVector, CategoricalMatrix
    export NominalArray, NominalVector, NominalMatrix
    export OrdinalArray, OrdinalVector, OrdinalMatrix

    export NullableCategoricalArray, NullableCategoricalVector, NullableCategoricalMatrix
    export NullableNominalArray, NullableNominalVector, NullableNominalMatrix
    export NullableOrdinalArray, NullableOrdinalVector, NullableOrdinalMatrix

    export droplevels!, levels, levels!

    using Compat

    if VERSION < v"0.5.0-dev"
        Base.convert{T,n,S}(::Type{Array{T}}, x::AbstractArray{S, n}) = convert(Array{T, n}, x)
        Base.convert{T,n,S}(::Type{Array{T,n}}, x::AbstractArray{S,n}) = copy!(Array{T}(size(x)), x)

        Base.convert{T}(::Type{Nullable   }, x::T) = Nullable{T}(x)

        allunique(C) = length(unique(C)) == length(C)
    end

    include("typedefs.jl")

    include("buildfields.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("nullablearray.jl")
end
