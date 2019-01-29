using Test

@testset "Barnes-Hut algorithm" begin
    include("../src/barnes_hut.jl")

    @testset "space fitting" begin
        quad = Quad(-2, -2, 2, 2)
        @test fit(quad, [1, 1]) == :ne
        @test fit(quad, [-1, 1]) == :nw
        @test fit(quad, [1, -1]) == :se
        @test fit(quad, [-1, -1]) == :sw

        @test fit(quad, [0, 0]) == :ne
        @test fit(quad, [1, 0]) == :ne
        @test fit(quad, [0, 1]) == :ne
        @test_throws DomainError fit(quad, [3, 3])

        @test quadrant_from_symbol(quad, :ne) == Quad(0,0,2,2)
        @test quadrant_from_symbol(quad, :nw) == Quad(-2,0,0,2)
        @test quadrant_from_symbol(quad, :se) == Quad(0,-2,2,0)
        @test quadrant_from_symbol(quad, :sw) == Quad(-2,-2,0,0)
    end
    @testset "tree creation" begin

    end
end
