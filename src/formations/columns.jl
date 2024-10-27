
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

@resumable function(f::ColumnOfFour)()
    for ds in f.lead()
        @yield ds
    end
    for ds in f.tail()
        @yield ds
    end
end

handedness(::ColumnOfFour) = NoHandedness()

direction(f::ColumnOfFour) = direction(f.lead)


@rule SquareDanceFormationRule.ColumnOfFourRule(lead::Tandem, tail::Tandem,
                                                centers::Tandem,
                                                ::ColumnOfFour) begin
    if direction(lead) != direction(tail)
        return
    end
    if direction(lead) != direction(centers)
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
