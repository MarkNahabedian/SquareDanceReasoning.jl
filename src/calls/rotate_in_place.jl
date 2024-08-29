export FaceRight, FaceLeft, UTurnBack, AndRoll

# QuarterIn and QuarterOut are Advanced1. Taminations says the timing
# is 2 beats.  We might want to have timing as a parameter though
# since they are parts of other calls, like SquareThru.


"""
    FaceRight(; role=Everyone(), time=2)

CallerLab Basic 1 square dance call causing dancers to turn 1/4 to their
right.  The timing defaults to 2 since, according to Taminations, two
beats is the duration for QuarterIn and QuarterOut.

Timing: CallerLab does not soecify timing.  Assume 1.  Can be
specified as a parameter.
"""
@with_kw_noshow struct FaceRight <: SquareDanceCall
    role::Role = Everyone()
    time::Int = 1
end

description(c::FaceRight) = "$(c.role) quarter right, $(c.time) ticks."

can_do_from(::FaceRight, ::DancerState) = 1

function perform(c::FaceRight, ds::DancerState, kb::ReteRootNode)
    rotate(ds, -1//4, c.time)
end


"""
    FaceLeft(; role=Everyone(), time=2)

CallerLab Basic 1 square dance call causing dancers to turn 1/4 to their
left.  The timing defaults to 2 since, according to Taminations, two
beats is the duration for QuarterIn and QuarterOut.

Timing: CallerLab does not soecify timing.  Assume 1.  Can be
specified as a parameter.
"""
@with_kw_noshow struct FaceLeft <: SquareDanceCall
    role::Role = Everyone()
    time::Int = 1
end

description(c::FaceLeft) = "$(c.role) quarter right, $(c.time) ticks."

can_do_from(::FaceLeft, ::DancerState) = 1

function perform(c::FaceLeft, ds::DancerState, kb::ReteRootNode)
    rotate(ds, 1//4, c.time)
end


"""
    UTurnBack(; role=Everyone())

CallerLab Basic1 call.

Timing: CallerLab: 2.
"""
@with_kw_noshow struct UTurnBack <: SquareDanceCall
    role::Role = Everyone()
end

description(c::UTurnBack) = "$(c.role) U Turn Back"

can_do_from(::UTurnBack, ::Couple) = 2
can_do_from(::UTurnBack, ::MiniWave) = 2
can_do_from(::UTurnBack, ::DancerState) = 1

function uturnback1(ds::DancerState, turn_toward::Vector{<:Real})
    # For UTurnBack, if a dancer already has rotational flow then he
    # should continue turning in that direction, otherwise he should
    # turn towards his partner or the center of the set (if they have
    # no partner).  This function performs UTurnBack for one dancer in
    # the appropriate direction.
    rotational_flow = sign(can_roll(ds))
    if rotational_flow != 0
        r = rotational_flow * 1//4
        return rotate(rotate(ds, r, 1), r, 1)
    end
    d = canonicalize_signed(direction(ds, turn_toward)
                            - ds.direction)
    if d == 0 || d == 1//2
        # The dancer turns 180 degrees in a single step so there is no
        # hint to AndRoll about which wat to ruen.
        return rotate(ds, 1//2, 2)
    else
        r = sign(d) * 1//4
        return rotate(rotate(ds, r, 1), r, 1)
    end
end

function perform(c::UTurnBack, ds::DancerState, kb::ReteRootNode)
    # If we knew the rotational flow here we could avoid the askc in
    # most cases.
    everyone = askc(Collector{DancerState}(), kb, DancerState)
    uturnback1(ds, center(everyone))
end

function perform(::UTurnBack, f::Couple, kb::ReteRootNode)
    ctr = center(dancer_states(f))
    Couple(uturnback1(f.belle, ctr),
           uturnback1(f.beau, ctr))
end

function perform(::UTurnBack, f::MiniWave, kb::ReteRootNode)
    mwtype = if handedness(f) == RightHanded
        LHMiniWave
    else
        RHMiniWave
    end
    ctr = center(dancer_states(f))
    mwtype(uturnback1(f.b, ctr),
           uturnback1(f.a, ctr))
end


"""
    AndRoll(; role=EveryOne())

CallerLab Plus call.

Timing: CallerLab: 2.
"""
@with_kw_noshow struct AndRoll <: SquareDanceCall
    role::Role = Everyone()
    # maybe eventually add "as if you could" flag
end

description(c::AndRoll) = "$(c.role) roll"

can_do_from(::AndRoll, ds::DancerState) =
    # This would require a try/catch guard in or above
    # get_call_options, which doesn't expect can_do_from to throw an
    # exception.
    # can_roll(ds) == 0 ? 0 : 1
    1

function perform(r::AndRoll, ds::DancerState, kb::ReteRootNode)
    # Taminations says that the timing for And Roll is 2.
    try
        r = sign(can_roll(ds))
    catch e
        if e isa CanRollAmbiguityException
            # Don't roll, just warn:
            @warn e
            return DancerState(ds, ds.time + 2, ds.direction,
                               ds.down, ds.left)
        else
            rethrow(e)
        end
    end
    # For the r == 1//2 case can_roll will have already thrown
    # CanRollAmbiguityException.
    if r == 0
        DancerState(ds, ds.time + 2, ds.direction, ds.down, ds.left)
    else
        rotate(ds, 1//4 * r, 2)
    end
end

