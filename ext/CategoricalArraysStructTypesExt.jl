module CategoricalArraysStructTypesExt

if isdefined(Base, :get_extension)
    using CategoricalArrays
    using StructTypes
else
    using ..CategoricalArrays
    using ..StructTypes
end

# define appropriate handlers for JSON3 interface
StructTypes.StructType(x::CategoricalValue) = StructTypes.StructType(unwrap(x))
StructTypes.StructType(::Type{<:CategoricalValue{T}}) where {T} = StructTypes.StructType(T)
StructTypes.numbertype(::Type{<:CategoricalValue{T}}) where {T <: Number} = T
StructTypes.construct(::Type{T}, x::CategoricalValue{T}) where {T} = T(unwrap(x))

# JSON3 writing/reading
StructTypes.StructType(::Type{<:CategoricalVector}) = StructTypes.ArrayType()

StructTypes.construct(::Type{<:CategoricalArray}, A::AbstractVector) =
    constructgeneral(A)
StructTypes.construct(::Type{<:CategoricalArray}, A::Vector) =
    constructgeneral(A)

function constructgeneral(A)
    if eltype(A) === Any
        # unlike `replace`, broadcast narrows the type, which allows us to return small
        # union eltypes (e.g. Union{String,Missing})
        categorical(ifelse.(A .=== nothing, missing, A))
    elseif eltype(A) >: Nothing
        categorical(replace(A, nothing=>missing))
    else
        categorical(A)
    end
end

StructTypes.construct(::Type{<:CategoricalArray{Union{Missing, T}}},
                    A::AbstractVector) where {T} =
    CategoricalArray{Union{Missing, T}}(replace(A, nothing=>missing))
StructTypes.construct(::Type{<:CategoricalArray{Union{Missing, T}}},
                    A::Vector) where {T} =
    CategoricalArray{Union{Missing, T}}(replace(A, nothing=>missing))

end
