module TestLevels
using Compat
using Compat.Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType, levels!

@testset "CategoricalPool{Int} updates levels/index/order correctly" begin
    pool = CategoricalPool([2, 1, 3])

    @test isa(levels(pool), Vector{Int})
    @test length(levels(pool)) === 3
    @test levels(pool) == pool.index == [2, 1, 3]
    @test pool.invindex == Dict(1=>2, 2=>1, 3=>3)
    @test pool.order == [1, 2, 3]
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:3]

    for rep in 1:3
        push!(pool, 4)

        @test isa(pool.index, Vector{Int})
        @test length(pool) === 4
        @test pool.index == [2, 1, 3, 4]
        @test pool.invindex == Dict(1=>2, 2=>1, 3=>3, 4=>4)
        @test pool.order == [1, 2, 3, 4]
        @test pool.levels == [2, 1, 3, 4]
        @test get(pool, 4) === DefaultRefType(4)
        @test pool[4] === CategoricalArrays.catvalue(4, pool)
        @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:4]
    end

    for rep in 1:3
        push!(pool, 0)

        @test isa(pool.index, Vector{Int})
        @test length(pool) === 5
        @test levels(pool) == pool.index == [2, 1, 3, 4, 0]
        @test pool.invindex == Dict(1=>2, 2=>1, 3=>3, 4=>4, 0=>5)
        @test pool.order == [1, 2, 3, 4, 5]
        @test pool.levels == [2, 1, 3, 4, 0]
        @test get(pool, 0) === DefaultRefType(5)
        @test pool[5] === CategoricalArrays.catvalue(5, pool)
        @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:5]
    end

    for rep in 1:3
        push!(pool, 10, 11)

        @test isa(pool.index, Vector{Int})
        @test length(pool) === 7
        @test levels(pool) == pool.index == [2, 1, 3, 4, 0, 10, 11]
        @test pool.invindex == Dict(1=>2, 2=>1, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7)
        @test pool.order == [1, 2, 3, 4, 5, 6, 7]
        @test pool.levels == [2, 1, 3, 4, 0, 10, 11]
        @test get(pool, 10) === DefaultRefType(6)
        @test get(pool, 11) === DefaultRefType(7)
        @test pool[6] === CategoricalArrays.catvalue(6, pool)
        @test pool[7] === CategoricalArrays.catvalue(7, pool)
        @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:7]
    end

    for rep in 1:3
        push!(pool, 12, 13)

        @test isa(pool.index, Vector{Int})
        @test length(pool) === 9
        @test levels(pool) == pool.index == [2, 1, 3, 4, 0, 10, 11, 12, 13]
        @test pool.invindex == Dict(1=>2, 2=>1, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8, 13=>9)
        @test pool.order == [1, 2, 3, 4, 5, 6, 7, 8, 9]
        @test pool.levels == [2, 1, 3, 4, 0, 10, 11, 12, 13]
        @test get(pool, 12) === DefaultRefType(8)
        @test get(pool, 13) === DefaultRefType(9)
        @test pool[8] === CategoricalArrays.catvalue(8, pool)
        @test pool[9] === CategoricalArrays.catvalue(9, pool)
        @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:9]
    end

    for rep in 1:3
        delete!(pool, 13)

        @test isa(pool.index, Vector{Int})
        @test length(pool) == 8
        @test levels(pool) == pool.index == [2, 1, 3, 4, 0, 10, 11, 12]
        @test pool.invindex == Dict(1=>2, 2=>1, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8)
        @test pool.order == [1, 2, 3, 4, 5, 6, 7, 8]
        @test pool.levels == [2, 1, 3, 4, 0, 10, 11, 12]
        @test_throws KeyError get(pool, 13)
        @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:8]
    end

    for rep in 1:3
        delete!(pool, 12, 11)

        @test isa(pool.index, Vector{Int})
        @test length(pool) == 6
        @test levels(pool) == pool.index == [2, 1, 3, 4, 0, 10]
        @test pool.invindex == Dict(1=>2, 2=>1, 3=>3, 4=>4, 0=>5, 10=>6)
        @test pool.order == [1, 2, 3, 4, 5, 6]
        @test pool.levels == [2, 1, 3, 4, 0, 10]
        @test_throws KeyError get(pool, 11)
        @test_throws KeyError get(pool, 12)
        @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:6]
    end

    for rep in 1:3
        delete!(pool, 4)

        @test isa(pool.index, Vector{Int})
        @test length(pool) == 5
        @test levels(pool) == pool.index == [2, 1, 3, 0, 10]
        @test pool.invindex == Dict(1=>2, 2=>1, 3=>3, 0=>4, 10=>5)
        @test pool.order == [1, 2, 3, 4, 5]
        @test pool.levels == [2, 1, 3, 0, 10]
        @test_throws KeyError get(pool, 4)
        @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:5]
    end

    @test levels!(pool, [1, 2, 3]) === pool
    @test levels(pool) == [1, 2, 3]

    @test isa(pool.index, Vector{Int})
    @test length(pool) == 3
    @test length(pool.valindex) == 3
    @test levels(pool) == pool.index == [1, 2, 3]
    @test pool.invindex == Dict(1=>1, 2=>2, 3=>3)
    @test pool.order == [1, 2, 3]
    @test pool.levels == [1, 2, 3]
    @test get(pool, 1) === DefaultRefType(1)
    @test_throws KeyError get(pool, 0)
    @test_throws KeyError get(pool, 10)
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:3]

    @test levels!(pool, [1, 2, 4]) === pool
    @test levels(pool) == [1, 2, 4]

    @test isa(pool.index, Vector{Int})
    @test length(pool) == 3
    @test length(pool.valindex) == 3
    @test levels(pool) == pool.index == [1, 2, 4]
    @test pool.invindex == Dict(1=>1, 2=>2, 4=>3)
    @test pool.order == [1, 2, 3]
    @test pool.levels == [1, 2, 4]
    @test get(pool, 1) === DefaultRefType(1)
    @test_throws KeyError get(pool, 3)
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:3]

    @test levels!(pool, [6, 5, 4]) === pool
    @test levels(pool) == [6, 5, 4]

    @test isa(pool.index, Vector{Int})
    @test length(pool) == 3
    @test length(pool.valindex) == 3
    @test levels(pool) == pool.index == [6, 5, 4]
    @test pool.invindex == Dict(6=>1, 5=>2, 4=>3)
    @test pool.order == [1, 2, 3]
    @test pool.levels == [6, 5, 4]
    @test get(pool, 5) === DefaultRefType(2)
    @test_throws KeyError get(pool, 3)
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:3]

    # Changing order while preserving existing levels
    @test levels!(pool, [5, 6, 4]) === pool
    @test levels(pool) == [5, 6, 4]

    @test isa(pool.index, Vector{Int})
    @test length(pool) == 3
    @test length(pool.valindex) == 3
    @test levels(pool) == [5, 6, 4]
    @test pool.index == [6, 5, 4]
    @test pool.invindex == Dict(6=>1, 5=>2, 4=>3)
    @test pool.order == [2, 1, 3]
    @test pool.levels == [5, 6, 4]
    @test get(pool, 5) === DefaultRefType(2)
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:3]

    # Adding levels while preserving existing ones
    @test levels!(pool, [5, 2, 3, 6, 4]) === pool
    @test levels(pool) == [5, 2, 3, 6, 4]

    @test isa(pool.index, Vector{Int})
    @test length(pool) == 5
    @test length(pool.valindex) == 5
    @test levels(pool) == [5, 2, 3, 6, 4]
    @test pool.index == [6, 5, 4, 2, 3]
    @test pool.invindex == Dict(6=>1, 5=>2, 4=>3, 2=>4, 3=>5)
    @test pool.order == [4, 1, 5, 2, 3]
    @test pool.levels == [5, 2, 3, 6, 4]
    @test get(pool, 2) === DefaultRefType(4)
    @test get(pool, 3) === DefaultRefType(5)
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:5]

    for rep in 1:3
        delete!(pool, 6)

        @test isa(pool.index, Vector{Int})
        @test length(pool) == 4
        @test length(pool.valindex) == 4
        @test levels(pool) == [5, 2, 3, 4]
        @test pool.index == [5, 4, 2, 3]
        @test pool.invindex == Dict(5=>1, 4=>2, 2=>3, 3=>4)
        @test pool.order == [1, 4, 2, 3]
        @test pool.levels == [5, 2, 3, 4]
        @test get(pool, 4) === DefaultRefType(2)
        @test_throws KeyError get(pool, 6)
        @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:4]
    end

    # get!
    ordered!(pool, true)
    @test_throws OrderedLevelsException get!(pool, 10)
    ordered!(pool, false)

    @test get!(pool, 10) === DefaultRefType(5)

    @test isa(pool.index, Vector{Int})
    @test length(pool) == 5
    @test length(pool.valindex) == 5
    @test levels(pool) == [5, 2, 3, 4, 10]
    @test pool.index == [5, 4, 2, 3, 10]
    @test pool.invindex == Dict(5=>1, 4=>2, 2=>3, 3=>4, 10=>5)
    @test pool.order == [1, 4, 2, 3, 5]
    @test pool.levels == [5, 2, 3, 4, 10]
    @test get(pool, 10) === DefaultRefType(5)
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:5]

    # get! with CategoricalValue adding new levels
    v = CategoricalArrays.catvalue(2, CategoricalPool([100, 99, 5, 2]))

    ordered!(pool, true)
    @test_throws OrderedLevelsException get!(pool, v)
    ordered!(pool, false)

    @test get!(pool, v) === DefaultRefType(7)

    @test isa(pool.index, Vector{Int})
    @test length(pool) == 7
    @test length(pool.valindex) == 7
    @test levels(pool) == [100, 99, 5, 2, 3, 4, 10]
    @test pool.index == [5, 4, 2, 3, 10, 100, 99]
    @test pool.invindex == Dict(5=>1, 4=>2, 2=>3, 3=>4, 10=>5, 100=>6, 99=>7)
    @test pool.order == [3, 6, 4, 5, 7, 1, 2]
    @test pool.levels == [100, 99, 5, 2, 3, 4, 10]
    @test get(pool, 99) === DefaultRefType(7)
    @test get(pool, 100) === DefaultRefType(6)
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:7]

    # get! with CategoricalValue not adding new levels
    v = CategoricalArrays.catvalue(1, CategoricalPool([100, 2]))
    @test get!(pool, v) === DefaultRefType(6)

    @test isa(pool.index, Vector{Int})
    @test length(pool) == 7
    @test length(pool.valindex) == 7
    @test levels(pool) == [100, 99, 5, 2, 3, 4, 10]
    @test pool.index == [5, 4, 2, 3, 10, 100, 99]
    @test pool.invindex == Dict(5=>1, 4=>2, 2=>3, 3=>4, 10=>5, 100=>6, 99=>7)
    @test pool.order == [3, 6, 4, 5, 7, 1, 2]
    @test pool.levels == [100, 99, 5, 2, 3, 4, 10]
    @test get(pool, 99) === DefaultRefType(7)
    @test get(pool, 100) === DefaultRefType(6)
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:7]

    # get! with CategoricalValue from same pool
    @test get!(pool, pool[1]) === DefaultRefType(1)

    @test isa(pool.index, Vector{Int})
    @test length(pool) == 7
    @test length(pool.valindex) == 7
    @test levels(pool) == [100, 99, 5, 2, 3, 4, 10]
    @test pool.index == [5, 4, 2, 3, 10, 100, 99]
    @test pool.invindex == Dict(5=>1, 4=>2, 2=>3, 3=>4, 10=>5, 100=>6, 99=>7)
    @test pool.order == [3, 6, 4, 5, 7, 1, 2]
    @test pool.levels == [100, 99, 5, 2, 3, 4, 10]
    @test get(pool, 99) === DefaultRefType(7)
    @test get(pool, 100) === DefaultRefType(6)
    @test pool.valindex == [CategoricalArrays.catvalue(i, pool) for i in 1:7]

    # get! with CategoricalValue not adding new levels
    v = CategoricalArrays.catvalue(1, CategoricalPool(["a", "b"]))
    @test_throws MethodError get!(pool, v)

    # get! with CategoricalValue{Any} (#220)
    p1 = CategoricalPool(Any['a', 'b', 'c'])
    p2 = CategoricalPool(Any['a', 'b', 'x'])
    @test get!(p1, p2[1]) === UInt32(1)
    @test get!(p1, p2[3]) === UInt32(4)
end

@testset "overflow of reftype is detected and doesn't corrupt levels" begin
    res = @test_throws LevelsException{Int, UInt8} CategoricalPool{Int, UInt8}(collect(256:-1:1))
    @test res.value.levels == [1]
    @test sprint(showerror, res.value) == "cannot store level(s) 1 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."

    pool = CategoricalPool(collect(30:288))
    res = @test_throws LevelsException{Int, UInt8} convert(CategoricalPool{Int, UInt8}, pool)
    @test res.value.levels == collect(285:288)
    @test sprint(showerror, res.value) == "cannot store level(s) 285, 286, 287 and 288 since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."

    pool = CategoricalPool{String, UInt8}(string.(318:-1:65))
    res = @test_throws LevelsException{String, UInt8} levels!(pool, vcat("az", levels(pool), "bz", "cz"))
    @test res.value.levels == ["bz", "cz"]
    @test sprint(showerror, res.value) == "cannot store level(s) \"bz\" and \"cz\" since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."
    lev = copy(levels(pool))
    levels!(pool, vcat(lev, "az"))
    @test levels(pool) == vcat(lev, "az")
end

end
