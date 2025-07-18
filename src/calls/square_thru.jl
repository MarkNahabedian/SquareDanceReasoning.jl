
export SquareThru

"""
    SquareThru(; role, handedness, count)

CallerLab Basic 1 square dance call.

Timing: count=1: 2, count=2: 5, count=3: 7 or 8, count=4: 10.
"""
@with_kw_noshow struct SquareThru <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()
    count::Int = 4
end

as_text(c::SquareThru) = (as_text(c.role) * " " *
    (c.handedness == LeftHanded() ? "left " : "") *
    "square thru $(c.count)")

note_call_text(SquareThru())
note_call_text(SquareThru(OriginalHeads(), RightHanded(), 3))
note_call_text(SquareThru(OriginalHeads(), LeftHanded(), 2))

can_do_from(::SquareThru, ::FacingCouples) = 1

can_do_from(call::SquareThru, wave::WaveOfFour) =
    call.handedness == handedness(wave) ? 1 : 0

function expand_parts(call::SquareThru, f::FacingCouples, sc::ScheduledCall)
    @assert call == sc.call
    @assert call.count > 0
    start = sc.when
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    if call.count == 1
        return [
            ScheduledCall(start + 0, PullBy(role = dd,
                                            handedness = call.handedness))
        ]
    else
        return [
            ScheduledCall(start + 0, PullBy(role = dd,
                                            handedness = call.handedness)),
            ScheduledCall(start + 2, QuarterIn(role = dd)),
            ScheduledCall(start + 4, SquareThru(role = dd,
                                                handedness = opposite(call.handedness),
                                                count = call.count - 1
                                                ))
        ]
    end
end

function expand_parts(call::SquareThru, f::WaveOfFour, sc::ScheduledCall)
    @assert call == sc.call
    @assert call.count > 0
    @assert call.handedness == handedness(f)
    start = sc.when
    dancers = map(ds -> ds.dancer, dancer_states(f))
    if call.count == 1
        return [
            ScheduledCall(start + 0, StepThru(role = DesignatedDancers(dancers)))
        ]
    else
        return [
            ScheduledCall(start + 0, StepThru(role = DesignatedDancers(dancers),
                                              handedness = call.handedness)),
            ScheduledCall(start + 1, QuarterIn(role = DesignatedDancers(dancers))),
            ScheduledCall(start + 3, SquareThru(role = DesignatedDancers(dancers),
                                                handedness = opposite(call.handedness),
                                                count = call.count - 1))
        ]
    end    
end

