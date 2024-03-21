using SquareDanceReasoning
using Test
using Rete


include("debug_formations.jl")

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

@testset "OriginalPartners" begin
    kb = Rete.ReteRootNode("root")
    install(kb, OriginalPartnerRule)
    op_node = ensure_IsaMemoryNode(kb, OriginalPartners)
    dancers = make_dancers(4)
    for d in dancers
        receive(kb, d)
    end
    original_partners = collecting() do c
        askc(c, op_node)
    end
    @test length(original_partners) == 4
    for op in original_partners
        @test op.guy.couple_number == op.gal.couple_number
    end
    @test Set(map(couple_number, original_partners)) == Set(1:4)
end

@testset "relative direction" begin
    fd = 1//15       # facing direction
    # direction vector from d1:
    dv(direction) = [ cos((fd + direction) * 2 * pi),
                      sin((fd + direction) * 2 * pi) ]
    d1 = DancerState(Dancer(1, Unspecified()), 0, fd, 0, 0)
    # to the left of d1:
    d2 = DancerState(Dancer(2, Unspecified()), 0, fd, dv(0.25)...)
    # in front of d1:
    d3 = DancerState(Dancer(3, Unspecified()), 0, fd, dv(0.0)...)
    @test in_front_of(d1, d3)
    @test !in_front_of(d3, d1)
    @test !in_front_of(d1, d2)
    @test behind(d3, d1)
    @test !behind(d1, d3)
    @test !behind(d1, d2)
    @test left_of(d1, d2)
    @test !left_of(d2, d1)
    @test !left_of(d2, d3)
    @test right_of(d2, d1)
    @test !right_of(d1, d2)
    @test !right_of(d2, d3)
end

# Arrange all dancers in a line with the specified down and direction:
function make_line(dancers, direction, down)
    left = 1
    map(dancers) do dancer
        ds = DancerState(dancer, 0, direction, down, left)
        left += 1
        ds
    end
end

@testset "Bounds" begin
    let
        dancers = make_dancers(4)
        dss = square_up(dancers)
        bounds = Bounds(dss; margin=0)
        println(bounds)
        @test bounds.min_down == -0.5
        @test bounds.max_down == 0.5
        @test bounds.min_left == -0.5
        @test bounds.max_left == 0.5
    end
    let
        dancers = make_dancers(4)
        dss = [ make_line(dancers[1:4], 0, 0)...,
                make_line(dancers[5:8], 1//2, 1)... ]
        bounds = Bounds(dss; margin=0)
        @test bounds.min_down == 0.0
        @test bounds.max_down == 1.0
        @test bounds.min_left == 1.0
        @test bounds.max_left == 4.0
        bounds = Bounds(dss)
        margin = COUPLE_DISTANCE / 2
        @test bounds.min_down == 0 - margin
        @test bounds.max_down == 1 + margin
        @test bounds.min_left == 1 - margin
        @test bounds.max_left == 4 + margin
    end
end

@testset "center" begin
    dancers = make_dancers(4)
    dss = square_up(dancers)
    c = center(dss)
    eq(a, b) = isapprox(a, b; atol = 0.00001)
    @test eq(c[1], 0.0)
    @test eq(c[2], 0.0)
end

include("test_formations/tests.jl")

