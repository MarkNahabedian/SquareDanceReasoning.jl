# Stars and diamonds.

export Star, Diamond, StarRule, DiamondRule


"""
    Star

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

# Might we some day consider facing stars?
handedness(f::Star) = handedness(f.mw1)

those_with_role(f::Star, role::Union{Beaus, Belles}) =
    [ those_with_role(f.mw1, role)...,
      those_with_role(f.mw2, role)...
      ]


@rule SquareDanceFormationRule.StarRule(mw1::MiniWave, mw2::MiniWave,
                                        ::Star, ::FormationContainedIn) begin
    @rejectif mw1 == mw2
    @rejectif mw1.a.direction > mw2.a.direction
    @rejectif  handedness(mw1) != handedness(mw2)
    @continueif mw1.a.direction + DIRECTION1 == mw2.a.direction
    # overlap test:
    @continueif distance(center(mw1), center(mw2)) < COUPLE_DISTANCE/4
    d1 = distance(mw1.a, mw1.b)
    d2 = distance(mw2.a, mw2.b)
    @continueif abs(d1 - d2) <= 0.1 * COUPLE_DISTANCE
    star = Star(mw1, mw2)
    emit(star)
    emit(FormationContainedIn(mw1, star))
    emit(FormationContainedIn(mw2, star))
end
@doc """
StarRule is the rule for recognizing right or left handed stars.
""" StarRule


"""
    Diamond

`Diamond`s are like [`star`](@ref)s, except that one of the
`MiniWave`s is further apart.
"""
struct Diamond <: FourDancerFormation
    centers::MiniWave
    points::_MaybeDiamondPoints
end

@resumable function(f::Diamond)()
    for ds in f.centers()
        @yield ds
    end
    for ds in f.points()
        @yield ds
    end
end

handedness(f::Diamond) = handedness(f.centers)

those_with_role(f::Diamond, role::Union{Beaus, Belles}) =
    [ those_with_role(f.centers, role)...,
      those_with_role(f.points, role)...
      ]

those_with_role(f::Diamond, role::Centers) = dancer_states(f.centers)
those_with_role(f::Diamond, role::Points) = dancer_states(f.points)


@rule SquareDanceFormationRule.DiamondRule(centers::MiniWave, points::_MaybeDiamondPoints,
                                           ::Diamond, ::FormationContainedIn) begin
    # concentric:
    @continueif distance(center(centers), center(points)) < COUPLE_DISTANCE/4
    # clocking:
    @continueif abs(centers.a.direction - points.a.direction) == FULL_CIRCLE//4
    diamond = Diamond(centers, points)
    emit(diamond)
    emit(FormationContainedIn(centers, diamond))
    emit(FormationContainedIn(points, diamond))
end

@doc """
    DiamondRule

DiamondRule is a rule for identifying diamond formations.
""" DiamondRule

