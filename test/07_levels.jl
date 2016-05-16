module TestLevels
    using Base.Test
    using CategoricalData

    pool = CategoricalPool([1, 2, 3])

    @test isa(levels(pool), Vector)
    @test length(levels(pool)) === 3
    @test levels(pool) == [1, 2, 3]
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:3]

    for rep in 1:3
        push!(pool, 4)

        @test isa(pool.index, Vector)
        @test length(pool) === 4
        @test pool.index == [1, 2, 3, 4]
        # TODO: Test invindex
        @test pool.invindex[4] === convert(CategoricalData.RefType, 4)
        @test pool.invindex[4] === get(pool, 4)
        @test pool[4] === CategoricalValue(4, pool)
        @test pool.valindex == [CategoricalValue(i, pool) for i in pool.index]
    end

    for rep in 1:3
        push!(pool, 0)

        @test isa(pool.index, Vector)
        @test length(pool) === 5
        @test pool.index == [1, 2, 3, 4, 0]
        # TODO: Test invindex
        @test pool.invindex[0] === convert(CategoricalData.RefType, 5)
        @test pool.invindex[0] === get(pool, 0)
        @test pool[5] === CategoricalValue(5, pool)
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:5]
    end

    for rep in 1:3
        push!(pool, 10, 11)

        @test isa(pool.index, Vector)
        @test length(pool) === 7
        @test pool.index == [1, 2, 3, 4, 0, 10, 11]
        # TODO: Test invindex
        @test pool.invindex[10] === convert(CategoricalData.RefType, 6)
        @test pool.invindex[10] === get(pool, 10)
        @test pool.invindex[11] === convert(CategoricalData.RefType, 7)
        @test pool.invindex[11] === get(pool, 11)
        @test pool[6] === CategoricalValue(6, pool)
        @test pool[7] === CategoricalValue(7, pool)
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:7]
    end

    for rep in 1:3
        push!(pool, 12, 13)

        @test isa(pool.index, Vector)
        @test length(pool) === 9
        @test pool.index == [1, 2, 3, 4, 0, 10, 11, 12, 13]
        # TODO: Test invindex
        @test pool.invindex[12] === convert(CategoricalData.RefType, 8)
        @test pool.invindex[12] === get(pool, 12)
        @test pool.invindex[13] === convert(CategoricalData.RefType, 9)
        @test pool.invindex[12] === get(pool, 12)
        @test pool[8] === CategoricalValue(8, pool)
        @test pool[9] === CategoricalValue(9, pool)
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:9]
    end

    for rep in 1:3
        delete!(pool, 13)

        @test isa(pool.index, Vector)
        @test length(pool) == 8
        @test pool.index == [1, 2, 3, 4, 0, 10, 11, 12]
        # TODO: Test invindex
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:8]
    end

    for rep in 1:3
        delete!(pool, 12, 11)

        @test isa(pool.index, Vector)
        @test length(pool) == 6
        @test pool.index == [1, 2, 3, 4, 0, 10]
        # TODO: Test invindex
        @test pool.valindex == [CategoricalValue(i, pool) for i in 1:6]
    end

    levels!(pool, [1, 2, 3])

    @test isa(pool.index, Vector)
    @test length(pool) == 3
    @test length(pool.valindex) == 3
    @test pool.index == [1, 2, 3]
    # TODO: Test invindex
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:3]

    levels!(pool, [1, 2, 4])

    @test isa(pool.index, Vector)
    @test length(pool) == 3
    @test length(pool.valindex) == 3
    @test pool.index == [1, 2, 4]
    # TODO: Test invindex
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:3]

    levels!(pool, [4, 5, 6])

    @test isa(pool.index, Vector)
    @test length(pool) == 3
    @test length(pool.valindex) == 3
    @test pool.index == [4, 5, 6]
    # TODO: Test invindex
    @test pool.valindex == [CategoricalValue(i, pool) for i in 1:3]

###

    opool = OrdinalPool([1, 2, 3], [3, 2, 1])

    @test levels(opool) == [1, 2, 3]
    # TODO: Test invindex
    @test opool.valindex == [OrdinalValue(i, opool) for i in 1:3]

    levels!(opool, [4, 5, 6])

    @test opool.pool.index == [4, 5, 6]
    # TODO: Test invindex
    @test opool.valindex == [OrdinalValue(i, opool) for i in 1:3]
    @test opool.order == [
        convert(CategoricalData.RefType, 1),
        convert(CategoricalData.RefType, 2),
        convert(CategoricalData.RefType, 3),
    ]

    levels!(opool, [4, 5, 6], [6, 5, 4])

    @test opool.pool.index == [4, 5, 6]
    # TODO: Test invindex
    @test opool.valindex == [OrdinalValue(i, opool) for i in 1:3]
    @test opool.order == [
        convert(CategoricalData.RefType, 3),
        convert(CategoricalData.RefType, 2),
        convert(CategoricalData.RefType, 1),
    ]
end
