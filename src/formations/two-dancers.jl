
export TwoDancerFormation, Couple, FaceToFace, BackToBack,
    Tandem, MiniWave, RHMiniWave, LHMiniWave

abstract type TwoDancerFormation <: SquareDanceFormation end

struct Couple <: TwoDancerFormation
    beau::DancerState
    belle::DancerState
end

dancers(f::Couple) = [f.beau, f.belle]

struct FaceToFace <: TwoDancerFormation
    a::DancerState
    b::DancerState
end

dancers(f::FaceToFace) = [f.a, f.b]

struct BackToBack <: TwoDancerFormation
    a::DancerState
    b::DancerState
end

dancers(f::BackToBack) = [f.a, f.b]

struct Tandem <: TwoDancerFormation
    leader::DancerState
    trailer::DancerState
end

dancers(f::Tandem) = [f.leader, f.trader]

abstract type MiniWave <: TwoDancerFormation end

dancers(f::MiniWave) = [f.a, f.b]

struct RHMiniWave <: MiniWave
    a::DancerState
    b::DancerState
end

struct LHMiniWave <: MiniWave
    a::DancerState
    b::DancerState
end


@rule TwoDancerFormationsRule(ds1::DancerState, ds2::DancerState,                           ::Couple, ::FaceToFace, ::BackToBack, ::Tandem,
                              ::RHMiniWave, ::LHMiniWave) begin
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
