
#=
@testset "test BoxCirculate" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(2)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 4 3;
                                  1 2 ],
                                [ "→→";
                                  "←←" ])
        receive.([kb], grid)
        @debug_formations(kb)
        @test 1 == askc(Counter(), kb, RHBoxOfFour)
        # Whole box circulate:
        kb = do_call(kb, note_call_text(BoxCirculate(; half_count = 2)))
        @debug_formations(kb)
        @test 1 == askc(Counter(), kb, RHMBoxOfFour)
        let
            box = only(askc(Collector{RHBoxOfFout}(), kb))
            @test handedness(box) == RightHanded()
            @test box.tandem1.trailer.dancer == square[1]
            @test box.tandem1.leader.dancer == square[4]
            @test box.tandem2.trailer.dancer == square[3]
            @test box.tandem2.leader.dancer == square[2]
        end
        # Half box circulate:
        kb = do_call(kb, note_call_text(BoxCirculate(; half_count = 1)))
        @debug_formations(kb)
        let
            diamond = only(askc(Collector{Diamond}(), kb))
            @test handedness(diamond) == RightHanded()
            @test diamond.centers.a.dancer == square[1]
            @test diamond.centers.b.dancer == square[3]
            @test diamond.points.a.dancer == square[4]
            @test diamond.points.b.dancer == square[2]
        end
    end
end
=#

