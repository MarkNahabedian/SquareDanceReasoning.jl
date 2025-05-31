# Making sure all Dancers are accounted for before searching for
# formations.

# In order for formation rules to be able to use the encroached_on
# test, we must first know that all of the current DancerStates for a
# square and time have been asserted to the knowledgebase.

export Attendance, AllPresent, SDSquareHasAttendanceRule, AttendanceRule

"""
    Attendance(::SDSquare)

`Attendance` is a fact in the knowledgebase that keeps track of how many
[`DancerState`](@ref)s in a square are present.

This is necessary because tests like [`encroached_on`](@ref) can only
provide a correct result if all of the `DanecerState`s are available
for consideration.

When all of the `Dancer`s of s set have `DancerState`s, then
`Attendance` emits an `AllPresent` fact.

Note that `Attendance` contains mutable data - but once an
`Attendance` is created, only the values in its `present` field are
changed.
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
in an [`SDSquare`](@ref) are present.

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


@rule SquareDanceFormationRule.AttendanceRule(a::Attendance, ds::DancerState,
                                              ::AllPresent) begin
    # The constructor for Attendance has already added all of the necessary keys.
    @continueif haskey(a.present, ds.dancer)
    a.present[ds.dancer] = true
    @continueif all(values(a.present))
    emit(AllPresent(a.expected))
end
@doc """
    AttendanceRule

AttendanceRule is the rule that updates an Attendance as new
[`DancerState`](@ref)s are asserted to the knowledgebase, and
ultimately asserts [`AllPresent`](@ref).
""" AttendanceRule

