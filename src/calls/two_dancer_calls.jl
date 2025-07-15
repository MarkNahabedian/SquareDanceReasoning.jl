export StepThru, StepToAWave, PassThru, PullBy, Dosado, Hinge,
    PartnerHinge, Trade, _FinishTrade, SlideThru, StarThru,
    CourtesyTurn

#= Some two dancer calls to implement:

HalfSashay, RollawayWithAHalfSashay
Run
BoxTheGnat espands to StepToAWave, revolve around the your center -1/4, AndRoll
=#


"""
    StepThru(; role=Everyone())

CallerLab Basic 1 square dance call that goes from MiniWave to
BackToBack.

Timing: CallerLab doesn't spoecify a timing, but since the specified
timing for [`PassThru`](@ref) is 2 and `StepThru` must be simpler,
assume 1.
"""
@with_kw_noshow struct StepThru <: SquareDanceCall
    role::Role = Everyone()
end

# Should we rename PassBy to Dosado!2?

as_text(c::StepThru) = "$(as_text(c.role)) StepThru"

can_do_from(::StepThru, ::MiniWave) = 1

function perform(c::StepThru, mw::MiniWave, kb::SDRKnowledgeBase)
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

as_text(c::PassThru) = "$(as_text(c.role)) pass thru"

can_do_from(::PassThru, ::FaceToFace) = 1

can_do_from(::PassThru, mw::RHMiniWave) = 1

#=
TODO:
Caller lab: From a Squared Set, Heads Pass Thru is proper. It ends
with the Heads back on Squared Set spots. See Squared Set Convention.

=#

function expand_parts(c::PassThru, f::FaceToFace, sc::ScheduledCall)
    @assert c == sc.call
    start = sc.when
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    [
        # The CallerLab timing for PassThru is 2, but the timing
        # for StepToAWave is 2 and the timing for StepThru is
        # presumably greater than zero.
        ScheduledCall(start + 0, StepToAWave(role = dd,
                                             handedness = RightHanded(),
                                             time = 1)),
        ScheduledCall(start + 1, StepThru(; role = dd)),
        ScheduledCall(start + 2, _EndAt(f))
    ]
end

function expand_parts(c::PassThru, f::RHMiniWave, sc::ScheduledCall)
    @assert c == sc.call
    start = sc.when
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    [
        ScheduledCall(start + 0, StepThru(; role = dd))
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

as_text(c::PullBy) = "$(as_text(c.role)) pull by"

can_do_from(c::PullBy, mw::MiniWave) =
    (c.handedness == mw.handedness) ? 1 : 0

can_do_from(::PullBy, ::FaceToFace) = 1

function expand_parts(c::PullBy, f::MiniWave, sc::ScheduledCall)
    @assert c == sc.call
    start = sc.when
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(mw)))
    [
        ScheduledCall(start + 0, StepThru(; role = dd))
    ]
end

