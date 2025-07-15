export _FollowCirculatePaths, BoxCirculate


@with_kw_noshow struct _FollowCirculatePaths <: SquareDanceCall
    role::Role = Everyone()
    half_count = 2
    paths::Vector{CirculatePath}
    formation_type::Type
end

as_text(c::_FollowCirculatePaths) = "_FollowCirculatePaths"

can_do_from(c::_FollowCirculatePaths, f::SquareDanceFormation) =
    f isa c.formation_type ? 1 : 0


function expand_parts(c::_FollowCirculatePaths, f::SquareDanceFormation, sc::ScheduledCall)
    start = sc.when
    if c.half_count == 1
        return sc
    end
    if c.half_count > 1
        return [
            ScheduledCall(start + 0, _FollowCirculatePaths(role = c.role,
                                                           half_count = 1,
                                                           paths = c.paths,
                                                           formation_type = c.formation_type))
            ScheduledCall(start + 1, _FollowCirculatePaths(role = c.role,
                                                           half_count = c.half_count - 1,
                                                           paths = c.paths,
                                                           formation_type = c.formation_type))
        ]
    else
        return ScheduledCall[]
    end
end

function perform(c::_FollowCirculatePaths, formation::SquareDanceFormation, kb::SDRKnowledgeBase)
    @assert c.half_count == 1
    successors = DancerState[]
    for ds in those_with_role(formation, c.role)
        push!(successors, DancerState(ds, 1, next_station(c.paths, ds)))
    end
    successors
end


@with_kw_noshow struct BoxCirculate <: SquareDanceCall
    role::Role = Everyone()
    half_count = 2
end

as_text(c::BoxCirculate) = "$(as_text(c.role)) box circulate"

can_do_from(::BoxCirculate, ::BoxOfFour) = 1

function expand_parts(c::BoxCirculate, f::BoxOfFour, sc::ScheduledCall)
    start = sc.when
    dancers = map(ds -> ds.dancer, those_with_role(f, c.role))
    # Can we do multiple half circulates without defining Diamond formations?
    [
        ScheduledCall(start, _FollowCirculatePaths(; role = DesignatedDancers(dancers),
                                                   half_count = c.half_count,
                                                   paths = circulate_paths(f),
                                                   formation_type = Union{BoxOfFour, Diamond}))
    ]
end

