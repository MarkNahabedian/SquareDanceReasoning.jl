export in_front_of, behind, left_of, right_of


"""
    in_front_of(focus::DancerState, other::DancerState)::Bool

returns true if `other` is in front of `focus`. 
"""
in_front_of(focus::DancerState, other::DancerState)::Bool =
    focus.direction == direction(focus, other)


"""
    behind(focus::DancerState, other::DancerState)::Bool

returns true if `other` is behind `focus`. 
"""
behind(focus::DancerState, other::DancerState)::Bool =
    opposite(focus.direction) == direction(focus, other)


"""
    left_of(focus::DancerState, other::DancerState)::Bool

returns true if `other` is to the left of `focus`. 
"""
left_of(focus::DancerState, other::DancerState)::Bool =
    quarter_left(focus.direction) == direction(focus, other)


"""
    right_of(focus::DancerState, other::DancerState)::Bool

returns true if `other` is to the right of `focus`. 
"""
right_of(focus::DancerState, other::DancerState)::Bool =
    quarter_right(focus.direction) == direction(focus, other)


