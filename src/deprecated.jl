@deprecate ordered isordered

@deprecate compact compress
@deprecate uncompact decompress

@deprecate CategoricalArray(::Type{T}, dims::NTuple{N,Int}; ordered=false) where {T, N} CategoricalArray{T}(dims, ordered=ordered)
@deprecate CategoricalArray(::Type{T}, dims::Int...; ordered=false) where {T} CategoricalArray{T}(dims, ordered=ordered)

@deprecate CategoricalVector(::Type{T}, m::Integer; ordered=false) where {T} CategoricalVector{T}(m, ordered=ordered)

@deprecate CategoricalMatrix(::Type{T}, m::Int, n::Int; ordered=false) where {T} CategoricalMatrix{T}(m, n, ordered=ordered)

@deprecate CategoricalArray(dims::Int...; ordered=false) CategoricalArray(undef, dims...; ordered=ordered)

@deprecate CategoricalArray{T, N, R}(dims::NTuple{N,Int}; ordered=false) where {T, N, R} CategoricalArray{T, N, R}(undef, dims; ordered=ordered)

@deprecate CategoricalArray{T, N}(dims::NTuple{N,Int}; ordered=false) where {T, N} CategoricalArray{T, N}(undef, dims; ordered=ordered)
@deprecate CategoricalArray{T}(dims::NTuple{N,Int}; ordered=false) where {T, N} CategoricalArray{T}(undef, dims; ordered=ordered)
@deprecate CategoricalArray{T, 1}(m::Int; ordered=false) where {T} CategoricalArray{T, 1}(undef, m; ordered=ordered)
@deprecate CategoricalArray{T, 2}(m::Int, n::Int; ordered=false) where {T} CategoricalArray{T, 2}(undef, m, n; ordered=ordered)
@deprecate CategoricalArray{T, 1, R}(m::Int; ordered=false) where {T, R} CategoricalArray{T, 1, R}(undef, m; ordered=ordered)
# R <: Integer is required to prevent default constructor from being called instead
@deprecate CategoricalArray{T, 2, R}(m::Int, n::Int; ordered=false) where {T, R <: Integer} CategoricalArray{T, 2, R}(undef, m, n; ordered=ordered)
@deprecate CategoricalArray{T, 3, R}(m::Int, n::Int, o::Int; ordered=false) where {T, R} CategoricalArray{T, 3, R}(undef, m, n, o; ordered=ordered)
@deprecate CategoricalArray{T}(m::Int; ordered=false) where {T} CategoricalArray{T}(undef, m; ordered=ordered)
@deprecate CategoricalArray{T}(m::Int, n::Int; ordered=false) where {T} CategoricalArray{T}(undef, m, n; ordered=ordered)
@deprecate CategoricalArray{T}(m::Int, n::Int, o::Int; ordered=false) where {T} CategoricalArray{T}(undef, m, n, o; ordered=ordered)

@deprecate CategoricalVector(m::Integer; ordered=false) CategoricalVector(undef, m; ordered=ordered)
@deprecate CategoricalVector{T}(m::Int; ordered=false) where {T} CategoricalVector{T}(undef, m; ordered=ordered)

@deprecate CategoricalMatrix(m::Int, n::Int; ordered=false) CategoricalMatrix(undef, m, n; ordered=ordered)
@deprecate CategoricalMatrix{T}(m::Int, n::Int; ordered=false) where {T} CategoricalMatrix{T}(undef, m::Int, n::Int; ordered=ordered)

# AbstractString interface for CategoricalString
import Base: eltype, length, lastindex, sizeof, nextind, prevind,
    iterate, getindex, codeunit, ascii, isvalid, match, collect, reverse,
    ncodeunits, isempty, firstindex, lpad, rpad, occursin, startswith, endswith,
    repeat, split, rsplit, strip, lstrip, rstrip, eachmatch,
    uppercase, lowercase, titlecase, uppercasefirst, lowercasefirst,
    chop, chomp, escape_string, textwidth, isascii
