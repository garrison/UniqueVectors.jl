# by JMW; taken from DataStructures.jl

macro delegate(source, targets)
    typename = esc(source.args[1])
    fieldname = source.args[2].value
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
