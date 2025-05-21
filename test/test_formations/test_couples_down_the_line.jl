
@testset "test FacingTandemCouples" begin
    square = make_square(4)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 3 1 6 8;
                              4 2 5 7 ],
                            [ "→→←←";
                              "→→←←" ])
    map(grid) do ds
        if ds != nothing
            receive(kb, ds)
        end
    end
    @debug_formations(kb)
    @test 4 == askc(Counter(), kb, Couple)
    @test 2 == askc(Counter(), kb, TandemCouples)
    @test 1 == askc(Counter(), kb, FacingCouples)
    f = askc(Collector{FacingTandemCouples}(), kb, FacingTandemCouples)
    @test length(f) == 1
    f = f[1]
    @test length(dancer_states(f)) == 8
    @test handedness(f) == NoHandedness()
    @test f.tandem_couples1.leaders.beau.dancer == square[1]
    @test f.tandem_couples1.leaders.belle.dancer == square[2]
    @test f.tandem_couples1.trailers.beau.dancer == square[3]
    @test f.tandem_couples1.trailers.belle.dancer == square[4]
    @test f.tandem_couples2.leaders.beau.dancer == square[5]
    @test f.tandem_couples2.leaders.belle.dancer == square[6]
    @test f.tandem_couples2.trailers.beau.dancer == square[7]
    @test f.tandem_couples2.trailers.belle.dancer == square[8]
    collect_formation_examples(kb)
end


@testset "test BeforeEightChain" begin
    square = make_square(4)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 1 4 5 8;
                              2 3 6 7 ],
                            [ "→←→←";
                              "→←→←" ])
    map(grid) do ds
        if ds != nothing
            receive(kb, ds)
        end
    end
    @debug_formations(kb)
    @test 4 == askc(Counter(), kb, Couple)
    @test 2 == askc(Counter(), kb, FacingCouples)
    @test 1 == askc(Counter(), kb, BackToBackCouples)
    f = askc(Collector{BeforeEightChain}(), kb, BeforeEightChain)
    @test length(f) == 1
    f = f[1]
    @test length(dancer_states(f)) == 8
    @test handedness(f) == NoHandedness()
    @test f.facing_couples1.couple1.beau.dancer == square[1]
    @test f.facing_couples1.couple1.belle.dancer == square[2]
    @test f.facing_couples1.couple2.beau.dancer == square[3]
    @test f.facing_couples1.couple2.belle.dancer == square[4]
    @test f.facing_couples2.couple1.beau.dancer == square[5]
    @test f.facing_couples2.couple1.belle.dancer == square[6]
    @test f.facing_couples2.couple2.beau.dancer == square[7]
    @test f.facing_couples2.couple2.belle.dancer == square[8]
    collect_formation_examples(kb)
end


@testset "test BeforeTradeBy" begin
    square = make_square(4)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 2 3 6 7;
                              1 4 5 8 ],
                            [ "←→←→",
                              "←→←→"])
    map(grid) do ds
        if ds != nothing
            receive(kb, ds)
        end
    end
    @debug_formations(kb)
    @test 4 == askc(Counter(), kb, Couple)
    @test 1 == askc(Counter(), kb, FacingCouples)
    @test 2 == askc(Counter(), kb, BackToBackCouples)
    f = askc(Collector{BeforeTradeBy}(), kb, BeforeTradeBy)
    @test length(f) == 1
    f = f[1]
    @test length(dancer_states(f)) == 8
    @test handedness(f) == NoHandedness()
    @test f.bbcouples1.couple1.beau.dancer == square[3]
    @test f.bbcouples1.couple1.belle.dancer == square[4]
    @test f.bbcouples1.couple2.beau.dancer == square[1]
    @test f.bbcouples1.couple2.belle.dancer == square[2]
    @test f.bbcouples2.couple1.beau.dancer == square[7]
    @test f.bbcouples2.couple1.belle.dancer == square[8]
    @test f.bbcouples2.couple2.beau.dancer == square[5]
    @test f.bbcouples2.couple2.belle.dancer == square[6]
    collect_formation_examples(kb)
end

@testset "test CompletedDoublePassThru" begin
    square = make_square(4)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 2 4 5 7;
                              1 3 6 8 ],
                            [ "←←→→",
                              "←←→→" ])
    map(grid) do ds
        if ds != nothing
            receive(kb, ds)
        end
    end
    @debug_formations(kb)
    @test 4 == askc(Counter(), kb, Couple)
    @test 0 == askc(Counter(), kb, FacingCouples)
    @test 1 == askc(Counter(), kb, BackToBackCouples)
    @test 2 == askc(Counter(), kb, TandemCouples)
    f = askc(Collector{CompletedDoublePassThru}(), kb,
             CompletedDoublePassThru)
    @test length(f) == 1
    f = f[1]
    @test length(dancer_states(f)) == 8
    @test handedness(f) == NoHandedness()
    @test f.tandem_couples1.leaders.beau.dancer == square[7]
    @test f.tandem_couples1.leaders.belle.dancer == square[8]
    @test f.tandem_couples1.trailers.beau.dancer == square[5]
    @test f.tandem_couples1.trailers.belle.dancer == square[6]
    @test f.tandem_couples2.leaders.beau.dancer == square[1]
    @test f.tandem_couples2.leaders.belle.dancer == square[2]
    @test f.tandem_couples2.trailers.beau.dancer == square[3]
    @test f.tandem_couples2.trailers.belle.dancer == square[4]
    collect_formation_examples(kb)
end

