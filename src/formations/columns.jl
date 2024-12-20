
export ColumnOfFour, ColumnOfFourRule


"""
    ColumnOfFour(lead::Tandem, tail::Tandem, centers::Tandem)

Represents a column of four dancers, each facing the back of the
dancer in front of them.
"""
struct ColumnOfFour <: OneByFourFormation
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
                                                ::ColumnOfFour,
                                                ::FormationContainedIn) begin
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
    f = ColumnOfFour(lead, tail, centers)
    emit(f)
    emit(FormationContainedIn(lead, f))
    emit(FormationContainedIn(tail, f))
end

@doc """
ColumnOfFourRule is the rule for identifying [`ColumnOfFour`](@ref)
formations.
""" ColumnOfFourRule
