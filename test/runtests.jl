using IndexedArrays
using Base.Test

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

empty!(ia)
@test isempty(ia)
@test_throws KeyError findfirst(ia, "cat")
@test findfirst!(ia, "horse") == 1

@test ia2[:] == ["cat", "dog", "mouse"]
@test findfirst(ia2, "cat") == 1

# push!, pop!

# setindex!, delete!

# FIXME: test trying to add something that already exists

# FIXME: test sending invalid stuff to the constructors

# indexin, findin

# findlast?, findnext, findprev
