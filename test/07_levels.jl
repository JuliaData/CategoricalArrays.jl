module TestLevels
using Test
using CategoricalArrays
using CategoricalArrays: DefaultRefType, levels!, hashlevels

@testset "CategoricalPool{Int} updates levels and order correctly" begin
    pool = CategoricalPool([2, 1, 3])

    @test isa(levels(pool), Vector{Int})
    @test length(pool) === 3
    @test levels(pool) == [2, 1, 3]
    @test all([levels(CategoricalValue(pool, i)) for i in 1:3] .=== Ref(levels(pool)))
    @test pool.invindex == Dict(2=>1, 1=>2, 3=>3)
    @test pool.hash === nothing
    @test pool.equalto == C_NULL
    @test pool.subsetof == C_NULL

    for rep in 1:3
        push!(pool, 4)

        @test isa(pool.levels, Vector{Int})
        @test length(pool) === 4
        @test levels(pool) == [2, 1, 3, 4]
        @test pool.invindex == Dict(2=>1, 1=>2, 3=>3, 4=>4)
        @test pool.hash === nothing
        @test pool.equalto == C_NULL
        @test pool.subsetof == C_NULL
        @test get(pool, 4) === DefaultRefType(4)
        @test pool[4] === CategoricalValue(pool, 4)
    end

    for rep in 1:3
        push!(pool, 0)

        @test isa(pool.levels, Vector{Int})
        @test length(pool) === 5
        @test levels(pool) == [2, 1, 3, 4, 0]
        @test pool.invindex == Dict(2=>1, 1=>2, 3=>3, 4=>4, 0=>5)
        @test pool.hash === nothing
        @test pool.equalto == C_NULL
        @test pool.subsetof == C_NULL
        @test get(pool, 0) === DefaultRefType(5)
        @test pool[5] === CategoricalValue(pool, 5)
    end

    for rep in 1:3
        push!(pool, 10, 11)

        @test isa(pool.levels, Vector{Int})
        @test length(pool) === 7
        @test levels(pool) == [2, 1, 3, 4, 0, 10, 11]
        @test pool.invindex == Dict(2=>1, 1=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7)
        @test pool.hash === nothing
        @test pool.equalto == C_NULL
        @test pool.subsetof == C_NULL
        @test get(pool, 10) === DefaultRefType(6)
        @test get(pool, 11) === DefaultRefType(7)
        @test pool[6] === CategoricalValue(pool, 6)
        @test pool[7] === CategoricalValue(pool, 7)
    end

    for rep in 1:3
        push!(pool, 12, 13)

        @test isa(pool.levels, Vector{Int})
        @test length(pool) === 9
        @test levels(pool) == [2, 1, 3, 4, 0, 10, 11, 12, 13]
        @test pool.invindex == Dict(2=>1, 1=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8, 13=>9)
        @test pool.hash === nothing
        @test pool.equalto == C_NULL
        @test pool.subsetof == C_NULL
        @test get(pool, 12) === DefaultRefType(8)
        @test get(pool, 13) === DefaultRefType(9)
        @test pool[8] === CategoricalValue(pool, 8)
        @test pool[9] === CategoricalValue(pool, 9)
    end

    # Removing levels
    @test_throws ArgumentError levels!(pool, levels(pool)[2:end])

    # Changing order while preserving existing levels
    @test_throws ArgumentError levels!(pool, reverse(levels(pool)))

    # Adding levels while preserving existing ones
    levs = [2, 1, 3, 4, 0, 10, 11, 12, 13, 15, 14]
    @test levels!(pool, levs) === pool
    @test levels(pool) == levs
    @test levels(pool) !== levs
    @test pool.hash === nothing
    @test pool.equalto == C_NULL
    @test pool.subsetof == C_NULL

    @test isa(pool.levels, Vector{Int})
    @test length(pool) === 11
    @test levels(pool) == [2, 1, 3, 4, 0, 10, 11, 12, 13, 15, 14]
    @test pool.invindex == Dict(2=>1, 1=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8, 13=>9,
                                15=>10, 14=>11)
    @test pool.hash === nothing
    @test pool.equalto == C_NULL
    @test pool.subsetof == C_NULL
    @test get(pool, 15) === DefaultRefType(10)
    @test get(pool, 14) === DefaultRefType(11)
    @test pool[10] === CategoricalValue(pool, 10)
    @test pool[11] === CategoricalValue(pool, 11)

    # get! adding new level works even for ordered pool
    ordered!(pool, true)
    @test get!(pool, 20) === DefaultRefType(12)

    @test isa(pool.levels, Vector{Int})
    @test length(pool) == 12
    @test levels(pool) == [2, 1, 3, 4, 0, 10, 11, 12, 13, 15, 14, 20]
    @test pool.invindex == Dict(2=>1, 1=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8, 13=>9,
                                15=>10, 14=>11, 20=>12)
    @test pool.hash === nothing
    @test pool.equalto == C_NULL
    @test pool.subsetof == C_NULL
    @test get(pool, 20) === DefaultRefType(12)

    # get! with CategoricalValue adding new levels in conflicting order
    v = CategoricalValue(CategoricalPool([100, 99, 4, 2]), 2)
    @test_throws ArgumentError get!(pool, v)

    # get! with CategoricalValue adding new levels in compatible order
    v = CategoricalValue(CategoricalPool([2, 4, 100, 99]), 4)

    @test get!(pool, v) === DefaultRefType(14)

    @test isa(pool.levels, Vector{Int})
    @test length(pool) == 14
    @test levels(pool) == [2, 1, 3, 4, 0, 10, 11, 12, 13, 15, 14, 20, 100, 99]
    @test pool.invindex == Dict(2=>1, 1=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8, 13=>9,
                                15=>10, 14=>11, 20=>12, 100=>13, 99=>14)
    @test pool.hash === nothing
    @test pool.equalto == C_NULL
    @test pool.subsetof == C_NULL
    @test get(pool, 100) === DefaultRefType(13)
    @test get(pool, 99) === DefaultRefType(14)

    # get! with CategoricalValue not adding new levels
    v = CategoricalValue(CategoricalPool([100, 2]), 1)
    @test get!(pool, v) === DefaultRefType(13)

    @test isa(pool.levels, Vector{Int})
    @test length(pool) == 14
    @test levels(pool) == [2, 1, 3, 4, 0, 10, 11, 12, 13, 15, 14, 20, 100, 99]
    @test pool.invindex == Dict(2=>1, 1=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8, 13=>9,
                                15=>10, 14=>11, 20=>12, 100=>13, 99=>14)
    @test pool.hash === CategoricalArrays.hashlevels(levels(pool))
    @test pool.equalto == C_NULL
    @test pool.subsetof == C_NULL

    # get! with CategoricalValue from same pool
    @test get!(pool, pool[1]) === DefaultRefType(1)

    @test isa(pool.levels, Vector{Int})
    @test length(pool) == 14
    @test levels(pool) == [2, 1, 3, 4, 0, 10, 11, 12, 13, 15, 14, 20, 100, 99]
    @test pool.invindex == Dict(2=>1, 1=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8, 13=>9,
                                15=>10, 14=>11, 20=>12, 100=>13, 99=>14)
    @test pool.hash === CategoricalArrays.hashlevels(levels(pool))
    @test pool.equalto == C_NULL
    @test pool.subsetof == C_NULL

    # get! with CategoricalValue conversion error
    v = CategoricalValue(CategoricalPool(["a", "b"]), 1)
    @test_throws MethodError get!(pool, v)

    # get! with ordered CategoricalValue marks unordered empty pool as ordered
    p1 = CategoricalPool(['b', 'c', 'a'])
    ordered!(p1, true)
    p2 = CategoricalPool(Char[])
    @test get!(p2, p1[1]) === UInt32(1)
    @test isordered(p2)
    # But push! does not
    p2 = CategoricalPool(Char[])
    @test push!(p2, p1[1]) === p2
    @test !isordered(p2)
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
    res = @test_throws LevelsException{String, UInt8} levels!(pool, vcat(levels(pool), "az", "bz", "cz"))
    @test res.value.levels == ["bz", "cz"]
    @test sprint(showerror, res.value) == "cannot store level(s) \"bz\" and \"cz\" since reference type UInt8 can only hold 255 levels. Use the decompress function to make room for more levels."
    lev = copy(levels(pool))
    levels!(pool, vcat(lev, "az"))
    @test levels(pool) == vcat(lev, "az")
