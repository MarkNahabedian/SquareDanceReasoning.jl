export can_do_from, do_call, expand_parts, perform


abstract type CallEngineException <: Exception end

"""
    UnsynchronizedDancersException

An exception which can be signaled by the call engine if the relevant
DancerStates are not symchronized to one another.
"""
struct UnsynchronizedDancersException <: CallEngineException
    dancer_states::Vector{DancerState}
end

function Base.showerror(io::IO, e::UnsynchronizedDancersException)
    print(io, "DancerStates do not have the same time: $(e.dancer_states)")
end


"""
    DancerStatesNotNewestException

An exception which can be signaled by the call engine if the
DancerStates being considered for a call are not the newest
DancerStates for their Dancers.
"""
struct DancerStatesNotNewestException <: CallEngineException
    formation::SquareDanceFormation
    not_newest::Vector{Tuple{Int, DancerState}}
end

function Base.showerror(io::IO, e::DancerStatesNotNewestException)
    print(io, "Some dancers in $(e.formation) are not newest: $(e.not_newest).")
end


"""
    NoCallOptionsForCall

An exception which can be signalled by the call engine when
`get_call_options` can't identify any formations from which a call can
be performed.
"""
struct NoCallOptionsForCall <: CallEngineException
    call::SquareDanceCall
    kb::SDRKnowledgeBase
end

function Base.showerror(io::IO, e::NoCallOptionsForCall)
    print(io, "No call options for $(e.call).")
end


"""
    restricted_to(call)::Role

Returns the role that `call` has been restricted to.

Each subtype of SquareDanceCall must have either a `role` field or a
`restricted_to` method.
"""
function restricted_to(call::SquareDanceCall)::Role
    if hasfield(typeof(call), :role)
        call.role
    else
        error("Each subtype of  SquareDanceCall must have either a `role` field or a `restricted_to` method: $(typeof(call))")
    end
end


expand_parts(cdc::CanDoCall) = expand_parts(cdc.scheduled_call.call,
                                            cdc.formation, cdc.scheduled_call)

"""
    expand_parts(::SquareDanceCall, ::SquareDanceFormation, ::ScheduledCall)

Returns either the ScheduledCall itself, if it has no expansion, or a
vector of a `ScheduledCall` for each part.

The `ScheduledCall`'s `when` field is the starting time for the call.
The pats in the expansion can have their times offset from that.
"""
expand_parts(::SquareDanceCall, ::SquareDanceFormation, sc::ScheduledCall) = sc


"""
can_do_from(::SquareDanceCall, ::SquareDanceFormation)::Int

Determins if the specified call can be performed from the specified
formation.  A return value of 0 means the call is not appropriate (or
not currently supported).  Otherwise the return value is a preference
level with a higher value indicating more preferable.  For example
UTurnBack from Couple is more preferable to UTurnBack from
DancerState, even though both would be applicable.
"""
can_do_from(::SquareDanceCall, ::SquareDanceFormation) = 0


"""
    perform(::SquareDanceCall, ::SquareDanceFormation, ::SDRKnowledgeBase)::SquareDanceFormation

Performs the call on the specified formation and returns the new
formation.
"""
function perform end


"""
    do_call(kb::SDRKnowledgeBase, call::SquareDanceCall; dbgctx = nothing)::SDRKnowledgeBase

Perform the specified square dance call and return an updated
knowledgebase.  `do_call` is the entry point into the call engine.
"""
function do_call(kb::SDRKnowledgeBase, call::SquareDanceCall;
                 dbgctx = nothing)::SDRKnowledgeBase
    @info("do_call", call)
    sched = let
        dss = askc(Collector{DancerState}(), kb)
        if allequal(map(ds -> ds.time, dss))
            CallSchedule(dss[1].time)
        else
            throw(UnsynchronizedDancersException(dss))
        end
    end
    schedule(sched, call, sched.now)
    do_schedule(sched, kb; dbgctx = dbgctx)
end