function expand_parts(c::PullBy, f::FaceToFace, sc::ScheduledCall)
    @assert c == sc.call
    start = sc.when
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    [
        ScheduledCall(start + 0, StepToAWave(role = dd,
                                             handedness = RightHanded(),
                                             time = 1)),
        ScheduledCall(start + 1, StepThru(; role = dd)),
        ScheduledCall(start + 2, _EndAt(f))
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

as_text(c::Dosado) = "$(as_text(c.role)) dosado"

can_do_from(::Dosado, ::FaceToFace) = 1

can_do_from(c::Dosado, mw::MiniWave) =
    (c.handedness == mw.handedness) ? 1 : 0    

function expand_parts(c::Dosado, f::FaceToFace, sc::ScheduledCall)
    @assert c == sc.call
    start = sc.when
    dancers = map(ds -> ds.dancer, dancer_states(f))
    [
        # The timing budget is at leat 6.  Where should we spread out
        # the extra time?
        ScheduledCall(start + 0, StepToAWave(role = DesignatedDancers(dancers),
                                             handedness = c.handedness)),
        ScheduledCall(start + 2, StepThru(role = DesignatedDancers(dancers))),
        ScheduledCall(start + 3, _EndAt(f)),
        ScheduledCall(start + 4, _BackToAWave(role = DesignatedDancers(dancers),
                                              handedness = opposite(c.handedness))),
        ScheduledCall(start + 5, _UnStepToAWave(role = DesignatedDancers(dancers))),
        ScheduledCall(start + 6, _EndAt(f, false))
    ]
end

function expand_parts(c::Dosado, mw::MiniWave, sc::ScheduledCall)
    @assert c == sc.call
    start = sc.when
    dancers = map(ds -> ds.dancer, dancer_states(mw))
    [
        # The timing budget is at least 6.  Where should we spread out
        # the extra time?
        ScheduledCall(start + 0, StepThru(role = DesignatedDancers(dancers))),
        ScheduledCall(start + 1, _BackToAWave(role = DesignatedDancers(dancers),
                                              handedness = opposite(c.handedness))),
        ScheduledCall(start + 2, _UnStepToAWave(role = DesignatedDancers(dancers)))
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

as_text(c::Hinge) = "$(as_text(c.role)) hinge"

can_do_from(::Hinge, ::MiniWave) = 1

function perform(call::Hinge, mw::MiniWave, kb::SDRKnowledgeBase)
    c = center(mw)
    rot = begin
        if handedness(mw) isa RightHanded
            - 1//4
        elseif handedness(mw) isa LeftHanded
            1//4
        end
    end
    r = typeof(mw)(revolve(mw.a, c, mw.a.direction + rot, call.time),
                   revolve(mw.b, c, mw.b.direction + rot, call.time))
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

as_text(c::PartnerHinge) = "$(as_text(c.role)) partner hinge"

can_do_from(::PartnerHinge, ::Couple) = 1

function perform(call::PartnerHinge, couple::Couple, kb::SDRKnowledgeBase)
    c = center(couple)
    cpl = RHMiniWave(let
                         dir = couple.beau.direction - 1//4
                         (d, l) = revolve(location(couple.beau),
                                          c, -1//4,
                                          COUPLE_DISTANCE)
                         DancerState(couple.beau, couple.beau.time + call.time,
                                     couple.beau.direction - 1//4,
                                     d, l)
                     end,
                     DancerState(couple.belle, couple.belle.time + call.time,
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
end

# What about "ends trade"?

can_do_from(::Trade, ::Couple) = 1
can_do_from(::Trade, ::MiniWave) = 1

as_text(c::Trade) = "$(as_text(c.role)) trade"

function expand_parts(c::Trade, mw::MiniWave, sc::ScheduledCall)
    @assert c == sc.call
    start = sc.when
    # Taminations says that from a MiniWave the total time for Trade
    # is 3.
    dancers = map(ds -> ds.dancer, dancer_states(mw))
    [
        ScheduledCall(start + 0, Hinge(; role=DesignatedDancers(dancers),
                                       time=1.5)),
        ScheduledCall(start + 1.5, Hinge(; role=DesignatedDancers(dancers),
                                         time=1.5)),
        ScheduledCall(start + 3, _EndAt(mw))
    ]
end

function expand_parts(c::Trade, cpl::Couple, sc::ScheduledCall)
    @assert c == sc.call
    start = sc.when
    # Taminations says that from a Couple the total time for Trade is
    # 4.
    dancers = map(ds -> ds.dancer, dancer_states(cpl))
    [
        ScheduledCall(start + 0, PartnerHinge(; role=DesignatedDancers(dancers),
                                              time=2)),
        ScheduledCall(start + 2, _FinishTrade(;
                                              original_beau=cpl.beau,
                                              original_belle=cpl.belle,
                                              time=2)),
        ScheduledCall(start + 4, _EndAt(cpl))
    ]
end


"""
    _FinishTrade(; role=Everyone, time=2)

a primitive call that represents the second half of
[`Trade`](@ref) from a `[Couple`](@ref).
"""
@with_kw_noshow struct _FinishTrade <: SquareDanceCall
    original_beau::DancerState
    original_belle::DancerState
    # Taminations says that timing for Trade from Couples is 4 and
    # timing for PartnerHinge is 2, leaving 2 for _FinishTrade.
    time = 2
end

can_do_from(::_FinishTrade, ::RHMiniWave) = 1

as_text(c::_FinishTrade) = "_FinishTrade"

restricted_to(call::_FinishTrade) =
    DesignatedDancers([ call.original_beau.dancer,
                        call.original_belle.dancer ])

function perform(c::_FinishTrade, mw::RHMiniWave, kb::SDRKnowledgeBase)
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

as_text(c::SlideThru) = "$(as_text(c.role)) slide thru"

function expand_parts(c::SlideThru, f::FaceToFace, sc::ScheduledCall)
    @assert c == sc.call
    start = sc.when
    designated_dancers = DesignatedDancers(map(ds -> ds.dancer,
                                               dancer_states(f)))
    [
        ScheduledCall(start + 0, PassThru(; role=designated_dancers)),
        ScheduledCall(start + 2, _GenderedRoll(; role=designated_dancers))
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

as_text(c::StarThru) = "$(as_text(c.role)) star thru"

can_do_from(::StarThru, f::FaceToFace) =
    if f.a.dancer.gender == opposite(f.b.dancer.gender)
        1
    else
        0
    end

function expand_parts(c::StarThru, f::FaceToFace, sc::ScheduledCall)
    @assert f.a.dancer.gender == opposite(f.b.dancer.gender)
    @assert sc.call == c
    start = sc.when
    designated_dancers = DesignatedDancers(map(ds -> ds.dancer,
                                               dancer_states(f)))
    [
        ScheduledCall(start + 0, PassThru(; role=designated_dancers)),
        ScheduledCall(start + 2, _GenderedRoll(; role=designated_dancers))
    ]
end


"""
    CourtesyTurn(; role=Everyone())

CallerLab Basic-1 call.

Timing: CallerLab: 4.
"""
@with_kw_noshow struct CourtesyTurn <: SquareDanceCall
    role::Role = Everyone()
    inactive::Union{Nothing, DancerState} = nothing
end

as_text(c::CourtesyTurn) = "$(as_text(c.role)) courtesy turn"

can_do_from(::CourtesyTurn, f::FaceToFace) = 1
can_do_from(::CourtesyTurn, f::Couple) = 1

function perform(c::CourtesyTurn, f::Couple, kb::SDRKnowledgeBase)
    # This dance action is a simplification which strays from the
    # actual definition.  We can try to fix it if we see it's a
    # problem.
    @assert c.inactive == nothing
    ctr = center(f)
    end_direction = opposite(f.beau.direction)
    # Revolving is done 1/4 turn at a time to facilitate SVG
    # animation.
    Couple(revolve(revolve(f.beau, ctr, end_direction - 1//4, 2),
                   ctr, end_direction, 2),
           revolve(revolve(f.belle, ctr, end_direction - 1//4, 2),
                   ctr, end_direction, 2))
end

function perform(c::CourtesyTurn, f::FaceToFace, kb::SDRKnowledgeBase)
    # This dance action is a simplification which strays from the
    # actual definition.  We can try to fix it if we see it's a
    # problem.
    @assert c.inactive isa DancerState
    inactive = c.inactive
    active = only(setdiff(dancer_states(f), [c.inactive]))
    end_direction = inactive.direction
    # active moves up to beside inactive while inactive turns in place
    # to face same direction as active.  Then both revolve around
    # their center pont to face end_direction.
    inactive1 = let
        half_rotation = (active.rotation - inactive.rotation) // 2
        rotate(rotate(inactive, half_rotation, 1),
               half_rotation, 1)
    end
    active1 = let
        pos = location(inactive) +
            COUPLE_DISTANCE * unit_vector(inactive.direction + 1//4)
        DancerState(active, active.time + 2, active.direction,
                    pos...)
    end
    end_direction = inactive.direction
    Couple(revolve(revolve(inactive1, ctr, end_direction - 1//4, 2),
                   ctr, end_direction, 2),
           revolve(revolve(active1, ctr, end_direction - 1//4, 2),
                   ctr, end_direction, 2))
end

