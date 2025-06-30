# Test calls that include a CourtesyTurn.

using Logging

@testset "test CourtesyTurn" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        Logging.disable_logging(Logging.Debug - 1)
        square = make_square(2)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 1 2;
                                  4 3 ],
                                [ "↑↑" ;
                                  "↓↓" ])
        println(grid)
        receive.([kb], grid)
        @debug_formations(kb)
        kb = do_call(kb, CourtesyTurn())
        @debug_formations(kb)
        ftfc = only(askc(Collector{FacingCouples}(), kb))
        # previous.previous because CourtesyTurn performs two 1//4 rotations:
        @test location(ftfc.couple1.belle) == location(ftfc.couple1.beau.previous.previous)
        @test location(ftfc.couple1.beau) == location(ftfc.couple1.belle.previous.previous)
        @test location(ftfc.couple2.beau) == location(ftfc.couple2.belle.previous.previous)
        @test location(ftfc.couple2.belle) == location(ftfc.couple2.beau.previous.previous)
        animate(joinpath(ANIMATIONS_DIRECTORY, "ccourtesy_turn.svg"),
                askc(Collector{DancerState}(), kb, DancerState))
    end
end

