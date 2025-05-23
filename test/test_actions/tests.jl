
cleanup_debug_formations(@__DIR__)

@testset "test forward motion" begin
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION1, 1, 1)
        ds1 = forward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down == ds1.down
        @test ds0.left + 2 == ds1.left
        @test can_roll(ds1) == 0
        @test earliest(ds0) == ds0
        @test earliest(ds1) == ds0
    end
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION2, 1, 1)
        ds1 = forward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down - 2 == ds1.down
        @test ds0.left == ds1.left
        @test can_roll(ds1) == 0
    end
end

@testset "test backward motion" begin
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION1, 1, 1)
        ds1 = backward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down == ds1.down
        @test ds0.left - 2 == ds1.left
        @test can_roll(ds1) == 0
    end
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION2, 1, 1)
        ds1 = backward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down + 2 == ds1.down
        @test ds0.left == ds1.left
        @test can_roll(ds1) == 0
    end
end

@testset "test leftward motion" begin
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION1, 1, 1)
        ds1 = leftward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down - 2 == ds1.down
        @test ds0.left == ds1.left
        @test can_roll(ds1) == 0
    end
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION2, 1, 1)
        ds1 = leftward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down == ds1.down
        @test ds0.left - 2 == ds1.left
        @test can_roll(ds1) == 0
    end
end

@testset "test rightward motion" begin
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION1, 1, 1)
        ds1 = rightward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down + 2 == ds1.down
        @test ds0.left == ds1.left
        @test can_roll(ds1) == 0
    end
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION2, 1, 1)
        ds1 = rightward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down == ds1.down
        @test ds0.left + 2 == ds1.left
        @test can_roll(ds1) == 0
    end
end

@testset "test revolve" begin
    let
        # rotate
        ds0 = DancerState(Dancer(1, Unspecified()),
                          0, DIRECTION1, 1, 1)
        ds1 = rotate(ds0, DIRECTION1, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds1.direction == DIRECTION2
        @test ds1.down == ds0.down
        @test ds1.left == ds0.left
        @test can_roll(ds1) == DIRECTION2 - DIRECTION1
    end
    let
        # revolve in place:
        ds0 = DancerState(Dancer(1, Unspecified()),
                          0, DIRECTION1, 1, 1)
        ds1 = revolve(ds0, [1, 1], DIRECTION2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds1.direction == DIRECTION2
        @test ds1.down == ds0.down
        @test ds1.left == ds0.left
        @test can_roll(ds1) == DIRECTION2 - DIRECTION1
    end
    let
        d, l = revolve([0, 0], [1, 1], 1//8, 2)
        @test isapprox(d, 1; atol=0.0001)
        @test isapprox(l, -1; atol=0.0001)
    end
    let
        # Revolve around another point:
        ds0 = DancerState(Dancer(1, Unspecified()),
                          0, DIRECTION1, 1, 0)
        ds1 = revolve(ds0, [0, 0], DIRECTION2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds1.direction == DIRECTION2
        @test isapprox(ds1.down, 0; atol=0.0001)
        @test isapprox(ds1.left, 1; atol=0.0001)
        @test can_roll(ds1) == DIRECTION2 - DIRECTION1
    end
end

@testset "test animate" begin
    ds = DancerState(Dancer(1, Unspecified()),
                     0, 0, 0, -1)
    center = [0, 0]
    for d in (1:32)//32
        ds = revolve(ds, center, d, 0.5)
    end
    animate(joinpath(@__DIR__, "revolve-single-dancer.svg"),
            [ds])
end

@testset "test step_to_a_wave" begin
    square = make_square(1)
    grid = grid_arrangement(square,
                            [ 1 2; ], [ "→←" ])
    f2f = FaceToFace(grid[1, 1], grid[1, 2])
    let   # right
        mw = step_to_a_wave(f2f, 1, RightHanded())
        @test handedness(mw) isa RightHanded
        @test mw.a.direction < mw.b.direction
        @test mw.a.left == mw.b.left
        @test mw.a.down < mw.b.down
    end
    let   # left
        mw = step_to_a_wave(f2f, 1, LeftHanded())
        @test handedness(mw) isa LeftHanded
        @test mw.a.direction < mw.b.direction
        @test mw.a.left == mw.b.left
        @test mw.a.down > mw.b.down
    end        
end

@testset "test back_to_a_wave" begin
    square = make_square(1)
    grid = grid_arrangement(square, [ 1 2; ], [ "←→" ])
    b2b = BackToBack(grid[1, 2], grid[1, 1])
    let   # right
        mw = back_to_a_wave(b2b, 1, RightHanded())
        @test handedness(mw) isa RightHanded
        @test mw.a.direction < mw.b.direction
        @test mw.a.left == mw.b.left
        @test mw.a.down < mw.b.down
    end
    let   # left
        mw = back_to_a_wave(b2b, 1, LeftHanded())
        @test handedness(mw) isa LeftHanded
        @test mw.a.direction < mw.b.direction
        @test mw.a.left == mw.b.left
        @test mw.a.down > mw.b.down
    end
end

@testset "test un_step_to_a_wave" begin
    square = make_square(2)
    grid = grid_arrangement(square,
                            [ 1 2 3 4; ], [ "↑↓↓↑" ])
    rhmw = RHMiniWave(grid[1, 2], grid[1, 1])
    lhmw = LHMiniWave(grid[1, 3], grid[1, 4])
    let
        ftf = un_step_to_a_wave(rhmw, 1)
        @test ftf.a.direction < ftf.b.direction
        @test ftf.a.left == ftf.b.left
        @test ftf.a.down < ftf.b.down
    end
    let
        ftf = un_step_to_a_wave(lhmw, 1)
        @test ftf.a.direction < ftf.b.direction
        @test ftf.a.left == ftf.b.left
        @test ftf.a.down < ftf.b.down
    end
end

include("test_breathing.jl")

