
export forward, backward, rightward, leftward, revolve, rotate,
    jitter, can_roll, step_to_a_wave, pass_by,
    CanRollAmbiguityException


function move(p::Vector, direction, distance)
    a = 2 * pi * direction
    p + distance * [ cos(a), sin(a) ]
end


"""
    forward(ds::DancerState, distance, time_delta)::DancerState

Move the `Dancer` identified by `ds` forward (based on ds.direction)
the specified distance by returning a new dancer state.
"""
function forward(ds::DancerState, distance, time_delta)::DancerState
    DancerState(ds, ds.time + time_delta,
                ds.direction,
                move(location(ds), ds.direction, distance)...)
end


"""
    backward(ds::DancerState, distance, time_delta)::DancerState

Move the `Dancer` identified by `ds` backward (based on ds.direction)
the specified distance by returning a new dancer state.
"""
function backward(ds::DancerState, distance, time_delta)
    a = 2 * pi * opposite(ds.direction)
    down = ds.down + distance * cos(a)
    left = ds.left + distance * sin(a)
    DancerState(ds, ds.time + time_delta,
                ds.direction, down, left)
end


"""
    rightward(ds::DancerState, distance, time_delta)::DancerState

Move the `Dancer` identified by `ds` to the right (based on
ds.direction) by the specified distance by returning a new dancer
state.
"""
function rightward(ds::DancerState, distance, time_delta)
    DancerState(ds, ds.time + time_delta,
                ds.direction,
                move(location(ds), quarter_right(ds.direction),
                     distance)...)
end


"""
    leftward(ds::DancerState, distance, time_delta)::DancerState

Move the `Dancer` identified by `ds` to the left (based on
ds.direction) by the specified distance by returning a new dancer
state.
"""
function leftward(ds::DancerState, distance, time_delta)
    DancerState(ds, ds.time + time_delta,
                ds.direction,
                move(location(ds), quarter_left(ds.direction),
                     distance)...)
end


"""
    revolve(ds::DancerState, center, new_direction, time_delta)::DancerState

Revolves the `Dancer` identified by `ds` around `center` (a two
element Vector of `down` and `left` coordinates) until the `Dancer`'s
new facing direction is `new_direction`.  A new `DancerState` is
returned.  `time_delta` is the duration of the revolution operation.
"""
function revolve(ds::DancerState, center,
                 new_direction, time_delta)::DancerState
    # radius from center:
    d = distance(location(ds), center)
    vStart = location(ds) - center
    thetaStart = atan(vStart[2], vStart[1])
    thetaEnd = thetaStart + 2 * pi * (new_direction - ds.direction)
    downEnd = center[1] + d * cos(thetaEnd)
    leftEnd = center[2] + d * sin(thetaEnd)
    DancerState(ds, ds.time + time_delta,
                new_direction, downEnd, leftEnd)
end


"""
    rotate(ds::DancerState, rotation, time_delta)::DancerState

Rotates the dancer idntified by the `DancerState` in place by
rotation.
"""
rotate(ds::DancerState, rotation, time_delta)::DancerState =
    revolve(ds::DancerState, location(ds),
            ds.direction + rotation, time_delta)


struct CanRollAmbiguityException <: Exception
    dancer_state::DancerState
end

function Base.showerror(io::IO, err::CanRollAmbiguityException)
    ds = err.dancer_state
    pdir = ds.previous.direction
    dir = ds.direction
    print(io, "$(typeof(err)): Can't determine roll direction "
          * "for $(ds.dancer): direction from $pdir to $dir.  "
          * "Maybe previous motion should have been done in "
          * "smaller pieces.")
end


"""
    can_roll(ds::DancerState)

Determine whether the modifier "and roll" can be applied to the
DancerState.  If the dancer can roll then `can_roll` returns a
signed rotation value.

This is not useful for "and roll as if you could".
"""
function can_roll(ds::DancerState)
    p = ds.previous
    if p == nothing
        return 0
    end
    r = ds.direction - p.direction
    if abs(r) == 1//2
          throw(CanRollAmbiguityException(ds))
    end
    # Because some functions can add zero-motion DancerStates, skip
    # over those to determine roll:
    if r == 0 && (ds.down - p.down) == 0 && (ds.left - p.left) == 0
        can_roll(p)
    else
        canonicalize_signed(r)
    end
end


"""
    jitter(ds::DancerState, time_delta)::DancerState

Adds noise to the position and facing direction of the DancerState.
This allows us to test whether our formation recognition rules are
sensitive to such noise.
"""
function jitter(ds::DancerState, time_delta)::DancerState
    displacement_direction = 2 * pi * (rand(Float32) * 0.1 - 0.05)
    displacement = 0.05 * (COUPLE_DISTANCE / 2) *
        [ cos(displacement_direction),
          sin(displacement_direction) ]
    DancerState(ds,
                ds.time + time_delta,
                ds.direction + (rand(Float32) * 0.1 - 0.05),
                ds.down + displacement[1],
                ds.left + displacement[2])
end


handward(::RightHanded) = rightward
handward(::LeftHanded) = leftward

"""
    step_to_a_wave(f::FaceToFace, time_delta, h::Handedness)::MiniWave

The face to face dancers move up to make a right or left handed
miniwave.

Breating should be done separately.
"""
function step_to_a_wave(f::FaceToFace, time_delta,
                        h::Union{RightHanded, LeftHanded})::MiniWave
    # Sometimes in the square dancer shorthand for describing calls,
    # this action is referred to as "touch".  There's already a
    # function in Base with that name though.
    d = distance(dancer_states(f)...)/2
    function move1(ds, sideways)
        to = move(move(location(ds), ds.direction, d),
                  sideways(ds.direction),
                  COUPLE_DISTANCE / 2)
        DancerState(ds, ds.time + time_delta,
                    ds.direction, to...)
    end
    if h isa RightHanded
        return RHMiniWave(move1(f.a, quarter_left),
                          move1(f.b, quarter_left))
    elseif h isa LeftHanded
        return LHMiniWave(move1(f.a, quarter_right),
                          move1(f.b, quarter_right))
    end
end


"""
    pass_by(mw::MiniWave, time_delta)::BackToBack

Dancers in a `MiniWave` pass by each other to end BackToBack.
"""
function pass_by(mw::MiniWave, time_delta)::BackToBack
    function m(ds::DancerState)
        ds1 = forward(ds, COUPLE_DISTANCE / 2, 0)
        ds2 = handward(handedness(mw))(ds1, COUPLE_DISTANCE / 2, 0)
        # Elide the intermediate motion
        DancerState(ds, ds.time + time_delta, ds.direction,
                    ds2.down, ds2.left)
    end
    BackToBack(m(mw.a), m(mw.b))
end

