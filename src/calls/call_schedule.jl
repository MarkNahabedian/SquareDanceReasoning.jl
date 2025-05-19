export CallSchedule

"""
    call_schedule_isless(call1::ScqareDanceCall, call2::SquareDanceCall)

We need some way to control the scheduleing order of zero duration
calls like _EndAt.

This is kind of a kludge but I've not thought of anything better.
"""
call_schedule_isless(::SquareDanceCall, ::SquareDanceCall) = false


Base.isless(sc1::ScheduledCall, sc2::ScheduledCall) =
    (sc1.when < sc2.when) ||
    ( sc1.when == sc2.when) && call_schedule_isless(sc1.call, sc2.call)

Base.isless(c1::SquareDanceCall, c2::SquareDanceCall) = false


"""
    CallSchedule(start_time)

CallSchedule maintains the schedule of the `ScheduledCall`s that are
to be performed.  The results of [`expand_parts` ](@ref) are added to
the schedule while calls are being executed.  The call engine (see
`do_schedule`) runs until the schedule is empty.
"""
mutable struct CallSchedule
    now::Real
    scheduled_calls::SortedSet{ScheduledCall}

    CallSchedule(start_time) = new(start_time, SortedSet{ScheduledCall}())
end

DataStructures.peek(sched::CallSchedule) = first(sched.scheduled_calls)

function DataStructures.dequeue!(sched::CallSchedule)
    sc = pop!(sched.scheduled_calls)
    @assert sc.when == sched.now
    sc
end

Base.length(sched::CallSchedule) = Base.length(sched.scheduled_calls)

Base.iterate(sched::CallSchedule) = Base.iterate(sched.scheduled_calls)
Base.iterate(sched::CallSchedule, state) = Base.iterate(sched.scheduled_calls, state)


"""
    schedule(sched::CallSchedule, call::SquareDanceCall, at)

Enters `call` into `sched` so that it will be performed at the
specified time `at`.
"""
schedule(sched::CallSchedule, call::SquareDanceCall, at) =
    schedule(sched, ScheduledCall(at, call))

function schedule(sched::CallSchedule, sc::ScheduledCall)
    @assert sc.when >= sched.now
    push!(sched.scheduled_calls, sc)
end

### SHOULD SOON NO LONGER BE NEEDED:
schedule(sched::CallSchedule, s::Tuple{Real, SquareDanceCall}) =
    push!(sched.scheduled_calls, ScheduledCall(s[1] + sched.now, s[2]))



"""
    advance_schedule_by(sched::CallSchedule, delta)

Move every entry in the schedule forward by `delta`.
"""
function advance_schedule_by(sched::CallSchedule, delta)
    @assert delta >= 0
    for sc in sched.scheduled_calls
        delete!(sched.scheduled_calls, sc)
        schedule(sched, sc.call, sc.when + delta)
    end
    sched.now += delta
    sched
end

