module TestLevels
    using Base.Test
    using CategoricalArrays
    using CategoricalArrays: DefaultRefType

    pool = CategoricalPool([2, 1, 3])

    @test isa(levels(pool), Vector{Int})
    @test length(levels(pool)) === 3
    @test levels(pool) == pool.index == [2, 1, 3]
    @test pool.invindex == Dict(1=>2, 2=>1, 3=>3)
    @test pool.order == [1, 2, 3]
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:3]

    for rep in 1:3
        push!(pool, 4)

        @test isa(pool.index, Vector{Int})
        @test length(pool) === 4
        @test pool.index == [2, 1, 3, 4]
        @test pool.invindex == Dict(1=>2, 2=>1, 3=>3, 4=>4)
        @test pool.order == [1, 2, 3, 4]
        @test pool.levels == [2, 1, 3, 4]
        @test get(pool, 4) === DefaultRefType(4)
        @test pool[4] === CategoricalValue(4, pool)
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:4]
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
        @test pool[5] === CategoricalValue(5, pool)
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:5]
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
        @test pool[6] === CategoricalValue(6, pool)
        @test pool[7] === CategoricalValue(7, pool)
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:7]
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
        @test pool[8] === CategoricalValue(8, pool)
        @test pool[9] === CategoricalValue(9, pool)
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:9]
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
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:8]
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
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:6]
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
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:5]
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
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:3]

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
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:3]

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
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:3]

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
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:3]

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
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:5]

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
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:4]
    end
end
