# Julia 0.5 support
_isnull(x::Any) = false
_isnull(x::Nullable) = isnull(x)

_unsafe_get(x::Any) = x
_unsafe_get(x::Nullable) = x.value

if VERSION < v"0.6.0" # Fix ambiguities
    recode!(dest::AbstractArray, src::AbstractArray, pair::Pair, pairs::Pair...) =
        recode!(dest, src, nothing, pair, pairs...)
    recode!(dest::CategoricalArray, src::AbstractArray, pair::Pair, pairs::Pair...) =
        recode!(dest, src, nothing, pair, pairs...)
    recode!(dest::NullableCategoricalArray, src::AbstractArray, pair::Pair, pairs::Pair...) =
        recode!(dest, src, nothing, pair, pairs...)
    recode!(dest::CategoricalArray, src::CatArray, pair::Pair, pairs::Pair...) =
        recode!(dest, src, nothing, pair, pairs...)
    recode!(dest::NullableCategoricalArray, src::CatArray, pair::Pair, pairs::Pair...) =
        recode!(dest, src, nothing, pair, pairs...)

    recode(a::AbstractArray, pair::Pair, pairs::Pair...) = recode(a, nothing, pair, pairs...)
    recode(a::CategoricalArray, pair::Pair, pairs::Pair...) = recode(a, nothing, pair, pairs...)
    recode(a::NullableCategoricalArray, pair::Pair, pairs::Pair...) = recode(a, nothing, pair, pairs...)
end


"""
    recode!(dest::AbstractArray, src::AbstractArray[, default::Any], pairs::Pair...)

Fill `dest` with elements from `src`, replacing those matching a key of `pairs`
with the corresponding value.

For each `Pair` in `pairs`, if the element is equal to (according to `isequal`) or `in` the key
(first item of the pair), then the corresponding value (second item) is copied to `src`.
If the element matches no key and `default` is not provided or `nothing`, it is copied as-is;
if `default` is specified, it is used in place of the original element.
`dest` and `src` must be of the same length, but not necessarily of the same type.
Elements of `src` as well as values from `pairs` will be `convert`ed when possible
on assignment.
If an element matches more than one key, the first match is used.

    recode!(dest::AbstractArray, src::AbstractArray{<:Nullable}[, default::Any], pairs::Pair...)

For a nullable array `src`, automatic lifting is applied: values are unwrapped before
comparing them to the keys of `pairs` using `isequal`. Null values are never replaced
with `default`: use `Nullable()` in a pair to recode them.
"""
function recode! end

recode!(dest::AbstractArray, src::AbstractArray, pairs::Pair...) =
    recode!(dest, src, nothing, pairs...)

function recode!{T}(dest::AbstractArray{T}, src::AbstractArray, default::Any, pairs::Pair...)
    if length(dest) != length(src)
        throw(DimensionMismatch("dest and src must be of the same length (got $(length(dest)) and $(length(src)))"))
    end

    @inbounds for i in eachindex(dest, src)
        x = src[i]

        for j in 1:length(pairs)
            p = pairs[j]
            if eltype(src) <: Nullable
                # FIXME: null values do not match a null inside a tuple or array, since that would
                # require going over all values in the container (inefficient for ranges)
                if (!isa(p.first, Union{AbstractArray, Tuple}) && !isa(p.first, Nullable) && isequal(x, Nullable(p.first))) ||
                   (!isa(p.first, Union{AbstractArray, Tuple}) && isa(p.first, Nullable) && isequal(x, p.first)) ||
                   (isa(p.first, Union{AbstractArray, Tuple}) && !isnull(x) && unsafe_get(x) in p.first)
                    dest[i] = p.second
                    @goto nextitem
                end
            else
                if (!isa(p.first, Union{AbstractArray, Tuple}) && isequal(x, p.first)) ||
                   (isa(p.first, Union{AbstractArray, Tuple}) && x in p.first)
                    dest[i] = p.second
                    @goto nextitem
                end
            end
        end

        # Value not in any of the pairs
        if _isnull(x)
            dest[i] = Nullable()
        elseif default === nothing
            try
                dest[i] = x
            catch err
                isa(err, MethodError) || rethrow(err)
                v = typeof(x) <: Nullable ? get(x) : x
                T1 = typeof(x) <: Nullable ? eltype(typeof(x)) : typeof(x)
                T2 = T <: Nullable ? eltype(T) : T
                throw(ArgumentError("cannot `convert` value $(repr(v)) (of type $T1) to type of recoded levels ($T2). " *
                                    "This will happen with recode() when not all original levels are recoded " *
                                    "(i.e. some are preserved) and their type is incompatible with that of recoded levels."))
            end
        else
            dest[i] = default
        end

        @label nextitem
    end

    dest
end

