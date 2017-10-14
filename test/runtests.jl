using UniqueVectors
using Base.Test

using Compat

@test length(UniqueVector([1,5,6,3])) == 4
@test_throws ArgumentError UniqueVector([1,3,5,6,3])

ia = UniqueVector{String}()

@test isempty(ia)
@test_throws ArgumentError pop!(ia)
@test findfirst(equalto("cat"), ia) == 0
@test findfirst!(equalto("cat"), ia) == 1
@test !isempty(ia)
@test "cat" in ia
@test "dog" ∉ ia
@test findfirst!(equalto("dog"), ia) == 2
@test findfirst!(equalto("cat"), ia) == 1
@test findfirst!(equalto("mouse"), ia) == 3
@test findfirst!(equalto("dog"), ia) == 2
@test findfirst(equalto("cat"), ia) == 1
@test findlast(equalto("cat"), ia) == 1
@test findfirst(equalto("dog"), ia) == 2
@test findfirst(equalto("mouse"), ia) == 3
@test ia[1] == "cat"
@test ia[2] == "dog"
@test ia[3] == "mouse"
@test ia[:] == ["cat", "dog", "mouse"]
@test size(ia) == (3,)
@test length(ia) == 3
@test endof(ia) == 3

ia2 = UniqueVector([1, 2, 3])
@test findfirst(equalto(0x02), ia2) == 2
@test findfirst!(equalto(0x02), ia2) == 2
@test ia2 == UniqueVector(i for i in 1:3)
for elt in [3,2,1]
    @test pop!(ia2) == elt
end
@test isempty(ia2)

ia2 = copy(ia)
@test ia2 == ia

@test empty!(ia) === ia
@test isempty(ia)
@test findfirst(equalto("cat"), ia) == 0
@test findfirst!(equalto("horse"), ia) == 1
@test_throws ArgumentError push!(ia, "horse")
@test length(ia) == 1
@test push!(ia, "human") === ia
@test findfirst(equalto("human"), ia) == 2
@test pop!(ia) == "human"
@test length(ia) == 1
@test ia[:] == ["horse"]
@test findfirst(equalto("human"), ia) == 0

@test ia2[:] == ["cat", "dog", "mouse"]
@test findfirst(equalto("cat"), ia2) == 1

let ia = UniqueVector(["cat", "dog", "mouse", "human"]), original = copy(ia)

    ia = swap!(ia, 2, 2)

    @test ia == original
    @test_throws BoundsError swap!(ia, 5, 5)

    swap!(ia, 2, 3)

    @test findfirst(equalto("mouse"), ia) == 2
    @test findfirst(equalto("mouse"), original) == 3

    @test findfirst(equalto("dog"), ia) == 3
    @test findfirst(equalto("dog"), original) == 2
end

@test UniqueVector([1,2,3,4]) == UniqueVector(1:4)

# Test it works with `Any` datatype
let ia3 = UniqueVector([1,"cat",2,"dog"])
    @test eltype(ia3) == Any
    @test findfirst(equalto(1), ia3) == 1
    @test findfirst!(equalto("dog"), ia3) == 4
    @test findfirst!(equalto("horse"), ia3) == 5
end

# Test setindex!
ia4 = UniqueVector(["cat", "dog", "mouse"])
@test_throws BoundsError ia4[4] = "horse"
ia4[2] = "horse"
ia4[3] = "dog"
@test ia4[:] == ["cat", "horse", "dog"]
ia4[1] = "cat"
@test_throws ArgumentError ia4[2] = "dog"
push!(ia4, "mouse")
@test ia4[:] == ["cat", "horse", "dog", "mouse"]
@test ia4[1:2] == ["cat", "horse"]

ia5 = UniqueVector{Float64}()
push!(ia5, 3)
@test ia5[:] == [3.0]
ia5[1] = 4
@test ia5[:] == [4.0]
@test 4 ∈ ia5
@test findfirst(equalto(4), ia5) == 1
@test findlast(equalto(4), ia5) == 1

# Test indexin and findin
@test indexin([1,2,34,0,5,56], UniqueVector([34,56,35,1,5,0])) == [4,0,1,6,5,2]
@test findin([1,2,34,0,5,56], UniqueVector([34,56,35,1,5,0])) == [1,3,4,5,6]

# Test findnext and findprev
@test findnext(equalto(7), UniqueVector([3,5,7,9]), 1) == 3
@test findnext(equalto(7), UniqueVector([3,5,7,9]), 2) == 3
@test findnext(equalto(7), UniqueVector([3,5,7,9]), 3) == 3
@test findnext(equalto(7), UniqueVector([3,5,7,9]), 4) == 0
@test findprev(equalto(7), UniqueVector([3,5,7,9]), 1) == 0
@test findprev(equalto(7), UniqueVector([3,5,7,9]), 2) == 0
@test findprev(equalto(7), UniqueVector([3,5,7,9]), 3) == 3
@test findprev(equalto(7), UniqueVector([3,5,7,9]), 4) == 3
