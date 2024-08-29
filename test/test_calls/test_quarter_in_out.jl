
@testset "test QuarterIn, QuarterOut" begin
    square = make_square(2)
    kb = make_kb()
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 2 1;
                              4 3 ],
                            [ "↓↓";
                              "↑↓" ])
    receive.([kb], grid)
    @test 1 == askc(Counter(), kb, Attendance)
    @test 1 == askc(Counter(), kb, AllPresent)
    @debug_formations(kb)
    dss1 = sort!(askc(Collector{DancerState}(), kb, DancerState);
                 by = ds -> ds.dancer)
    @test 1 == askc(Counter(), kb, Couple)
    @test 1 == askc(Counter(), kb, RHMiniWave)
    kb = do_call(kb, QuarterIn())
    @debug_formations(kb)
    dss2 = sort!(askc(Collector{DancerState}(), kb, DancerState);
                 by = ds -> ds.dancer)
    @test 2 == askc(Counter(), kb, FaceToFace)
    for i in 1 : length(dss1)
        @test dss1[i].time + 2 == dss2[i].time
        @test dss1[i].down == dss2[i].down
        @test dss1[i].left == dss2[i].left
    end
    @test dss2[1].direction == 3//4
    @test dss2[2].direction == 1//4
    @test dss2[3].direction == 3//4
    @test dss2[4].direction == 1//4
    kb = do_call(kb, UTurnBack(;
                               role = DesignatedDancers([Dancer(2, Guy())])))
    @debug_formations(kb)
    dss3 = sort!(askc(Collector{DancerState}(), kb, DancerState);
                 by = ds -> ds.dancer)
    @test 1 == askc(Counter(), kb, Couple)
    @test 1 == askc(Counter(), kb, LHMiniWave)    
    kb = do_call(kb, QuarterOut())
    @debug_formations(kb)
    dss4 = sort!(askc(Collector{DancerState}(), kb, DancerState);
                 by = ds -> ds.dancer)
    @test 2 == askc(Counter(), kb, FaceToFace)
    @test 2 == askc(Counter(), kb, Couple)
        for i in 1 : length(dss1)
        @test dss3[i].time + 2 == dss4[i].time
        @test dss3[i].down == dss4[i].down
        @test dss3[i].left == dss4[i].left
    end
    @test dss4[1].direction == 0
    @test dss4[2].direction == 0
    @test dss4[3].direction == 1//2
    @test dss4[4].direction == 1//2
end

