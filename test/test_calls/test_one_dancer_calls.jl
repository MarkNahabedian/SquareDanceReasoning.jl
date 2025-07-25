
@testset "test Identify" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        @test as_text(note_call_text(Identify())) == "everyone identify"
        kb = make_kb()
        square = make_square(2)
        receive(kb, square)
        grid = grid_arrangement(
            sort!(square.dancers),
            [ 2 1;
              3 4 ],
            [ "↓↓";
              "↑↑" ])
        receive.([kb], grid)
        original_dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                             by = ds -> ds.dancer)
        @debug_formations(kb)
        kb = do_call(kb, note_call_text(Identify(role=Guys())))
        kb = do_call(kb, note_call_text(Identify(role=Gals())))
        dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                    by = ds -> ds.dancer)    
        for i in 1:length(original_dss)
            @test dss[i].time ≈ original_dss[i].time + 2 + 2
            @test dss[i].direction == original_dss[i].direction
            @test dss[i].down == original_dss[i].down
            @test dss[i].left == original_dss[i].left
        end
        animate(joinpath(ANIMATIONS_DIRECTORY, "identify.svg"), dss)
    end
end
