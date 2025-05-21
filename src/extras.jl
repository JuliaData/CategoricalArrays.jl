using Statistics

function fill_refs!(refs::AbstractArray, X::AbstractArray,
                    breaks::AbstractVector, extend::Union{Bool, Missing})
    n = length(breaks)
    lower = first(breaks)
    upper = last(breaks)

    @inbounds for i in eachindex(X)
        x = X[i]

        if x isa Number && isnan(x)
            throw(ArgumentError("NaN values are not allowed in input vector"))
        elseif ismissing(x)
            refs[i] = 0
        elseif isequal(x, upper)
            refs[i] = n-1
        elseif extend !== true &&
            !((isless(lower, x) || isequal(x, lower)) && isless(x, upper))
            extend === missing ||
                throw(ArgumentError("value $x (at index $i) does not fall inside the breaks: " *
                                    "adapt them manually, or pass extend=true or extend=missing"))
            refs[i] = 0
        else
            refs[i] = searchsortedlast(breaks, x)
        end
    end
end

if VERSION >= v"1.10"
    const CUT_FMT = Printf.Format("%.*g")
end

"""
    CategoricalArrays.default_formatter(from, to, i::Integer;
                                        leftclosed::Bool, rightclosed::Bool,
                                        sigdigits::Integer)

Provide the default label format for the `cut(x, breaks)` method,
which is `"[from, to)"` if `leftclosed` is `true` and `"[from, to)"` otherwise.

If they are floating points values, breaks are turned into to strings using
`@sprintf("%.*g", sigdigits, break)`
(or `to` using `@sprintf("%.*g", sigdigits, break)` for the last break).
"""
function default_formatter(from, to, i::Integer;
                           leftclosed::Bool, rightclosed::Bool,
                           sigdigits::Integer)
    @static if VERSION >= v"1.10"
        from_str = from isa AbstractFloat ?
            Printf.format(CUT_FMT, sigdigits, from) :
            string(from)
        to_str = to isa AbstractFloat ?
            Printf.format(CUT_FMT, sigdigits, to) :
            string(to)
    else
        from_str = from isa AbstractFloat ?
            Printf.format(Printf.Format("%.$(sigdigits)g"), from) :
            string(from)
        to_str = to isa AbstractFloat ?
            Printf.format(Printf.Format("%.$(sigdigits)g"), to) :
            string(to)
    end
    string(leftclosed ? "[" : "(", from_str, ", ", to_str, rightclosed ? "]" : ")")
end

"""
    CategoricalArrays.numbered_formatter(from, to, i::Integer;
                                         leftclosed::Bool, rightclosed::Bool,
                                         sigdigits::Integer)

Provide the default label format for the `cut(x, ngroups)` method
when `allowempty=true`, which is `"i: [from, to)"` if `leftclosed`
is `true` and `"i: [from, to)"` otherwise.

If they are floating points values, breaks are turned into to strings using
`@sprintf("%.*g", sigdigits, breaks)`
(or `to` using `@sprintf("%.*g", sigdigits, break)` for the last break).
"""
numbered_formatter(from, to, i::Integer;
                   leftclosed::Bool, rightclosed::Bool,
                   sigdigits::Integer) =
    string(i, ": ",
           default_formatter(from, to, i, leftclosed=leftclosed, rightclosed=rightclosed,
                             sigdigits=sigdigits))

