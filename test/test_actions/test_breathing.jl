
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
    playmates = Vector{TwoDancerFormation}()
    askc(kb, FaceToFace) do f
        mw = step_to_a_wave(f, 1, RightHanded())
        dss = dancer_states(mw)
        @assert length(dss) == 2
        push!(playmates, mw)
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

