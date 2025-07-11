export Collision, find_collisions


DANCER_COLLISION_DISTANCE = 0.8 * COUPLE_DISTANCE


"""
Collision notes that two dancers are occupying the same space.
"""
struct Collision
    a::DancerState
    b::DancerState
    center
    sideways

    function Collision(ds1::DancerState, ds2::DancerState)
        # @assert ds1.time == ds2.time [ds1, ds2]
        if ds1.direction > ds2.direction
            ds1, ds2 = ds2, ds1
        end
        ctr = center([ds1, ds2])
        if location(ds1) == location(ds2)
            if ds1.direction in (ds2.direction, opposite(ds2.direction))
                sideways = unit_vector(quarter_left(ds1.direction))
            else
                sideways = unit_vector(quarter_left((ds1.direction + ds2.direction) / 2))
            end
        else
            sideways = normalize(location(ds2) - location(ds1))
        end
        sideways = (COUPLE_DISTANCE / 2) * sideways
        new(ds1, ds2, ctr, canonicalize_coordinate.(sideways))
    end
end

@resumable function(f::Collision)()
    @yield f.a
    @yield f.b
end

dancer_states(f::Collision) = [f()...]


"""
    uncollide(collisions::Vector{Collision}, dss::Vector{DancerState})
    uncollide(collisions::Vector{Collision}, ds::DancerState)
    uncollide(collision::Collision, ds::DancerState)

Returns a vector describing how the `DancerState`'s position should be
adjusted so that no `DancerState`s are colliding.

Only the first method (which takes vectords of Collisions and
DancerStates) should be called by outside code.  The other two are
part of the implementation.

`uncollide` should only move dancers further apart, never closer
together.
"""
function uncollide end

function uncollide(collision::Collision, ds::DancerState)
    if ds == collision.a || ds == collision.b
        if collision.a.direction == collision.b.direction
            uncollide_direction = unit_vector(direction(collision.center, ds.previous))
        else
            uncollide_direction = unit_vector(quarter_left(ds.direction))
        end
    else
        uncollide_direction = unit_vector(direction(collision.center, ds))
    end
    sign(dot(collision.sideways, uncollide_direction)) * collision.sideways
end

function uncollide(collisions::Vector{Collision}, ds::DancerState)
    motion = [0, 0]
    for collision in collisions
        motion += uncollide(collision, ds)
    end
    if motion == [0, 0]
        ds
    else
        DancerState(ds, ds.time, ds.direction, (location(ds) + motion)...)
    end
end

function uncollide(collisions::Vector{Collision}, dss::Vector{DancerState})
    map(ds -> uncollide(collisions, ds), dss)
end


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
