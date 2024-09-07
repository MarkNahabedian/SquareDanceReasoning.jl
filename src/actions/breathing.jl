using LinearAlgebra: dot, normalize!

export breathe

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
    d2ds = Dict{Dancer, DancerState}()
    flagpole = center(map(location, everyone))
    dancers = []
    accumulated_movement = Dict{Dancer, Vector}()
    for ds in everyone
        push!(dancers, ds.dancer)
        d2ds[ds.dancer] = ds
        accumulated_movement[ds.dancer] = [0, 0]
    end
    current_location(d::Dancer) =
        location(d2ds[d]) + accumulated_movement[d]
    function next_collision()
        n = length(dancers)
        for i in 1:(n-1)
            for j in (i+1):n
                a = current_location(dancers[i])
                b = current_location(dancers[j])
                if distance(a, b) < DANCER_COLLISION_DISTANCE
                    collision = [dancers[i], dancers[j]]
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
        #=
        for d in dancers
            dbgprint((limit, d, current_location(d)))
        end
        =#
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
        if (distance(current_location(playmate(d2, playmates)), flagpole) >
            distance(current_location(playmate(d1, playmates)), flagpole))
            (d1, d2) = (d2, d1)
        end
        # d1's playmate is further from the flagpole center than d2's
        # playmate.
        @info("breathe: playmate for", d1, playmate(d1, playmates))
        @info("breathe: playmate for", d2, playmate(d2, playmates))
        @assert current_location(playmate(d1, playmates)) !=
            current_location(d1)
        ctr = center([current_location(d1),
                      current_location(d2)])
        # MOve d1 and playmate away from flagpole in the direction of
        # midpoint between d1 and his playmate:
        move_d1_u = normalize!(center([
            current_location(d1), 
            current_location(playmate(d1, playmates))])
                               - flagpole)
        move_d1 = move_d1_u * COUPLE_DISTANCE
        @info("breathe: collision center", ctr, move_d1)
        # Consider amount of collision overlap:
        move_d1 += dot(current_location(d2) - current_location(d1),
                       move_d1_u) * move_d1_u
        moved = []
        for d in dancers
            # Never move d2 -- it might be at the same location as d1:
            if d == d2
                continue
            end
            # Only move the dancers who are in the move_d1 direction
            # from ctr:
            if dot(current_location(d) - ctr, move_d1) < 0
                continue
            end
            # Make sure that the magnitude is increasing:
            mag2(v) = sum(x -> x^2, v)
            m1 = mag2(accumulated_movement[d])
            @info("Breathe: moving $d by", move_d1)
            accumulated_movement[d] += move_d1
            push!(moved, d)
            m2 = mag2(accumulated_movement[d])
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
                    current_location(ds.dancer)...)
    end
    result
end

