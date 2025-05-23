
@testset "Squared Set" begin
    square = make_square(4)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    for ds in square_up(square)
        receive(kb, ds)
    end
    @debug_formations(kb)
    @test 4 == askc(Counter(), kb, Couple)
    @test 4 == askc(Counter(), kb, FaceToFace)
    @test 1 == askc(Counter(), kb, SquaredSet)
    @test 1 == askc(Counter(), kb, CircleOfEight)
    f = only(askc(Collector{SquaredSet}(), kb, SquaredSet))
    @test Set(those_with_role(f, kb, OriginalHeads())) ==
        Set(those_with_role(f, kb, CurrentHeads()))
    @test Set(those_with_role(f, kb, OriginalSides())) ==
        Set(those_with_role(f, kb, CurrentSides()))
    @test all(ds -> ds.dancer.gender isa Guy,
              those_with_role(f, kb, Guys()))
    @test all(ds -> ds.dancer.gender isa Gal,
              those_with_role(f, kb, Gals()))
    @test askc(Counter(), kb, FormationContainedIn) == 34
    collect_formation_examples(kb)
end

@testset "Squared Set with joker" begin
    square = make_square(4)
    joker = DancerState(Dancer(5, Unspecified()), 0, 0, 0, 0)
    kb = make_kb()
    receive(kb, square)
    receive(kb, joker.dancer)
    receive(kb, joker)
    for ds in square_up(square)
        receive(kb, ds)
    end
    @debug_formations(kb)
    @test 4 == askc(Counter(), kb, Couple)
    @test 0 == askc(Counter(), kb, FaceToFace)
    @test 0 == askc(Counter(), kb, SquaredSet)
    @test 1 == askc(Counter(), kb, CircleOfEight)
end

