function Base.isless{S, T}(x::CategoricalVariable{S}, y::CategoricalVariable{T})
    error("CategoricalVariable objects cannot be tested for order")
end
