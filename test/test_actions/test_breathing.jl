
using SquareDanceReasoning: Respirator, current_location, move,
    collisions, motion_for_collision, apply_motion,
    resultingDancerStates


@testset "test breathing for tight step to a wave" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        # We construct 4 DancerStates as two MiniWaves with their centers
        # slightly beyond overlapping so that they will need to be moved a
        # bit more than if they were on the same spot.
        DOWN = 0
        LEFT1 = COUPLE_DISTANCE * 1//16
        # Set up as if FacingCouples just stepped to a wave but breathing
        # hasn't happened yet.
        ds1f = DancerState(Dancer(1, Gal()), 0, 0, DOWN, LEFT1)
        ds2m = DancerState(Dancer(2, Guy()), 0, 1//2, DOWN,
                           ds1f.left + COUPLE_DISTANCE)
        ds2f = DancerState(Dancer(2, Gal()), 0, 1//2, DOWN, - LEFT1)
        ds1m = DancerState(Dancer(1, Guy()), 0, 0, DOWN,
                           ds2f.left - COUPLE_DISTANCE)
        playmates = [ RHMiniWave(ds1m, ds2f),
                      RHMiniWave(ds1f, ds2m) ]
        everyone = [ ds1m, ds1f, ds2m, ds2f ]
        @debug_formations(everyone)
        # Check initial dancer ordering:
        map(ds -> ds.dancer, sort(everyone; by = ds -> ds.left)) ==
            [ Dancer(1, Guy()),
              Dancer(2, Gal()),
              Dancer(1, Gal()),
              Dancer(2, Guy()) ]
        everyone2 = sort(breathe(playmates, everyone); by = dancer)
        (ds1m, ds1f, ds2m, ds2f) = everyone2
        @debug_formations(everyone2)
        # dancer states devectored correctly:
        @test ds1m.dancer == Dancer(1, Guy())
        @test ds1f.dancer == Dancer(1, Gal())
        @test ds2m.dancer == Dancer(2, Guy())
        @test ds2f.dancer == Dancer(2, Gal())
        playmates = map(playmates) do pm
            update_from(pm, everyone2)
        end
        # Playmates moved the same amounts:
        for pm in playmates
            deltas = map(ds -> location(ds) - location(ds.previous),
                         pm())
            @test deltas[1] == deltas[2]
        end
        # Dancer left ordering:
        everyone2 = sort(everyone2; by = ds -> ds.left)
        # Resulting locations:
        @test all(ds -> ds.down == DOWN, everyone2)
        @test map(ds -> ds.left, everyone2) == [ -1.5, -0.5, 0.5, 1.5 ]
        @test map(dancer, everyone2) ==
            [ Dancer(1, Guy()),
              Dancer(2, Gal()),
              Dancer(1, Gal()),
              Dancer(2, Guy()) ]
    end
end

@testset "test breathing for tight step to a wave, off center" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        # Set up as if FacingCouples just stepped to a wave but breathing
        # hasn't happened yet.
        DOWN = 0
        HALF = COUPLE_DISTANCE / 2
        LEFT1 = COUPLE_DISTANCE * 1//16
        # Set up as if FacingCouples just stepped to a wave but breathing
        # hasn't happened yet.
        ds1f = DancerState(Dancer(1, Gal()), 0, 0, DOWN, LEFT1)
        ds2m = DancerState(Dancer(2, Guy()), 0, 1//2, DOWN,
                           ds1f.left + COUPLE_DISTANCE)
        ds2f = DancerState(Dancer(2, Gal()), 0, 1//2, DOWN, - LEFT1)
        ds1m = DancerState(Dancer(1, Guy()), 0, 0, DOWN,
                           ds2f.left - COUPLE_DISTANCE)
        playmates = [ RHMiniWave(ds1m, ds2f),
                      RHMiniWave(ds1f, ds2m) ]
        # Add a non-participating 3rd couple at one end:
        ds3m = DancerState(Dancer(3, Guy()), 0, 3//4,
                           DOWN + HALF,
                           3 * COUPLE_DISTANCE)
        ds3f = DancerState(Dancer(3, Gal()), 0, 3//4,
                           DOWN - HALF,
                           3 * COUPLE_DISTANCE)
        everyone = [ ds1m, ds1f, ds2m, ds2f, ds3m, ds3f ]
        @debug_formations(everyone)
        playmates = [ RHMiniWave(ds1m, ds2f),
                      RHMiniWave(ds1f, ds2m),
                      Couple(ds3m, ds3f) ]
        everyone2 = sort(breathe(playmates, everyone); by = dancer)
        (ds1m, ds1f, ds2m, ds2f, ds3m, ds3f) = everyone2
        @debug_formations(everyone2)
        @test ds1m.dancer == Dancer(1, Guy())
        @test ds1f.dancer == Dancer(1, Gal())
        @test ds2m.dancer == Dancer(2, Guy())
        @test ds2f.dancer == Dancer(2, Gal())
        @test ds3m.dancer == Dancer(3, Guy())
        @test ds3f.dancer == Dancer(3, Gal())
        # down is unchanged:
        @test all(everyone2) do ds
            ds.down == ds.previous.down
        end
        everyone2 = sort(everyone2; by = ds -> ds.left)
        @test map(dancer, everyone2) ==
            [ Dancer(1, Guy()),
              Dancer(2, Gal()),
              Dancer(1, Gal()),
              Dancer(2, Guy()),
              Dancer(3, Guy()),
              Dancer(3, Gal()) ]
        @test ds3m.left == ds3m.previous.left
        @test ds3f.left == ds3f.previous.left
        # Dancers in wave properly separated:
        @test everyone2[2].left - everyone2[1].left == COUPLE_DISTANCE
        @test everyone2[3].left - everyone2[2].left == COUPLE_DISTANCE
        @test everyone2[4].left - everyone2[3].left == COUPLE_DISTANCE
    end
end

@testset "breathing for FacingCouples step_to_a_wave" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
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
        # Check that only the right facts are copied:
        counts2 = kb_counts(kb2)
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
        @test 3 == length(find_collisions(
            askc(Collector{DancerState}(), kb2, DancerState)))
        new_dss = breathe(playmates,
                          askc(Collector{DancerState}(), kb2, DancerState))
        updated_mws = sort!(update_from(mws, new_dss);
                            by = mw -> mw.a.dancer)
        kb3 = make_kb(kb2)
        receive.([kb3], new_dss)
        @test 0 == length(find_collisions(
            askc(Collector{DancerState}(), kb3, DancerState)))
        @test updated_mws ==sort!(askc(Collector{RHMiniWave}(), kb3, RHMiniWave);
                                  by = mw -> mw.a.dancer)
        @debug_formations(kb3)
    end
end


@testset "breathing for SquaredSet step_to_a_wave" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        square = make_square(4)
        kb = make_kb()
        receive(kb, square)
        receive.([kb], square_up(square))
        @debug_formations(kb)
        kb2 = make_kb(kb)
        # Heads step to a wave
        playmates = Vector{TwoDancerFormation}()
        mws = RHMiniWave[]
        askc(kb, FaceToFace) do f
            if all(ds -> is_original_head(ds.dancer),
                   dancer_states(f))
                mw = step_to_a_wave(f, 1, RightHanded())
                push!(mws, mw)
                dss = dancer_states(mw)
                push!(playmates, mw)
                receive.([kb2], dss)
            end
        end
        askc(kb, Couple) do f
            if all(ds -> is_original_side(ds.dancer),
                   dancer_states(f))
                push!(playmates, f)
                receive.([kb2], dancer_states(f))
            end
        end
        @debug_formations(kb2)
        # Centers of the RHWaveOfFour collide, ends of the wave collide
        # with sids Couples:
        @test 5 == length(find_collisions(
            askc(Collector{DancerState}(), kb2, DancerState)))
        new_dss = breathe(playmates,
                          askc(Collector{DancerState}(), kb2, DancerState))
        updated_mws = sort!(update_from(mws, new_dss);
                            by = mw -> mw.a.dancer)
        kb3 = make_kb(kb2)
        receive.([kb3], new_dss)
        @debug_formations(kb3)
        @test 0 == length(find_collisions(
            askc(Collector{DancerState}(), kb3, DancerState)))
        @test updated_mws ==sort!(askc(Collector{RHMiniWave}(), kb3, RHMiniWave);
                                  by = mw -> mw.a.dancer)
        @debug_formations(kb3)
    end
end

