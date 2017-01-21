function fill_refs!(refs::AbstractVector, X::AbstractArray,
                    breaks::AbstractVector, extend::Bool, nullok::Bool)
    n = length(breaks)
    lower = first(breaks)
    upper = last(breaks)

    @inbounds for i in eachindex(X)
        x = X[i]

        if extend && x == upper
            refs[i] = n-1
        elseif !extend && !(lower <= x < upper)
            throw(ArgumentError("value $x (at index $i) is outside the breaks: adapt them manually, or pass extend=true"))
        else
            refs[i] = searchsortedlast(breaks, x)
        end
    end
end

function fill_refs!{T<:Nullable}(refs::AbstractVector, X::AbstractArray{T},
                                  breaks::AbstractVector, extend::Bool, nullok::Bool)
    n = length(breaks)
    lower = first(breaks)
    upper = last(breaks)

    @inbounds for i in eachindex(X)
        isnull(X[i]) && continue

        x = unsafe_get(X[i])

        if extend && x == upper
            refs[i] = n-1
        elseif !extend && !(lower <= x < upper)
            nullok || throw(ArgumentError("value $x (at index $i) is outside the breaks: adapt them manually, or pass extend=true or nullok=true"))
            refs[i] = 0
        else
            refs[i] = searchsortedlast(breaks, x)
        end
    end
end

function fill_refs!{T}(refs::AbstractVector, X::NullableArray{T},
                       breaks::AbstractVector, extend::Bool, nullok::Bool)
    n = length(breaks)
    lower = first(breaks)
    upper = last(breaks)

    @inbounds for i in eachindex(X)
        X.isnull[i] && continue

        x = X.values[i]

        if extend && x == upper
            refs[i] = n-1
        elseif !extend && !(lower <= x < upper)
            nullok || throw(ArgumentError("value $x (at index $i) is outside the breaks: adapt them manually, or pass extend=true or nullok=true"))
            refs[i] = 0
        else
            refs[i] = searchsortedlast(breaks, x)
        end
    end
end


_extrema(X::Any) = extrema(X)
# NullableArrays provide a more efficient version with higher precedence
_extrema{T<:Nullable}(X::AbstractArray{T}) = (minimum(X), maximum(X))

unwrap(x::Any) = x
unwrap(x::Nullable) = x.value

"""
    cut(x::AbstractArray, breaks::AbstractVector;
        extend::Bool=false, labels::AbstractVector)

Cut a numeric array into intervals and return an ordered `CategoricalArray` indicating
the interval into which each entry falls. Intervals are of the form `[lower, upper)`,
i.e. the lower bound is included and the upper bound is excluded.

# Arguments
* `extend::Bool=false`: when `false`, an error is raised if some values in `x` fall
  outside of the breaks; when `true`, breaks are automatically added to include all
  values in `x`.
* `labels::AbstractVector=String[]`: the names to use for the intervals; if empty,
  default labels are used.

    cut(x::AbstractArray{<:Nullable}, breaks::AbstractVector;
        extend::Bool=false, nullok::Bool=false)

For nullable arrays, return a `NullableCategoricalArray`. If `nullok=true`, values outside
of breaks result in null values.
"""
function cut{T, N, U}(x::AbstractArray{T, N}, breaks::AbstractVector;
                      extend::Bool=false, nullok::Bool=false, labels::AbstractVector{U}=String[])
    if !issorted(breaks)
        sort!(breaks)
    end

    if extend
        min_x, max_x = _extrema(x)
        if !isnull(min_x) && breaks[1] > unwrap(min_x)
            unshift!(breaks, unwrap(min_x))
        end
        if !isnull(max_x) && breaks[end] < unwrap(max_x)
            push!(breaks, unwrap(max_x))
        end
    end

    refs = Array{DefaultRefType}(size(x))
    fill_refs!(refs, x, breaks, extend, nullok)

    n = length(breaks)
    if isempty(labels)
        from = map(x -> sprint(showcompact, x), breaks[1:n-1])
        to = map(x -> sprint(showcompact, x), breaks[2:n])
        levs = Vector{U}(n-1)
        for i in 1:n-2
            levs[i] = string("[", from[i], ", ", to[i], ")")
        end
        if extend
            levs[end] = string("[", from[end], ", ", to[end], "]")
        else
            levs[end] = string("[", from[end], ", ", to[end], ")")
        end
    else
        length(labels) == n-1 || throw(ArgumentError("labels must be of length $(n-1), but got length $(length(labels))"))
        levs = copy(labels)
    end

    pool = CategoricalPool(levs, true)
    if T <: Nullable
        NullableCategoricalArray{U, N, DefaultRefType}(refs, pool)
    else
        CategoricalArray{U, N, DefaultRefType}(refs, pool)
    end
end

"""
    cut(x::AbstractArray, ngroups::Integer)

Cut a numeric array into `ngroups` quantiles using `quantile`.
"""
cut(x::AbstractArray, ngroups::Integer) = cut(x, quantile(x, 1:ngroups-1)/ngroups)
