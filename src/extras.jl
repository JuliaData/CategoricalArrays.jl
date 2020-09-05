using Statistics

function fill_refs!(refs::AbstractArray, X::AbstractArray,
                    breaks::AbstractVector, extend::Bool, allowoutside::Bool)
    n = length(breaks)
    lower = first(breaks)
    upper = last(breaks)

    @inbounds for i in eachindex(X)
        x = X[i]

        if ismissing(x)
            refs[i] = 0
        elseif extend && x == upper
            refs[i] = n-1
        elseif !extend && !(lower <= x < upper)
            allowoutside ||
                throw(ArgumentError("value $x (at index $i) does not fall inside the breaks: " *
                                    "adapt them manually, or pass extend=true or allowoutside=true"))
            refs[i] = 0
        else
            refs[i] = searchsortedlast(breaks, x)
        end
    end
end

"""
    default_formatter(from, to, i; leftclosed, rightclosed)

Provide the default label format for the `cut(x, breaks)` method.
"""
default_formatter(from, to, i; leftclosed, rightclosed) =
    string(leftclosed ? "[" : "(", from, ", ", to, rightclosed ? "]" : ")")

@doc raw"""
    cut(x::AbstractArray, breaks::AbstractVector;
        labels::Union{AbstractVector{<:AbstractString},Function},
        extend::Bool=false, allowoutside::Bool=false, allowempty::Bool=false)

Cut a numeric array into intervals and return an ordered `CategoricalArray` indicating
the interval into which each entry falls. Intervals are of the form `[lower, upper)`,
i.e. the lower bound is included and the upper bound is excluded.

If `x` accepts missing values (i.e. `eltype(x) >: Missing`) the returned array will
also accept them.

# Keyword arguments
* `extend::Bool=false`: when `false`, an error is raised if some values in `x` fall
  outside of the breaks; when `true`, breaks are automatically added to include all
  values in `x`, and the upper bound is included in the last interval.
* `labels::Union{AbstractVector,Function}`: a vector of strings giving the names to use for
  the intervals; or a function `f(from, to, i; leftclosed, rightclosed)` that generates
  the labels from the left and right interval boundaries and the group index. Defaults to
  `"[from, to)"` (or `"[from, to]"` for the rightmost interval if `extend == true`).
* `allowoutside::Bool=false`: when `true`, values outside of breaks result in missing values.
  Only supported when `x` accepts missing values.
* `allowempty::Bool=false`: when `false`, an error is raised if some breaks appear
  multiple times, generating empty intervals; when `true`, duplicate breaks are allowed
  and the intervals they generate are kept as unused levels
  (but duplicate labels are not allowed).

# Examples
```jldoctest
julia> using CategoricalArrays

julia> cut(-1:0.5:1, [0, 1], extend=true)
5-element CategoricalArray{String,1,UInt32}:
 "[-1.0, 0.0)"
 "[-1.0, 0.0)"
 "[0.0, 1.0]"
 "[0.0, 1.0]"
 "[0.0, 1.0]" 

julia> cut(-1:0.5:1, 2)
5-element CategoricalArray{String,1,UInt32}:
 "Q1: [-1.0, 0.0)"
 "Q1: [-1.0, 0.0)"
 "Q2: [0.0, 1.0]"
 "Q2: [0.0, 1.0]"
 "Q2: [0.0, 1.0]" 

julia> cut(-1:0.5:1, 2, labels=["A", "B"])
5-element CategoricalArray{String,1,UInt32}:
 "A"
 "A"
 "B"
 "B"
 "B"

julia> fmt(from, to, i; leftclosed, rightclosed) = "grp $i ($from//$to)"
fmt (generic function with 1 method)

julia> cut(-1:0.5:1, 3, labels=fmt)
5-element CategoricalArray{String,1,UInt32}:
 "grp 1 (-1.0//-0.333333)"
 "grp 1 (-1.0//-0.333333)"
 "grp 2 (-0.333333//0.333333)"
 "grp 3 (0.333333//1.0)"
 "grp 3 (0.333333//1.0)"      
```
"""
@inline function cut(x::AbstractArray, breaks::AbstractVector;
                    extend::Bool=false,
                    labels::Union{AbstractVector{<:AbstractString},Function}=default_formatter,
                    allowoutside::Bool=false,
                    allowmissing::Union{Bool, Nothing}=nothing,
                    allow_missing::Union{Bool, Nothing}=nothing,
                    allowempty::Bool=false)
    if allow_missing !== nothing
        Base.depwarn("allow_missing argument is deprecated, use allowoutside instead",
                     :cut)
        allowoutside = allow_missing
    end
    if allowmissing !== nothing
        Base.depwarn("allowmissing argument is deprecated, use allowoutside instead",
                     :cut)
        allowoutside = allowmissing
    end
    return _cut(x, breaks, extend, labels,
                allowoutside, allowoutside ? Missing : Union{}, allowempty)
end

