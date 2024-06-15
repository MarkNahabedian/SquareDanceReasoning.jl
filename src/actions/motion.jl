
export forward, backward, rightward, leftward, revolve, rotate,
    jitter, can_roll


"""
    forward(ds::DancerState, distance, time_delta)::DancerState

Move the `Dancer` identified by `ds` forward (based on ds.direction)
the specified distance by returning a new dancer state.
"""
function forward(ds::DancerState, distance, time_delta)::DancerState
    a = 2 * pi * ds.direction
    down = ds.down + distance * cos(a)
    left = ds.left + distance * sin(a)
    DancerState(ds, ds.time + time_delta,
                ds.direction, down, left)
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
ds.direction) to the right the specified distance by returning a new
dancer state.
"""
function rightward(ds::DancerState, distance, time_delta)
    a = 2 * pi * quarter_right(ds.direction)
    down = ds.down + distance * cos(a)
    left = ds.left + distance * sin(a)
    DancerState(ds, ds.time + time_delta,
                ds.direction, down, left)
end


"""
    leftward(ds::DancerState, distance, time_delta)::DancerState

Move the `Dancer` identified by `ds` to the left (based on
ds.direction) to the right the specified distance by returning a new
dancer state.
"""
function leftward(ds::DancerState, distance, time_delta)
    a = 2 * pi * quarter_left(ds.direction)
    down = ds.down + distance * cos(a)
    left = ds.left + distance * sin(a)
    DancerState(ds, ds.time + time_delta,
                ds.direction, down, left)
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


"""
    can_roll(ds::DancerState)

Determine whether the modifier "and roll" can be applied to the
DancerState.  If the dancer can roll then `can_roll` returns a
non-zero rotation value.

This is not useful for "and roll as if you could".
"""
function can_roll(ds::DancerState)
    p = ds.previous
    r = ds.direction - p.direction
    # Because functions like synchronize can add zero-motion
    # DancerStates, skip those over to determine roll:
    if r == 0 && (ds.down - p.down) == 0 && (ds.left - p.left) == 0
        can_roll(p)
    else
        r
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