@doc raw"""
    cut(x::AbstractArray, breaks::AbstractVector;
        labels::Union{AbstractVector,Function},
        sigdigits::Integer=3,
        extend::Union{Bool,Missing}=false, allowempty::Bool=false)

Cut a numeric array into intervals at values `breaks`
and return an ordered `CategoricalArray` indicating
the interval into which each entry falls. Intervals are of the form `[lower, upper)`
(closed on the left), i.e. the lower bound is included and the upper bound is excluded, except
the last interval, which is closed on both ends, i.e. `[lower, upper]`.

If `x` accepts missing values (i.e. `eltype(x) >: Missing`) the returned array will
also accept them.

!!! note
    For floating point data, breaks may be rounded to `sigdigits` significant digits
    when generating interval labels, meaning that they may not reflect exactly the cutpoints
    used.

# Keyword arguments
* `extend::Union{Bool, Missing}=false`: when `false`, an error is raised if some values
  in `x` fall outside of the breaks; when `true`, breaks are automatically added to include
  all values in `x`; when `missing`, values outside of the breaks generate `missing` entries.
* `labels::Union{AbstractVector, Function}`: a vector of strings, characters
  or numbers giving the names to use for the intervals; or a function
  `f(from, to, i::Integer; leftclosed::Bool, rightclosed::Bool, sigdigits::Integer)` that generates
  the labels from the left and right interval boundaries and the group index. Defaults to
  [`CategoricalArrays.default_formatter`](@ref), giving `"[from, to)"` (or `"[from, to]"`
  for the rightmost interval if `extend == true`).
* `sigdigits::Integer=3`: the minimum number of significant digits to use in labels.
  This value is increased automatically if necessary so that rounded breaks are unique.
  Only used for floating point types and when `labels` is a function, in which case it
  is passed to it as a keyword argument.
* `allowempty::Bool=false`: when `false`, an error is raised if some breaks other than
  the last one appear multiple times, generating empty intervals; when `true`,
  duplicate breaks are allowed and the intervals they generate are kept as
  unused levels (but duplicate labels are not allowed).

# Examples
```jldoctest
julia> using CategoricalArrays

julia> cut(-1:0.5:1, [0, 1], extend=true)
5-element CategoricalArray{String,1,UInt32}:
 "[-1, 0)"
 "[-1, 0)"
 "[0, 1]"
 "[0, 1]"
 "[0, 1]" 

julia> cut(-1:0.5:1, 2)
5-element CategoricalArray{String,1,UInt32}:
 "[-1, 0)"
 "[-1, 0)"
 "[0, 1]"
 "[0, 1]"
 "[0, 1]"

julia> cut(-1:0.5:1, 2, labels=["A", "B"])
5-element CategoricalArray{String,1,UInt32}:
 "A"
 "A"
 "B"
 "B"
 "B"

julia> cut(-1:0.5:1, 2, labels=[-0.5, +0.5])
5-element CategoricalArray{Float64,1,UInt32}:
 -0.5
 -0.5
 0.5
 0.5
 0.5

julia> fmt(from, to, i; leftclosed, rightclosed) = "grp $i ($from//$to)"
fmt (generic function with 1 method)

julia> cut(-1:0.5:1, 3, labels=fmt)
5-element CategoricalArray{String,1,UInt32}:
 "grp 1 (-1.0//0.0)"
 "grp 1 (-1.0//0.0)"
 "grp 2 (0.0//0.5)"
 "grp 3 (0.5//1.0)"
 "grp 3 (0.5//1.0)"
```
"""
@inline function cut(x::AbstractArray, breaks::AbstractVector;
                     extend::Union{Bool, Missing}=false,
                     labels::Union{AbstractVector{<:SupportedTypes},Function}=default_formatter,
                     sigdigits::Integer=3,
                     allowempty::Bool=false)
    return _cut(x, breaks, extend, labels, sigdigits, allowempty)
end

