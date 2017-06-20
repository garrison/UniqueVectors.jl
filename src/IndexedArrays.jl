__precompile__()

module IndexedArrays

warn("The IndexedArrays package is deprecated. It is now named UniqueVectors; please use that package instead.")

include("delegate.jl")

import Base: copy, in, getindex, findfirst, length, size, isempty, start, done, next, empty!, push!, pop!

using Compat

@compat abstract type AbstractIndexedArray{T} <: AbstractVector{T} end

type IndexedArrayError <: Exception # FIXME: or should we just use ArgumentError here?
    msg::AbstractString
end

immutable IndexedArray{T} <: AbstractIndexedArray{T}
    items::Vector{T}
    lookup::Dict{T,Int}

    (::Type{IndexedArray{T}}){T}() = new{T}(T[], Dict{T,Int}())
    function (::Type{IndexedArray{T}}){T}(items::Vector{T})
        ia = new{T}(items, Dict{T,Int}())
        sizehint!(ia.lookup, length(ia.items))
        for (i, item) in enumerate(ia.items)
            if item in ia
                throw(IndexedArrayError("cannot construct IndexedArray with duplicate items"))
            end
            ia.lookup[item] = i
        end
        @assert length(ia.items) == length(ia.lookup)
        return ia
    end
end

IndexedArray{T}(items::Vector{T}) = IndexedArray{T}(items)
IndexedArray{T}(items::AbstractVector{T}) = IndexedArray{T}(Vector{T}(items))

@delegate IndexedArray.items [ length, size, isempty, start, done, next ]

getindex(ia::IndexedArray, i::Int) = getindex(ia.items, i)
getindex(ia::IndexedArray, r::UnitRange{Int}) = getindex(ia.items, r)

function empty!(ia::IndexedArray)
    # NOTE: does not provide any exception safety guarantee
    empty!(ia.items)
    empty!(ia.lookup)
    return ia
end

in{T}(item::T, ia::IndexedArray{T}) = haskey(ia.lookup, item)

findfirst{T}(ia::IndexedArray{T}, item::T) = ia.lookup[item] # throws KeyError if not found

function findfirst!{T}(ia::IndexedArray{T}, item::T)
    rv = get!(ia.lookup, item) do
        # NOTE: does not provide any exception safety guarantee
        push!(ia.items, item)
        return length(ia.items)
    end
    @assert length(ia.items) == length(ia.lookup)
    return rv
end

findfirst{T}(ia::IndexedArray{T}, item) =
    findfirst(ia, convert(T, item))

findfirst!{T}(ia::IndexedArray{T}, item) =
    findfirst!(ia, convert(T, item))

function push!{T}(ia::IndexedArray{T}, item::T)
    if item in ia
        throw(IndexedArrayError("cannot add duplicate item to IndexedArray"))
    end
    # NOTE: does not provide any exception safety guarantee
    push!(ia.items, item)
    ia.lookup[item] = length(ia)
    @assert length(ia.items) == length(ia.lookup)
    return ia
end

function pop!(ia::IndexedArray)
    if isempty(ia.items)
        throw(ArgumentError("array must be non-empty"))
    end
    # NOTE: does not provide any exception safety guarantee
    delete!(ia.lookup, ia.items[end])
    rv = pop!(ia.items)
    @assert length(ia.items) == length(ia.lookup)
    return rv
end

copy{T}(ia::IndexedArray{T}) = IndexedArray{T}(copy(ia.items))

"`swap!(ia::IndexedArray, to::Int, from::Int)` interchange/swap the values on the indices `to` and `from` in the `IndexedArray`"
function swap!(ia::IndexedArray, to::Int, from::Int)
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

export AbstractIndexedArray, IndexedArray, IndexedArrayError, findfirst!, swap!

end # module
