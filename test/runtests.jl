using UniqueVectors
using Test

@test length(UniqueVector([1,5,6,3])) == 4
@test_throws ArgumentError UniqueVector([1,3,5,6,3])

uv = UniqueVector{String}()

@test isempty(uv)
@test allunique(uv)
@test_throws ArgumentError pop!(uv)
@test findfirst(isequal("cat"), uv) == nothing
@test findfirst(isequal("cat"), uv) == nothing
@test findfirst!(isequal("cat"), uv) == 1
@test !isempty(uv)
@test "cat" in uv
@test "dog" ∉ uv
@test count(isequal("cat"), uv) == 1
@test count(isequal("dog"), uv) == 0
@test findall(isequal("cat"), uv) == [1]
@test findall(isequal("dog"), uv) == Int[]
@test findfirst!(isequal("dog"), uv) == 2
@test findfirst!(isequal("cat"), uv) == 1
@test findfirst!(isequal("mouse"), uv) == 3
@test findfirst!(isequal("dog"), uv) == 2
@test findfirst(isequal("cat"), uv) == 1
@test findlast(isequal("cat"), uv) == 1
@test findfirst(isequal("dog"), uv) == 2
@test findfirst(isequal("mouse"), uv) == 3
@test uv[1] == "cat"
@test uv[2] == "dog"
@test uv[3] == "mouse"
@test uv[:] == ["cat", "dog", "mouse"]
@test size(uv) == (3,)
@test length(uv) == 3
@test lastindex(uv) == 3
@test allunique(uv)
@test unique!(uv) === uv
@test unique(uv) == uv
@test unique(uv) == uv.items
@test unique(uv) !== uv.items
empty!(unique(uv))
@test length(uv.items) == 3

uv2 = UniqueVector([1, 2, 3])
@test eltype(uv2) == Int
@test findfirst(isequal(0x02), uv2) == 2
@test findfirst!(isequal(0x02), uv2) == 2
@test uv2 == UniqueVector(i for i in 1:3)
for elt in [3,2,1]
    @test pop!(uv2) == elt
end
@test isempty(uv2)

uv2 = copy(uv)
@test uv2 == uv

@test empty!(uv) === uv
@test isempty(uv)
@test findfirst(isequal("cat"), uv) == nothing
@test findfirst(isequal("cat"), uv) == nothing
@test findfirst!(isequal("horse"), uv) == 1
@test_throws ArgumentError push!(uv, "horse")
@test length(uv) == 1
@test push!(uv, "human") === uv
@test findfirst(isequal("human"), uv) == 2
@test pop!(uv) == "human"
@test length(uv) == 1
@test uv[:] == ["horse"]
@test findfirst(isequal("human"), uv) == nothing
@test findlast(isequal("human"), uv) == nothing

@test uv2[:] == ["cat", "dog", "mouse"]
@test findfirst(isequal("cat"), uv2) == 1

let uv = UniqueVector(["cat", "dog", "mouse", "human"]), original = copy(uv)

    uv = swap!(uv, 2, 2)

    @test uv == original
    @test_throws BoundsError swap!(uv, 5, 5)

    swap!(uv, 2, 3)

    @test findfirst(isequal("mouse"), uv) == 2
    @test findfirst(isequal("mouse"), original) == 3

    @test findfirst(isequal("dog"), uv) == 3
    @test findfirst(isequal("dog"), original) == 2
end

@test UniqueVector([1,2,3,4]) == UniqueVector(1:4)

# Test it works with `Any` datatype
let uv3 = UniqueVector([1,"cat",2,"dog"])
    @test eltype(uv3) == Any
    @test findfirst(isequal(1), uv3) == 1
    @test findlast(isequal(1), uv3) == 1
    @test findall(isequal(1), uv3) == [1]
    @test count(isequal(1), uv3) == 1
    @test findfirst!(isequal("dog"), uv3) == 4
    @test findfirst!(isequal("horse"), uv3) == 5
end

# Test setindex!
uv4 = UniqueVector(["cat", "dog", "mouse"])
@test_throws BoundsError uv4[4] = "horse"
uv4[2] = "horse"
uv4[3] = "dog"
@test uv4[:] == ["cat", "horse", "dog"]
uv4[1] = "cat"
@test_throws ArgumentError uv4[2] = "dog"
push!(uv4, "mouse")
@test uv4[:] == ["cat", "horse", "dog", "mouse"]
@test uv4[1:2] == ["cat", "horse"]

uv5 = UniqueVector{Float64}()
push!(uv5, 3)
@test uv5[:] == [3.0]
uv5[1] = 4
@test uv5[:] == [4.0]
@test 4 ∈ uv5
@test findfirst(isequal(4), uv5) == 1
@test findlast(isequal(4), uv5) == 1
@test findall(isequal(4), uv5) == [1]

# Test indexin and findall(in)
@test indexin([1,2,34,0,5,56], UniqueVector([34,56,35,1,5,0])) == [4,nothing,1,6,5,2]
@test indexin([1,2,34,0,5,56], UniqueVector([34,56,35,1,5,0])) == [4,nothing,1,6,5,2]
@test findall(in(UniqueVector([34,56,35,1,5,0])), [1,2,34,0,5,56]) == [1,3,4,5,6]
@test findall(in(UniqueVector([5,7,9])), [5 6; 7 8]) == findall(in([5,7,9]), [5 6; 7 8])

# Test findnext and findprev
@test findnext(isequal(7), UniqueVector([3,5,7,9]), 1) == 3
@test findnext(isequal(7), UniqueVector([3,5,7,9]), 2) == 3
@test findnext(isequal(7), UniqueVector([3,5,7,9]), 3) == 3
@test findnext(isequal(7), UniqueVector([3,5,7,9]), 4) == nothing
@test findnext(isequal(7), UniqueVector([3,5,7,9]), 4) == nothing
@test findprev(isequal(7), UniqueVector([3,5,7,9]), 1) == nothing
@test findprev(isequal(7), UniqueVector([3,5,7,9]), 1) == nothing
@test findprev(isequal(7), UniqueVector([3,5,7,9]), 2) == nothing
@test findprev(isequal(7), UniqueVector([3,5,7,9]), 2) == nothing
@test findprev(isequal(7), UniqueVector([3,5,7,9]), 3) == 3
@test findprev(isequal(7), UniqueVector([3,5,7,9]), 4) == 3
