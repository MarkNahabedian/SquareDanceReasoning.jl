using SquareDanceReasoning
using Test
using Rete
using InteractiveUtils
using Logging
using XML


include("debug_formations.jl")

@testset "utils" begin
    @test collect(SquareDanceReasoning.merge_sorted_iterators(1:3, 2:2:6, 1:8)) ==
        collect(1:8)
end

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
    @test Unspecified() < Gal()
    @test !(Guy() > Gal())
end

@testset "dancers" begin
    square = make_square(4)
    @test all(broadcast(==, square, [
        Dancer(1, Guy()), Dancer(1, Gal()),
        Dancer(2, Guy()), Dancer(2, Gal()),
        Dancer(3, Guy()), Dancer(3, Gal()),
        Dancer(4, Guy()), Dancer(4, Gal()),
    ]))
    @test length(square.dancers) == 8
    @test all(filter(is_original_head, square.dancers)) do dancer
        isodd(dancer.couple_number)
    end
    @test all(filter(is_original_side, square.dancers)) do dancer
        iseven(dancer.couple_number)
    end
    sort
end

@testset "SDSquare identity" begin
    # I wonder iof this works or if we need to add a square number to
    # Dancer?
    @test make_square(4) != make_square(4)
end

@testset "square up" begin
    ds = square_up(make_square(4))
    @test length(ds) == 8
    @test isapprox(sum(location, ds), [0.0, 0.0]; atol=0.001)
end

@testset "OriginalPartners" begin
    kb = make_kb()
    install(kb, OriginalPartnerRule)
    install(kb, SquareHasDancers)
    square = make_square(4)
    receive(kb, square)
    original_partners = askc(Collector{Any}(), kb, OriginalPartners)
    @test length(original_partners) == 4
    for op in original_partners
        @test op.guy.couple_number == op.gal.couple_number
    end
    @test Set(map(couple_number, original_partners)) == Set(1:4)
end

@testset "relative direction" begin
    d1 = DancerState(Dancer(1, Unspecified()), 0, 1//15, 0, 0)
    # unit direction vector from d1:
    dv(direction) = unit_vector(d1.direction + direction)
    # to the left of d1:
    d2 = DancerState(Dancer(2, Unspecified()), 0, d1.direction, dv(1//4)...)
    # in front of d1:
    d3 = DancerState(Dancer(3, Unspecified()), 0, d1.direction, dv(0)...)
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

@testset "Bounds" begin
    square = make_square(4)
    grid = grid_arrangement(square,
                            [ 1 2 3 4; 5 6 7 8 ],
                            [ "↓↓↓↓", "↑↑↑↑" ])
    let
        bounds = Bounds(grid)
        @test bounds.min_down == 1.0
        @test bounds.max_down == 2.0
        @test bounds.min_left == 1.0
        @test bounds.max_left == 4.0
    end
    let
        bounds = Bounds(grid)
        bounds = bump_out(bounds)
        margin = COUPLE_DISTANCE / 2
        @test bounds.min_down == 1 - margin
        @test bounds.max_down == 2 + margin
        @test bounds.min_left == 1 - margin
        @test bounds.max_left == 4 + margin
    end
    let
        bounds = bump_out(Bounds([grid[1, 1], grid[1, 3]]))
        @test in_bounds(bounds, grid[1, 1])
        @test in_bounds(bounds, grid[1, 2])
        @test in_bounds(bounds, grid[1, 3])
        @test !in_bounds(bounds, grid[1, 4])
    end
end

@testset "test encrooached_on" begin
    kb = make_kb()
    ds1 = DancerState(Dancer(1, Unspecified()), 0, 0, 1, 1)
    ds2 = DancerState(Dancer(2, Unspecified()), 0, 0, 1, 2)
    ds3 = DancerState(Dancer(3, Unspecified()), 0, 0, 1, 3)
    receive(kb, ds1)
    receive(kb, ds2)
    receive(kb, ds3)
    @test encroached_on([ds1, ds3], kb) != nothing
    @test encroached_on([ds1, ds2], kb) == nothing
end

@testset "center" begin
    square = make_square(4)
    dss = square_up(square)
    c = center(dss)
    eq(a, b) = isapprox(a, b; atol = 0.00001)
    @test eq(c[1], 0.0)
    @test eq(c[2], 0.0)
end

@testset "test grid_arrangement columns" begin
    let # columns
        dancers = sort(collect(make_square(4).dancers))
        dancer_indices = [ 1 2 3 4;
                           5 6 7 8 ]
        directions = [ "→→→→",
                       "←←←←" ]
        a = grid_arrangement(dancers, dancer_indices, directions)
        directions = SquareDanceReasoning.arrows_to_directions(directions)
        for down in 1:2
            for left in 1:4
                ds = a[down, left]
                @test ds isa DancerState
                @test ds.down == down
                @test ds.left == left
                @test ds.direction == directions[down, left]
                @test ds.dancer == dancers[dancer_indices[down, left]]
            end
        end
    end
    let # boxes
        dancers = sort(collect(make_square(4).dancers))
        dancer_indices = [ 1 2 3 4;
                           5 6 7 8 ]
        directions = [ "↓↑↓↑",
                       "↓↑↓↑" ]
        a = grid_arrangement(dancers, dancer_indices, directions)
        directions = SquareDanceReasoning.arrows_to_directions(directions)
        for down in 1:2
            for left in 1:4
                ds = a[down, left]
                @test ds isa DancerState
                @test ds.down == down
                @test ds.left == left
                @test ds.direction == directions[down, left]
                @test ds.dancer == dancers[dancer_indices[down, left]]
            end
        end
    end
end

@testset "Test polar arrangement" begin
    let
        compass_points = polar_arrangement(4, [0, 0], 2, 1//2)
        expect =  [ [ 1//2, -2,  0 ],
                    [ 3//4,  0, -2 ],
                    [ 1,     2,  0 ],
                    [ 5//4,  0,  2 ] ]
        @test length(compass_points) == length(expect)
        for i in 1:length(expect)
            @test isapprox(compass_points[i], expect[i]; atol = 0.0001)
        end
    end
    # Star promenade:
    center = [0, 0]
    dancers = sort(collect(make_square(4).dancers))
    guys = filter(d -> d.gender isa Guy, dancers)
    gals = filter(d -> d.gender isa Gal, dancers)
    guy_dss = polar_arrangement(guys, center,
                                COUPLE_DISTANCE/2, 0,
                                left_hand_in)
    gal_dss = polar_arrangement(gals, center,
                                COUPLE_DISTANCE * 3/2, 0,
                                left_hand_in)
    for (guy, gal) in zip(guy_dss, gal_dss)
        @test guy.dancer.gender isa Guy
        @test gal.dancer.gender isa Gal
        @test guy.direction == gal.direction
        @test isapprox(distance(guy, gal), COUPLE_DISTANCE;
                       atol=0.01)
        @test direction(center, guy) == direction(center, gal)
    end
    XML.write(joinpath(@__DIR__, "star_promenade.svg"),
              formation_svg([guy_dss..., gal_dss...], ""; inline_stylesheet=true))
end

include("test_collisions.jl")

include("test_formations/tests.jl")

include("test_actions/tests.jl")

include("test_calls/tests.jl")

