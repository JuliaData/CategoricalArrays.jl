module TestLevels
    using Base.Test
    using CategoricalData

    for (P, V) in ((NominalPool, NominalValue), (OrdinalPool, OrdinalValue))
        pool = P([1, 2, 3])

        @test isa(levels(pool), Vector{Int})
        @test length(levels(pool)) === 3
        @test levels(pool) == pool.index == [1, 2, 3]
        @test pool.invindex == Dict(1=>1, 2=>2, 3=>3)
        @test pool.order == [1, 2, 3]
        @test pool.valindex == [V(i, pool) for i in 1:3]

        for rep in 1:3
            push!(pool, 4)

            @test isa(pool.index, Vector{Int})
            @test length(pool) === 4
            @test pool.index == [1, 2, 3, 4]
            @test pool.invindex == Dict(1=>1, 2=>2, 3=>3, 4=>4)
            @test pool.order == [1, 2, 3, 4]
            @test pool.invindex[4] === convert(CategoricalData.RefType, 4)
            @test pool.invindex[4] === get(pool, 4)
            @test pool[4] === V(4, pool)
            @test pool.valindex == [V(i, pool) for i in pool.index]
        end

        for rep in 1:3
            push!(pool, 0)

            @test isa(pool.index, Vector{Int})
            @test length(pool) === 5
            @test levels(pool) == pool.index == [1, 2, 3, 4, 0]
            @test pool.invindex == Dict(1=>1, 2=>2, 3=>3, 4=>4, 0=>5)
            @test pool.order == [1, 2, 3, 4, 5]
            @test pool.invindex[0] === convert(CategoricalData.RefType, 5)
            @test pool.invindex[0] === get(pool, 0)
            @test pool[5] === V(5, pool)
            @test pool.valindex == [V(i, pool) for i in 1:5]
        end

        for rep in 1:3
            push!(pool, 10, 11)

            @test isa(pool.index, Vector{Int})
            @test length(pool) === 7
            @test levels(pool) == pool.index == [1, 2, 3, 4, 0, 10, 11]
            @test pool.invindex == Dict(1=>1, 2=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7)
            @test pool.order == [1, 2, 3, 4, 5, 6, 7]
            @test pool.invindex[10] === convert(CategoricalData.RefType, 6)
            @test pool.invindex[10] === get(pool, 10)
            @test pool.invindex[11] === convert(CategoricalData.RefType, 7)
            @test pool.invindex[11] === get(pool, 11)
            @test pool[6] === V(6, pool)
            @test pool[7] === V(7, pool)
            @test pool.valindex == [V(i, pool) for i in 1:7]
        end

        for rep in 1:3
            push!(pool, 12, 13)

            @test isa(pool.index, Vector{Int})
            @test length(pool) === 9
            @test levels(pool) == pool.index == [1, 2, 3, 4, 0, 10, 11, 12, 13]
            @test pool.invindex == Dict(1=>1, 2=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8, 13=>9)
            @test pool.order == [1, 2, 3, 4, 5, 6, 7, 8, 9]
            @test pool.invindex[12] === convert(CategoricalData.RefType, 8)
            @test pool.invindex[12] === get(pool, 12)
            @test pool.invindex[13] === convert(CategoricalData.RefType, 9)
            @test pool.invindex[12] === get(pool, 12)
            @test pool[8] === V(8, pool)
            @test pool[9] === V(9, pool)
            @test pool.valindex == [V(i, pool) for i in 1:9]
        end

        for rep in 1:3
            delete!(pool, 13)

            @test isa(pool.index, Vector{Int})
            @test length(pool) == 8
            @test levels(pool) == pool.index == [1, 2, 3, 4, 0, 10, 11, 12]
            @test pool.invindex == Dict(1=>1, 2=>2, 3=>3, 4=>4, 0=>5, 10=>6, 11=>7, 12=>8)
            @test pool.order == [1, 2, 3, 4, 5, 6, 7, 8]
            @test pool.valindex == [V(i, pool) for i in 1:8]
        end

        for rep in 1:3
            delete!(pool, 12, 11)

            @test isa(pool.index, Vector{Int})
            @test length(pool) == 6
            @test levels(pool) == pool.index == [1, 2, 3, 4, 0, 10]
            @test pool.invindex == Dict(1=>1, 2=>2, 3=>3, 4=>4, 0=>5, 10=>6)
            @test pool.order == [1, 2, 3, 4, 5, 6]
            @test pool.valindex == [V(i, pool) for i in 1:6]
        end

        for rep in 1:3
            delete!(pool, 4)

            @test isa(pool.index, Vector{Int})
            @test length(pool) == 5
            @test levels(pool) == pool.index == [1, 2, 3, 0, 10]
            @test pool.invindex == Dict(1=>1, 2=>2, 3=>3, 0=>4, 10=>5)
            @test pool.order == [1, 2, 3, 4, 5]
            @test pool.valindex == [V(i, pool) for i in 1:5]
        end

        levels!(pool, [1, 2, 3])

        @test isa(pool.index, Vector{Int})
        @test length(pool) == 3
        @test length(pool.valindex) == 3
        @test levels(pool) == pool.index == [1, 2, 3]
        @test pool.invindex == Dict(1=>1, 2=>2, 3=>3)
        @test pool.order == [1, 2, 3]
        @test pool.valindex == [V(i, pool) for i in 1:3]

        levels!(pool, [1, 2, 4])

        @test isa(pool.index, Vector{Int})
        @test length(pool) == 3
        @test length(pool.valindex) == 3
        @test levels(pool) == pool.index == [1, 2, 4]
        @test pool.invindex == Dict(1=>1, 2=>2, 4=>3)
        @test pool.order == [1, 2, 3]
        @test pool.valindex == [V(i, pool) for i in 1:3]

        levels!(pool, [6, 5, 4])

        @test isa(pool.index, Vector{Int})
        @test length(pool) == 3
        @test length(pool.valindex) == 3
        @test levels(pool) == pool.index == [6, 5, 4]
        @test pool.invindex == Dict(6=>1, 5=>2, 4=>3)
        @test pool.order == [1, 2, 3]
        @test pool.valindex == [V(i, pool) for i in 1:3]
    end
end
