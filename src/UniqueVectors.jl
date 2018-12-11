module UniqueVectors

include("delegate.jl")

import Base: copy, in, getindex, findfirst, findlast, length, size, isempty, iterate, empty!, push!, pop!, setindex!, indexin, findnext, findprev, findall, count, allunique, unique, unique!

EqualTo = Base.Fix2{typeof(isequal)}

abstract type AbstractUniqueVector{T} <: AbstractVector{T} end

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

copy(uv::UniqueVector) = UniqueVector(copy(uv.items))

@delegate UniqueVector.items [ length, size, isempty, getindex, iterate ]

function empty!(uv::UniqueVector)
    # NOTE: does not provide any exception safety guarantee
    empty!(uv.items)
    empty!(uv.lookup)
    return uv
end

in(item::T, uv::UniqueVector{T}) where {T} = haskey(uv.lookup, item)
in(item, uv::UniqueVector{T}) where {T} = in(convert(T, item), uv)

findfirst(p::EqualTo{<:T}, uv::UniqueVector{T}) where {T} =
    get(uv.lookup, p.x, nothing)

function findfirst!(p::EqualTo{<:T}, uv::UniqueVector{T}) where {T}
    rv = get!(uv.lookup, p.x) do
        # NOTE: does not provide any exception safety guarantee
        push!(uv.items, p.x)
        return length(uv.items)
    end
    @assert length(uv.items) == length(uv.lookup)
    return rv
end

findfirst(p::EqualTo, uv::UniqueVector{T}) where {T} =
    findfirst(isequal(convert(T, p.x)), uv)

findfirst!(p::EqualTo, uv::UniqueVector{T}) where {T} =
    findfirst!(isequal(convert(T, p.x)), uv)

findlast(p::EqualTo, uv::AbstractUniqueVector) =
    findfirst(p, uv)

indexin(a::AbstractArray, b::AbstractUniqueVector) =
    [findlast(isequal(elt), b) for elt in a]

function findall(p::Base.Fix2{typeof(in),<:AbstractUniqueVector},
                 a::Union{Tuple, AbstractArray})
    # The version in Base creates a Set that is unnecessary in our case.  So
    # the override it here.
    [i for (i, ai) in (@static if VERSION >= v"1.1.0-DEV.832" pairs else enumerate end)(a) if p(ai)]
end

function findnext(p::EqualTo, A::AbstractUniqueVector, i::Integer)
    idx = findfirst(p, A)
    idx >= i ? idx : nothing
end

function findprev(p::EqualTo, A::AbstractUniqueVector, i::Integer)
    idx = findfirst(p, A)
    idx <= i ? idx : nothing
end

function findall(p::EqualTo, uv::AbstractUniqueVector)
    idx = findfirst(p, uv)
    (idx == nothing) ? Int[] : Int[idx]
end

count(p::EqualTo, uv::AbstractUniqueVector) =
    Int(p.x ∈ uv)

allunique(::AbstractUniqueVector) = true

unique!(uv::AbstractUniqueVector)::AbstractUniqueVector = uv
unique(uv::UniqueVector)::Vector = copy(uv.items)

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

"`swap!(uv::UniqueVector, to::Int, from::Int)` interchange/swap the values on the indices `to` and `from` in the `UniqueVector`"
function swap!(uv::UniqueVector, to::Int, from::Int)
    if to == from
        checkbounds(uv,to)
        return uv
    end

    # NOTE: does not provide any exception safety guarantee
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
