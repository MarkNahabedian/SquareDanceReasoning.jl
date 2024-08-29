
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

can_do_from(::SquareThru, ::FacingCouples) = 1

can_do_from(call::SquareThru, wave::WaveOfFour) =
    call.handedness == handedness(wave) ? 1 : 0

function expand_parts(call::SquareThru, f::FacingCouples)
    @assert call.count > 0
    dd = DesignatedDancers(map(ds -> ds.dancer, dancer_states(f)))
    if call.count == 1
        return [
            (0, PullBy(role = dd,
                       handedness = call.handedness))
        ]
    else
        return [
            (0, PullBy(role = dd,
                       handedness = call.handedness)),
            (2, QuarterIn(role = dd)),
            (4, SquareThru(role = dd,
                           handedness = opposite(call.handedness),
                           count = call.count - 1
                           ))
        ]
    end
end

function expand_parts(call::SquareThru, f::WaveOfFour)
    @assert call.handedness == handedness(f)
    @assert call.count > 0
    dancers = map(ds -> ds.dancer, dancer_states(f))
    if call.count == 1
        return [
            (0, StepThru(role = DesignatedDancers(dancers)))
        ]
    else
        return [
            (0, StepThru(role = DesignatedDancers(dancers),
                         handedness = call.handedness)),
            (1, QuarterIn(role = DesignatedDancers(dancers))),
            (3, SquareThru(role = DesignatedDancers(dancers),
                           handedness = opposite(call.handedness),
                           count = call.count - 1))
        ]
    end    
end

