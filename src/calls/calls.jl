export SquareDanceCall, can_do_from, do_call, CanDoCall, perform

# Should SquareDanceCall <: TemporalFact
# so that they don't persist across successive knowledge bases?
abstract type SquareDanceCall end

include("callerlab_programs.jl")


"""
    expand_parts(::SquareDanceCall)

Returns a sequence of the call itself if it has no separate parts, or a
sequence of "calls" representing itys parts. 
"""
expand_parts(c::SquareDanceCall) = [ c ]

function expand_parts(s)
    result = []
    for c in s
        push!(result, expand_parts(c)...)
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
    CanDoCall(preference, call::SquareDanceCall, formation::SquareDanceFormation)

is concluded by CanDoCallRule when `call` can be performed from
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
    perform(::SquareDanceCall, ::SquareDanceFormation, ::ReteRootNode)::SquareDanceFormation

Forforms the call on the specified formation and returns the new
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
    e = expand_parts(call)
    if length(e) == 1
        dss = do_simple_call(kb, e[1])
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
    # Restrict by role:
    options = filter!(options) do cdc
        # Every dancer in the formation satisfies the role
        # restriction:
        length(dancer_states(those_with_role(cdc.formation, call.role))) ==
            length(dancer_states(cdc.formation))
    end
    # Find highest preference option for each dancer:
    preferred = Dict{DancerState, CanDoCall}()
    for opt in options
        for ds in dancer_states(opt.formation)
            if haskey(preferred, ds)
                if opt.preference == preferred[ds].preference
                    error("$opt and $(preferred[ds]) conflict.")
                elseif opt.preference > preferred[ds].preference
                    preferred[ds] = opt
                end
            else
                preferred[ds] = opt
            end
        end
    end
    # Consolidate the options, making sure that there are no two
    # options that concern the same dancer:
    do_these = Vector{CanDoCall}()
    for (ds, opt) in preferred
        if in(opt, do_these)
            for dto in do_these
                if dto == opt
                    continue
                end
                if ds in dancer_states(dto.formation)
                    error("$(ds.dancer) in both $opt and $dto")
                end
            end
        else
            push!(do_these, opt)
        end
    end
    do_these
end

function do_simple_call(kb::ReteRootNode,
                        call::SquareDanceCall)::Vector{DancerState}
    receive(kb, call)
    options = get_call_options(call, kb)
    # Should we make sure that the formations in the remaining options
    # are disjoint?
    everyone = askc(Collector{DancerState}(), kb, DancerState)
    # We really only need collision detection here.
    after = map(options) do cdc
        @assert call == cdc.call
        perform(call, cdc.formation, kb)
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
    everyone
end


include("primitive_calls.jl")
include("rotate_in_place.jl")
include("two_dancer_calls.jl")

# include("circle_left_right.jl")


