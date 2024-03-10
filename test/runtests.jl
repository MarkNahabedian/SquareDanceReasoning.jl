using SquareDanceReasoning
using Test


@testset "directions" begin
    @test opposite(DIRECTION0) == DIRECTION2
    @test opposite(DIRECTION1) == DIRECTION3
    @test quarter_left(DIRECTION0) == DIRECTION1
    @test quarter_right(DIRECTION0) == DIRECTION3
    @test canonicalize(5 * DIRECTION1) == DIRECTION1
end

@testset "gender" begin
    @test Guy() == Guy()
    @test Gal() == Gal()
    @test Unspecified() != Unspecified()
    @test Guy() != Gal()
    @test Unspecified() != Guy()
    @test Unspecified() != Gal()
    @test Unspecified() != Unspecified()
    @test opposite(Guy()) == Gal()
    @test opposite(Gal()) == Guy()
    @test opposite(Unspecified()) isa Unspecified
    @test Unspecified() < Guy()
    @test Guy() < Gal()
end

@testset "dancers" begin
    dancers = make_dancers(4)
    
    @test length(dancers) == 8
    @test is_original_head(dancers[1])
    @test !is_original_side(dancers[1])
    @test !is_original_head(dancers[4])
    @test is_original_side(dancers[4])
end

@testset "square up" begin
    ds = square_up(make_dancers(4))
    @test length(ds) == 8
    @test isapprox(sum(location, ds), [0.0 0.0]; atol=0.001)
end

