# Test use of FormationContainedIn facts in Role identification.

@testset "test centers trade" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(4)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 1 2 3 4;
                                  5 6 7 8 ],
                                [ "↓↓↓↓";
                                  "↓↑↓↑" ])
        receive.([kb], grid)
        @debug_formations(kb)
        containment_graph(kb, "test_centers_trade", DotBackend(@__DIR__, "test_centers_trade"))
        # Check that those_with_role is working:
        line = only(askc(Collector{LineOfFour}(), kb))
        @test Set(those_with_role(line, kb, Centers())) ==
            Set(dancer_states(line.centers))
        @test Set(those_with_role(line.centers, kb, Centers())) ==   # this fails
            Set(dancer_states(line.centers))
        wave = only(askc(Collector{WaveOfFour}(), kb))
        @test Set(those_with_role(wave, kb, Centers())) ==
            Set(dancer_states(wave.centers))            
        @test Set(those_with_role(wave.centers, kb, Centers())) ==
            Set(dancer_states(wave.centers))
        kb = do_call(kb, Trade(role=Centers()))
        @debug_formations(kb)
        # BUG: The animation shows that there are both timing and breathing issues.
        # the centers in the line pause in the middle of their trade.
        # The centers of the wave are no longer lined up with the rest of the wave.
        pos(ds::DancerState) = (ds.down, ds.left)
        let
            line2 = only(askc(Collector{InvertedLineOfFour}(), kb))
            @test line2.centers.beau.direction == opposite(line.centers.belle.direction)
            @test line2.centers.belle.direction == opposite(line.centers.beau.direction)
            @test pos(line2.centers.beau) == pos(line.centers.belle)
            @test pos(line2.centers.belle) == pos(line.centers.beau)
        end
        #= TEST_FAILS: Doesn't work because, due to breathing issues, we don't see a wave
        let
            wave2 = only(askc(Collector{WaveOfFour}(), kb))
            @test wave2.centers.a.direction == wave.centers.b.direction
            @test wave2.centers.b.direction == line.centers.a.direction
            @test pos(wave2.centers.a) == pos(wave.centers.b)
            @test pos(wave2.centers.b) == pos(wave.centers.a)
        end
        =#
        animate(joinpath(@__DIR__, "centers_trade.svg"),
                askc(Collector{DancerState}(), kb, DancerState))
    end
end

