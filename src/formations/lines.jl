
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

 
