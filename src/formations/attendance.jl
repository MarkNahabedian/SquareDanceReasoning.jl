# Making sure all Dancers are accounted for before searching for
# formations.

# In order for formation rules to be able to use the encroached_on
# test, we must firt know that all of the current DancerStates for a
# square have been asserted to the knowledgebase.

export Attendance, AllPresent, SDSquareHasAttendanceRule, AttendanceRule

"""
    Attendance(::SDSquare)

`Attendane` is a fact in the knowledgebase that leeps track of how many
[`DancerState`](@ref)s in a square are present.

This is necessary because tests like [`encroached_on`](@ref) can only
provide a correct result if all of the `DanecerState`s are available
for consideration.
"""
struct Attendance <: TemporalFact
    expected::SDSquare
    present::Dict{Dancer, Bool}

    Attendance(s::SDSquare) =
        new(s,
            Dict{Dancer, Bool}(map(d -> d => false, s.dancers)))
end


"""
    AllPresent(::SDSquare)

`AllPresent` is a fact that is asserted to the knowledgebase by
[`SDSquareHasAttendanceRule`](@ref) when all of the [`Dancer`](@ref)s
in an [`SQSquare`](@ref) are present.

It can be used as a trigger for rules that depend on all `Dancer`s
having an associated `DancerState`.
"""
struct AllPresent <: TemporalFact
    expected::SDSquare
end


@rule SquareDanceFormationRule.SDSquareHasAttendanceRule(s::SDSquare, ::Attendance) begin
    emit(Attendance(s))
end
@doc """
    SquareDanceFormationRule

A rule that ensures that there is an [`Attendance`](@ref) fact for
every [`SDSquare`](@ref) fact.
""" SDSquareHasAttendanceRule


@rule SquareDanceFormationRule.AttendanceRule(a::Attendance, ds::DancerState, ::AllPresent) begin
    if haskey(a.present, ds.dancer)
        a.present[ds.dancer] = true
        if all(values(a.present))
            emit(AllPresent(a.expected))
        end
    end
end
@doc """
    AttendanceRule

AttendanceRule is the rule that updated a Attendance as new
[`DancerState`](@ref)s are asserted to the nowledgebase, and
ultimately asserts [`AllPresent`](@ref).
""" AttendanceRule

