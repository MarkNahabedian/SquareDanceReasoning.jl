# Stars and diamonds.

export Star, StarRule


"""
Star represents four dancers holding either right or left hands
together in their center.  All are facing either clockwise or
counterclockwise.
"""
struct Star <: FourDancerFormation
    mw1::MiniWave
    mw2::MiniWave
end

dancer_states(f::Star)::Vector{DancerState} = [
    dancer_states(f.mw1)...,
    dancer_states(f.mw2)...
]

handedness(f::Star) = handedness(f.mw1)

those_with_role(f::Star, role::Union{Beau, Belle}) =
    [ those_with_role(f.mw1, role)...,
      those_with_role(f.mw2, role)...
      ]

@rule SquareDanceFormationRule.StarRule(mw1::MiniWave, mw2::MiniWave, ::Star) begin
    if mw1 == mw2
        return
    end
    if mw1.a.direction > mw2.a.direction
        return
    end
    if handedness(mw1) != handedness(mw2)
        return
    end
    if mw1.a.direction + DIRECTION1 == mw2.a.direction
        emit(Star(mw1, mw2))
    end
end

@doc """
StarRule is the rule for recognizing right or left handed stars.
""" StarRule

