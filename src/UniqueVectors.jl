__precompile__()

module UniqueVectors

include("delegate.jl")

import Base: copy, in, getindex, findfirst, length, size, isempty, start, done, next, empty!, push!, pop!

using Compat

@compat abstract type AbstractUniqueVector{T} <: AbstractVector{T} end

type UniqueVectorError <: Exception # FIXME: or should we just use ArgumentError here?
    msg::AbstractString
end

immutable UniqueVector{T} <: AbstractUniqueVector{T}
    items::Vector{T}
    lookup::Dict{T,Int}

    (::Type{UniqueVector{T}}){T}() = new{T}(T[], Dict{T,Int}())
    function (::Type{UniqueVector{T}}){T}(items::Vector{T})
        ia = new{T}(items, Dict{T,Int}())
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

UniqueVector{T}(items::Vector{T}) = UniqueVector{T}(items)
UniqueVector{T}(items::AbstractVector{T}) = UniqueVector{T}(Vector{T}(items))
UniqueVector(items) = UniqueVector(collect(items))

@delegate UniqueVector.items [ length, size, isempty, start, done, next ]

getindex(ia::UniqueVector, i::Int) = getindex(ia.items, i)
getindex(ia::UniqueVector, r::UnitRange{Int}) = getindex(ia.items, r)

function empty!(ia::UniqueVector)
    # NOTE: does not provide any exception safety guarantee
    empty!(ia.items)
    empty!(ia.lookup)
    return ia
end

in{T}(item::T, ia::UniqueVector{T}) = haskey(ia.lookup, item)

findfirst{T}(ia::UniqueVector{T}, item::T) = ia.lookup[item] # throws KeyError if not found

function findfirst!{T}(ia::UniqueVector{T}, item::T)
    rv = get!(ia.lookup, item) do
        # NOTE: does not provide any exception safety guarantee
        push!(ia.items, item)
        return length(ia.items)
    end
    @assert length(ia.items) == length(ia.lookup)
    return rv
end

findfirst{T}(ia::UniqueVector{T}, item) =
    findfirst(ia, convert(T, item))

findfirst!{T}(ia::UniqueVector{T}, item) =
    findfirst!(ia, convert(T, item))

function push!{T}(ia::UniqueVector{T}, item::T)
    if item in ia
        throw(UniqueVectorError("cannot add duplicate item to UniqueVector"))
    end
    # NOTE: does not provide any exception safety guarantee
    push!(ia.items, item)
    ia.lookup[item] = length(ia)
    @assert length(ia.items) == length(ia.lookup)
    return ia
end

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

copy{T}(ia::UniqueVector{T}) = UniqueVector{T}(copy(ia.items))

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
