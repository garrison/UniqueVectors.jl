# UniqueVectors

[![Build Status](https://travis-ci.org/garrison/UniqueVectors.jl.svg?branch=master)](https://travis-ci.org/garrison/UniqueVectors.jl)
[![Coverage Status](https://coveralls.io/repos/garrison/UniqueVectors.jl/badge.svg?branch=master)](https://coveralls.io/r/garrison/UniqueVectors.jl?branch=master)
[![UniqueVectors](http://pkg.julialang.org/badges/UniqueVectors_0.6.svg)](http://pkg.julialang.org/detail/UniqueVectors)
[![UniqueVectors](http://pkg.julialang.org/badges/UniqueVectors_0.7.svg)](http://pkg.julialang.org/detail/UniqueVectors)


    julia> Pkg.add("UniqueVectors")

`UniqueVector` is a data structure acts like a `Vector` of unique elements, but also maintains a dictionary that is updated in sync with the vector, which allows for quick lookup of the index of any element:

	julia> using UniqueVectors

	julia> ia = UniqueVector(["cat", "dog", "mouse"])
	3-element UniqueVectors.UniqueVector{String}:
	 "cat"
	 "dog"
	 "mouse"

	julia> ia[1]
	"cat"

	julia> findfirst(isequal("dog"), ia)         # executes quickly via a dictionary lookup, not sequential search
	2

As might be expected, `UniqueVector` supports many of the usual methods for `Vector`, but all operations enforce the condition that each element of the array must be unique.  The mutating methods `push!`, `pop!`, and `empty!` are implemented as well, as these operations keep constant the indices of existing elements in the array, allowing the dictionary to be updated efficiently.

In addition, `UniqueVector` implements a mutating `findfirst!` method, which returns the index of an element if it exists in the array, or otherwise appends the element and returns its new index:

    julia> findfirst!(isequal("cat"), ia)
    1

    julia> findfirst!(isequal("horse"), ia)
	4

	julia> ia
	4-element UniqueVectors.UniqueVector{String}:
	 "cat"
	 "dog"
	 "mouse"
	 "horse"

`UniqueVector` is derived from an abstract type known as `AbstractUniqueVector`.  This type is meant for anything that implements a fast bi-directional mapping between elements of a type `T` and integers from `1` to `N`.  For some applications, it will be possible to have alternative implementations of this interface--ones that resemble an `UniqueVector` but can be calculated quickly on the fly (and may not need to be fully stored in memory).  One notable example of this would be [Lin](http://www.phy.cuhk.edu.hk/hqlin/paper/018PRB42_6561.pdf) [Tables](http://www.phy.cuhk.edu.hk/hqlin/paper/033ComPhys7_400.pdf), which are often used in numerical exact diagonalization studies, and which are used to map each basis element of a quantum Hamiltonian to indices `1` through `N`.

(More generally, one might want an abstract type that represents any bidirectional mapping between two different sets (without one of them necessarily being contiguous integers from `1` to `N`).  In this case, using `findfirst` may not be the appropriate interface, and I'd welcome any comments on this.)

Note: This package was formerly known as `IndexedArrays` (see issue #4).
