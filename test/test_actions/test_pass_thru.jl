
@testset "test pass thru" begin
    # Make a square of four couples, 8 Dancers:
    square = make_square(4)
    # Make a knowledge base with all of the square dancer reasoning
    # rules installed:
    kb = make_kb()
    # Assert the square, dancers and their initial positions to the
    # knowledge base:
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 2 4 6 8;
                              1 3 5 7 ],
                            [ "↓↓↓↓";
                              "↑↑↑↑" ])
    receive.([kb], grid)
    # Write an HTML file so we can see what we have at thispoint:
    @debug_formations(kb)
    # Find all of the two dancer FaceToFace formations:
    f2f = askc(Collector{FaceToFace}(), kb, FaceToFace)
    @test 4 == length(f2f)
    # Make a new knowledge base from the original one, copying only
    # the non-temporal facts (those that don't change with time):
    kb2 = make_kb(kb)
    # For each of the FaceToFace formations, have them step to a right
    # hand miniwave and assert the resulting dancer positions to the
    # new knowledge base:
    mws = map(f2f) do f
        mw = step_to_a_wave(f, 1, RightHanded())
        receive(kb2, mw.a)
        receive(kb2, mw.b)
        mw
    end
    # That will result in collisions, find and fix them:
    collisions = askc(Collector{Collision}(), kb2, Collision)
    @test 3 == length(collisions)
    dss = breathe(collisions,
                  map(dancer_states, mws),
                  askc(Collector{DancerState}(), kb2, DancerState))
    # Make a third knowledge base to clear out the old positions and
    # facing directions:
    kb3 = make_kb(kb2)
    # Assert the post-breathing cancer positions:
    receive.([kb3], dss)
    # Find all of the right hand miniwaves and have their dancers pass
    # by each other:
    mws = askc(Collector{RHMiniWave}(), kb3, RHMiniWave)
    @test 4 == length(mws)
    b2bs = map(mws) do mw
        pass_by(mw, 1)
    end
    # We don't do compaction breathing yet.
    #
    # Yet another knowledge base:
    kb4 = make_kb(kb3)
    # Assert the new dancer positions after pass_by:
    for b2b in b2bs
        receive.([kb4], dancer_states(b2b))
    end
    # We should have 2 LineOfFour, 4 BackToBack and six Couple
    # formations:
    @test 2 == askc(Counter(), kb4, LineOfFour)
    @test 4 == askc(Counter(), kb4, BackToBack)
    @test 6 == askc(Counter(), kb4, Couple)
    # Write an SVG animation file:
    animate(joinpath(@__DIR__, "pass_thru.svg"),
            askc(Collector{DancerState}(), kb4, DancerState),
            40)
end

