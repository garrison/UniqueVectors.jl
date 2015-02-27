# IndexedArrays

[![Build Status](https://travis-ci.org/garrison/IndexedArrays.jl.svg?branch=master)](https://travis-ci.org/garrison/IndexedArrays.jl)
[![Coverage Status](https://coveralls.io/repos/garrison/IndexedArrays.jl/badge.svg?branch=master)](https://coveralls.io/r/garrison/IndexedArrays.jl?branch=master)

`IndexedArray` is a data structure acts like a `Vector` of unique elements, but also maintains a dictionary that is updated in sync with the vector, which allows for quick lookup of the index of any element:

	julia> using IndexedArrays

	julia> ia = IndexedArray(["cat", "dog", "mouse"])
	3-element IndexedArray{ASCIIString}:
	 "cat"
	 "dog"
	 "mouse"

	julia> ia[1]
	"cat"

	julia> findfirst(ia, "dog")         # executes quickly via a dictionary lookup, not sequential search
	2

As might be expected, `IndexedArray` supports many of the usual methods for `Vector`, but all operations enforce the condition that each element of the array must be unique.

In addition, `IndexedArray` implements a mutating `findfirst!` method, which returns the index of an element if it exists in the array, or otherwise appends the element and returns its new index:

    julia> findfirst!(ia, "cat")
    1

    julia> findfirst!(ia, "horse")
	4

	julia> ia
	4-element IndexedArray{ASCIIString}:
	 "cat"
	 "dog"
	 "mouse"
	 "horse"

`IndexedArray` is derived from an abstract type known as `AbstractIndexedArray`.  This type is meant for anything that implements a fast bi-directional mapping between elements of a type `T` and integers from `1` to `N`.  For some applications, it will be possible to have alternative implementations of this interface--ones that resemble an `IndexedArray` but can be calculated quickly on the fly (and may not need to be fully stored in memory).  One notable example of this would be [Lin](http://www.phy.cuhk.edu.hk/hqlin/paper/018PRB42_6561.pdf) [Tables](http://www.phy.cuhk.edu.hk/hqlin/paper/033ComPhys7_400.pdf), which are often used in numerical exact diagonalization studies, and which are used to map each basis element of a quantum Hamiltonian to indices `1` through `N`.

(More generally, one might want an abstract type that represents any bidirectional mapping between two different sets (without one of them necessarily being contiguous integers from `1` to `N`).  In this cast, using `findfirst` may not be the appropriate interface, and I'd welcome any comments on this.)
