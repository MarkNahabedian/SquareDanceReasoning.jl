export SquareDanceCall, CanDoCall


"""
    next_call_id()

Returns a unique integer to serve as the unique id of a square dance
call.  Every call struct should have a `uid` field which is
initialized by a return value of this function.

Square dance calls are immutable structs, and they serve as "keys" in
a `PriorityQueue`.  so that a call like `Trade()` can appear more than
once in a [`CallSchedule`](@ref), each call must be given a unique id.
"""
next_call_id = let
    id_counter = 0
    function next_call_id()
        # id_counter += 1
        0
    end
end


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
    CanDoCall(preference, call::SquareDanceCall, formation::SquareDanceFormation)

CanDoCall represents that `call` can be performed from `formation`,
and doing so has the specified preference.
"""
struct CanDoCall
    preference::Int
    call::SquareDanceCall
    formation::SquareDanceFormation
end


