
export LineOfFour, TwoFacedLine, LineOfFourRule

struct LineOfFour <: FourDancerFormation
    a::Couple
    b::Couple
    centers::Couple
end

dancer_states(f::LineOfFour) = [ dancer_states(f.a)...,
                                 dancer_states(f.b)... ]

handedness(::LineOfFour) = NoHandedness()

struct TwoFacedLine <: FourDancerFormation
    a::Couple
    b::Couple
    centers::MiniWave
end

dancer_states(f::TwoFacedLine) = [ dancer_states(f.a)...,
                                   dancer_states(f.b)... ]

handedness(f::TwoFacedLine) = handedness(f.centers)


@rule SquareDanceFormationRule.LineOfFourRule(a::Couple, b::Couple,
                                              centers::Couple,
                                              ::LineOfFour) begin
    if !direction_equal(a.beau.direction, b.beau.direction)
        return
    end
    if !direction_equal(a.beau.direction, centers.beau.direction)
        return
    end
    if centers.beau != b.belle
        return
    end
    if centers.belle != a.beau
        return
    end
    emit(LineOfFour(a, b, centers))
end


@rule SquareDanceFormationRule.TwoFacedLineRume(a::Couple, b::Couple,
                                                centers::MiniWave,
                                                ::TwoFacedLine) begin
    if !direction_equal(a.beau.direction,
                        opposite(b.beau.direction))
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
    emit(TwoFacedLine(a, b, centers))
end

