
export DancerState, location, direction, square_up
export DANCER_HEAR_DISTANCE, near, direction


"""
    DancerState(dancer, time, down, left, direction)

represents the location and facing direction of a single
dancer at a moment in time.

`time` is a number defining a temporal ordering.  It could represent a
number of beats, for example.
"""
struct DancerState
    dancer::Dancer
    time
    direction
    down::Float32
    left::Float32

    DancerState(dancer::Dancer, time, direction,
                down, left) = new(dancer, time, direction,
                                  Float32(down), Float32(left))
end


location(ds::DancerState) = [ds.down ds.left]
direction(ds::DancerState) = ds.direction

distance(s1::DancerState, s2::DancerState) =
    distance(location(s1), location(s2))



"""
    square_up(dancers; initial_time = 0)

returns a list of `DancerState`s for the initial squared set.
"""
function square_up(dancers::Vector{Dancer};
                   center = [0.0  0.0],
                   initial_time = 0)
    dancers = sort(dancers)
    circle_fraction = FULL_CIRCLE / (length(dancers) / 2)
    rad(angle) = 2 * pi * angle
    angle_from_center(couple_number) =
        (couple_number - 1) * circle_fraction
    function unit_vector(couple_number)
        a = rad(angle_from_center(couple_number))
        [ cos(a) sin(a) ]
    end
    results = []
    distance_from_center = let
        a = rad(circle_fraction / 2)
        (COUPLE_DISTANCE / 2) * cot(a)
    end
    for dancer in dancers
        angle = angle_from_center(dancer.couple_number)
        # We assume for simplicity that dancers of Unspecifiedgender
        # don't square up.
        d = rad(angle) + (rad(angle) / 2) *
            (dancer.gender isa Guy ? -1 : 1)
        push!(results,
              DancerState(dancer,
                          initial_time,
                          opposite(angle),
                          Float32.(distance_from_center *
                              unit_vector(dancer.couple_number))...))
    end
    results
end


DANCER_HEAR_DISTANCE = 1.2 * COUPLE_DISTANCE

"""
    near(::DancerState, ::DancerState)

returns true if the two DancerStates are for different dancers and are
close enough together (within DANCER_HEAR_DISTANCE).
"""
function near(d1::DancerState, d2::DancerState)::Bool
    if d1.dancer == d2.dancer
        return false
    end
    distance(d1, d2) < DANCER_HEAR_DISTANCE
end


"""
    direction(focus::DancerState, other::DancerState)

returns the direction that `other` is from the point of view of
`focus`.
"""
function direction(focus::DancerState, other::DancerState)
    down, left = location(other) - location(focus)
    canonicalize(atan(left, down) / (2 * pi))
end


