# UniqueVectors

[![version](https://juliahub.com/docs/UniqueVectors/version.svg)](https://juliahub.com/ui/Packages/UniqueVectors/iZpAV)
[![Build Status](https://github.com/garrison/UniqueVectors.jl/actions/workflows/test.yml/badge.svg)](https://github.com/garrison/UniqueVectors.jl/actions)
[![pkgeval](https://juliahub.com/docs/UniqueVectors/pkgeval.svg)](https://juliahub.com/ui/Packages/UniqueVectors/iZpAV)

```julia
julia> import Pkg; Pkg.add("UniqueVectors")
```

`UniqueVector` is a data structure acts like a `Vector` of unique elements, but also maintains a dictionary that is updated in sync with the vector, which allows for quick `O(1)` lookup of the index of any element:

```julia
julia> using UniqueVectors

julia> uv = UniqueVector(["cat", "dog", "mouse"])
3-element UniqueVectors.UniqueVector{String}:
 "cat"
 "dog"
 "mouse"

julia> uv[1]
"cat"

julia> findfirst(isequal("dog"), uv)         # executes quickly via a dictionary lookup, not sequential search
2
```

As might be expected, `UniqueVector` supports many of the usual methods for `Vector`, but all operations enforce the condition that each element of the array must be unique (as defined by `isequal`).  The mutating methods `push!`, `pop!`, and `empty!` are implemented as well, as these operations keep constant the indices of existing elements in the array, allowing the dictionary to be updated efficiently.

In addition, `UniqueVector` implements a mutating `findfirst!` method, which returns the index of an element if it exists in the array, or otherwise appends the element and returns its new index:

```julia
julia> findfirst!(isequal("cat"), uv)
1

julia> findfirst!(isequal("horse"), uv)
4

julia> uv
4-element UniqueVectors.UniqueVector{String}:
 "cat"
 "dog"
 "mouse"
 "horse"
```

`UniqueVector` is derived from an abstract type known as `AbstractUniqueVector`.  This type is meant for anything that implements a fast bi-directional mapping between elements of a type `T` and integers from `1` to `N`.  For some applications, it will be possible to have alternative implementations of this interface--ones that resemble an `UniqueVector` but can be calculated quickly on the fly (and may not need to be fully stored in memory).  One notable example of this would be [Lin](http://www.phy.cuhk.edu.hk/hqlin/paper/018PRB42_6561.pdf) [Tables](http://www.phy.cuhk.edu.hk/hqlin/paper/033ComPhys7_400.pdf), which are often used in numerical exact diagonalization studies, and which are used to map each basis element of a quantum Hamiltonian to indices `1` through `N`.

(More generally, one might want an abstract type that represents any bidirectional mapping between two different sets (without one of them necessarily being contiguous integers from `1` to `N`).  In this case, using `findfirst` may not be the appropriate interface, and I'd welcome any comments on this.)

Note: This package was formerly known as `IndexedArrays` (see issue [#4]).

[#4]: https://github.com/garrison/UniqueVectors.jl/issues/4
