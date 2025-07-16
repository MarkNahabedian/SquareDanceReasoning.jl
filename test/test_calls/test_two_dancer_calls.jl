
@testset "test _Meet from SquaredSet" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(4)
        kb = make_kb()
        receive(kb, square)
        receive.([kb], square_up(square))
        @test 1 == askc(Counter(), kb, SquaredSet)
        kb = do_call(kb, note_call_text(_Meet(; role=OriginalHeads())))
        f2fs = askc(Collector{FaceToFace}(), kb)
        @test length(f2fs) == 2
        for f2f in f2fs
            @test distance(f2f.a, f2f.b) == COUPLE_DISTANCE
        end
    end
end

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
        kb = do_call(kb, note_call_text(Hinge()))
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
        animate(joinpath(ANIMATIONS_DIRECTORY, "hinge.svg"),
                askc(Collector{DancerState}(), kb, DancerState))
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
        kb = do_call(kb, note_call_text(PartnerHinge()))
        @debug_formations(kb)
        dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                    by = ds -> ds.dancer)
        @test 0 == askc(Counter(), kb, Couple)
        @test 1 == askc(Counter(), kb, RHMiniWave)
        @test 0 == askc(Counter(), kb, LHMiniWave)
        animate(joinpath(ANIMATIONS_DIRECTORY, "partner_hinge.svg"),
                askc(Collector{DancerState}(), kb, DancerState))
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
        kb = do_call(kb, note_call_text(Trade()))
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
        animate(joinpath(ANIMATIONS_DIRECTORY, "trade.svg"),
                askc(Collector{DancerState}(), kb, DancerState))
    end
end

@testset "test SlideThru" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(3)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 1 2 0 0 0 0;
                                  0 0 3 5 0 0;
                                  0 0 0 0 4 6 ],
                                [ "→←    ",
                                  "  →←  ",
                                  "    →←" ])
        receive.([kb], grid)
        # 1, 2 => Couple,
        # 3, 5 => RHMiniWave,
        # 4, 6 => LHMiniWave
        @debug_formations(kb)
        kb = do_call(kb, note_call_text(SlideThru()))
        @debug_formations(kb)
        cpl = only(askc(Collector{Couple}(), kb, Couple))
        rhw = only(askc(Collector{RHMiniWave}(), kb, RHMiniWave))
        lhw = only(askc(Collector{LHMiniWave}(), kb, LHMiniWave))
        @test cpl.beau.dancer == square[1]
        @test cpl.belle.dancer == square[2]
        @test rhw.a.dancer == square[3]
        @test rhw.b.dancer == square[5]
        @test lhw.a.dancer == square[6]
        @test lhw.b.dancer == square[4]
        animate(joinpath(ANIMATIONS_DIRECTORY, "SlideThru.svg"),
                askc(Collector{DancerState}(), kb, DancerState))
    end
end

@testset "test StarThru" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(3)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 1 2 0 0 0 0;
                                  0 0 3 5 0 0;
                                  0 0 0 0 4 6 ],
                                [ "→←    ",
                                  "  →←  ",
                                  "    →←" ])
        receive.([kb], grid)
        # 1, 2 => Couple,
        # 3, 5 => FaceToFace (can't do)
        # 4, 6 => FaceToFace (can't do)
        @debug_formations(kb)
        kb = do_call(kb, note_call_text(StarThru()))
        @debug_formations(kb)
        cpl = only(askc(Collector{Couple}(), kb, Couple))
        @test 2 == askc(Counter(), kb, FaceToFace)
        @test cpl.beau.dancer == square[1]
        @test cpl.belle.dancer == square[2]
        animate(joinpath(ANIMATIONS_DIRECTORY, "StarThrusvg"),
                askc(Collector{DancerState}(), kb, DancerState))
    end
end