# Separate function for inferability (thanks to inlining of cut)
function _cut(x::AbstractArray{T, N}, breaks::AbstractVector,
              extend::Union{Bool, Missing},
              labels::Union{AbstractVector{<:SupportedTypes},Function},
              sigdigits::Integer,
              allowempty::Bool) where {T, N}
    if !issorted(breaks)
        breaks = sort(breaks)
    end

    if any(x -> x isa Number && isnan(x), breaks)
        throw(ArgumentError("NaN values are not allowed in breaks"))
    end

    if !allowempty && !allunique(@view breaks[1:end-1])
        throw(ArgumentError("all breaks other than the last one must be unique " *
                            "unless `allowempty=true`"))
    end

    if extend === true
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
        if !ismissing(min_x) && isless(min_x, breaks[1])
            # this type annotation is needed on Julia<1.7 for stable inference
            breaks = [min_x::nonmissingtype(eltype(x)); breaks]
        end
        if !ismissing(max_x) && isless(breaks[end], max_x)
            breaks = [breaks; max_x::nonmissingtype(eltype(x))]
        end
        length(breaks) > 1 ||
            throw(ArgumentError("could not extend breaks as all values are equal: " *
                                "please specify at least two breaks manually"))
    end

    refs = Array{DefaultRefType, N}(undef, size(x))
    try
        fill_refs!(refs, x, breaks, extend)
    catch err
        # So that the error appears to come from cut() itself,
        # since it refers to its keyword arguments
        if isa(err, ArgumentError)
            throw(err)
        else
            rethrow(err)
        end
    end

    # Find minimal number of digits so that distinct breaks remain so
    if eltype(breaks) <: AbstractFloat
        while true
            local i
            for outer i in 2:lastindex(breaks)
                b1 = breaks[i-1]
                b2 = breaks[i]
                isequal(b1, b2) && continue

                @static if VERSION >= v"1.9"
                    b1_str = Printf.format(CUT_FMT, sigdigits, b1)
                    b2_str = Printf.format(CUT_FMT, sigdigits, b2)
                else
                    b1_str = Printf.format(Printf.Format("%.$(sigdigits)g"), b1)
                    b2_str = Printf.format(Printf.Format("%.$(sigdigits)g"), b2)
                end
                if b1_str == b2_str
                    sigdigits += 1
                    break
                end
            end
            i == lastindex(breaks) && break
        end
    end
    n = length(breaks)
    n >= 2 || throw(ArgumentError("at least two breaks must be provided when extend is not true"))
    if labels isa Function
        from = breaks[1:n-1]
        to = breaks[2:n]
        local firstlevel
        try
            firstlevel = labels(from[1], to[1], 1,
                                leftclosed=!isequal(breaks[1], breaks[2]), rightclosed=false,
                                sigdigits=sigdigits)
        catch
            # Support functions defined before v1.0, where sigdigits did not exist
            Base.depwarn("`labels` function is now required to accept a `sigdigits` keyword argument",
                         :cut)
            labels_orig = labels
            labels = (from, to, i; leftclosed, rightclosed, sigdigits) ->
                labels_orig(from, to, i; leftclosed, rightclosed)
            firstlevel = labels_orig(from[1], to[1], 1,
                                     leftclosed=!isequal(breaks[1], breaks[2]), rightclosed=false)
        end
        levs = Vector{typeof(firstlevel)}(undef, n-1)
        levs[1] = firstlevel
        for i in 2:n-2
            levs[i] = labels(from[i], to[i], i,
                             leftclosed=!isequal(breaks[i], breaks[i+1]), rightclosed=false,
                             sigdigits=sigdigits)
        end
        levs[end] = labels(from[end], to[end], n-1,
                           leftclosed=true, rightclosed=true,
                           sigdigits=sigdigits)
    else
        length(labels) == n-1 ||
            throw(ArgumentError("labels must be of length $(n-1), but got length $(length(labels))"))
        levs = copy(labels)
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
    S = T >: Missing || extend isa Missing ? Union{eltype(levs), Missing} : eltype(levs)
    CategoricalArray{S, N}(refs, pool)
end

"""
Find first value in (sorted) `v` which is greater than or equal to each quantile
in (sorted) `qs`.
"""
function find_breaks(v::AbstractVector, qs::AbstractVector)
    n = length(qs)
    breaks = similar(v, n)
    n == 0 && return breaks

    i = 1
    q = qs[1]
    @inbounds for x in v
        # Use isless and isequal to differentiate -0.0 from 0.0
        if isless(q, x) || isequal(q, x)
            breaks[i] = x
            i += 1
            i > n && break
            q = qs[i]
        end
    end
    return breaks
end

# AbstractWeights method is defined in StatsBase extension
# There is no in-place weighted quantile method in StatsBase
_wquantile(x::AbstractArray, w::AbstractVector, p::AbstractVector) =
    throw(ArgumentError("`weights` must be an `AbstractWeights` vector from StatsBase.jl"))

