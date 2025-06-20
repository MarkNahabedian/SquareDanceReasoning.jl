export polar_arrangement, facing_center, right_hand_in, left_hand_in

"""
    polar_arrangement(dancers, center, radius, phase_angle, facing_direction)

Arranges `dancers` in a circle around `center` (a two element vector
of down and left) with the specified `radius`.  Returns a Vector of
`DaqncerState`s.

Like all angles in this package, `phase_angle` ranges from 0 to 1
counterclockwise, with 1 being a full circle.  If `phase_angle` is 0,
The first dancer is placed `radius` distance `down` from `center`.
That dancer would be facing the center if their facing direction is 1/2.

`facing_direction` takes a `Dancer` and the placement angle of that
dancer (angle of the vector from center to dancer) and returns the
facing direction for that dancer.  See [`facing_center`](@ref),
[`right_hand_in`](@ref), and [`left_hand_in`](@ref) for examples.
"""
function polar_arrangement(dancers::Vector{Dancer}, center,
                           radius, phase_angle,
                           facing_direction)
    points = polar_arrangement(length(dancers), center, radius, phase_angle)
    map(dancers, points) do dancer, (theta, down, left)
        DancerState(dancer, 0, facing_direction(dancer, theta), down, left)
    end
end


"""
    polar_arrangement(count, center, radius, phase_angle)

Computtes `count` points in a circle around `center` (a two element
vector of down and left) with the specified `radius`.  Returns a
`Vector` of `count` `Vector`s of direction from center point, down and
left.

Like all angles in this package, `phase_angle` ranges from 0 to 1
counterclockwise, with 1 being a full circle.  If `phase_angle` is 0,
The first point is placed `radius` distance `up` from `center`.

`radius` can either be a number or a function of an *index* in the
range of `1::count`.  This function should return the radius.  This is
useful when the resulting points need to have different radii.
"""
function polar_arrangement(count, center, radius, phase_angle)
    delta_theta = 1 // count
    map(0:(count - 1)) do i
        theta = i * delta_theta + phase_angle
        r = if radius isa Function
            radius(i)
        else
            radius
        end
        return [ theta, (center + r * unit_vector(theta))... ]
    end
end


"""
    facing_center(::Dancer, theta)

Used in conjunstion with [`polar_arrangement`](@ref) to cause the
dancer to be facing inward towards the center of the circle.
"""
facing_center(::Dancer, theta) = opposite(theta)


"""
    right_hand_in(::Dancer, theta)

Used in conjunstion with [`polar_arrangement`](@ref) to cause the
dancer to be facing in promenade direction with their left shouolder
towards the center.
"""
right_hand_in(::Dancer, theta) = quarter_right(theta)


"""
    fleft_hand_in(::Dancer, theta)

Used in conjunstion with [`polar_arrangement`](@ref) to cause the
dancer to be facing in promenade direction with their left shouolder
towards the center.
"""
left_hand_in(::Dancer, theta) = quarter_left(theta)

