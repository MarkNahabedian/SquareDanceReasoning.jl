
@testset "test MoveApart" begin
    square = make_square(1)
    let
        ds = DancerState(square[1], 0, 0, 1, 2)
        mp = MoveApart([1, 2], [0, 0.5], ds)
        @test mp(ds) == [0.0, 0.5]
    end
    let
        ds = DancerState(square[1], 0, 0, 1, 2)
        mp = MoveApart([1, 2], [0, 0.5], ds)
        other = DancerState(square[1], 0, 1//2, 1, 2)
        @test mp(other) == [0.0, -0.5]
    end
    let
        ds = DancerState(square[1], 0, 0, 2, 2)
        mp = MoveApart([1, 2], [0.5, 0], ds)
        @test mp(ds) == [0.5, 0.0]
    end
    let
        ds = DancerState(square[1], 0, 0, -1, -1)
        mp = MoveApart([0, 0], [0, 0.5], ds)
        @test mp(ds) == [0.0, -0.5]
    end
end


@testset "breathing for FacingCouples step_to_a_wave" begin
    square = make_square(4)
    grid = grid_arrangement(square,
                            [ 1 3 5 7; 2 4 6 8 ],
                            [ "↓↓↓↓" ; "↑↑↑↑"])
    kb = make_kb()
    receive(kb, square)
    receive.([kb], grid)
    @debug_formations(kb)
    # A knowledge base without the temporal facts:
    kb2 = make_kb(kb)
    @test kb2.label == "SquareDanceReasoning 2"
    # Check that the right facts got copied:
    counts2 = kb_counts(kb2)
    # Check that only the right facts are copied:
    for (t, count) in kb_counts(kb)
        if t <: TemporalFact
            @test counts2[t] == 0
        else
            @test counts2[t] == count
        end
    end
    # We now want DancerStates that require breathing:
    playmates = []
    askc(kb, FaceToFace) do f
        mw = step_to_a_wave(f, 1, RightHanded())
        dss = dancer_states(mw)
        push!(playmates, dss)
        receive.([kb2], dss)
    end
    @debug_formations(kb2)
    @test 3 == askc(Counter(), kb2, Collision)
    collisions = askc(Collector{Collision}(), kb2, Collision)
    new_dss = breathe(collisions,
                      playmates,
                      askc(Collector{DancerState}(), kb2, DancerState))
    kb3 = make_kb(kb2)
    receive.([kb3], new_dss)
    @test 0 == askc(Counter(), kb3, Collision)
    @debug_formations(kb3)    
end

