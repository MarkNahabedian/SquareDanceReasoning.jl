using LinearAlgebra: dot, normalize!

export breathe, find_collisions

### ONLY USED IN TESTS:
"""
   find_collisions(dss::Vector{DancerState})::Vector{Collision}

Find the `DancerState`s that have collided with each other. 
"""
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

#=
### NOT USED
"""
    sort_collisions(flagpole, location_function, collisions::Vector{Collision})::Vector{Collision}

Sorts the collisions in order of decreasing distance from the flagpole
center.

`flagpole` is a Vector of the *down* and *left* coordinates of the
flagpole center of the set.

`location_function` maps a `Dancer` to its current location.
"""
function sort_collisions(flagpole,
                         collisions::Vector{Collision})::Vector{Collision}
    center(c::Collision) = center(location_function(c.a.dancer),
                                  location_function(c.b.dancer))
    sort(collisions;
         by = c -> distance(flagpole, center(c)),
         rev = true)
end
=#


"""
    Respirator(::Vector{DancerState))

Respirator is a device for assisting breating.  It performbs the
bookkeeping associed with tracking the current location of each dancer
as adjusted by the breathing algorithm without creating new
`DancerState`s.
"""
struct Respirator
    dancers::Vector{Dancer}
    d2ds::Dict{Dancer, DancerState}
    accumulated_movement::Dict{Dancer, Vector}

    function Respirator(dss::Vector{DancerState})
        dancers = Vector{Dancer}()
        d2ds = Dict{Dancer, DancerState}()
        accumulated_movement = Dict{Dancer, Vector}()
        for ds in dss
            push!(dancers, ds.dancer)
            d2ds[ds.dancer] = ds
            accumulated_movement[ds.dancer] = [0, 0]
        end
        new(dancers, d2ds, accumulated_movement)
    end
end


"""
    current_location(r::Respirator, d::Dancer)

returns the current location of the `Dancer` as recorded in the
`Respirator`.
"""
current_location(r::Respirator, d::Dancer) =
        location(r.d2ds[d]) + r.accumulated_movement[d]

function current_location(r::Respirator, i::Integer)
    dancer = r.dancers[i]
    location(r.d2ds[dancer]) + r.accumulated_movement[dancer]
end


"""
    breathe(playmates::Vector{TwoDancerFormation}, everyone::Vector{DancerState})::Vector{DancerState}

Moves the dancers apart such that those that have collided no longer
overlap.

`playmates` is used to inform what direction colliders should be moved
in such that playmates are not separated.

`everyone` includes all DancerStates that are to be affected.
"""
function breathe(playmates::Vector{TwoDancerFormation},
                 everyone::Vector{DancerState}
                 )::Vector{DancerState}
    @info("breathe", playmates, everyone)
    let
        too_close = []
        for pms in playmates
            (ds1, ds2) = dancer_states(pms)
            if distance(ds1, ds2) < COUPLE_DISTANCE
                push!(too_close, pms)
            end
        end
        if !isempty(too_close)
            error("breathe: playmates too close: $too_close.  Fix the instigating square dance call.")
        end
    end
    rsp = Respirator(everyone)

    flagpole = center(map(location, everyone))
    function next_collision()
        n = length(rsp.dancers)
        for i in 1:(n-1)
            for j in (i+1):n
                a = current_location(rsp, i)
                b = current_location(rsp, j)
                if distance(a, b) < DANCER_COLLISION_DISTANCE
                    collision = [ rsp.dancers[i],
                                  rsp.dancers[j] ]
                    @info("breathing collision",
                          collision, a, b)
                    return collision
                end
            end
        end
        nothing
    end
    limit = 20
    while (begin
               collision = next_collision()
               collision != nothing
           end)
        if limit <= 0
            error("limit exceeded")
        end
        limit -= 1
        (d1, d2) = collision
        # We arrange that d1 is the dancer whose playmate is further
        # from flagpole.  We use their playmates because d1 and d2
        # might have moved past each other when colliding.
        if playmate(d2, playmates) == nothing
            error("no playmate for $d2")
        end
        if playmate(d1, playmates) == nothing
            error("no playmate for $d1")
        end
        if (distance(current_location(rsp, playmate(d2, playmates)),
                     flagpole) >
                distance(current_location(rsp, playmate(d1, playmates)),
                         flagpole))
            (d1, d2) = (d2, d1)
        end
        # d1's playmate is further from the flagpole center than d2's
        # playmate.
        @info("breathe: playmate for", d1, playmate(d1, playmates))
        @info("breathe: playmate for", d2, playmate(d2, playmates))
        @assert current_location(rsp, playmate(d1, playmates)) !=
            current_location(rsp, d1)
        ctr = center([current_location(rsp, d1),
                      current_location(rsp, d2)])
        pm = playmate(d1, playmates)
        # What if we should move both d1 and d2?  This would be the
        # case if the line from flagpole to ctr is perpendicular to
        # the direction of motion.
        center_axis = normalize(ctr - flagpole)
        playmate_axis =
            normalize((current_location(rsp, playmate(d1, playmates))
                       - current_location(rsp, playmate(d2, playmates))))
        if abs(dot(center_axis, playmate_axis)) < 0.01
        else
        end
        # Move d1 and playmate away from flagpole in the direction of
        # midpoint between d1 and his playmate:
        move_d1_u = normalize!(center([current_location(rsp, d1), 
                                       current_location(rsp, pm)])
                               - flagpole)
        move_d1 = move_d1_u * COUPLE_DISTANCE
        @info("breathe: collision center", ctr, move_d1)
        # Consider amount of collision overlap:
        move_d1 += dot(current_location(rsp, d2) - current_location(rsp, d1),
                       move_d1_u) * move_d1_u
        moved = []
        for d in [d1, pm]   # dancers
            # Never move d2 -- it might be at the same location as d1:
            if d == d2
                continue
            end
            # Only move the dancers who are in the move_d1 direction
            # from ctr:
            if dot(current_location(rsp, d) - ctr, move_d1) < 0
                continue
            end
            # Make sure that the magnitude is increasing:
            mag2(v) = sum(x -> x^2, v)
            m1 = mag2(rsp.accumulated_movement[d])
            @info("Breathe: moving $d by", move_d1)
            rsp.accumulated_movement[d] += move_d1
            push!(moved, d)
            m2 = mag2(rsp.accumulated_movement[d])
            if m2 < m1
                error("movement decreased for $d in breathing")
            end
        end
        if isempty(moved)
            error("no dancers moved")
        end
    end
    result = map(everyone) do ds
        DancerState(ds, ds.time, ds.direction,
                    current_location(rsp, ds.dancer)...)
    end
    result
end

