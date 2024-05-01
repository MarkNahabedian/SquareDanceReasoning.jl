
export ColumnOfFour, ColumnOfFourRule


"""
    ColumnOfFour(lead::Tandem, tail::Tandem, centers::Tandem)

Represents a column of four dancers, each facing the back of the
dancer in front of them.
"""
struct ColumnOfFour <: FourDancerFormation
    lead::Tandem
    tail::Tandem
    centers::Tandem
end

dancer_states(f::ColumnOfFour)::Vector{DancerState} =
    [ dancer_states(f.lead)...,
      dancer_states(f.tail)... ]

handedness(::ColumnOfFour) = NoHandedness()


@rule SquareDanceFormationRule.ColumnOfFourRule(lead::Tandem, tail::Tandem,
                                                centers::Tandem,
                                                ::ColumnOfFour) begin
    if !direction_equal(lead.leader.direction, tail.leader.direction)
        return
    end
    if !direction_equal(lead.leader.direction, centers.leader.direction)
        return
    end
    if lead.trailer != centers.leader
        return
    end
    if tail.leader != centers.trailer
        return
    end
    emit(ColumnOfFour(lead, tail, centers))
end

@doc """
ColumnOfFourRule is the rule for identifying [`ColumnOfFour`](@ref)
formations.
""" ColumnOfFourRule
