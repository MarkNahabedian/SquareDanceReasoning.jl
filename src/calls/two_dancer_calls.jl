export StepThru, StepToAWave, PassThru, PullBy, Dosado, Hinge, Trade

#= Some two dancer calls to implement:

HalfSashay, RollawayWithAHalfSashay
Primitive FaceYourPartner
primitive FaceYourCorner
SlideThru
StarThru expands to SlideThru
PartnerTrade
Primitive FinishPartnerTrade
Run
BoxTheGnat espands to StepToAWave, revolve around the your center -1/4, AndRoll
=#


"""
    StepThru(; role=Everyone())

CallerLab Basic 1 square dance call that goes from MiniWave to
BackToBack.

Timing: CallerLab doesn't spoecify a timing, but since the specified
timing for [`PassThru`](@ref) is 2 and `StepThro` must be smpler,
assume 1.
"""
@with_kw_noshow struct StepThru <: SquareDanceCall
    role::Role = Everyone()
end

# Should we rename PassBy to Dosado!2?

description(c::StepThru) = "$(c.role) pass by from MiniWave to BackToBack"

can_do_from(::StepThru, ::MiniWave) = 1

function perform(c::StepThru, mw::MiniWave, kb::ReteRootNode)
    pass_by(mw, 1)
end


"""
    PassThru(; role=Everyone())

CallerLab Basic 1 call.

Timing: CallerLab: 2.

`PassThru` is only proper from `FaceToFace` or from `RHMiniWave`
(because of the "Icean Wave Rule").  For `LHMiniWave`, use
[`StepThru`](@ref).
"""
@with_kw_noshow struct PassThru <: SquareDanceCall
    role::Role = Everyone()
end

can_do_from(::PassThru, ::FaceToFace) = 1

can_do_from(::PassThru, mw::RHMiniWave) = 1

#=
TODO:
Caller lab: From a Squared Set, Heads Pass Thru is proper. It ends
with the Heads back on Squared Set spots. See Squared Set Convention.

=#

function expand_parts(c::PassThru, f::FaceToFace)
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    [
        # ??? The CallerLab timing for PassThru is 2, but the timing
        # for StepToAWave is 2 and the timing for StepThru is
        # presumably greater than zero.
        (0, StepToAWave(role = dd,
                        handedness = RightHanded())),
        (2, StepThru(role = dd))
    ]
end

function expand_parts(c::PassThru, f::RHMiniWave)
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    [
        (0, StepThru(role = dd))
    ]
end


"""
    PullBy(; role=Everyone(), handedness=RightHanded())

CallerLab Basic 1 call.

Timing: CallerLab doesn't specify timing, but since the timing for
[`PassThru`](@ref) is 2, assume the same for `PullBy`.
"""
@with_kw_noshow struct PullBy <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()
end

can_do_from(c::PullBy, mw::MiniWave) =
    (c.handedness == mw.handedness) ? 1 : 0

can_do_from(::PullBy, ::FaceToFace) = 1

function expand_parts(c::PullBy, f::MiniWave)
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(mw)))
    [
        (0, StepThru(role = dd))
    ]
end

function expand_parts(c::PullBy, f::FaceToFace)
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    [
        (0, StepToAWave(role = dd,
                        handedness = c.handedness)),
        (1, StepThru(role = dd))
    ]
end


"""
    Dosado(; role=Everyone(), handedness=RightHanded())

CallerLab Basic1 call.

Timing: Callerlab: 6, unless coming from and returnuing to a squared
set, in which case 8.
"""
@with_kw_noshow struct Dosado <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()
end

can_do_from(::Dosado, ::FaceToFace) = 1

can_do_from(c::Dosado, mw::MiniWave) =
    (c.handedness == mw.handedness) ? 1 : 0    

function expand_parts(c::Dosado, f::FaceToFace)
    dancers = map(ds -> ds.dancer, dancer_states(f))
    [
        # The timing budget is at leat 6.  Where should we spread out
        # the extra time?
        (0, StepToAWave(role = DesignatedDancers(dancers),
                        handedness = c.handedness)),
        (2, StepThru(role = DesignatedDancers(dancers))),
        (3, _BackToAWave(role = DesignatedDancers(dancers),
                         handedness = opposite(c.handedness))),
        (4, _UnStepToAWave(role = DesignatedDancers(dancers)))
    ]
end

function expand_parts(c::Dosado, mw::MiniWave)
    dancers = map(ds -> ds.dancer, dancer_states(mw))
    [
        # The timing budget is at leat 6.  Where should we spread out
        # the extra time?
        (0, StepThru(role = DesignatedDancers(dancers))),
        (1, _BackToAWave(role = DesignatedDancers(dancers),
                         handedness = opposite(c.handedness))),
        (2, _UnStepToAWave(role = DesignatedDancers(dancers)))
    ]
end


"""
    Hinge(; role=Everyone(), tile=2)

CallerLab Mainstream call.

Timing: CallerLab: 2.
"""
@with_kw_noshow struct Hinge <: SquareDanceCall
    role::Role = Everyone()
    # Taminations says timing is 2, but for Trade from a MiniWave the
    # total timing is 3 rather than 4.
    time::Int = 2
end

can_do_from(::Hinge, ::MiniWave) = 1
can_do_from(::Hinge, ::Couple) = 1

function perform(c::Hinge, mw::MiniWave, kb::ReteRootNode)
    c = center(mw)
    rot = begin
        if handedness(mw) isa RightHanded
            - 1//4
        elseif handedness(mw) isa LeftHanded
            1//4
        end
    end
    r = typeof(mw)(revolve(mw.a, c, mw.a.direction + rot, 2),
                   revolve(mw.b, c, mw.b.direction + rot, 2))
    r
end

function perform(c::Hinge, couple::Couple, kb::ReteRootNode)
    c = center(couple)
    cpl = RHMiniWave(let
                         dir = couple.beau.direction - 1//4
                         (d, l) = revolve(location(couple.beau),
                                          c, -1//4,
                                          COUPLE_DISTANCE)
                         DancerState(couple.beau, couple.beau.time + 2,
                                     couple.beau.direction - 1//4,
                                     d, l)
                     end,
                     DancerState(couple.belle, couple.belle.time + 2,
                                 couple.belle.direction + 1//4,
                                 c...))
    cpl
end

