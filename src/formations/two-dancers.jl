
export Couple, FaceToFace, BackToBack,
    Tandem, MiniWave, RHMiniWave, LHMiniWave
export TwoDancerFormationsRule


"""
    Couble(beau::DancerState, belle::DancerState)

Couple represents a formation of two dancers both
facing the same direction.
"""
struct Couple <: TwoDancerFormation
    beau::DancerState
    belle::DancerState
end

dancer_states(f::Couple)::Vector{DancerState} = [f.beau, f.belle]

handedness(::Couple) = NoHandedness()

direction(f::Couple) = direction(f.beau)


"""
FaceToFace represents a formation of two dancers facing each other.
"""
struct FaceToFace <: TwoDancerFormation
    a::DancerState
    b::DancerState
end

dancer_states(f::FaceToFace)::Vector{DancerState} = [f.a, f.b]

handedness(::FaceToFace) = NoHandedness()


"""
BackToBack represents a formation of two dancers with their backs
facing each other.
"""
struct BackToBack <: TwoDancerFormation
    a::DancerState
    b::DancerState
end

dancer_states(f::BackToBack)::Vector{DancerState} = [f.a, f.b]

handedness(::BackToBack) = NoHandedness()


"""
    Tandem(leaderLLDancerState, trailer::DancerState)

Tandem repreents a formation of two dancers where the `trailer`
is facing the back of the `leader`.
"""
struct Tandem <: TwoDancerFormation
    leader::DancerState
    trailer::DancerState
end

dancer_states(f::Tandem)::Vector{DancerState} = [f.leader, f.trailer]

handedness(::Tandem) = NoHandedness()

direction(f::Tandem) = direction(f.leader)


"""
MiniWave is the abstract supertype for all two dancer waves.
"""
abstract type MiniWave <: TwoDancerFormation end

dancer_states(f::MiniWave)::Vector{DancerState} = [f.a, f.b]


"""
RHMiniWave represents a right handed wave of two dancers.
"""
struct RHMiniWave <: MiniWave
    a::DancerState
    b::DancerState
end

handedness(::RHMiniWave) = RightHanded()


"""
LHMiniWave represents a left handed wave of two dancers.
"""
struct LHMiniWave <: MiniWave
    a::DancerState
    b::DancerState
end

handedness(::LHMiniWave) = LeftHanded()


@rule SquareDanceFormationRule.TwoDancerFormationsRule(kb::ReteRootNode,
                                                       sq::SDSquare,
                                                       ds1::DancerState,
                                                       ds2::DancerState,
                                                       ::Couple,
                                                       ::FaceToFace,
                                                       ::BackToBack,
                                                       ::Tandem,
                                                       ::RHMiniWave,
                                                       ::LHMiniWave) begin
    # Not the same dancer:
    if ds1.dancer == ds2.dancer
        return
    end
    # Contemporary:
    if ds1.time != ds2.time
        return
    end
    # In the same square:
    if !in(ds1, sq) || !in(ds2, sq)
        return
    end
    # Rather than using near, make sure there are no other dancers
    # between these two:
    let
        these = [ds1, ds2]
        b = bump_out(Bounds(these))
        encroaching = false
        askc(kb, DancerState) do ds
            if !(ds in these)
                if ds.time == ds1.time
                    if in_bounds(b, ds)
                        encroaching = true
                        # It would be nice to have a short-circuiting exit
                        # for askc.
                    end
                end
            end
        end
        if encroaching
            return
        end
    end
    if direction_equal(direction(ds1), direction(ds2))
        # Couple or Tandem?
        if right_of(ds1, ds2) && left_of(ds2, ds1)
            emit(Couple(ds1, ds2))
            return
        end
        if in_front_of(ds1, ds2) && behind(ds2, ds1)
            emit(Tandem(ds2, ds1))
            return
        end
    elseif direction_equal(direction(ds1), opposite(direction(ds2)))
        # FaceToFace, BackToBack or MiniWave We break symetry using
        # dancer facing direction instead of dancer order.
        if direction(ds2) < direction(ds1)
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

@doc """
TwoDancerFormationsRule is the rule for identifying all two dancer
formations: [`Couple`](@ref), [`FaceToFace`](@ref),
[`BackToBack`](@ref), [`Tandem`](@ref), [`RHMiniWave`](@ref), and
[`LHMiniWave`](@ref).
""" TwoDancerFormationsRule