"""
    cut(x::AbstractArray, ngroups::Integer;
        labels::Union{AbstractVector{<:AbstractString},Function},
        sigdigits::Integer=3,
        allowempty::Bool=false,
        weights::Union{AbstractWeights, Nothing}=nothing)

Cut a numeric array into `ngroups` quantiles.

This is equivalent to `cut(x, quantile(x, (0:ngroups)/ngroups))`,
but breaks are taken from actual data values instead of estimated quantiles.

If `x` contains `missing` values, they are automatically skipped when computing
quantiles.

!!! note
    For floating point data, breaks may be rounded to `sigdigits` significant digits
    when generating interval labels, meaning that they may not reflect exactly the cutpoints
    used.

# Keyword arguments
* `labels::Union{AbstractVector, Function}`: a vector of strings, characters
  or numbers giving the names to use for the intervals; or a function
  `f(from, to, i::Integer; leftclosed::Bool, rightclosed::Bool, sigdigits::Integer)` that generates
  the labels from the left and right interval boundaries and the group index. Defaults to
  [`CategoricalArrays.default_formatter`](@ref), giving `"[from, to)"` (or `"[from, to]"`
  for the rightmost interval if `extend == true`) if `allowempty=false`, otherwise to
  [`CategoricalArrays.numbered_formatter`](@ref), which prefixes the label with the quantile
  number to ensure uniqueness.
* `sigdigits::Integer=3`: the minimum number of significant digits to use when rounding
  breaks for inclusion in generated labels. This value is increased automatically if necessary
  so that rounded breaks are unique. Only used for floating point types and when `labels` is a
  function, in which case it is passed to it as a keyword argument.
* `allowempty::Bool=false`: when `false`, an error is raised if some quantiles breakpoints
  other than the last one are equal, generating empty intervals;
  when `true`, duplicate breaks are allowed and the intervals they generate are kept as
  unused levels (but duplicate labels are not allowed).
* `weights::Union{AbstractWeights, Nothing}=nothing`: observations weights to used when
  computing quantiles (see `quantile` documentation in StatsBase).
"""
function cut(x::AbstractArray, ngroups::Integer;
             labels::Union{AbstractVector{<:SupportedTypes},Function,Nothing}=nothing,
             sigdigits::Integer=3,
             allowempty::Bool=false,
             weights::Union{AbstractVector, Nothing}=nothing)
    ngroups >= 1 || throw(ArgumentError("ngroups must be strictly positive (got $ngroups)"))
    if weights === nothing
        sorted_x = eltype(x) >: Missing ? sort!(collect(skipmissing(x))) : sort(x)
        min_x, max_x = first(sorted_x), last(sorted_x)
        if (min_x isa Number && isnan(min_x)) ||
            (max_x isa Number && isnan(max_x))
            throw(ArgumentError("NaN values are not allowed in input vector"))
        end
        qs = quantile!(sorted_x, (1:(ngroups-1))/ngroups, sorted=true)
    else
        if eltype(x) >: Missing
            nm_inds = findall(!ismissing, x)
            nm_x = view(x, nm_inds)
            # TODO: use a view once this is supported (JuliaStats/StatsBase.jl#723)
            nm_weights = weights[nm_inds]
        else
            nm_x = x
            nm_weights = weights
        end
        sorted_x = sort(nm_x)
        min_x, max_x = first(sorted_x), last(sorted_x)
        if (min_x isa Number && isnan(min_x)) ||
            (max_x isa Number && isnan(max_x))
            throw(ArgumentError("NaN values are not allowed in input vector"))
        end
        qs = _wquantile(nm_x, nm_weights, (1:(ngroups-1))/ngroups)
    end
    breaks = [min_x; find_breaks(sorted_x, qs); max_x]
    if !allowempty && !allunique(@view breaks[1:end-1])
        throw(ArgumentError("cannot compute $ngroups quantiles due to " *
                            "too many duplicated values in `x`. " *
                            "Pass `allowempty=true` to allow empty quantiles or " *
                            "choose a lower value for `ngroups`."))
    end
    if labels === nothing
        labels = allowempty ? numbered_formatter : default_formatter
    end
    return cut(x, breaks; labels=labels, sigdigits=sigdigits, allowempty=allowempty)
end
