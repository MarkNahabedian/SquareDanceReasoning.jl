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
        for j in (i+1):length(dss)
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

Respirator is a device for assisting breating.  It performs the
bookkeeping associed with tracking the current location of each dancer
as adjusted by the breathing algorithm without creating new
`DancerState`s.
"""
struct Respirator
    flagpole
    dancers::Vector{Dancer}
    d2ds::Dict{Dancer, DancerState}
    accumulated_movement::Dict{Dancer, Vector}
    playmates::Vector{<:TwoDancerFormation}

    function Respirator(dss::Vector{DancerState},
                        playmates::Vector{<:TwoDancerFormation})
        flagpole = center(dss)
        dancers = Vector{Dancer}()
        d2ds = Dict{Dancer, DancerState}()
        accumulated_movement = Dict{Dancer, Vector}()
        for ds in dss
            push!(dancers, ds.dancer)
            d2ds[ds.dancer] = ds
            accumulated_movement[ds.dancer] = [0, 0]
        end
        dancers = sort(dancers)
        new(flagpole, dancers, d2ds, accumulated_movement, playmates)
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
    move(r::Respirator, d::Dancer, down, left)

Applies the relative `down` and `left` motion to the `Dancer`.
"""
function move(r::Respirator, d::Dancer, down, left)
    r.accumulated_movement[d] += [down, left]
end

function playmates_center(rsp::Respirator, d::Dancer)
    playmates = only(filter(rsp.playmates) do f
                         any(ds -> d == ds.dancer,
                             dancer_states(f))
                     end)
    center(playmates)
end


"""
    collisions(::Respirator)

Returns an iterator over the current collisions in the `Respirator`.
"""
@resumable function collisions(rsp::Respirator)
    n = length(rsp.dancers)
    for i in 1:(n-1)
        for j in (i+1):n
            a = current_location(rsp, i)
            b = current_location(rsp, j)
            if distance(a, b) < DANCER_COLLISION_DISTANCE
                collision = [ rsp.dancers[i],
                              rsp.dancers[j] ]
                @info("breathing collisions",
                      collision = collision,
                      location1 = a,
                      location2 = b)
                @yield collision
            end
        end
    end
end


"""
    motion_for_collision(rsp::Respirator, collision, movement::Dict{Dancer, Vector})

Compute the motions required to resolve the specified collision and
add it to `movement`.  Does not apply those motions yet.  `movement`
is a Dict mapping Dancer to motion vector.
"""
function motion_for_collision(rsp::Respirator, collision,
                              movement::Dict{Dancer, Vector})
    (d1, d2) = collision
#    @assert !(d1 in keys(movement))
#    @assert !(d2 in keys(movement))
    # We arrange that d1 is the dancer that should be further from
    # flagpole.  We use the center of the dancer and its playmate
    # because d1 and d2 might have moved past each other when
    # colliding.
    if (distance(playmates_center(rsp, d2), rsp.flagpole) >
        distance(playmates_center(rsp, d1), rsp.flagpole))
        (d1, d2) = (d2, d1)
    end
    # We believe d1 is the dancer that should be moved.
    @info("motion_for_collision: playmate for", d1, playmate(d1, rsp.playmates))
    @info("motion_for_collision: playmate for", d2, playmate(d2, rsp.playmates))
    @assert current_location(rsp, playmate(d1, rsp.playmates)) !=
        current_location(rsp, d1)
    ctr = center([current_location(rsp, d1),
                  current_location(rsp, d2)])
    move_d1_u = normalize(playmates_center(rsp, d1)
                          - rsp.flagpole)
    move_d1 = move_d1_u * COUPLE_DISTANCE
    overlap = (current_location(rsp, d2)
               - current_location(rsp, d1))
    overlap_fix = dot(current_location(rsp, d2)
                      - current_location(rsp, d1),
                      move_d1_u) * move_d1_u
    move_d1 += overlap_fix    
    @info("motion_for_collision:", overlap, overlap_fix, move_d1)
#    @assert !haskey(movement, d1)
    if distance(ctr, rsp.flagpole) < 0.1 * COUPLE_DISTANCE
        # Collision near flagpole, move both of the colliders, and
        # their playmates
        let
            @assert !haskey(movement, d2)
            m = move_d1 / 2
            movement[d1] = m
            movement[d2] = - m
            movement[playmate(d1, rsp.playmates)] = m
            movement[playmate(d2, rsp.playmates)] = - m
        end
    else
        # The center of the collision is noticably different from the
        # flagpole center, so just move the further playmates:
        movement[d1] = move_d1
        movement[playmate(d1, rsp.playmates)] = move_d1
    end
    @info("motion_for_collision:", movement)
    movement    
end


"""
    apply_motion(rsp::Respirator, movement::Dict{Dancer, Vector})

Update `rsp` to reflect the Dancer movement specified in `movement`.
"""
function apply_motion(rsp::Respirator, movement::Dict{Dancer, Vector})
    for (dancer, motion) in movement
        move(rsp, dancer, motion...)
    end
    @info("breathing apply_motion",
          current_locations = map(rsp.dancers) do dancer
              dancer => current_location(rsp, dancer)
          end)
end


"""
    resultingDancerStates(rsp::Respirator)

Returns new `DancerState`s which have had the computed breathing
applied to them.
"""
resultingDancerStates(rsp::Respirator) =
    map(values(rts.d2ds)) do ds
        DancerState(ds, ds.time, ds.direction,
                    current_location(rsp, ds.dancer)...)
    end


"""
    breathe(playmates::Vector{<:TwoDancerFormation}, everyone::Vector{DancerState})::Vector{DancerState}

Moves the dancers apart such that those that have collided no longer
overlap.

`playmates` is used to inform what direction colliders should be moved
in such that playmates are not separated.

`everyone` includes all DancerStates that are to be affected.
"""
function breathe(playmates::Vector{<:TwoDancerFormation},
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
    rsp = Respirator(everyone, playmates)
    flagpole = center(map(location, everyone))
    limit = 20
    while true
        if limit <= 0
            error("Breating iteration limit exceeded.")
        end
        limit -= 1
        movement = Dict{Dancer, Vector}()
        for collision in collisions(rsp)
            motion_for_collision(rsp, collision, movement)
        end
        if isempty(movement)
            break
        end
        apply_motion(rsp, movement)
    end
    result = map(everyone) do ds
        DancerState(ds, ds.time, ds.direction,
                    current_location(rsp, ds.dancer)...)
    end
    result
end

