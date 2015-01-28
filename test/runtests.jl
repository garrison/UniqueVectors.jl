using IndexedArrays
using Base.Test

@test length(IndexedArray([1,5,6,3])) == 4
@test_throws IndexedArrayError IndexedArray([1,3,5,6,3])

ia = IndexedArray{ASCIIString}()

@test isempty(ia)
@test_throws KeyError findfirst(ia, "cat")
@test findfirst!(ia, "cat") == 1
@test !isempty(ia)
@test "cat" in ia
@test "dog" ∉ ia
@test findfirst!(ia, "dog") == 2
@test findfirst!(ia, "cat") == 1
@test findfirst!(ia, "mouse") == 3
@test findfirst!(ia, "dog") == 2
@test findfirst(ia, "cat") == 1
@test findfirst(ia, "dog") == 2
@test findfirst(ia, "mouse") == 3
@test ia[1] == "cat"
@test ia[2] == "dog"
@test ia[3] == "mouse"
@test ia[:] == ["cat", "dog", "mouse"]
@test size(ia) == (3,)
@test length(ia) == 3
@test endof(ia) == 3

elts = Set(["cat", "dog", "mouse"])
for elt in ia
    pop!(elts, elt)
end
@test isempty(elts)

ia2 = copy(ia)
@test ia2 == ia

@test is(empty!(ia), ia)
@test isempty(ia)
@test_throws KeyError findfirst(ia, "cat")
@test findfirst!(ia, "horse") == 1
@test_throws IndexedArrayError push!(ia, "horse")
@test length(ia) == 1
@test is(push!(ia, "human"), ia)
@test findfirst(ia, "human") == 2
@test is(pop!(ia), ia)
@test length(ia) == 1
@test ia[:] == ["horse"]
@test_throws KeyError findfirst(ia, "human")

@test ia2[:] == ["cat", "dog", "mouse"]
@test findfirst(ia2, "cat") == 1

# setindex!

# indexin, findin

# findlast?, findnext, findprev
