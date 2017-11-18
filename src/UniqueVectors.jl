__precompile__()

module UniqueVectors

using Compat

include("delegate.jl")

import Base: copy, in, getindex, findfirst, findlast, length, size, isempty, start, done, next, empty!, push!, pop!, setindex!, indexin, findin, findnext, findprev, find, count

abstract type AbstractUniqueVector{T} <: AbstractVector{T} end

Base.@deprecate_binding UniqueVectorError ArgumentError

struct UniqueVector{T} <: AbstractUniqueVector{T}
    items::Vector{T}
    lookup::Dict{T,Int}

    UniqueVector{T}() where {T} = new(T[], Dict{T,Int}())
    function UniqueVector{T}(items::Vector{T}) where {T}
        uv = new(items, Dict{T,Int}())
        sizehint!(uv.lookup, length(uv.items))
        for (i, item) in enumerate(uv.items)
            if item in uv
                throw(ArgumentError("cannot construct UniqueVector with duplicate items"))
            end
            uv.lookup[item] = i
        end
        @assert length(uv.items) == length(uv.lookup)
        return uv
    end
end

UniqueVector(items::Vector{T}) where {T} = UniqueVector{T}(items)
UniqueVector(items::AbstractVector{T}) where {T} = UniqueVector{T}(Vector{T}(items))
UniqueVector(items) = UniqueVector(collect(items))

@delegate UniqueVector.items [ length, size, isempty, getindex, start, done, next ]

function empty!(uv::UniqueVector)
    # NOTE: does not provide any exception safety guarantee
    empty!(uv.items)
    empty!(uv.lookup)
    return uv
end

in(item::T, uv::UniqueVector{T}) where {T} = haskey(uv.lookup, item)
in(item, uv::UniqueVector{T}) where {T} = in(convert(T, item), uv)

findfirst(p::equalto{<:T}, uv::UniqueVector{T}) where {T} =
    get(uv.lookup, p.x, 0)

function findfirst!(p::equalto{<:T}, uv::UniqueVector{T}) where {T}
    rv = get!(uv.lookup, p.x) do
        # NOTE: does not provide any exception safety guarantee
        push!(uv.items, p.x)
        return length(uv.items)
    end
    @assert length(uv.items) == length(uv.lookup)
    return rv
end

findfirst(p::equalto, uv::UniqueVector{T}) where {T} =
    findfirst(equalto(convert(T, p.x)), uv)

findfirst!(p::equalto, uv::UniqueVector{T}) where {T} =
    findfirst!(equalto(convert(T, p.x)), uv)

findlast(p::equalto, uv::AbstractUniqueVector) =
    findfirst(p, uv)

if VERSION >= v"0.7.0-DEV"
    @deprecate findfirst(uv::UniqueVector, item) findfirst(equalto(item), uv)
    @deprecate findfirst!(uv::UniqueVector, item) findfirst!(equalto(item), uv)
else
    findfirst(uv::UniqueVector, item) = findfirst(equalto(item), uv)
    findfirst!(uv::UniqueVector, item) = findfirst!(equalto(item), uv)
end

@deprecate findlast(uv::UniqueVector, item) findlast(equalto(item), uv)

indexin(a::AbstractArray, b::AbstractUniqueVector) =
    [findlast(equalto(elt), b) for elt in a]

findin(a, b::AbstractUniqueVector) =
    [i for (i, ai) in enumerate(a) if ai ∈ b]

function findnext(p::equalto, A::AbstractUniqueVector, i::Integer)
    idx = findfirst(p, A)
    idx >= i ? idx : 0
end

@deprecate findnext(A::UniqueVector, v, i::Integer) findnext(equalto(v), A, i)

function findprev(p::equalto, A::AbstractUniqueVector, i::Integer)
    idx = findfirst(p, A)
    idx <= i ? idx : 0
end

@deprecate findprev(A::UniqueVector, v, i::Integer) findprev(equalto(v), A, i)

function find(p::equalto, uv::AbstractUniqueVector)
    idx = findfirst(p, uv)
    (idx == 0) ? Int[] : Int[idx]
end

count(p::equalto, uv::AbstractUniqueVector) =
    Int(p.x ∈ uv)

function push!(uv::UniqueVector{T}, item::T) where {T}
    if item in uv
        throw(ArgumentError("cannot add duplicate item to UniqueVector"))
    end
    # NOTE: does not provide any exception safety guarantee
    push!(uv.items, item)
    uv.lookup[item] = length(uv)
    @assert length(uv.items) == length(uv.lookup)
    return uv
end

push!(uv::UniqueVector{T}, item) where {T} =
    push!(uv, convert(T, item))

function pop!(uv::UniqueVector)
    if isempty(uv.items)
        throw(ArgumentError("array must be non-empty"))
    end
    # NOTE: does not provide any exception safety guarantee
    delete!(uv.lookup, uv.items[end])
    rv = pop!(uv.items)
    @assert length(uv.items) == length(uv.lookup)
    return rv
end

function setindex!(uv::UniqueVector{T}, item::T, idx::Integer) where {T}
    checkbounds(uv, idx)
    uv[idx] == item && return uv # nothing to do
    item ∉ uv || throw(ArgumentError("cannot set an element that exists elsewhere in UniqueVector"))
    # NOTE: does not provide any exception safety guarantee
    delete!(uv.lookup, uv.items[idx])
    uv.items[idx] = item
    uv.lookup[item] = idx
    @assert length(uv.items) == length(uv.lookup)
    return uv
end

setindex!(uv::UniqueVector{T}, item, idx::Integer) where {T} =
    setindex!(uv, convert(T, item), idx)

copy(uv::UniqueVector) = UniqueVector(copy(uv.items))

"`swap!(uv::UniqueVector, to::Int, from::Int)` interchange/swap the values on the indices `to` and `from` in the `UniqueVector`"
function swap!(uv::UniqueVector, to::Int, from::Int)
    if to == from
        checkbounds(uv,to)
        return uv
    end
    previous_id  = uv[to]
    future_id    = uv[from]

    uv.items[to]   = future_id
    uv.items[from] = previous_id

    uv.lookup[previous_id] = from
    uv.lookup[future_id]   = to

    return uv
end

export AbstractUniqueVector, UniqueVector, findfirst!, swap!

end # module
