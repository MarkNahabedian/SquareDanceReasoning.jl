
export Couple, FaceToFace, BackToBack,
    Tandem, MiniWave, RHMiniWave, LHMiniWave
export TwoDancerFormationsRule

struct Couple <: TwoDancerFormation
    beau::DancerState
    belle::DancerState
end

dancer_states(f::Couple)::Vector{DancerState} = [f.beau, f.belle]

handedness(::Couple) = NoHandedness()


struct FaceToFace <: TwoDancerFormation
    a::DancerState
    b::DancerState
end

dancer_states(f::FaceToFace)::Vector{DancerState} = [f.a, f.b]

handedness(::FaceToFace) = NoHandedness()


struct BackToBack <: TwoDancerFormation
    a::DancerState
    b::DancerState
end

dancer_states(f::BackToBack)::Vector{DancerState} = [f.a, f.b]

handedness(::BackToBack) = NoHandedness()


struct Tandem <: TwoDancerFormation
    leader::DancerState
    trailer::DancerState
end

dancer_states(f::Tandem)::Vector{DancerState} = [f.leader, f.trailer]

handedness(::Tandem) = NoHandedness()


abstract type MiniWave <: TwoDancerFormation end

dancer_states(f::MiniWave)::Vector{DancerState} = [f.a, f.b]


struct RHMiniWave <: MiniWave
    a::DancerState
    b::DancerState
end

handedness(::RHMiniWave) = RightHanded()


struct LHMiniWave <: MiniWave
    a::DancerState
    b::DancerState
end

handedness(::LHMiniWave) = LeftHanded()


@rule SquareDanceFormationRule.TwoDancerFormationsRule(ds1::DancerState,
                                                       ds2::DancerState,
                                                       ::Couple,
                                                       ::FaceToFace,
                                                       ::BackToBack,
                                                       ::Tandem,
                                                       ::RHMiniWave,
                                                       ::LHMiniWave) begin
    if ds1.dancer == ds2.dancer
        return
    end
    # Maybe we don't want to use the hear test for FaceToFace.
    if !near(ds1, ds2)
        return
    end
    if direction_equal(ds1.direction, ds2.direction)
        # Couple or Tandem?
        if right_of(ds1, ds2) && left_of(ds2, ds1)
            emit(Couple(ds1, ds2))
            return
        end
        if in_front_of(ds1, ds2) && behind(ds2, ds1)
            emit(Tandem(ds2, ds1))
            return
        end
    elseif direction_equal(ds1.direction, opposite(ds2.direction))
        # FaceToFace, BackToBack or MiniWave We break symetry using
        # dancer facing direction instead of dancer order.
        if ds2.direction < ds1.direction
            return
        end
        if in_front_of(ds1, ds2) && in_front_of(ds2, ds1)
            emit(FaceToFace(ds1, ds2))
            return
        end
        if behind(ds1, ds2) && behind(ds2, ds1)
            emit(BackToBack(ds1, ds2))
            return
        end
        if right_of(ds1, ds2) && right_of(ds2, ds1)
            emit(RHMiniWave(ds1, ds2))
            return
        end
        if left_of(ds1, ds2) && left_of(ds2, ds1)
            emit(LHMiniWave(ds1, ds2))
            return
        end
    end
end

