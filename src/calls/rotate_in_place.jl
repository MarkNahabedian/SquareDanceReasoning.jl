export Rest, UTurnBack, AndRoll

# QuarterRight, QuarterLeft aren't on a CallerLab list, but maybe we
# want them anyway.

# QuarterIn and QuarterOut are Advanced1


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

function perform(c::UTurnBack, ds::DancerState)
    # Taminations says that the timing is 2.
    # Use the roll direction if the dancer has one:
    r = can_roll(ds)
    if r == 0
        # Turn towards the center of the set
        r = 1//4 * sign(direction(ds, center(everyone)))
    else
        r = 1//4 * sign(r)
    end
    rotate(rotate(ds, r, 1), r, 1)
end

function perform(::UTurnBack, c::Couple)
    Couple(rotate(rotate(c.beau, -1//4, 1), -1//4, 1),
           rotate(rotate(c.belle, 1//4, 1), 1//4, 1))
end

function perform(::UTurnBack, f::MiniWave)
    mwtype = if handedness(f) == RightHanded
        LHMiniWave
    else
        RHMiniWave
    end
    function r(ds1::DancerState, ds2::DancerState)
        d = direction(ds1, ds2)
        rotate(ds1, 2 * d, 2)
    end
    mwtype(r(f.a), r(f.b))
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

function perform(r::AndRoll, ds::DancerState)
    # Taminations says that the timing for And Roll is 2.
    r = can_roll(ds)
    if r == 0
        ds
    else
        rotate(ds, 1//4 * sign(r), 2)
    end
end

