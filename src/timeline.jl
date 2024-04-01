
export DancerState, location, direction, square_up
export DANCER_NEAR_DISTANCE, near, direction
export Collision, CollisionRule
export latest_dancer_states


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
                down, left) = new(dancer, time,
                                  canonicalize(direction),
                                  Float32(down), Float32(left))
end


location(ds::DancerState) = [ds.down, ds.left]
direction(ds::DancerState) = ds.direction

distance(s1::DancerState, s2::DancerState) =
    distance(location(s1), location(s2))


"""
    square_up(dancers; initial_time = 0)

returns a list of `DancerState`s for the initial squared set.
"""
function square_up(dancers::Vector{Dancer};
                   center = [0.0  0.0],
                   initial_time = 0)::Vector{DancerState}
    dancers = sort(dancers)
    circle_fraction = FULL_CIRCLE / length(dancers)
    dancer_direction(dancer) =
        (dancer.couple_number - 1) * circle_fraction * 2
    angle_from_center(i) =
        opposite((i - 1) * circle_fraction - circle_fraction / 2)
    rad(angle) = 2 * pi * angle
    function unit_vector(dancer_angle)
        a = rad(dancer_angle)
        [ cos(a) sin(a) ]
    end
    results = Vector{DancerState}()
    distance_from_center =
        (COUPLE_DISTANCE / 2) +   # additional radius to account for
                                  # the size of a dancer
        (COUPLE_DISTANCE / 2) / sin(rad(circle_fraction))
    for (i, dancer) in enumerate(dancers)
        angle = angle_from_center(i)
        direction = dancer_direction(dancer)
        push!(results,
              DancerState(dancer,
                          initial_time,
                          dancer_direction(dancer),
                          Float32.(distance_from_center *
                              unit_vector(angle))...))
    end
    results
end

square_up(square::SDSquare;  initial_time = 0) =
    square_up(collect(square.dancers); initial_time)


DANCER_NEAR_DISTANCE = 1.2 * COUPLE_DISTANCE

"""
    near(::DancerState, ::DancerState)

returns true if the two DancerStates are for different dancers and are
close enough together (within DANCER_NEAR_DISTANCE).
"""
function near(d1::DancerState, d2::DancerState)::Bool
    if d1.dancer == d2.dancer
        return false
    end
    distance(d1, d2) < DANCER_NEAR_DISTANCE
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


DANCER_COLLISION_DISTANCE = 0.8 * COUPLE_DISTANCE

struct Collision
    a::DancerState
    b::DancerState
end

dancer_states(c::Collision)::Vector{DancerState} = [c.a, c.b]

@rule SquareDanceRule.CollisionRule(a::DancerState, b::DancerState,
                                    ::Collision) begin
    if b.dancer <= a.dancer
        return
    end
    if distance(a, b) < DANCER_COLLISION_DISTANCE
        emit(Collision(a, b))
    end
end


function latest_dancer_states(root::ReteRootNode)::Dict{Dancer, DancerState}
    latest_dss = Dict{Dancer, DancerState}()
    askc(root, DancerState) do ds
        if !haskey(latest_dss, ds.dancer)
            latest_dss[ds.dancer] = ds
        end
        if latest_dss[ds.dancer].time < ds.time
            latest_dss[ds.dancer] = ds
        end
    end
    latest_dss
end

