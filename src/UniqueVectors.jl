__precompile__()

module UniqueVectors

include("delegate.jl")

import Base: copy, in, getindex, findfirst, length, size, isempty, start, done, next, empty!, push!, pop!, setindex!, indexin, findin

abstract type AbstractUniqueVector{T} <: AbstractVector{T} end

struct UniqueVectorError <: Exception # FIXME: or should we just use ArgumentError here?
    msg::AbstractString
end

struct UniqueVector{T} <: AbstractUniqueVector{T}
    items::Vector{T}
    lookup::Dict{T,Int}

    UniqueVector{T}() where {T} = new(T[], Dict{T,Int}())
    function UniqueVector{T}(items::Vector{T}) where {T}
        ia = new(items, Dict{T,Int}())
        sizehint!(ia.lookup, length(ia.items))
        for (i, item) in enumerate(ia.items)
            if item in ia
                throw(UniqueVectorError("cannot construct UniqueVector with duplicate items"))
            end
            ia.lookup[item] = i
        end
        @assert length(ia.items) == length(ia.lookup)
        return ia
    end
end

UniqueVector(items::Vector{T}) where {T} = UniqueVector{T}(items)
UniqueVector(items::AbstractVector{T}) where {T} = UniqueVector{T}(Vector{T}(items))
UniqueVector(items) = UniqueVector(collect(items))

@delegate UniqueVector.items [ length, size, isempty, getindex, start, done, next ]

function empty!(ia::UniqueVector)
    # NOTE: does not provide any exception safety guarantee
    empty!(ia.items)
    empty!(ia.lookup)
    return ia
end

in(item::T, ia::UniqueVector{T}) where {T} = haskey(ia.lookup, item)
in(item, ia::UniqueVector{T}) where {T} = in(convert(T, item), ia)

findfirst(ia::UniqueVector{T}, item::T) where {T} =
    get(ia.lookup, item, 0)

function findfirst!(ia::UniqueVector{T}, item::T) where {T}
    rv = get!(ia.lookup, item) do
        # NOTE: does not provide any exception safety guarantee
        push!(ia.items, item)
        return length(ia.items)
    end
    @assert length(ia.items) == length(ia.lookup)
    return rv
end

findfirst(ia::UniqueVector{T}, item) where {T} =
    findfirst(ia, convert(T, item))

findfirst!(ia::UniqueVector{T}, item) where {T} =
    findfirst!(ia, convert(T, item))

findlast(ia::UniqueVector, item) =
    findfirst(ia, item)

indexin(a::AbstractArray, b::UniqueVector) =
    [findfirst(b, elt) for elt in a]

findin(a, b::UniqueVector) =
    [i for (i, ai) in enumerate(a) if ai ∈ b]

function push!(ia::UniqueVector{T}, item::T) where {T}
    if item in ia
        throw(UniqueVectorError("cannot add duplicate item to UniqueVector"))
    end
    # NOTE: does not provide any exception safety guarantee
    push!(ia.items, item)
    ia.lookup[item] = length(ia)
    @assert length(ia.items) == length(ia.lookup)
    return ia
end

push!(ia::UniqueVector{T}, item) where {T} =
    push!(ia, convert(T, item))

function pop!(ia::UniqueVector)
    if isempty(ia.items)
        throw(ArgumentError("array must be non-empty"))
    end
    # NOTE: does not provide any exception safety guarantee
    delete!(ia.lookup, ia.items[end])
    rv = pop!(ia.items)
    @assert length(ia.items) == length(ia.lookup)
    return rv
end

function setindex!(ia::UniqueVector{T}, item::T, idx::Integer) where {T}
    checkbounds(ia, idx)
    ia[idx] == item && return ia # nothing to do
    item ∉ ia || throw(UniqueVectorError("cannot set an element that exists elsewhere in UniqueVector"))
    # NOTE: does not provide any exception safety guarantee
    delete!(ia.lookup, ia.items[idx])
    ia.items[idx] = item
    ia.lookup[item] = idx
    @assert length(ia.items) == length(ia.lookup)
    return ia
end

setindex!(ia::UniqueVector{T}, item, idx::Integer) where {T} =
    setindex!(ia, convert(T, item), idx)

copy(ia::UniqueVector) = UniqueVector(copy(ia.items))

"`swap!(ia::UniqueVector, to::Int, from::Int)` interchange/swap the values on the indices `to` and `from` in the `UniqueVector`"
function swap!(ia::UniqueVector, to::Int, from::Int)
    if to == from
        checkbounds(ia,to)
        return ia
    end
    previous_id  = ia[to]
    future_id    = ia[from]

    ia.items[to]   = future_id
    ia.items[from] = previous_id

    ia.lookup[previous_id] = from
    ia.lookup[future_id]   = to

    return ia
end

export AbstractUniqueVector, UniqueVector, UniqueVectorError, findfirst!, swap!

end # module
