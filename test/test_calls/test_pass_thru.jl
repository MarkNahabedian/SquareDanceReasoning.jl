
function original_ds(ds)
    if ds.previous == nothing
        ds
    else
        original_ds(ds.previous)
    end
end

function facing_lines_pass_thru(call)
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
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
        lines = askc(Collector{LineOfFour}(), kb, LineOfFour)
        @test length(lines) == 2
        note_call_text(call)
        kb = do_call(kb, call)
        @debug_formations(kb)
        for ds in askc(Collector{DancerState}(), kb, DancerState)
            ods = original_ds(ds)
            @test ods.direction == ds.direction
            # @test ods.left == ds.left     BREATHING!
            odsf = forward(ods, COUPLE_DISTANCE, 0)
            @test odsf.down == ds.down
        end
        animate(joinpath(ANIMATIONS_DIRECTORY, "pass_thru.svg"),
                askc(Collector{DancerState}(), kb, DancerState))
    end
end

@testset "test PassThru" begin
    facing_lines_pass_thru(PassThru())
end

@testset "test PullBy" begin
    # Pretty much the same as PassThru
    facing_lines_pass_thru(PullBy())
end

@testset "test Dosado" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
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
        lines = askc(Collector{LineOfFour}(), kb, LineOfFour)
        @test length(lines) == 2
        kb = do_call(kb, note_call_text(Dosado()))
        @debug_formations(kb)
        for ds in askc(Collector{DancerState}(), kb, DancerState)
            ods = original_ds(ds)
            @test ods.direction == ds.direction
            # @test ods.left == ds.left     BREATHING!
            @test ods.down == ds.down
        end
        animate(joinpath(ANIMATIONS_DIRECTORY, "dosado.svg"),
                askc(Collector{DancerState}(), kb, DancerState))
    end
end

