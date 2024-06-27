
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
    @test 4 == counting() do c
        askc(c, kb, Couple)
    end
    @test 2 == counting() do c
        askc(c, kb, TandemCouples)
    end
    @test 1 == counting() do c
        askc(c, kb, FacingCouples)
    end
    f = collecting() do c
        askc(c, kb, FacingTandemCouples)
    end
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
    @test 4 == counting() do c
        askc(c, kb, Couple)
    end
    @test 2 == counting() do c
        askc(c, kb, FacingCouples)
    end
    @test 1 == counting() do c
        askc(c, kb, BackToBackCouples)
    end
    f = collecting() do c
        askc(c, kb, BeforeEightChain)
    end
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


@testset "test AfterEightChainOne" begin
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
    @test 4 == counting() do c
        askc(c, kb, Couple)
    end
    @test 1 == counting() do c
        askc(c, kb, FacingCouples)
    end
    @test 2 == counting() do c
        askc(c, kb, BackToBackCouples)
    end
    f = collecting() do c
        askc(c, kb, AfterEightChainOne)
    end
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
    @test 4 == counting() do c
        askc(c, kb, Couple)
    end
    @test 0 == counting() do c
        askc(c, kb, FacingCouples)
    end
    @test 1 == counting() do c
        askc(c, kb, BackToBackCouples)
    end
    @test 2 == counting() do c
        askc(c, kb, TandemCouples)
    end
    f = collecting() do c
        askc(c, kb, CompletedDoublePassThru)
    end
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

