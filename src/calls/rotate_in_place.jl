export UTurnBack, AndRoll

# QuarterRight, QuarterLeft aren't on a CallerLab list, but maybe we
# want them anyway, maybe as primitives.

# QuarterIn and QuarterOut are Advanced1. Taminations says the timing
# is 2 beats.  We might want to have timing as a parameter though
# since they are parts of other calls, like SquareThru.


"""
    UTurnBack()

CallerLab Basic1 call.
"""
@with_kw struct UTurnBack <: SquareDanceCall
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
    # Taminations says that the timing is 2.
    #
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
    AndRoll()

CallerLab Plus call.
"""
@with_kw struct AndRoll <: SquareDanceCall
    role::Role = Everyone()
    # maybe eventually add "as if you could" flag
end

description(c::AndRoll) = "$(c.role) roll"

can_do_from(::AndRoll, ::DancerState) = 1

function perform(r::AndRoll, ds::DancerState, kb::ReteRootNode)
    # Taminations says that the timing for And Roll is 2.
    try
        r = sign(can_roll(ds))
    catch e
        if e isa CanRollAmbiguityException
            # Don't roll, just warn:
            @warn e
            return ds
        end
    end
    if r == 0 || r == 1//2
        # ISSUE: For 1//2 the roll direction is ambiguous.  Should
        # this throw an error instead of not rolling?
        ds
    else
        rotate(ds, 1//4 * sign(r), 2)
    end
end

