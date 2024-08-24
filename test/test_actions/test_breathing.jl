
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
        # Attendance will have already been concluded from SDSquare.
        if t <: Attendance
            @test count == 1
            @test counts2[t] == 1
        elseif t <: TemporalFact
            @test counts2[t] == 0
        else
            @test counts2[t] == count
        end
    end
    # We now want DancerStates that require breathing:
    playmates = Vector{TwoDancerFormation}()
    mws = RHMiniWave[]
    askc(kb, FaceToFace) do f
        mw = step_to_a_wave(f, 1, RightHanded())
        push!(mws, mw)
        dss = dancer_states(mw)
        @assert length(dss) == 2
        push!(playmates, mw)
        receive.([kb2], dss)
    end
    @debug_formations(kb2)
    collisions = askc(Collector{Collision}(), kb2, Collision)
    @test 3 == length(collisions)
    new_dss = breathe(collisions,
                      playmates,
                      askc(Collector{DancerState}(), kb2, DancerState))
    updated_mws = sort!(update_from(mws, new_dss);
                        by = mw -> mw.a.dancer)
    kb3 = make_kb(kb2)
    receive.([kb3], new_dss)
    @test 0 == askc(Counter(), kb3, Collision)
    @test updated_mws ==sort!(askc(Collector{RHMiniWave}(), kb3, RHMiniWave);
                              by = mw -> mw.a.dancer)
    @debug_formations(kb3)    
end

