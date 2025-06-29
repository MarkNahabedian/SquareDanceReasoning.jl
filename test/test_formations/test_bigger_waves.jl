
@testset "test right hand wave of four" begin
    square = make_square(2)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    receive.([kb], grid_arrangement(square, [ 1 2 3 4 ],
                                    [ "↑↓↑↓" ]))
    @debug_formations(kb)
    # First make sure we have the MiniWaves:
    @test askc(Counter(), kb, RHMiniWave) == 2
    @test askc(Counter(), kb, LHMiniWave) == 1
    @test askc(Counter(), kb, MiniWave) == 3
    let
        waves = askc(Collector{RHWaveOfFour}(), kb)
        @test length(waves) == 1
        f = first(waves)
        @test length(dancer_states(f)) == 4
        @test handedness(f) == RightHanded()
        @test f.wave1.a.dancer == square[2]
        @test f.wave1.b.dancer == square[1]
        @test f.wave2.a.dancer == square[4]
        @test f.wave2.b.dancer == square[3]
        @test Set(dancer.(those_with_role(f, kb, Centers()))) ==
            Set([square[2], square[3]])
        @test Set(dancer.(those_with_role(f, kb, Ends()))) ==
            Set([square[1], square[4]])
    end
    @test askc(Counter(), kb, FormationContainedIn) == 15
    collect_formation_examples(kb)
end

@testset "test left hand wave of four" begin
    square = make_square(2)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    receive.([kb], grid_arrangement(square, [ 1 2 3 4],
                                    [ "↓↑↓↑" ]))
    @debug_formations(kb)
    # First make sure we have the MiniWaves:
    @test askc(Counter(), kb, RHMiniWave) == 1
    @test askc(Counter(), kb, LHMiniWave) == 2
    let
        waves = askc(Collector{LHWaveOfFour}(), kb, LHWaveOfFour)
        @test length(waves) == 1
        f = waves[1]
        @test length(dancer_states(f)) == 4
        @test handedness(f) == LeftHanded()
        @test f.wave1.a.dancer == square[3]
        @test f.wave1.b.dancer == square[4]
        @test f.wave2.a.dancer == square[1]
        @test f.wave2.b.dancer == square[2]
        @test Set(dancer.(those_with_role(f, kb, Centers()))) ==
            Set([square[2], square[3]])
        @test Set(dancer.(those_with_role(f, kb, Ends()))) ==
            Set([square[1], square[4]])
    end
    @test askc(Counter(), kb, FormationContainedIn) == 15
    collect_formation_examples(kb)
end

@testset "test right hand wave of eight" begin
    square = make_square(4)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    receive.([kb], grid_arrangement(square, [ 1 2 3 4 5 6 7 8 ],
                                    [ "↑↓↑↓↑↓↑↓" ]))
    @debug_formations(kb)
    # First make sure we have the MiniWaves:
    @test askc(Counter(), kb, RHMiniWave) == 4
    @test askc(Counter(), kb, LHMiniWave) == 3
    # and the waves of four:
    @test askc(Counter(), kb, RHWaveOfFour) == 3
    @test askc(Counter(), kb, LHWaveOfFour) == 2
    let
        waves = askc(Collector{RHWaveOfEight}(), kb, RHWaveOfEight)
        @test length(waves) == 1
        f = first(waves)
        push!(TEST_EXAMPLE_FORMATIONS, f)
        @test handedness(f) == RightHanded()
        @test f.wave1.wave1.a.dancer == square[2]
        @test f.wave1.wave1.b.dancer == square[1]
        @test f.wave1.wave2.a.dancer == square[4]
        @test f.wave1.wave2.b.dancer == square[3]
        @test f.wave2.wave1.a.dancer == square[6]
        @test f.wave2.wave1.b.dancer == square[5]
        @test f.wave2.wave2.a.dancer == square[8]
        @test f.wave2.wave2.b.dancer == square[7]
        @test Set(dancer.(those_with_role(f, kb, VeryCenters()))) ==
            Set([square[4], square[5]])
        @test Set(dancer.(those_with_role(f, kb, Centers()))) ==
            Set([square[2], square[3], square[6], square[7]])
        @test Set(dancer.(those_with_role(f, kb, Ends()))) ==
            Set([square[1], square[4], square[5], square[8]])
    end
    @test askc(Counter(), kb, FormationContainedIn) == 54
    collect_formation_examples(kb)
end

