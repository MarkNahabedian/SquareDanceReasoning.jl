
@testset "test Hinge" begin
    square = make_square(3)
    kb = make_kb()
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 1 2 0 3 4 0 5 6 ],
                            [ "↑↑ ↓↑ ↑↓" ])
    receive.([kb], grid)
    @debug_formations(kb)
    kb = do_call(kb, Hinge())
    @debug_formations(kb)
    dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                by = ds -> ds.dancer)
    @test 0 == askc(Counter(), kb, Couple)
    @test 2 == askc(Counter(), kb, RHMiniWave)
    @test 1 == askc(Counter(), kb, LHMiniWave)
    @test dss[1].direction == 1//4
    @test dss[2].direction == 3//4
    @test dss[3].direction == 1//4
    @test dss[4].direction == 3//4
    @test dss[5].direction == 1//4
    @test dss[6].direction == 3//4
    animate(joinpath(@__DIR__, "hinge.svg"),
            askc(Collector{DancerState}(), kb, DancerState),
            40)
end

