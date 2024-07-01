
@testset "test pass thru" begin
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 2 4 6 8;
                              1 3 5 7 ],
                            [ "↓↓↓↓";
                              "↑↑↑↑" ])
    receive.([kb], grid)
    @debug_formations(kb)
    f2f = askc(Collector{FaceToFace}(), kb, FaceToFace)
    @test 4 == length(f2f)
    kb2 = make_kb(kb)
    mws = map(f2f) do f
        mw = step_to_a_wave(f, 1, RightHanded())
        receive(kb2, mw.a)
        receive(kb2, mw.b)
        mw
    end
    collisions = askc(Collector{Collision}(), kb2, Collision)
    @test 3 == length(collisions)
    dss = breathe(collisions,
                  map(dancer_states, mws),
                  askc(Collector{DancerState}(), kb2, DancerState))
    kb3 = make_kb(kb2)
    receive.([kb3], dss)
    mws = askc(Collector{RHMiniWave}(), kb3, RHMiniWave)
    @test 4 == length(mws)
    b2bs = map(mws) do mw
        pass_by(mw, 1)
    end
    # We don't do compaction breathing yet.
    kb4 = make_kb(kb3)
    for b2b in b2bs
        receive.([kb4], dancer_states(b2b))
    end
    @test 4 == askc(Counter(), kb4, BackToBack)
    @test 6 == askc(Counter(), kb4, Couple)
    animate(joinpath(@__DIR__, "pass_thru.svg"),
            askc(Collector{DancerState}(), kb4, DancerState),
            40)
end

