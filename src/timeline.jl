
export DancerState, location, direction, square_up


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
    down
    left
end


location(ds::DancerState) = [ds.down ds.left]
direction(ds::DancerState) = ds.direction


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

