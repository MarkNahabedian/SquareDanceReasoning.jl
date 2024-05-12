# Formations of four dancers that are two dancers wide and two high.

export FacingCouples, BackToBackCouples


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
    

@rule SquareDanceFormationRule.CoupleBoxRule(couple1::Couple, couple2::Couple, ::FacingCouples, ::BackToBackCouples) begin
    if couple1 == couple2
        return
    end
    if !direction_equal(couple1.beau.direction,
                        opposite(couple2.beau.direction))
        return
    end
    # Symetry disambiguation
    if couple1.beau.direction > couple2.beau.direction
        return
    end
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

@doc """
CoupleBoxRule is the rule for identifying ['FacingCouples'](@ref)
and [`BackToBackCouples`](@ref) formations.
""" CoupleBoxRule

