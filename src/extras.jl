function fill_refs!(refs::AbstractArray, X::AbstractArray,
                    breaks::AbstractVector, extend::Bool, nullok::Bool)
    n = length(breaks)
    lower = first(breaks)
    upper = last(breaks)

    @inbounds for i in eachindex(X)
        x = X[i]

        if extend && x == upper
            refs[i] = n-1
        elseif !extend && !(lower <= x < upper)
            throw(ArgumentError("value $x (at index $i) does not fall inside the breaks: adapt them manually, or pass extend=true"))
        else
            refs[i] = searchsortedlast(breaks, x)
        end
    end
end

function fill_refs!(refs::AbstractArray, X::AbstractArray{>: Null},
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
            nullok || throw(ArgumentError("value $x (at index $i) does not fall inside the breaks: adapt them manually, or pass extend=true or nullok=true"))
            refs[i] = 0
        else
            refs[i] = searchsortedlast(breaks, x)
        end
    end
end

"""
    cut(x::AbstractArray, breaks::AbstractVector;
        extend::Bool=false, labels::AbstractVector=[], nullok::Bool=false)

Cut a numeric array into intervals and return an ordered `CategoricalArray` indicating
the interval into which each entry falls. Intervals are of the form `[lower, upper)`,
i.e. the lower bound is included and the upper bound is excluded.

If `x` is nullable (i.e. `eltype(x) >: Null`), a nullable `CategoricalArray` is returned.

# Arguments
* `extend::Bool=false`: when `false`, an error is raised if some values in `x` fall
  outside of the breaks; when `true`, breaks are automatically added to include all
  values in `x`, and the upper bound is included in the last interval.
* `labels::AbstractVector=[]`: a vector of strings giving the names to use for the
  intervals; if empty, default labels are used.
* `nullok::Bool=true`: when `true`, values outside of breaks result in null values.
  only supported when `x` is nullable.
"""
function cut(x::AbstractArray{T, N}, breaks::AbstractVector;
                                      extend::Bool=false, labels::AbstractVector{U}=String[],
                                      nullok::Bool=false) where {T, N, U<:AbstractString}
    if !issorted(breaks)
        breaks = sort(breaks)
    end

    if extend
        min_x, max_x = extrema(x)
        if !isnull(min_x) && breaks[1] > min_x
            unshift!(breaks, min_x)
        end
        if !isnull(max_x) && breaks[end] < max_x
            push!(breaks, max_x)
        end
    end

    refs = Array{DefaultRefType, N}(size(x))
    try
        fill_refs!(refs, x, breaks, extend, nullok)
    catch err
        # So that the error appears to come from cut() itself,
        # since it refers to its keyword arguments
        if isa(err, ArgumentError)
            throw(err)
        else
            rethrow(err)
        end
    end

    n = length(breaks)
    if isempty(labels)
        from = map(x -> sprint(showcompact, x), breaks[1:n-1])
        to = map(x -> sprint(showcompact, x), breaks[2:n])
        levs = Vector{String}(n-1)
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
        # Levels must have element type String for type stability of the result
        levs::Vector{String} = copy(labels)
    end

    pool = CategoricalPool(levs, true)
    S = T >: Null ? Union{String, Null} : String
    CategoricalArray{S, N, DefaultRefType}(refs, pool)
end

"""
    cut(x::AbstractArray, ngroups::Integer;
        labels::AbstractVector=String[])

Cut a numeric array into `ngroups` quantiles, determined using
[`quantile`](@ref).
"""
cut(x::AbstractArray, ngroups::Integer;
                       labels::AbstractVector{U}=String[]) where {U<:AbstractString} =
    cut(x, quantile(x, (1:ngroups-1)/ngroups); extend=true, labels=labels)
