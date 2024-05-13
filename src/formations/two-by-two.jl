# Formations of four dancers that are two dancers wide and two high.

export FacingCouples, BackToBackCouples, TandemCouples, CoupleBoxRule


"""
FacingCouples is a formation that includes two `Couple` formations
that are facing each other.
"""
struct FacingCouples <: FourDancerFormation
    couple1::Couple
    couple2::Couple
end

dancer_states(f::FacingCouples)::Vector{DancerState} =
    [ dancer_states(f.couple1)...,
      dancer_states(f.couple2)... ]

handedness(::FacingCouples) = NoHandedness()


"""
BackToBackCouples is a formation that includes two `Couple` formations
that have their backs to each other.
"""
struct BackToBackCouples <: FourDancerFormation
    couple1::Couple
    couple2::Couple
end

dancer_states(f::BackToBackCouples)::Vector{DancerState} =
    [ dancer_states(f.couple1)...,
      dancer_states(f.couple2)... ]

handedness(::BackToBackCouples) = NoHandedness()
    

"""
TandemCouples is a formation for two Couples in Tandem.
"""
struct TandemCouples <: FourDancerFormation
    leaders::Couple
    trailers::Couple
end

dancer_states(f::TandemCouples)::Vector{DancerState} =
    [ dancer_states(f.leaders)...,
      dancer_states(f.trailers)... ]

handedness(::TandemCouples) = NoHandedness()


@rule SquareDanceFormationRule.CoupleBoxRule(couple1::Couple,
                                             couple2::Couple,
                                             ::FacingCouples,
                                             ::BackToBackCouples,
                                             ::TandemCouples) begin
    if couple1 == couple2
        return
    end
    # Symetry disambiguation
    if couple1.beau.direction > couple2.beau.direction
        return
    end
    if (direction_equal(couple1.beau.direction,
                        couple2.beau.direction) &&
                            in_front_of(couple2.beau, couple1.beau) &&
                            in_front_of(couple2.belle, couple1.belle))
        emit(TandemCouples(couple1, couple2))
    elseif direction_equal(couple1.beau.direction,
                           opposite(couple2.beau.direction))
        if (in_front_of(couple1.beau, couple2.belle) &&
            in_front_of(couple2.belle, couple1.beau) &&
            in_front_of(couple1.belle, couple2.beau) &&
            in_front_of(couple2.beau, couple1.belle))
            emit(FacingCouples(couple1, couple2))
        elseif (behind(couple1.beau, couple2.belle) &&
            behind(couple2.belle, couple1.beau) &&
            behind(couple1.belle, couple2.beau) &&
            behind(couple2.beau, couple1.belle))
            emit(BackToBackCouples(couple1, couple2))
        end
    end
end

@doc """
CoupleBoxRule is the rule for identifying two couples arranged in a
two by two box.
""" CoupleBoxRule

