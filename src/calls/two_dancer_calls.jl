export StepThru, StepToAWave, PassThru, PullBy, Dosado,
    Hinge, PartnerHinge, Trade, SlideThru, StarThru

#= Some two dancer calls to implement:

CourtesyTurn
HalfSashay, RollawayWithAHalfSashay
Run
BoxTheGnat espands to StepToAWave, revolve around the your center -1/4, AndRoll
=#


"""
    StepThru(; role=Everyone())

CallerLab Basic 1 square dance call that goes from MiniWave to
BackToBack.

Timing: CallerLab doesn't spoecify a timing, but since the specified
timing for [`PassThru`](@ref) is 2 and `StepThro` must be simpler,
assume 1.
"""
@with_kw_noshow struct StepThru <: SquareDanceCall
    role::Role = Everyone()
end

# Should we rename PassBy to Dosado!2?

as_text(c::StepThru) = "$(as_text(c.role)) StepThru"

can_do_from(::StepThru, ::MiniWave) = 1

function perform(c::StepThru, mw::MiniWave, kb::ReteRootNode)
    pass_by(mw, 1)
end


"""
    PassThru(; role=Everyone())

CallerLab Basic 1 call.

Timing: CallerLab: 2.

`PassThru` is only proper from `FaceToFace` or from `RHMiniWave`
(because of the "Ocean Wave Rule").  For `LHMiniWave`, use
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
        # The CallerLab timing for PassThru is 2, but the timing
        # for StepToAWave is 2 and the timing for StepThru is
        # presumably greater than zero.
        (0, StepToAWave(role = dd,
                        handedness = RightHanded(),
                        time = 1)),
        (1, StepThru(; role = dd))
    ]
end

function expand_parts(c::PassThru, f::RHMiniWave)
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    [
        (0, StepThru(; role = dd))
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
        (0, StepThru(; role = dd))
    ]
end

function expand_parts(c::PullBy, f::FaceToFace)
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    [
        (0, StepToAWave(role = dd,
                        handedness = RightHanded(),
                        time = 1)),
        (1, StepThru(; role = dd))
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
        # The timing budget is at least 6.  Where should we spread out
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
    time = 2
end

can_do_from(::Hinge, ::MiniWave) = 1

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


"""
    PartnerHinge(; role=Everyone(), tile=2)

CallerLab Advanced-1 call.

Timing: CallerLab: 2.
"""
@with_kw_noshow struct PartnerHinge <: SquareDanceCall
    role::Role = Everyone()
    # Taminations says timing is 2.
    time = 2
end

can_do_from(::PartnerHinge, ::Couple) = 1

function perform(c::PartnerHinge, couple::Couple, kb::ReteRootNode)
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


"""
    Trade(; role=Everyone(), time=2)

CallerLab Basic call.

Timing: CallerLab: MiniWave: 3, Couple: 4
"""
@with_kw_noshow struct Trade <: SquareDanceCall
    role::Role = Everyone()
    # Taminations says timing is 2.
    time = 4
end

# What about "ends trade"?

can_do_from(::Trade, ::Couple) = 1
can_do_from(::Trade, ::MiniWave) = 1

function expand_parts(c::Trade, mw::MiniWave)
    dancers = map(ds -> ds.dancer, dancer_states(mw))
    [
        (0, Hinge(; role=DesignatedDancers(dancers),
                  time=1.5)),
        (1.5, Hinge(; role=DesignatedDancers(dancers),
                    time=1.5))
    ]
end

function expand_parts(c::Trade, cpl::Couple)
    dancers = map(ds -> ds.dancer, dancer_states(cpl))
    [
        (0, PartnerHinge(; role=DesignatedDancers(dancers),
                         time=2)),
        (2, _FinishTrade(;
                         original_beau= cpl.beau,
                         original_belle=cpl.belle,
                         time=2))
    ]
end


"""
    _FinishTrade(; role=Everyone, time=2)

a primitive call that represents the second half of
[`Trade`](@ref) from `[Couple`](@ref).
"""
@with_kw_noshow struct _FinishTrade <: SquareDanceCall
    original_beau::DancerState
    original_belle::DancerState
    # Taminations says that timing for Trade from Couples is 4 and
    # timing for PartnerHinge is 2, leaving 2 for _FinishTrade.
    time = 2
end

can_do_from(::_FinishTrade, ::RHMiniWave) = 1

restricted_to(call::_FinishTrade) =
    DesignatedDancers([ call.original_beau.dancer,
                        call.original_belle.dancer ])

function perform(c::_FinishTrade, mw::RHMiniWave, kb::ReteRootNode)
    beau = only(filter(dancer_states(mw)) do ds
                    ds.dancer == c.original_beau.dancer
                end)
    belle = only(filter(dancer_states(mw)) do ds
                     ds.dancer == c.original_belle.dancer
                 end)
    new_direction = c.original_beau.direction + 1//2
    Couple(
        DancerState(beau, beau.time + c.time,
                    new_direction,
                    location(c.original_belle)...),
        DancerState(belle, belle.time + c.time,
                    new_direction,
                    location(c.original_beau)...))
end


"""
    SlideThru(; role=Everyone())

CallerLab Mainstream call.

Timing: CallerLab: 4.
"""
@with_kw_noshow struct SlideThru <: SquareDanceCall
    role::Role = Everyone()
end

can_do_from(::SlideThru, ::FaceToFace) = 1

function expand_parts(c::SlideThru, f::FaceToFace)
    designated_dancers = DesignatedDancers(map(ds -> ds.dancer,
                                               dancer_states(f)))
    [
        (0, PassThru(; role=designated_dancers)),
        (2, _GenderedRoll(; role=designated_dancers))
    ]
end

"""
    StarThru(; role=Everyone())

CallerLab Basic-1 call.

Timing: CallerLab: 4.
"""
@with_kw_noshow struct StarThru <: SquareDanceCall
    role::Role = Everyone()
end

can_do_from(::StarThru, f::FaceToFace) =
    if f.a.dancer.gender == opposite(f.b.dancer.gender)
        1
    else
        0
    end

function expand_parts(c::StarThru, f::FaceToFace)
    @assert f.a.dancer.gender == opposite(f.b.dancer.gender)
    designated_dancers = DesignatedDancers(map(ds -> ds.dancer,
                                               dancer_states(f)))
    [
        (0, PassThru(; role=designated_dancers)),
        (2, _GenderedRoll(; role=designated_dancers))
    ]
end