function do_schedule(sched::CallSchedule, kb::SDRKnowledgeBase;
                     dbgctx = nothing)
    call_history = []
    newest_dancer_states = Dict{Dancer, DancerState}()
    local playmates::Vector{TwoDancerFormation}
    function update_newest(ds::DancerState)
        if haskey(newest_dancer_states, ds.dancer)
            # >= rather than > because some actions like breathing or
            # the _EndAt call create new DancrStates without advancing
            # its time.
            if history_position(ds) >= history_position(newest_dancer_states[ds.dancer])
                newest_dancer_states[ds.dancer] = ds
            end
        else
            newest_dancer_states[ds.dancer] = ds
        end
    end
    function expand_cdc(cdc::CanDoCall)
        @info("do_schedule expand_cdc", now=sched.now, cdc)
        e = expand_parts(cdc)
        @info("do_schedule expand_parts returned", cdc, e)
        e
    end
    function perform_cdc(cdc::CanDoCall)
        @info("do_schedule performing",  now=sched.now, cdc)
        push!(call_history, (sched.now, cdc))
        f = perform(cdc.scheduled_call.call, cdc.formation, kb)
        @info("do_schedule perform returned", f)
        @assert f isa SquareDanceFormation
        if f isa TwoDancerFormation
            push!(playmates, f)
        end
        for ds in dancer_states(f)
            #=
            # This assertion assumes that there are no calls
            # that require no elapsed time.
            # Ensure that the dancers that performed the call
            # experience the passage of time:
            @assert(ds.time > newest_dancer_states[ds.dancer].time,
            "$ds, $(newest_dancer_states[ds.dancer].time)")
            =#
            update_newest(ds)
        end
    end
    askc(update_newest, kb, DancerState)
    try
        while !isempty(sched)
            @info("do_schedule while loop",
                  now = sched.now,
                  queue = sched.scheduled_calls)
            playmates = TwoDancerFormation[]
            formations = askc(Collector{SquareDanceFormation}(),
                              kb, SquareDanceFormation)
            @info("do_schedule formations",
                  formations)
            ur_playmates = filter(formations) do f
                f isa TwoDancerFormation &&
                    near(dancer_states(f)...)
            end
            write_debug_formation_file(dbgctx, kb, sched.now)
            while (!isempty(sched)) && sched.now == peek(sched).when
                # Temporary experimental hack while debugging the call
                # engine behavior regarding zero duration calls like
                # _EndAt.  We wouldn't need this is we adopted ordinal
                # based scheduling.
                if (!isempty(call_history) &&
                    call_schedule_isless(last(call_history)[2].scheduled_call.call,
                                         peek(sched).call))
                    kb = make_kb(kb)
                    for ds in values(newest_dancer_states)
                        receive(kb, ds)
                    end
                    @info("do_schedule updated knowledgebase for zero diration call hack", kb)
                end
                # Process a queue entry, performing it if it's "atomic" or
                # requeueing its parts.
                #
                # Should we do all of the expand_parts before doing
                # any of the performs?  We would need some way to defer
                # the atomic calls, perhaps with more complicated
                # values in the PriorityQueue.
                now_do_this = dequeue!(sched)
                @info("do_schedule dequeued", now_do_this)
                @assert now_do_this isa ScheduledCall
                let
                    done = 0
                    # get_call_options only considers formations that match now_do_this.when
                    options = get_call_options(now_do_this, kb)
                    @info("do_schedule get_call_options returned", options)
                    for cdc in options
                        let
                            not_newest = filter(ds -> ds != newest_dancer_states[ds.dancer],
                                                collect(cdc.formation()))
                            if !isempty(not_newest)
                                throw(DancerStatesNotNewestException(
                                    cdc.formation,
                                    [
                                        (history_position(ds), ds)
                                        for ds in not_newest
                                            ]))
                            end
                        end
                        e = expand_cdc(cdc)
                        # No further expansion.  Perform the call:
                        if e == now_do_this
                            perform_cdc(cdc)
                            done += 1
                        else
                            # queue the parts:
                            for new_entry in e
                                @info("scheduling", new_entry)
                                schedule(sched, new_entry)
                            end
                            @info("updated schedule",
                                  queue = sched.scheduled_calls)
                            done += 1
                        end
                    end
                    @assert done > 0
                end
            end      # while (!isempty(sched)) && sched.now == peek(sched).when
            @info("do_schedule schedule", queue = sched.scheduled_calls)
            # We have finished all of the calls that were scheduled for a
            # given time.
            # Synchronize: catch the dancers up to the next schedule
            # entry:
            let
                old = sched.now
                # Advance the schedule forward to the next time:
                latest = maximum(ds -> ds.time,
                                 values(newest_dancer_states);
                                 init = sched.now)
                if isempty(sched)
                    sched.now = latest
                else
                    sched.now = peek(sched).when
                end
                @info("sched.now advanced from $old to $(sched.now).")
                @assert old <= sched.now
            end
            # Breathe:
            # Do we need for all of the DancerStates to be
            # synchronized before breathing?
            let
                # find_collisions should probably make sure
                # potentially colliding DancerStates are contemporary.
                collisions = find_collisions(
                    collect(values(newest_dancer_states)))
                if length(collisions) > 0
                    let
                        # Ensure that the inactive dancers also have
                        # playmates:
                        exclude = map(ds -> ds.dancer,
                                      flatten(map(dancer_states, playmates)))
                        ur_playmates = filter!(ur_playmates) do f
                            isempty(intersect(exclude,
                                              map(ds -> ds.dancer,
                                                  dancer_states(f))))
                        end
                        push!(playmates, ur_playmates...)
                    end
                    # Time doesn't elapse during breathing.
                    for ds in breathe(playmates,
                                      collect(values(newest_dancer_states)))
                        update_newest(ds)
                    end
                end
            end
            # Update the knowledgebase:
            if !isempty(sched)
                kb = make_kb(kb)
                for ds in values(newest_dancer_states)
                    receive(kb, ds)
                end
                @info("do_schedule updated knowledgebase", kb)
            end
        end    # while !isempty(sched)
        # Synchronize the dancers who lag behind sched.now for furure
        # calls:
        for ds in values(newest_dancer_states)
            if ds.time < sched.now
                update_newest(DancerState(ds,
                                          sched.now,
                                          ds.direction,
                                          ds.down, ds.left))
            end
        end
        # Update the knowledgebase:
        kb = make_kb(kb)
        for ds in values(newest_dancer_states)
            receive(kb, ds)
        end
    catch e
        @error("Exception",
               error=e,
               sched=deepcopy(sched),
               newest_dancer_states=deepcopy(newest_dancer_states),
               call_history=deepcopy(call_history))
        rethrow(e)
    end
    @info("do_schedule finished",
          newest_dancer_states=deepcopy(newest_dancer_states),
          call_history=deepcopy(call_history))
    return kb
