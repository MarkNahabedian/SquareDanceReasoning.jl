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
        # containment_graph(kb, "test_centers_trade", DotBackend(@__DIR__, "test_centers_trade"))
        # Check that those_with_role is working:
        let
            line = only(askc(Collector{LineOfFour}(), kb))
            @test Set(those_with_role(line, kb, Centers())) ==
                Set(dancer_states(line.centers))
            @test Set(those_with_role(line.centers, kb, Centers())) ==   # this fails
                Set(dancer_states(line.centers))
        end
        let
            wave = only(askc(Collector{WaveOfFour}(), kb))
            @test Set(those_with_role(wave, kb, Centers())) ==
                Set(dancer_states(wave.centers))            
            @test Set(those_with_role(wave.centers, kb, Centers())) ==
                Set(dancer_states(wave.centers))
        end
        kb = do_call(kb, Trade(role=Centers()))
        @debug_formations(kb)
        animate(joinpath(@__DIR__, "centers_trade.svg"),
                askc(Collector{DancerState}(), kb, DancerState),
                40)
    end
end

