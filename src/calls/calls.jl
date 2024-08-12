
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
        id_counter += 1
    end
end


include("callerlab_programs.jl")
include("call_engine.jl")

include("primitive_calls.jl")
include("rotate_in_place.jl")
include("one_dancer_calls.jl")
include("two_dancer_calls.jl")
include("quarter_in_out.jl")

# include("circle_left_right.jl")


