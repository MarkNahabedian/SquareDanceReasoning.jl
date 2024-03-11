
export COUPLE_DISTANCE
export canonicalize, FULL_CIRCLE, DIRECTION0, DIRECTION1,
    DIRECTION2, DIRECTION3, direction_equal
export opposite, quarter_left, quarter_right
export distance


"""
FULL_CIRCLE represents a change in direction of 360 degrees.
"""
const FULL_CIRCLE = 1


"""
    canonicalize(direction)

canonicalizes the direction to be between 0.0 and 1.0.
"""
canonicalize(direction) = mod(direction, FULL_CIRCLE)


# Actually , these will be different if dancing hexagons.
const DIRECTION0 = 0
const DIRECTION1 = DIRECTION0 + 1 * FULL_CIRCLE // 4
const DIRECTION2 = DIRECTION0 + 2 * FULL_CIRCLE // 4
const DIRECTION3 = DIRECTION0 + 3 * FULL_CIRCLE // 4


"""
    direction_equal(direction1, direction2)::Bool =

returns true if direction1 and direction2 are roughly equal.
"""
direction_equal(direction1, direction2)::Bool =
    isapprox(canonicalize(direction1),
             canonicalize(direction2);
             atol = 0.05)


"""
    opposite(direction)

returns the direction opposite to the given one.
"""
opposite(direction) = canonicalize(direction + FULL_CIRCLE // 2)


"""
    quarter_left(direction)

returns the direction that's a quarter turn left from the given
direction.
"""
quarter_left(direction) = canonicalize(direction + FULL_CIRCLE // 4)


"""
    quarter_right(direction)

returns the direction that's a quarter turn right from the given
direction.
"""
quarter_right(direction) = canonicalize(direction - FULL_CIRCLE // 4)


"""
CoupleDistance is the distance between (the center reference points
of) two dancers standing side by side, face to face, or back to back.
"""
const COUPLE_DISTANCE::Float32 = 1.0


"""
    distance9p1, p2)

returns the distance between the two points represented by vectors.
"""
function distance(p1, p2)
    delta = p2 - p1
    sqrt(sum(x -> x^2, delta))
end

