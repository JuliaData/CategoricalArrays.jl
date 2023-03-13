module CategoricalArraysJSONExt

if isdefined(Base, :get_extension)
    using CategoricalArrays
    using JSON
else
    using ..CategoricalArrays
    using ..JSON
end

# JSON of CategoricalValue is JSON of the value it refers to
JSON.lower(x::CategoricalValue) = JSON.lower(unwrap(x))

end
