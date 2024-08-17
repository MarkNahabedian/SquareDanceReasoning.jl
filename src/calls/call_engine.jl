export can_do_from, do_call, expand_parts, CanDoCall, perform


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
`Pair{part, relative_time}` containing Pair for each part.
`relative_time` is the time (relative to the start of the call) at
which the corresonding part should start.
"""
expand_parts(c::SquareDanceCall, ::SquareDanceFormation) = c


"""
can_do_from(::SquareDanceCall, ::SquareDanceFormation)::Int

Determins if the specified call can be performed from the specified
formation.  A return value of 0 means the call is not appropriate (or
currently supported).  Otherwise the return value is a preference
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


function find_collisions(dss::Vector{DancerState})::Vector{Collision}
    found = Vector{Collision}()
    for i in 1:(length(dss) - 1)
        for j in i:length(dss)
            a = dss[i]
            b = dss[j]
            if a == b    # Why would this be?
                continue
            end
            if distance(a, b) < DANCER_COLLISION_DISTANCE
                push!(found, Collision(a, b))
            end
        end
    end
    found
end


function do_call(kb::ReteRootNode, call::SquareDanceCall)::ReteRootNode
    sched = let
        dss = askc(Collector{DancerState}(), kb, DancerState)
        if allequal(map(ds -> ds.time, dss))
            CallSchedule(dss[1].time)
        else
            error("DancerStates do not have same time: $dss")
        end
    end
    schedule(sched, call, sched.now)
    do_schedule(sched, kb)
end

function do_schedule(sched::CallSchedule, kb::ReteRootNode)
    newest_dancer_states = Dict{Dancer, DancerState}()
    askc(kb, DancerState) do ds
        newest_dancer_states[ds.dancer] = ds
    end
    playmates = TwoDancerFormation[]
    while !isempty(sched)
        # dbgprint("\n# outer loop")
        # Process a queue entry, performing it if it's "atomic" or
        # requeueing its parts.

        call = dequeue!(sched) 
        options = get_call_options(call, kb)
        # dbgprint("# get_call_options returned\n$options")

        # When we expand a call, it might apply to multiple formations
        # and we expand it multiple times because there might be
        # variations in those formations that interact with the
        # parameters of the call.  The parameters of the call don't
        # change though.

        # when we perform each part, we once again match multiple
        # formations to each part.

        # Maybe expand_parts should explicitly use the
        # DesignatedDancers role in the expansion so that it's clear
        # which scheduled part should act on which dancers?

        # If this is the problem, why has it only affected Dosados so
        # far and why does it seemingly randomly aftect different
        # dancers on each test run?

        # dbgprint("# length options: $(length(options))")
        while !isempty(options)
            # dbgprint("# options loop, $(length(options)) remaining.")
            cdc = pop!(options)
            e = expand_parts(call, cdc.formation)
            if e == call
                if let
                    # disregarding uid, we might see the same call
                    # several times for a given schedule time.  we
                    # should only perform the call for a given
                    # CanDoCall only once.
                    ds = first(dancer_states(cdc.formation))
                    ds.time < newest_dancer_states[ds.dancer].time
                end
                    # dbgprint("\n# skipping\n$(cdc.formation)")
                    continue
                end
                f = perform(call, cdc.formation, kb)
                # dbgprint("\n# performing\n$call on $(cdc.formation) gives $f")
                @assert f isa SquareDanceFormation
                if f isa TwoDancerFormation
                    push!(playmates, f)
                end
                for ds in dancer_states(f)
                    # Ensure that the dancers that performed the call
                    # experienced the passage opf time:
                    @assert newest_dancer_states[ds.dancer].time <= ds.time "$(newest_dancer_states[ds.dancer].time) <= $(ds.time), $call, $f"
                    newest_dancer_states[ds.dancer] = ds
                end
            else
                for part_pair in e
                    schedule(sched, part_pair.first,
                             part_pair.second + sched.now)
                end
                # dbgprint("\n# schedule:\n$sched")
            end
        end
        # Is the earliest entry in the schedule greater than
        # sched.now?  If so then we need to breathe, update the
        # knowledgebase, etc. first.  We also need to do these once
        # the schedule is empty.
        if isempty(sched) || peek(sched).second > sched.now
            # Breathe:
            let
                collisions = find_collisions(collect(values(newest_dancer_states)))
                if length(collisions) > 0
                    # Time doesn't elapse during breathing.
                    for ds in breathe(collisions, playmates,
                                      collect(values(newest_dancer_states)))
                        newest_dancer_states[ds.dancer] = ds
                    end
                end
                empty!(playmates)
            end
            # Synchronize: catch the dancers up to the next schedule
            # entry.
            let
                latest = maximum(ds -> ds.time,
                                 values(newest_dancer_states))
                if isempty(sched)
                    sched.now = latest
                else
                    sched.now = peek(sched).second
                end
                # What if a dancer has progressed beyond the next
                # schedule entry because the last part it performed in
                # was longer?  Deal with it when it becomes a problem.
                @assert latest <= sched.now
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
            # dbgprint("# Adding to new kb:")
            for ds in values(newest_dancer_states)
                # dbgprint(ds)
                receive(kb, ds)
            end
        end
    end
    return kb
end

function get_call_options(call::SquareDanceCall,
                          kb::ReteRootNode)::Vector{CanDoCall}
    # This needs to be a set to avoid the duplicates we would get from
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
        kb_stats(kb)
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