end

@testset "issubset" begin
    pool1 = CategoricalPool(["a", "b", "c"])
    pool1b = CategoricalPool(["a", "b", "c"])
    pool2 = CategoricalPool(["c", "a", "b"])
    pool3 = CategoricalPool(["a", "b", "c", "d"])
    pool4 = CategoricalPool(["a", "b"])
    pool5 = CategoricalPool(["a", "b", "e"])
    pool6 = CategoricalPool(String[])

    @test issubset(pool1, pool1)
    @test pool1.equalto == C_NULL
    @test pool1.subsetof == C_NULL

    @test issubset(pool2, pool1)
    @test pool1.equalto == pool2.equalto == C_NULL
    @test pool1.subsetof == C_NULL
    @test pool2.subsetof == pointer_from_objref(pool1)

    @test issubset(pool1b, pool1)
    @test pool1.equalto == pointer_from_objref(pool1b)
    @test pool1b.equalto == pointer_from_objref(pool1)
    @test pool1.subsetof == C_NULL
    @test pool2.subsetof == pointer_from_objref(pool1)

    @test !issubset(pool3, pool1)
    @test pool1.equalto == pointer_from_objref(pool1b)
    @test pool3.equalto == C_NULL
    @test pool1.subsetof == pool3.subsetof == C_NULL

    @test issubset(pool1, pool3)
    @test pool1.equalto == pointer_from_objref(pool1b)
    @test pool3.equalto == C_NULL
    @test pool1.subsetof == pointer_from_objref(pool3)
    @test pool3.subsetof == C_NULL

    @test issubset(pool4, pool1)
    @test pool1.equalto == pointer_from_objref(pool1b)
    @test pool4.equalto == C_NULL
    @test pool1.subsetof == pointer_from_objref(pool3)
    @test pool4.subsetof == pointer_from_objref(pool1)

    @test !issubset(pool5, pool1)
    @test pool1.equalto == pointer_from_objref(pool1b)
    @test pool5.equalto == C_NULL
    @test pool1.subsetof == pointer_from_objref(pool3)
    @test pool5.subsetof == C_NULL

    @test issubset(pool6, pool1)
    @test pool1.equalto == pointer_from_objref(pool1b)
    @test pool6.equalto == C_NULL
    @test pool1.subsetof == pointer_from_objref(pool3)
    @test pool6.subsetof == pointer_from_objref(pool1)
end

end