function recode!{T}(dest::CatArray{T}, src::AbstractArray, default::Any, pairs::Pair...)
    if length(dest) != length(src)
        throw(DimensionMismatch("dest and src must be of the same length (got $(length(dest)) and $(length(src)))"))
    end

    vals = T[_unsafe_get(p.second) for p in pairs if !_isnull(p.second)]
    if default !== nothing && !_isnull(default)
        push!(vals, _unsafe_get(default))
    end

    levels!(dest.pool, unique(vals))
    # In the absence of duplicated recoded values, we do not need to lookup the reference
    # for each pair in the loop, which is more efficient (with loop unswitching)
    dupvals = length(vals) != length(levels(dest.pool))

    drefs = dest.refs
    pairmap = [get(dest.pool, v) for v in vals]
    defaultref = default === nothing || _isnull(default) ?
                 0 : get(dest.pool, _unsafe_get(default))
    @inbounds for i in eachindex(drefs, src)
        x = src[i]

        for j in 1:length(pairs)
            p = pairs[j]
            if eltype(src) <: Nullable
                # FIXME: null values do not match a null inside a tuple or array, since that would
                # require going over all values in the container (inefficient for ranges)
                if (!isa(p.first, Union{AbstractArray, Tuple}) && !isa(p.first, Nullable) && isequal(x, Nullable(p.first))) ||
                   (!isa(p.first, Union{AbstractArray, Tuple}) && isa(p.first, Nullable) && isequal(x, p.first)) ||
                   (isa(p.first, Union{AbstractArray, Tuple}) && !isnull(x) && unsafe_get(x) in p.first)
                    drefs[i] = dupvals ? pairmap[j] : j
                    @goto nextitem
                end
            else
                if (!isa(p.first, Union{AbstractArray, Tuple}) && isequal(x, p.first)) ||
                   (isa(p.first, Union{AbstractArray, Tuple}) && x in p.first)
                    drefs[i] = dupvals ? pairmap[j] : j
                    @goto nextitem
                end
            end
        end

        # Value not in any of the pairs
        if _isnull(x)
            eltype(dest) <: Nullable || throw(NullException())
            drefs[i] = 0
        elseif default === nothing
            try
                dest[i] = x # Need a dictionary lookup, and potentially adding a new level
            catch err
                isa(err, MethodError) || rethrow(err)
                T1 = typeof(x) <: Nullable ? eltype(typeof(x)) : typeof(x)
                throw(ArgumentError("cannot `convert` value $(repr(x)) (of type $T1) to type of recoded levels ($T). " *
                                    "This will happen with recode() when not all original levels are recoded "*
                                    "(i.e. some are preserved) and their type is incompatible with that of recoded levels."))
            end
        else
            drefs[i] = defaultref
        end

        @label nextitem
    end

    # Put existing levels first, and sort them if possible
    # for consistency with CategoricalArray
    oldlevels = setdiff(levels(dest), vals)
    if method_exists(isless, (eltype(oldlevels), eltype(oldlevels)))
        sort!(oldlevels)
    end
    levels!(dest, union(oldlevels, levels(dest)))

    dest
end

function recode!{T}(dest::CatArray{T}, src::CatArray, default::Any, pairs::Pair...)
    if length(dest) != length(src)
        throw(DimensionMismatch("dest and src must be of the same length (got $(length(dest)) and $(length(src)))"))
    end

    vals = T[_unsafe_get(p.second) for p in pairs if !_isnull(p.second)]
    if default === nothing
        srclevels = levels(src)

        # Remove recoded levels as they won't appear in result
        firsts = (p.first for p in pairs)
        keptlevels = Vector{T}()
        sizehint!(keptlevels, length(srclevels))

        for l in srclevels
            if !(l in firsts || any(f -> isa(f, Union{AbstractArray, Tuple}) && l in f, firsts))
                try
                    push!(keptlevels, l)
                catch err
                    isa(err, MethodError) || rethrow(err)
                    throw(ArgumentError("cannot `convert` value $(repr(l)) (of type $(typeof(l))) to type of recoded levels ($T). " *
                                        "This will happen with recode() when not all original levels are recoded " *
                                        "(i.e. some are preserved) and their type is incompatible with that of recoded levels."))
                end
            end
        end
        levs, ordered = mergelevels(isordered(src), keptlevels, unique(vals))
    else
        !_isnull(default) && push!(vals, _unsafe_get(default))
        levs = unique(vals)
        # The order of default cannot be determined
        ordered = false
    end

    srcindex = src.pool === dest.pool ? copy(index(src.pool)) : index(src.pool)
    levels!(dest.pool, levs)

    drefs = dest.refs
    srefs = src.refs

    origmap = [get(dest.pool, v, 0) for v in srcindex]
    indexmap = Vector{DefaultRefType}(length(srcindex)+1)
    # For null values (0 if no null in pairs' keys)
    indexmap[1] = 0
    for p in pairs
        if _isnull(p.first)
            indexmap[1] = get(dest.pool, p.second)
            break
        end
    end
    pairmap = [_isnull(p.second) ? 0 : get(dest.pool, p.second) for p in pairs]
    # Preserving ordered property only makes sense if new order is consistent with previous one
    ordered && (ordered = issorted(pairmap))
    ordered!(dest, ordered)
    defaultref = default === nothing || _isnull(default) ?
                 0 : get(dest.pool, _unsafe_get(default))
    @inbounds for (i, l) in enumerate(srcindex)
        for j in 1:length(pairs)
            p = pairs[j]
            if (!isa(p.first, Union{AbstractArray, Tuple}) && isequal(l, p.first)) ||
               (isa(p.first, Union{AbstractArray, Tuple}) && l in p.first)
                indexmap[i+1] = pairmap[j]
                @goto nextitem
            end
        end

        # Value not in any of the pairs
        if default === nothing
            indexmap[i+1] = origmap[i]
        else
            indexmap[i+1] = defaultref
        end

        @label nextitem
    end

    @inbounds for i in eachindex(drefs)
        v = indexmap[srefs[i]+1]
        if !(eltype(dest) <: Nullable)
            v > 0 || throw(NullException())
        end
        drefs[i] = v
    end

    dest
