export SquareDanceCall, CanDoCall, as_text


# Should SquareDanceCall <: TemporalFact
# so that they don't persist across successive knowledge bases?

"""
    SquareDanceCall

For each call, a struct is defined that is a subtype of
`SquareDanceCall`.

For each call and each formation it can be done from, a
[`can_do_from`](@ref) method should be defined.  If the "Ocean Wave
Rule" applies, then a `can_do_from` method should be defined for that
case.

For each call and each formation it can be performed from, either a
`perform` or an `expand_parts` method should be defined.
"""
abstract type SquareDanceCall end


"""
    as_text(call)

Return a textual description of the call as a String.
"""
function as_text end


"""
    ScheduledCall(when, ::SquareDanceCall)

ScheduledCall associates a `SquareDanceCall` with the time it should be performed.
"""
struct ScheduledCall
    when::Real
    call::SquareDanceCall
end


"""
    CanDoCall(preference, call::SquareDanceCall, formation::SquareDanceFormation)

CanDoCall represents that `call` can be performed from `formation`,
and doing so has the specified preference.
"""
struct CanDoCall
    preference::Int
    scheduled_call::ScheduledCall
    formation::SquareDanceFormation
end


