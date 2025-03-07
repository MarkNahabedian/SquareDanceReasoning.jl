
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
    @rejectif direction(lead) != direction(tail)
    @rejectif direction(lead) != direction(centers)
    @rejectif lead.trailer != centers.leader
    @rejectif tail.leader != centers.trailer
    @continueif timeof(lead) == timeof(tail)
    f = ColumnOfFour(lead, tail, centers)
    emit(f)
    emit(FormationContainedIn(lead, f))
    emit(FormationContainedIn(tail, f))
    emit(FormationContainedIn(centers, f))
end

@doc """
ColumnOfFourRule is the rule for identifying [`ColumnOfFour`](@ref)
formations.
""" ColumnOfFourRule
