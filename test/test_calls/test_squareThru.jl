
@testset "test SquareThru" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(2)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 4 3;
                                  1 2 ],
                                [ "↓↓";
                                  "↑↑" ])
        receive.([kb], grid)
        @debug_formations(kb)
        @test 1 == askc(Counter(), kb, FacingCouples)
        kb = do_call(kb, SquareThru())
        @debug_formations(kb)
        @test 1 == askc(Counter(), kb, BackToBackCouples)
        animate(joinpath(@__DIR__, "SquareThru_facing_couples.svg"),
                askc(Collector{DancerState}(), kb, DancerState))
    end
end