end

"""
    recode!(a::AbstractArray[, default::Any], pairs::Pair...)

Convenience function for in-place recoding, equivalent to `recode!(a, a, ...)`.

# Examples
```jldoctest
julia> x = collect(1:10);
julia> recode!(x, 1=>100, 2:4=>0, [5; 9:10]=>-1);
julia> x
10-element Array{Int64,1}:
 100
   0
   0
   0
  -1
   6
   7
   8
  -1
  -1
 ```
"""
recode!(a::AbstractArray, default::Any, pairs::Pair...) = recode!(a, a, default, pairs...)
recode!(a::AbstractArray, pairs::Pair...) = recode!(a, a, nothing, pairs...)

promote_valuetype{K, V}(x::Pair{K, V}) = V
promote_valuetype{K, V}(x::Pair{K, V}, y::Pair...) = promote_type(V, promote_valuetype(y...))

"""
    recode(a::AbstractArray[, default::Any], pairs::Pair...)

Return a new categorical array with elements from `a`, replacing elements matching a key
of `pairs` with the corresponding value. The type of the array is chosen so that it can
hold all recoded elements (but not necessarily original elements from `a`).

For each `Pair` in `pairs`, if the element is equal to (according to `isequal`) or `in` the key
(first item of the pair), then the corresponding value (second item) is copied to `src`.
If the element matches no key and `default` is not provided or `nothing`, it is copied as-is;
if `default` is specified, it is used in place of the original element.
If an element matches more than one key, the first match is used.

# Examples
```jldoctest
julia> recode(1:10, 1=>100, 2:4=>0, [5; 9:10]=>-1)
10-element Array{Int64,1}:
 100
 0  
 0  
 0  
 -1 
 6  
 7  
 8  
 -1 
 -1 
 ```

     recode(a::AbstractArray{<:Nullable}[, default::Any], pairs::Pair...)

For a nullable array `a`, automatic lifting is applied: values are unwrapped before
comparing them to the keys of `pairs` using `isequal`. Null values are never replaced
with `default`: use `Nullable()` in a pair to recode them.

Return a `NullableArray` unless `default` is provided and not nullable, in which case
an `Array` is returned.

# Examples
```jldoctest
julia> using NullableArrays

julia> recode(NullableArray(1:10), 1=>100, 2:4=>0, [5; 9:10]=>-1, 6=>Nullable())
10-element NullableArrays.NullableArray{Int64,1}:
 100  
 0    
 0    
 0    
 -1   
 #NULL
 7    
 8    
 -1   
 -1   
 ```
"""
function recode end

recode(a::AbstractArray, pairs::Pair...) = recode(a, nothing, pairs...)

function recode(a::AbstractArray, default::Any, pairs::Pair...)
    V = promote_valuetype(pairs...)
    # T cannot take into account eltype(src), since we can't know
    # whether it matters at compile time (all levels recoded or not)
    # and using a wider type than necessary would be annoying
    T = default === nothing ? V : promote_type(typeof(default), V)
    # TODO: result should not be a nullable array when one of the pairs' LHS is null
    if T <: Nullable || eltype(a) <: Nullable
        dest = NullableArray{T <: Nullable ? eltype(T) : T}(size(a))
    else
        dest = Array{T}(size(a))
    end
    recode!(dest, a, default, pairs...)
end

function recode{S, N, R}(a::CatArray{S, N, R}, default::Any, pairs::Pair...)
    V = promote_valuetype(pairs...)
    # T cannot take into account eltype(src), since we can't know
    # whether it matters at compile time (all levels recoded or not)
    # and using a wider type than necessary would be annoying
    T = default === nothing ? V : promote_type(typeof(default), V)
    # TODO: result should not be a nullable array when one of the pairs' LHS is null
    if T <: Nullable || eltype(a) <: Nullable
        dest = NullableCategoricalArray{T <: Nullable ? eltype(T) : T, N, R}(size(a))
    else
        dest = CategoricalArray{T, N, R}(size(a))
    end
    recode!(dest, a, default, pairs...)
end
