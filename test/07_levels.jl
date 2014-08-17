module TestLevels
    using Base.Test
    using CategoricalData

    pool = CategoricalPool([1, 2, 3])

    @test isa(levels(pool), Vector)
    @test length(levels(pool)) === 3
    @test levels(pool) == [1, 2, 3]

    for rep in 1:3
        add!(pool, 4)

        @test isa(pool.index, Vector)
        @test length(pool) === 4
        @test pool.index == [1, 2, 3, 4]
        # TODO: Test invindex
        @test pool.invindex[4] === convert(CategoricalData.RefType, 4)
    end

    for rep in 1:3
        add!(pool, 0)

        @test isa(pool.index, Vector)
        @test length(pool) === 5
        @test pool.index == [1, 2, 3, 4, 0]
        # TODO: Test invindex
        @test pool.invindex[0] === convert(CategoricalData.RefType, 5)
    end

    for rep in 1:3
        add!(pool, 10, 11)

        @test isa(pool.index, Vector)
        @test length(pool) === 7
        @test pool.index == [1, 2, 3, 4, 0, 10, 11]
        # TODO: Test invindex
        @test pool.invindex[10] === convert(CategoricalData.RefType, 6)
        @test pool.invindex[11] === convert(CategoricalData.RefType, 7)
    end

    for rep in 1:3
        add!(pool, 12, 13)

        @test isa(pool.index, Vector)
        @test length(pool) === 9
        @test pool.index == [1, 2, 3, 4, 0, 10, 11, 12, 13]
        # TODO: Test invindex
        @test pool.invindex[12] === convert(CategoricalData.RefType, 8)
        @test pool.invindex[13] === convert(CategoricalData.RefType, 9)
    end

    for rep in 1:3
        delete!(pool, 13)

        @test isa(pool.index, Vector)
        @test length(pool) == 8
        @test pool.index == [1, 2, 3, 4, 0, 10, 11, 12]
        # TODO: Test invindex
    end

    for rep in 1:3
        delete!(pool, 12, 11)

        @test isa(pool.index, Vector)
        @test length(pool) == 6
        @test pool.index == [1, 2, 3, 4, 0, 10]
        # TODO: Test invindex
    end

    levels!(pool, [1, 2, 3])

    @test isa(pool.index, Vector)
    @test length(pool) == 3
    @test pool.index == [1, 2, 3]
    # TODO: Test invindex

    levels!(pool, [1, 2, 4])

    @test isa(pool.index, Vector)
    @test length(pool) == 3
    @test pool.index == [1, 2, 4]
    # TODO: Test invindex

    levels!(pool, [4, 5, 6])

    @test isa(pool.index, Vector)
    @test length(pool) == 3
    @test pool.index == [4, 5, 6]
    # TODO: Test invindex

###

    opool = OrdinalPool([1, 2, 3], [3, 2, 1])

    @test levels(opool) == [1, 2, 3]

    levels!(opool, [4, 5, 6])

    @test opool.pool.index == [4, 5, 6]
    # TODO: Test invindex
    @test opool.order == [
        convert(CategoricalData.RefType, 1),
        convert(CategoricalData.RefType, 2),
        convert(CategoricalData.RefType, 3),
    ]

    levels!(opool, [4, 5, 6], [6, 5, 4])

    @test opool.pool.index == [4, 5, 6]
    # TODO: Test invindex
    @test opool.order == [
        convert(CategoricalData.RefType, 3),
        convert(CategoricalData.RefType, 2),
        convert(CategoricalData.RefType, 1),
    ]
end
