# by JMW; taken from DataStructures.jl

# See https://github.com/JuliaCollections/DataStructures.jl/commit/bb7b51f95a9ddc7582acb171486f150353c6e361
function unquote(e::Expr)
    # For julia < 0.7
    @assert e.head == :quote
    return e.args[1]
end

function unquote(e::QuoteNode)
    return e.value
end

macro delegate(source, targets)
    typename = esc(source.args[1])
    fieldname = unquote(source.args[2])
    funcnames = targets.args
    n = length(funcnames)
    fdefs = Any[]
    for i in 1:n
        funcname = esc(funcnames[i])
        push!(fdefs, quote
            ($funcname)(a::($typename), args...) =
            ($funcname)(a.$fieldname, args...)
        end)
    end
    return Expr(:block, fdefs...)
end