# NOTE: drop dependency on Unicode when removing these deprecations
import Unicode: normalize, graphemes
@deprecate eltype(x::CategoricalString) eltype(String(x))
@deprecate length(x::CategoricalString) length(String(x))
@deprecate lastindex(x::CategoricalString) lastindex(String(x))
@deprecate sizeof(x::CategoricalString) sizeof(String(x))
@deprecate nextind(x::CategoricalString, i::Int) nextind(String(x), i)
@deprecate prevind(x::CategoricalString, i::Int) prevind(String(x), i)
@deprecate iterate(x::CategoricalString) iterate(String(x))
@deprecate iterate(x::CategoricalString, i::Int) iterate(String(x), i)
@deprecate getindex(x::CategoricalString, i::Int) getindex(String(x), i)
@deprecate codeunit(x::CategoricalString, i::Integer) codeunit(String(x), i)
@deprecate ascii(x::CategoricalString) ascii(String(x))
@deprecate isvalid(x::CategoricalString) isvalid(String(x))
@deprecate isvalid(x::CategoricalString, i::Integer) isvalid(String(x), i)
@deprecate match(r::Regex, s::CategoricalString,
      idx::Integer=firstindex(s), add_opts::UInt32=UInt32(0); kwargs...) match(r, String(s), idx, add_opts; kwargs...)
@deprecate collect(x::CategoricalString) collect(String(x))
@deprecate reverse(x::CategoricalString) reverse(String(x))
@deprecate ncodeunits(x::CategoricalString) ncodeunits(String(x))

# Methods which are not strictly necessary
# but which allow giving a single and accurate deprecation warning
@deprecate isempty(x::CategoricalString) isempty(String(x))
@deprecate firstindex(x::CategoricalString) firstindex(String(x))
@deprecate normalize(x::CategoricalString, s::Symbol) normalize(String(x), s)
@deprecate graphemes(x::CategoricalString) graphemes(String(x))
@deprecate length(x::CategoricalString, i::Int, j::Int) length(String(x), i, j)
@deprecate repeat(x::CategoricalString, i::Integer) repeat(String(x), i)
@deprecate eachmatch(r::Regex, x::CategoricalString; overlap=false) eachmatch(r, String(x), overlap=overlap)
@deprecate lpad(x::CategoricalString, n::Integer, c::Union{AbstractChar,AbstractString}=' ') lpad(String(x), n)
@deprecate rpad(x::CategoricalString, n::Integer, c::Union{AbstractChar,AbstractString}=' ') rpad(String(x), n)
@deprecate occursin(x::CategoricalString, y::AbstractString) occursin(String(x), y)
@deprecate occursin(x::AbstractString, y::CategoricalString) occursin(x, String(y))
@deprecate occursin(x::Regex, y::CategoricalString) occursin(x, String(y))
@deprecate occursin(x::AbstractChar, y::CategoricalString) occursin(x, String(y))
@deprecate startswith(x::CategoricalString, y::AbstractString) startswith(String(x), y)
@deprecate startswith(x::AbstractString, y::CategoricalString) startswith(x, String(y))
@deprecate endswith(x::CategoricalString, y::AbstractString) endswith(String(x), y)
@deprecate endswith(x::AbstractString, y::CategoricalString) endswith(x, String(y))
@deprecate split(x::CategoricalString; kwargs...) split(String(x); kwargs...)
@deprecate rsplit(x::CategoricalString; kwargs...) rsplit(String(x); kwargs...)
@deprecate strip(x::CategoricalString) strip(String(x))
@deprecate lstrip(x::CategoricalString) lstrip(String(x))
@deprecate rstrip(x::CategoricalString) rstrip(String(x))
@deprecate lowercase(x::CategoricalString) lowercase(String(x))
@deprecate uppercase(x::CategoricalString) uppercase(String(x))
@deprecate lowercasefirst(x::CategoricalString) lowercasefirst(String(x))
@deprecate uppercasefirst(x::CategoricalString) uppercasefirst(String(x))
@deprecate titlecase(x::CategoricalString) titlecase(String(x))
@deprecate chop(x::CategoricalString; kwargs...) chop(String(x); kwargs...)
@deprecate chomp(x::CategoricalString) chomp(String(x))
@deprecate textwidth(x::CategoricalString) textwidth(String(x))
@deprecate isascii(x::CategoricalString) isascii(String(x))
@deprecate escape_string(x::CategoricalString) escape_string(String(x))

# Avoid printing a deprecation until CategoricalString is no longer AbstractString
Base.string(io::IO, x::CategoricalString) = print(io, get(x))
Base.escape_string(io::IO, x::CategoricalString, esc) = escape_string(io, get(x), esc)