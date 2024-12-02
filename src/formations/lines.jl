
export LineOfFour, TwoFacedLine
export LineOfFourRule, TwoFacedLineRule


"""
LineOfFour represents a line of four dancerrs all facing
in the same direction.
"""
struct LineOfFour <: OneByFourFormation
    a::Couple
    b::Couple
    centers::Couple
end

@resumable function(f::LineOfFour)()
    for ds in f.a()
        @yield ds
    end
    for ds in f.b()
        @yield ds
    end
end

handedness(::LineOfFour) = NoHandedness()

direction(f::LineOfFour) = direction(f.a)


"""
TwoFacedLine represents a two faced line formation.
"""
struct TwoFacedLine <: OneByFourFormation
    a::Couple
    b::Couple
    centers::MiniWave
end

@resumable function(f::TwoFacedLine)()
    for ds in f.a()
        @yield ds
    end
    for ds in f.b()
        @yield ds
    end
end

handedness(f::TwoFacedLine) = handedness(f.centers)


@rule SquareDanceFormationRule.LineOfFourRule(a::Couple,
                                              b::Couple,
                                              centers::Couple,
                                              ::LineOfFour,
                                              ::FormationContainedIn) begin
    if direction(a) != direction(b)
        return
    end
    if direction(a) != direction(centers)
        return
    end
    if centers.beau != b.belle
        return
    end
    if centers.belle != a.beau
        return
    end
    l = LineOfFour(a, b, centers)
    emit(l)
    emit(FormationContainedIn(a, l))
    emit(FormationContainedIn(b, l))
end

@doc """
LineOfFourRule is the rule for iderntifying a [`LineOfFour`](@ref)
formation.
""" LineOfFourRule


@rule SquareDanceFormationRule.TwoFacedLineRule(a::Couple,
                                                b::Couple,
                                                centers::MiniWave,
                                                ::TwoFacedLine,
                                                ::FormationContainedIn) begin
    if direction(a) != opposite(direction(b))
        return
    end
    if handedness(centers) == RightHanded()
        #  ↑↑↓↓
        center_dancer_field = :belle
    else
        #  ↓↓↑↑
        @assert handedness(centers) == LeftHanded()
        center_dancer_field = :beau
    end
    # We arbitrarily decide that the `centers.a` field of the
    # TwoFacedLine should be in the 'a' couple, and `centers.b` should
    # be in the `b` couple.
    if centers.a != getfield(a, center_dancer_field)
        return
    end
    if centers.b != getfield(b, center_dancer_field)
        return
    end
    l = TwoFacedLine(a, b, centers)
    emit(l)
    emit(FormationContainedIn(a, l))
    emit(FormationContainedIn(b, l))
end

@doc """
TwoFacedLineRule is the rule for identifying [`TwoFacedLine`](@ref)
formations.
""" TwoFacedLineRule
