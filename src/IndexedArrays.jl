module IndexedArrays

using Compat

include("delegate.jl")

import Base: copy, in, getindex, findfirst, length, size, start, done, next, empty!, push!

abstract AbstractIndexedArray{T} <: AbstractVector{T}

type IndexedArrayError <: Exception # FIXME: or should we just use ArgumentError here?
    msg::AbstractString
end

immutable IndexedArray{T} <: AbstractIndexedArray
    items::Array{T}
    lookup::Dict{T,Int}

    IndexedArray() = new(T[], Dict{T,Int}())
    function IndexedArray(items::Array{T})
        ia = new(items, Dict{T,Int}())
        sizehint!(ia.lookup, length(ia.items))
        for (i, item) in enumerate(ia.items)
            if item in ia
                throw(IndexedArrayError())
            end
            ia.lookup[item] = i
        end
        return ia
    end
end

@delegate IndexedArray.items [ length, size, start, done, next ]

getindex(ia::IndexedArray, i::Int) = getindex(ia.items, i)
getindex(ia::IndexedArray, r::UnitRange{Int}) = getindex(ia.items, r)

function empty!(ia::IndexedArray)
    # NOTE: does not provide any exception safety guarantee
    empty!(ia.items)
    empty!(ia.lookup)
    return ia
end

in(item, ia::IndexedArray) = haskey(ia.lookup, item)

findfirst(ia::IndexedArray, item) = ia.lookup[item] # throws KeyError if not found

findfirst!(ia::IndexedArray, item) = get!(ia.lookup, item) do
    # NOTE: does not provide any exception safety guarantee
    push!(ia.items, item)
    ia.lookup[item] = length(ia)
end

function push!(ia::IndexedArray, item)
    if item in ia
        throw(IndexedArrayError())
    end
    # NOTE: does not provide any exception safety guarantee
    push!(ia.items, item)
    ia.lookup[item] = length(ia)
    return ia
end

copy{T}(ia::IndexedArray{T}) = IndexedArray{T}(copy(ia.items))

export AbstractIndexedArray, IndexedArray, findfirst!

end # module
