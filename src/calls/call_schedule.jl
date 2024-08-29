

struct ScheduledCall
    when::Real
    call::SquareDanceCall
end


"""
    CallSchedule()
    CallSchedule(now)

Creates and returns an empty square dance call schedule, either
starting at time 0 or at the specified time.

Use [`schedule`](@ref) to add a new entry to the schedule.
"""
mutable struct CallSchedule
    # Should the "priority" value here be a time/beat, or just a
    # relative ordering?  We need to be able to say when sequential
    # parts in simultaneous sequences are in lock step, but relative
    # ordering can achieve that as long as the calls are scheduled by
    # the same function.
    # Maybe initially use beat/time for simplicity until that's found
    # to be a problem.

    # How might we deal with something like "do the first 2 parts of
    # RelayTheDeucey (Trade, centers cast off 3/4); diamond circulate
    # (very centers of the wave of 6 and the two circulators); finish
    # RelayTheDeucey"?

    # A hack might be to assemble the parts into a temporary
    # CallSchedule and fiddle with it and then merge it with the real
    # schedule.

    # We could have a function which takes a time index into a
    # CallSchedule and delays everything starting at that point by
    # some additional time. openup(::CallSchedule, amount, at)

    # What mechanism provides the easiest approach to part
    # manipulation?
    now::Real
    queue::PriorityQueue{ScheduledCall, Real}
    
    CallSchedule() =
        new(0, PriorityQueue{ScheduledCall, Real}())

    CallSchedule(now::Real) =
        new(now, PriorityQueue{ScheduledCall, Real}())
end


Base.isempty(sched::CallSchedule) = isempty(sched.queue)

DataStructures.peek(sched::CallSchedule) =
    peek(sched.queue)

DataStructures.dequeue!(sched::CallSchedule) =
    dequeue!(sched.queue).call


"""
    schedule(sched::CallSchedule, call::SquareDanceCall, at)

Enters `call` into `sched` so that it will be performed at the
specified time `at`.
"""
function schedule(sched::CallSchedule, call::SquareDanceCall, at)
    @assert at >= sched.now
    @assert !haskey(sched.queue, call)
    sched.queue[ScheduledCall(at, call)] = at
end


function schedule(sched::CallSchedule,
                  t::Tuple{Real, SquareDanceCall})
    schedule(sched, t.second, t.first + sched.now)
end


"""
    advance_schedule_by(sched::CallSchedule, delta)

Move every entry in the schedule forward by `delta`.
"""
function advance_schedule_by(sched::CallSchedule, delta)
    for key in keys(sched.queue)
        delete!(sched.queue, key)
        schedule(sched, key.call, key.when + delta)
    end
    sched.now += delta
    sched
end

