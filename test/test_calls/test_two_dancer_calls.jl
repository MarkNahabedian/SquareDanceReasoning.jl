
@testset "test Hinge" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(3)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 1 2; 3 4; 5 6 ],
                                [ "↑↑", "↓↑", "↑↓" ])
        receive.([kb], grid)
        @debug_formations(kb)
        # Dancers 1 and 2 can't Hinge, they can PartnerHinge.
        kb = do_call(kb, Hinge())
        @debug_formations(kb)
        dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                    by = ds -> ds.dancer)
        # additional Couple from adjacent opposite handed MiniWaves:
        @test 2 == askc(Counter(), kb, Couple)
        @test 1 == askc(Counter(), kb, RHMiniWave)
        @test 1 == askc(Counter(), kb, LHMiniWave)
        @test dss[1].direction == 1//2
        @test dss[2].direction == 1//2
        @test dss[3].direction == 1//4
        @test dss[4].direction == 3//4
        @test dss[5].direction == 1//4
        @test dss[6].direction == 3//4
        animate(joinpath(@__DIR__, "hinge.svg"),
                askc(Collector{DancerState}(), kb, DancerState),
                40)
    end
end

@testset "test PartnerHinge" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(1)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 1 2 ],
                                [ "↑↑" ])
        receive.([kb], grid)
        @debug_formations(kb)
        kb = do_call(kb, PartnerHinge())
        @debug_formations(kb)
        dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                    by = ds -> ds.dancer)
        @test 0 == askc(Counter(), kb, Couple)
        @test 1 == askc(Counter(), kb, RHMiniWave)
        @test 0 == askc(Counter(), kb, LHMiniWave)
        animate(joinpath(@__DIR__, "partner_hinge.svg"),
                askc(Collector{DancerState}(), kb, DancerState),
                40)
    end
end

@testset "test Trade" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(3)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 1 2 0 0 0 0;
                                  0 0 3 4 0 0;
                                  0 0 0 0 5 6 ],
                                [ "↑↑    ",
                                  "  ↓↑  ",
                                  "    ↑↓" ])
        receive.([kb], grid)
        @debug_formations(kb)
        kb = do_call(kb, Trade())
        @debug_formations(kb)
        dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                    by = ds -> ds.dancer)
        @test 1 == askc(Counter(), kb, Couple)
        @test 1 == askc(Counter(), kb, RHMiniWave)
        @test 1 == askc(Counter(), kb, LHMiniWave)
        @test dss[1].direction == opposite(grid[1, 1].direction)
        @test dss[2].direction == opposite(grid[1, 2].direction)
        @test dss[3].direction == opposite(grid[2, 3].direction)
        @test dss[4].direction == opposite(grid[2, 4].direction)
        @test dss[5].direction == opposite(grid[3, 5].direction)
        @test dss[6].direction == opposite(grid[3, 6].direction)
        @test location(dss[1]) == location(grid[1, 2])
        @test location(dss[2]) == location(grid[1, 1])
        @test location(dss[3]) == location(grid[2, 4])
        @test location(dss[4]) == location(grid[2, 3])
        @test location(dss[5]) == location(grid[3, 6])
        @test location(dss[6]) == location(grid[3, 5])
        animate(joinpath(@__DIR__, "trade.svg"),
                askc(Collector{DancerState}(), kb, DancerState),
                40)
    end
end

