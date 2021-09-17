module CategoricalArrays
    export CategoricalPool, CategoricalValue
    export AbstractCategoricalArray, AbstractCategoricalVector, AbstractCategoricalMatrix,
           CategoricalArray, CategoricalVector, CategoricalMatrix
    export LevelsException

    export categorical, compress, decompress, droplevels!, levels, levels!, levelcode,
           isordered, ordered!
    export cut, recode, recode!

    import DataAPI: unwrap
    export unwrap

    using DataAPI
    using Missings
    using Printf
    using Requires: @require

    # JuliaLang/julia#36810
    if VERSION < v"1.5.2"
        Base.OrderStyle(::Type{Union{}}) = Base.Ordered()
    end

    include("typedefs.jl")

    include("pool.jl")
    include("value.jl")

    include("array.jl")
    include("missingarray.jl")
    include("subarray.jl")

    include("extras.jl")
    include("recode.jl")

    include("deprecated.jl")

    function __init__()
        @require JSON="682c06a0-de6a-54ab-a142-c8b1cf79cde6" begin
            # JSON of CategoricalValue is JSON of the value it refers to
            JSON.lower(x::CategoricalValue) = JSON.lower(unwrap(x))
        end

        @require RecipesBase="3cdcf5f2-1ef4-517c-9805-6587b60abb01" @eval begin
            RecipesBase.@recipe function f(::Type{T}, v::T) where T <: CategoricalValue
                level_strings = [map(string, levels(v)); missing]
                ticks --> eachindex(level_strings)
                v -> ismissing(v) ? length(level_strings) : Int(refcode(v)),
                i -> level_strings[Int(i)]
            end
        end

        @require SentinelArrays="91c51154-3ec4-41a3-a24f-3f23e20d615c" begin
            copyto!(dest::CatArrOrSub{<:Any, 1}, src::SentinelArrays.ChainedVector) =
                copyto!(dest, 1, src, 1, length(src))
            copyto!(dest::CatArrOrSub{<:Any, 1}, dstart::Union{Signed, Unsigned},
                    src::SentinelArrays.ChainedVector, sstart::Union{Signed, Unsigned},
                    n::Union{Signed, Unsigned}) =
                invoke(copyto!, Tuple{AbstractArray, Union{Signed, Unsigned},
                                    SentinelArrays.ChainedVector,
                                    Union{Signed, Unsigned}, Union{Signed, Unsigned}},
                    dest, dstart, src, sstart, n)
        end

        @require StructTypes="856f2bd8-1eba-4b0a-8007-ebc267875bd4" begin
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
    end
end
