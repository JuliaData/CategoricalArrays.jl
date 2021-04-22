function index(pool::CategoricalPool)
    throw(ErrorException("CategoricalArrays.index(pool::CategoricalPool) is deprecated: " *
                         "use levels(pool) instead"))
end
function order(pool::CategoricalPool)
    throw(ErrorException("CategoricalArrays.index(pool::CategoricalPool) is deprecated: " *
                         "use 1:length(levels(pool)) instead"))
end

function categorical(A::AbstractArray, compress::Bool; kwargs...)
    throw(ErrorException("categorical(A::AbstractArray, compress, kwargs...) is deprecated: " *
                         "use categorical(A, compress=compress, kwargs...) instead."))
end

import Base: get

@deprecate get(x::CategoricalValue) DataAPI.unwrap(x)
@deprecate CategoricalValue(i::Integer, pool::CategoricalPool) pool[i]