end

function get_call_options(sc::ScheduledCall, kb::SDRKnowledgeBase)::Vector{CanDoCall}
    now = sc.when
    call = sc.call
    # This needs to be a Set to avoid the duplicates we would get from
    # querying for SquareDanceFormation and it subtypes.  Maybe this
    # should be fixed in Rete.Collector.
    #
    # We also need to make sure that for a given formation we have the
    # DancerStates with the greatest history_position.
    formation_key(f::SquareDanceFormation) =
        (typeof(f), [ ds.dancer for ds in f() ]...)
    formations = Dict()
    askc(kb, SquareDanceFormation) do f
        if timeof(f) <= now
            # The formation must exist at the time of the ScheduledCall.
            # Testing against now is not sufficient.  We must also
            # make sure we get the greatest history_position for each
            # DancerState
            key = formation_key(f)
            if haskey(formations, key)
                if f != formations[key]
                    # It's not the one we already have:
                    existing_hist = map(history_position, dancer_states(formations[key]))
                    fds_hist = map(history_position, dancer_states(f))
                    @assert length(existing_ds_hist) == length(fds_hist)
                    if any(map(>=, f_hist, existing_hist))
                        # f has more history:
                        formations[key] = f
                    end
                end
            else
                formations[key] = f
            end
        end
    end
    formations = values(formations)
    # What calls can we do from where?
    options = CanDoCall[]
    for f in formations
        p = can_do_from(call, f)
        if p > 0
            push!(options, CanDoCall(p, sc, f))
        end
    end
    @info("get_call_options formations", now, call, formations, kb)
    if length(options) == 0
        throw(NoCallOptionsForCall(call, kb))
    end
    @info("get_call_options initial options", options)
    # Restrict by role:
    options = filter!(options) do cdc
        # Every dancer in the formation satisfies the role
        # restriction:
        Set(those_with_role(cdc.formation, kb, restricted_to(call))) ==
            Set(dancer_states(cdc.formation))
    end
    @info("get_call_options after role restriction", options)
    # Find highest preference option for each dancer:
    preferred = Dict{DancerState, Vector{CanDoCall}}()
    for opt in options
        for ds in dancer_states(opt.formation)
            if !haskey(preferred, ds)
                preferred[ds] = CanDoCall[]
            end
            if isempty(preferred[ds])
                push!(preferred[ds], opt)
            elseif opt.preference > preferred[ds][1].preference
                preferred[ds] = CanDoCall[opt]
            elseif opt.preference == preferred[ds][1].preference
                push!(preferred[ds], opt)
            end
        end
    end
    @info("get_call_options preferred", preferred)
    # Consolidate the options, making sure that there are no two
    # options that concern the same dancer.  We map each Dancer to
    # each CanDoCall whose formation contains that dancer.
    do_these = CanDoCall[]
    used_ds = DancerState[]
    while any(v -> !isempty(v), values(preferred))
        # Guard against formations like Alamo ring.  What should we do
        # in that case?  Everyone can SwingThru, but the handed
        # definition of SwingThru fixes that.  Hinge or Trade would
        # need further direction.  Role restriction might fix some
        # cases.  Maybe the user just needs to be told to add
        # restrictions because the call is ambiguous.
        found_one = false
        # Keep a CanDoCall if it's the only one that concerns a given
        # dancer:
        for (_, opts) in preferred
            if length(opts) == 1
                this_opt = opts[1]
                push!(do_these, this_opt)
                push!(used_ds, dancer_states(this_opt.formation)...)
                found_one = true
                for (ds, opts) in preferred
                    preferred[ds] = filter(opts) do opt
                        (opt != this_opt
                         && isempty(intersect(used_ds,
                                              dancer_states(opt.formation))))
                    end
                end
            end
        end
        if !found_one
            # Could just break and return noting and have a higher
            # context deal with it.  It's probably good to have the
            # issue noticed as soon as possible in case there's a bug.
            if isempty(do_these)
                error("Ambiguous call: $options")
            end
            break
        end
    end
    do_these
end

