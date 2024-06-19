
export SquaredSet, SquaredSetFormationRule

"""
    SquaredSet(couples1::FacingCouples, couples2::FacingCouples)

SquaredSet represents a squared set of eight dancers.
"""
struct SquaredSet <: EightDancerFormation
    couples1::FacingCouples
    couples2::FacingCouples
end

dancer_states(f::SquaredSet)::Vector{DancerState} =
    [ dancer_states(f.couples1)...,
      dancer_states(f.couples2)... ]

handedness(::SquaredSet) = NoHandedness()

@rule SquareDanceFormationRule.SquaredSetFormationRule(fc1::FacingCouples, fc2::FacingCouples, ::SquaredSet) begin
    if !direction_equal(direction(fc1.couple1) + 1//4,
                        direction(fc2.couple1))
        return
    end
    emit(SquaredSet(fc1, fc2))
end

