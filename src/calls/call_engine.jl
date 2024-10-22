export can_do_from, do_call, expand_parts, perform


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
        error("Each subtype of  SquareDanceCall must have either a `role` field or a `restricted_to` method.")
    end
end


"""
    expand_parts(::SquareDanceCall, ::SquareDanceFormation)

Returns either the call itself, if it has no expansion, or a vector of
`Tuple{relative_time, part}` containing one Tuple for each part.
`relative_time` is the time (relative to the start of the call) at
which the corresonding part should start.
"""
expand_parts(c::SquareDanceCall, ::SquareDanceFormation) = c


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
    perform(::SquareDanceCall, ::SquareDanceFormation, ::ReteRootNode)::SquareDanceFormation

Performs the call on the specified formation and returns the new
formation.
"""
function perform end


"""
    do_call(kb::ReteRootNode, call::SquareDanceCall; dbgctx = nothing)::ReteRootNode

Perform the specified square dance call and retrn an updated
knowledgebase.
"""
function do_call(kb::ReteRootNode, call::SquareDanceCall;
                 dbgctx = nothing)::ReteRootNode
    sched = let
        dss = askc(Collector{DancerState}(), kb, DancerState)
        if allequal(map(ds -> ds.time, dss))
            CallSchedule(dss[1].time)
        else
            error("DancerStates do not have same time: $dss")
        end
    end
    schedule(sched, call, sched.now)
    do_schedule(sched, kb; dbgctx = dbgctx)
end

function do_schedule(sched::CallSchedule, kb::ReteRootNode;
                     dbgctx = nothing)
    call_history = []
    newest_dancer_states = Dict{Dancer, DancerState}()
    askc(kb, DancerState) do ds
        newest_dancer_states[ds.dancer] = ds
    end
    try
        while !isempty(sched)
            playmates = TwoDancerFormation[]
            function expand_cdc(cdc::CanDoCall)
                @info("do_schedule expand_cdc", cdc)
                if !all(ds -> ds == newest_dancer_states[ds.dancer],
                        dancer_states(cdc.formation))
                    error("Some dancers in $(cdc.formation) are not newest: $newest_dancer_states")
                end
                @assert all(ds -> ds.time == sched.now,
                            dancer_states(cdc.formation))
                dancer_states(cdc.formation)
                e = expand_parts(cdc.call, cdc.formation)
                @info("do_schedule expand_parts returned", e)
                e
            end
            function perform_cdc(cdc::CanDoCall)
                @info("do_schedule performing",  cdc)
                push!(call_history, (sched.now, cdc))
                @assert all(ds -> ds.time == sched.now,
                            dancer_states(cdc.formation))
                @assert all(ds -> ds == newest_dancer_states[ds.dancer],
                            dancer_states(cdc.formation))
                f = perform(cdc.call, cdc.formation, kb)
                @info(("do_schedule perform returned", f))
                @assert f isa SquareDanceFormation
                if f isa TwoDancerFormation
                    push!(playmates, f)
                end
                for ds in dancer_states(f)
                    # Ensure that the dancers that performed the call
                    # experience the passage of time:
                    @assert(ds.time > newest_dancer_states[ds.dancer].time,
                            "$ds, $(newest_dancer_states[ds.dancer].time)")
                    newest_dancer_states[ds.dancer] = ds
                end
            end
            formations = askc(Collector{SquareDanceFormation}(),
                              kb, SquareDanceFormation)
            @info("do_schedule formations",
                  formations)
            ur_playmates = filter(formations) do f
                f isa TwoDancerFormation &&
                    near(dancer_states(f)...)
            end
            write_debug_formation_file(dbgctx, kb, sched.now)
            while (!isempty(sched)) && sched.now == peek(sched).second
                # Process a queue entry, performing it if it's "atomic" or
                # requeueing its parts.
                #
                # Should we do all of the expand_parts before doing
                # any of the performs?  Wewould need some way to defer
                # the atomic calls, perhaps with more complicated
                # values in the PriorityQueue.
                now_do_this = dequeue!(sched)
                @info("do_schedule dequeued", now_do_this)
                @assert now_do_this isa SquareDanceCall
                let
                    done = 0
                    options = get_call_options(now_do_this, kb)
                    @info("do_schedule get_call_options returned", options)
                    for cdc in options
                        e = expand_cdc(cdc)
                        # No further expansion.  Perform the call:
                        if e == now_do_this
                            perform_cdc(cdc)
                            done += 1
                        else
                            # queue the parts:
                            for (when, part) in e
                                schedule(sched, part,
                                         when + sched.now)
                            end
                            done += 1
                        end
                    end
                    @assert done > 0
                end
            end
            @info("do_schedule schedule", sched)
            # We have finished all of the calls that were scheduled for a
            # given time.
            # Synchronize: catch the dancers up to the next schedule
            # entry:
            let
                # Advance the schedule forward to the next time:
                latest = maximum(ds -> ds.time,
                                 values(newest_dancer_states))
                if isempty(sched)
                    sched.now = latest
                else
                    sched.now = peek(sched).second
                    if latest > sched.now
                        let
                            delta = latest - sched.now
                            @warn("The dancers are ahead of the schedule",
                                  latest = latest,
                                  sched_now = sched.now)
                            advance_schedule_by(sched, delta)
                        end
                    end
                end
            end
            # Breathe:
            let
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
                        newest_dancer_states[ds.dancer] = ds
                    end
                end
            end
            begin
                # What if a dancer has progressed beyond the next
                # schedule entry because the last part it performed in
                # was longer?  This is dealt with above by advancing
                # the schedule.
                for ds in values(newest_dancer_states)
                    if ds.time < sched.now
                        newest_dancer_states[ds.dancer] =
                            DancerState(ds,
                                        sched.now,
                                        ds.direction,
                                        ds.down, ds.left)
                    end
                end
                @assert allequal(map(ds -> ds.time,
                                     values(newest_dancer_states)))
            end
            # Update the knowledgebase:
            kb = make_kb(kb)
            for ds in values(newest_dancer_states)
                receive(kb, ds)
            end
        end
    catch e
        dbgprint("\n# schedule\n", sched)
        dbgprint("\n# newest_dancer_states\n", newest_dancer_states)
        dbgprint("\n# call_history\n", call_history)
        dbgprint("\n# DancerState history\n")
        for ds in values(newest_dancer_states)
            SquareDanceReasoning.history(ds) do ds1
                dbgprint((ds1.dancer, ds1.time) => (ds1.direction, location(ds1)...))
            end
        end
        rethrow(e)
    end
    return kb
end

function get_call_options(call::SquareDanceCall,
                          kb::ReteRootNode)::Vector{CanDoCall}
    # This needs to be a Set to avoid the duplicates we would get from
    # querying for SquareDanceFormation sand it subtypes.  Maybe this
    # should be fixed in Rete.Collector.
    formations = Set{SquareDanceFormation}()
    askc(kb, SquareDanceFormation) do f
        push!(formations, f)
    end
    # What calls can we do from where?
    options = CanDoCall[]
    for f in formations
        p = can_do_from(call, f)
        if p > 0
            push!(options, CanDoCall(p, call, f))
        end
    end
    if length(options) == 0
        @info("get_call_options formations", formations)
        error("No options for $call")
    end
    # Restrict by role:
    options = filter!(options) do cdc
        # Every dancer in the formation satisfies the role
        # restriction:
        length(those_with_role(cdc.formation, restricted_to(call))) ==
            length(dancer_states(cdc.formation))
    end
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