# Separate function for inferability (thanks to inlining of cut)
function _cut(x::AbstractArray{T, N}, breaks::AbstractVector,
              extend::Bool,
              labels::Union{AbstractVector{<:AbstractString},Function},
              allowoutside::Bool,
              ::Type{M},
              allowempty::Bool=false) where {T, N, M}
    if !allowempty && !allunique(breaks)
        throw(ArgumentError("all breaks must be unique unless `allowempty=true`"))
    end

    if !issorted(breaks)
        breaks = sort(breaks)
    end

    if extend
        xnm = T >: Missing ? skipmissing(x) : x
        length(breaks) >= 1 || throw(ArgumentError("at least one break must be provided"))
        local min_x, max_x
        try
            min_x, max_x = extrema(xnm)
        catch err
            if T >: Missing && all(ismissing, xnm)
                if length(breaks) < 2
                    throw(ArgumentError("could not extend breaks as all values are missing: " *
                                        "please specify at least two breaks manually"))
                else
                    min_x, max_x = missing, missing
                end
            else
                rethrow(err)
            end
        end
        if !ismissing(min_x) && breaks[1] > min_x
            breaks = [min_x; breaks]
        end
        if !ismissing(max_x) && breaks[end] < max_x
            breaks = [breaks; max_x]
        end
        length(breaks) > 1 ||
            throw(ArgumentError("could not extend breaks as all values are equal: " *
                                "please specify at least two breaks manually"))
    end

    refs = Array{DefaultRefType, N}(undef, size(x))
    try
        fill_refs!(refs, x, breaks, extend, allowoutside)
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
    n >= 2 || throw(ArgumentError("at least two breaks must be provided when extend=false"))
    if labels isa Function
        from = map(x -> sprint(show, x, context=:compact=>true), breaks[1:n-1])
        to = map(x -> sprint(show, x, context=:compact=>true), breaks[2:n])
        levs = Vector{String}(undef, n-1)
        for i in 1:n-2
            levs[i] = labels(from[i], to[i], i,
                             leftclosed=breaks[i] != breaks[i+1], rightclosed=false)
        end
        levs[end] = labels(from[end], to[end], n-1,
                           leftclosed=breaks[end-1] != breaks[end], rightclosed=extend)
    else
        length(labels) == n-1 || throw(ArgumentError("labels must be of length $(n-1), but got length $(length(labels))"))
        # Levels must have element type String for type stability of the result
        levs::Vector{String} = copy(labels)
    end
    if !allunique(levs)
        if labels === default_formatter
            throw(ArgumentError("all labels must be unique, but `breaks` contains duplicates: " *
                                "specify custom `labels` with unique names"))
        else
            throw(ArgumentError("all labels must be unique"))
        end
    end

    pool = CategoricalPool(levs, true)
    S = T >: Missing ? Missing : M
    CategoricalArray{Union{String, S}, N}(refs, pool)
end

"""
    quantile_formatter(from, to, i; leftclosed, rightclosed)

Provide the default label format for the `cut(x, ngroups)` method.
"""
quantile_formatter(from, to, i; leftclosed, rightclosed) =
    string("Q", i, ": ", leftclosed ? "[" : "(", from, ", ", to, rightclosed ? "]" : ")")

"""
    cut(x::AbstractArray, ngroups::Integer;
        labels::Union{AbstractVector{<:AbstractString},Function},
        allowempty::Bool=false)

Cut a numeric array into `ngroups` quantiles, determined using `quantile`.

If `x` contains `missing` values, they are automatically skipped when computing
quantiles.

# Keyword arguments
* `labels::Union{AbstractVector,Function}`: a vector of strings giving the names to use for
  the intervals; or a function `f(from, to, i; leftclosed, rightclosed)` that generates
  the labels from the left and right interval boundaries and the group index. Defaults to
  `"Qi: [from, to)"` (or `"Qi: [from, to]"` for the rightmost interval if `extend == true`).
* `allowempty::Bool=false`: when `false`, an error is raised if some quantiles breakpoints
  are equal, generating empty intervals; when `true`, duplicate breaks are allowed
  and the intervals they generate are kept as unused levels
  (but duplicate labels are not allowed).
"""
function cut(x::AbstractArray, ngroups::Integer;
             labels::Union{AbstractVector{<:AbstractString},Function}=quantile_formatter,
             allowempty::Bool=false)
    xnm = eltype(x) >: Missing ? skipmissing(x) : x
    breaks = Statistics.quantile(xnm, (1:ngroups-1)/ngroups)
    if !allowempty && !allunique(breaks)
        n = length(unique(breaks)) - 1
        throw(ArgumentError("cannot compute $ngroups quantiles: `quantile` " *
                            "returned only $n groups due to duplicated values in `x`." *
                            "Pass `allowempty=true` to allow empty quantiles or " *
                            "choose a lower value for `ngroups`."))
    end
    cut(x, breaks; extend=true, labels=labels, allowempty=allowempty)
end
