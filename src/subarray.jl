# delegate methods for SubArrays to support view

isordered(sa::SubArray{T,N,P}) where {T,N,P<:CategoricalArray} = isordered(parent(sa))
# This method cannot support allowmissing=true since that would modify the parent
levels!(sa::SubArray{T,N,P}, newlevels::Vector) where {T,N,P<:CategoricalArray} =
    levels!(parent(sa), newlevels)

function unique(sa::SubArray{T,N,P}) where {T,N,P<:CategoricalArray}
    A = parent(sa)
    refs = view(A.refs, sa.indices...)
    S = eltype(P) >: Missing ? Union{eltype(levels(A.pool)), Missing} : eltype(levels(A.pool))
    _unique(S, refs, A.pool)
end

refs(A::SubArray{<:Any, <:Any, <:CategoricalArray}) =
    view(parent(A).refs, parentindices(A)...)

pool(A::SubArray{<:Any, <:Any, <:CategoricalArray}) = A.parent.pool

function Base.fill!(A::SubArray{<:Any, <:Any, <:CategoricalArray}, v::Any)
    r = get!(A.parent.pool, convert(leveltype(A.parent), v))
    fill!(refs(A), r)
    A
end

Base.fill!(A::SubArray{<:Any, <:Any, <:CategoricalArray{>:Missing}}, ::Missing) =
    (fill!(refs(A), 0); A)

Base.Broadcast.broadcasted(::typeof(ismissing),
                           A::SubArray{<:Any, <:Any, <:CategoricalArray{T}}) where {T} =
    T >: Missing ? Base.Broadcast.broadcasted(==, refs(A), 0) :
                   Base.Broadcast.broadcasted(_ -> false, refs(A))

Base.Broadcast.broadcasted(::typeof(!ismissing),
                           A::SubArray{<:Any, <:Any, <:CategoricalArray{T}}) where {T} =
    T >: Missing ? Base.Broadcast.broadcasted(>, refs(A), 0) :
                   Base.Broadcast.broadcasted(_ -> true, refs(A))