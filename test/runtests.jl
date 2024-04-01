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
    square = make_square(4)
    @test length(square.dancers) == 8
    @test all(filter(is_original_head, square.dancers)) do dancer
        isodd(dancer.couple_number)
    end
    @test all(filter(is_original_side, square.dancers)) do dancer
        iseven(dancer.couple_number)
    end
end

@testset "square up" begin
    ds = square_up(make_square(4))
    @test length(ds) == 8
    @test isapprox(sum(location, ds), [0.0, 0.0]; atol=0.001)
end

@testset "OriginalPartners" begin
    kb = Rete.ReteRootNode("root")
    install(kb, OriginalPartnerRule)
    install(kb, SquareHasDancers)
    op_node = ensure_IsaMemoryNode(kb, OriginalPartners)
    square = make_square(4)
    receive(kb, square)
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
    square = make_square(4)
    dancers = collect(square.dancers)
    dss = [ make_line(dancers[1:4], 0, 0)...,
            make_line(dancers[5:8], 1//2, 1)... ]
    let
        bounds = Bounds(dss)
        @test bounds.min_down == 0.0
        @test bounds.max_down == 1.0
        @test bounds.min_left == 1.0
        @test bounds.max_left == 4.0
    end
    let
        bounds = Bounds(dss)
        bounds = bump_out(bounds)
        margin = COUPLE_DISTANCE / 2
        @test bounds.min_down == 0 - margin
        @test bounds.max_down == 1 + margin
        @test bounds.min_left == 1 - margin
        @test bounds.max_left == 4 + margin
    end
    let
        bounds = bump_out(Bounds([dss[1], dss[3]]))
        @test in_bounds(bounds, dss[1])
        @test in_bounds(bounds, dss[2])
        @test in_bounds(bounds, dss[3])
        @test !in_bounds(bounds, dss[4])
    end
end

@testset "center" begin
    square = make_square(4)
    dss = square_up(square)
    c = center(dss)
    eq(a, b) = isapprox(a, b; atol = 0.00001)
    @test eq(c[1], 0.0)
    @test eq(c[2], 0.0)
end

include("test_formations/tests.jl")

include("test_actions/tests.jl")

