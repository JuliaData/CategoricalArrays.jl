module CategoricalArrays
    export CategoricalPool, CategoricalValue
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export AbstractNullableCategoricalArray, AbstractNullableCategoricalVector,
           AbstractNullableCategoricalMatrix,
           NullableCategoricalArray, NullableCategoricalVector, NullableCategoricalMatrix

    export categorical, compact, droplevels!, levels, levels!, isordered, ordered!

    using Compat

    include("typedefs.jl")

    include("buildfields.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("nullablearray.jl")
    include("deprecated.jl")

    include("subarray.jl")

    if VERSION < v"0.5.0-dev"
        Base.convert{T,n,S}(::Type{Array{T}}, x::AbstractArray{S, n}) = convert(Array{T, n}, x)
        Base.convert{T,n,S}(::Type{Array{T,n}}, x::AbstractArray{S,n}) = copy!(Array{T}(size(x)), x)

        Base.convert{T}(::Type{Nullable   }, x::T) = Nullable{T}(x)

        Base.promote_op{S<:CategoricalValue, T<:CategoricalValue}(::typeof(@functorize(==)),
                                                                  ::Type{S}, ::Type{T}) = Bool
        Base.promote_op{S<:CategoricalValue, T<:CategoricalValue}(::typeof(@functorize(>)),
                                                                  ::Type{S}, ::Type{T}) = Bool
        Base.promote_op{S<:CategoricalValue, T<:CategoricalValue}(::typeof(@functorize(<)),
                                                                  ::Type{S}, ::Type{T}) = Bool
        Base.promote_op{S<:CategoricalValue, T<:CategoricalValue}(::typeof(@functorize(>=)),
                                                                  ::Type{S}, ::Type{T}) = Bool
        Base.promote_op{S<:CategoricalValue, T<:CategoricalValue}(::typeof(@functorize(<=)),
                                                                  ::Type{S}, ::Type{T}) = Bool
    end
end
