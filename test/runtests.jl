using UniqueVectors
using Base.Test

@test length(UniqueVector([1,5,6,3])) == 4
@test_throws UniqueVectorError UniqueVector([1,3,5,6,3])

ia = UniqueVector{String}()

@test isempty(ia)
@test_throws ArgumentError pop!(ia)
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

ia2 = UniqueVector([1, 2, 3])
@test findfirst(ia2, 0x02) == 2
@test findfirst!(ia2, 0x02) == 2
@test ia2 == UniqueVector(i for i in 1:3)
for elt in [3,2,1]
    @test pop!(ia2) == elt
end
@test isempty(ia2)

ia2 = copy(ia)
@test ia2 == ia

@test empty!(ia) === ia
@test isempty(ia)
@test_throws KeyError findfirst(ia, "cat")
@test findfirst!(ia, "horse") == 1
@test_throws UniqueVectorError push!(ia, "horse")
@test length(ia) == 1
@test push!(ia, "human") === ia
@test findfirst(ia, "human") == 2
@test pop!(ia) == "human"
@test length(ia) == 1
@test ia[:] == ["horse"]
@test_throws KeyError findfirst(ia, "human")

@test ia2[:] == ["cat", "dog", "mouse"]
@test findfirst(ia2, "cat") == 1

let ia = UniqueVector(["cat", "dog", "mouse", "human"]), original = copy(ia)

    ia = swap!(ia, 2, 2)

    @test ia == original
    @test_throws BoundsError swap!(ia, 5, 5)

    swap!(ia, 2, 3)

    @test findfirst(ia, "mouse") == 2
    @test findfirst(original, "mouse") == 3

    @test findfirst(ia, "dog") == 3
    @test findfirst(original, "dog") == 2
end

@test UniqueVector([1,2,3,4]) == UniqueVector(1:4)

# Test it works with `Any` datatype
let ia3 = UniqueVector([1,"cat",2,"dog"])
    @test eltype(ia3) == Any
    @test findfirst(ia3, 1) == 1
    @test findfirst!(ia3, "dog") == 4
    @test findfirst!(ia3, "horse") == 5
end

# setindex!

# indexin, findin

# findlast?, findnext, findprev
