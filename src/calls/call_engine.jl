export SquareDanceCall, can_do_from, do_call, expand_parts,
    CanDoCall, CanDoCallRule, perform

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

is concluded by [`CanDoCallRule`](@ref) when `call` can be performed from
`formation`.
"""
struct CanDoCall
    preference::Int
    call::SquareDanceCall
    formation::SquareDanceFormation
end


@rule SquareDanceRule.CanDoCallRule(call::SquareDanceCall,
                                    f::SquareDanceFormation,
                                    ::CanDoCall) begin
    p = can_do_from(call, f)
    if p > 0
        emit(CanDoCall(p, call, f))
    end
end
    
@doc """
CanDoCallRule identifies which calls can be applied to which formations.
""" CanDoCallRule


"""
    expand_parts(::SquareDanceCall, options::Vector{CanDoCall})

Returns a sequence of the call itself if it has no separate parts, or a
sequence of "calls" representing itys parts.

`options` is the result of `get_call_options`.
"""
expand_parts(c::SquareDanceCall, ::Vector{CanDoCall}) = [ c ]

function expand_parts(s, options::Vector{CanDoCall})
    result = []
    for c in s
        push!(result, expand_parts(c, options)...)
    end
    result
end


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
    receive(kb, call)
    options = get_call_options(call, kb)
    e = expand_parts(call, options)
    if length(e) == 1
        (formations, dss) = do_simple_call(kb, e[1], options)
        kb = make_kb(kb)
        receive.([kb], dss)
    else
        for c in e
            kb = do_call(kb, c)
        end
    end
    return kb
end

function get_call_options(call::SquareDanceCall,
                          kb::ReteRootNode)::Vector{CanDoCall}
    # What calls can we do from where?
    options = askc(Collector{CanDoCall}(), kb, CanDoCall)
    options = filter!(options) do cdc
        cdc.call == call
    end
    if length(options) == 0
        kb_stats(kb)
        error("No options for $call")
    end
    # Restrict by role:
    options = filter!(options) do cdc
        # Every dancer in the formation satisfies the role
        # restriction:
        length(those_with_role(cdc.formation, call.role)) ==
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


"""
    do_simple_call(kb::ReteRootNode, call::SquareDanceCall, options::Vector{CanDoCall})

calls `perform` on the call and each applicable member of options,
breathes and then synchronizes.

Returns the formations returned by `perform` after applying
`update_from`.

Maybe breathing and synchronization should be defered until
`do_simple_call` returns to `do_call` in support of
concurrent parts.
"""
function do_simple_call(kb::ReteRootNode,
                        call::SquareDanceCall,
                        options::Vector{CanDoCall}
                        )::Tuple{Vector{SquareDanceFormation},
                                 Vector{DancerState}}
    # Should we make sure that the formations in the remaining options
    # are disjoint?
    everyone = askc(Collector{DancerState}(), kb, DancerState)
    # We really only need collision detection here.
    formations = SquareDanceFormation[]
    after = map(options) do cdc
        @assert call == cdc.call
        f = perform(call, cdc.formation, kb)
        @assert f isa SquareDanceFormation
        push!(formations, f)
        f
    end
    altered = Dict{Dancer, DancerState}()
    for a in after
        for ds in dancer_states(a)
            altered[ds.dancer] = ds
        end
    end
    # Merge DancerStates from altered into everyone:
    everyone = map(everyone) do ds
        get(altered, ds.dancer, ds)
    end
    collisions = find_collisions(everyone)
    if length(collisions) > 0
        everyone = breathe(collisions,
                           filter(after) do f
                               f isa TwoDancerFormation
                           end,
                           everyone)
    end
    # Synchronize everyone:
    latest = maximum(ds -> ds.time, everyone)
    everyone = map(everyone) do ds
        if ds.time < latest
            DancerState(ds,
                        latest,
                        ds.direction,
                        ds.down,
                        ds.left)
        else
            ds
        end
    end
    formations = map(formations) do formation
        update_from(formation, everyone)
    end
    (formations, everyone)
end

