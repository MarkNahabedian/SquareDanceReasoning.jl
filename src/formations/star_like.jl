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

@resumable function(f::Star)()
    for ds in f.mw1()
        @yield ds
    end
    for ds in f.mw2()
        @yield ds
    end
end

handedness(f::Star) = handedness(f.mw1)

those_with_role(f::Star, role::Union{Beaus, Belles}) =
    [ those_with_role(f.mw1, role)...,
      those_with_role(f.mw2, role)...
      ]

@rule SquareDanceFormationRule.StarRule(mw1::MiniWave, mw2::MiniWave, ::Star,
                                        ::FormationContainedIn) begin
    if mw1 == mw2
        return
    end
    if mw1.a.direction > mw2.a.direction
        return
    end
    if handedness(mw1) != handedness(mw2)
        return
    end
    if distance(center(mw1), center(mw2)) > COUPLE_DISTANCE/4
        return
    end
    if mw1.a.direction + DIRECTION1 == mw2.a.direction
        star = Star(mw1, mw2)
        emit(star)
        emit(FormationContainedIn(mw1, star))
        emit(FormationContainedIn(mw2, star))
    end
end

@doc """
StarRule is the rule for recognizing right or left handed stars.
""" StarRule

