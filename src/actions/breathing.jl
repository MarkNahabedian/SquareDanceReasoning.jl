using LinearAlgebra: dot, normalize!

export MoveApart, move_apart, breathe


"""
    MoveApart(center, displacement)
    MoveApart(collision::Collision, playmates)

struct MoveApart can be applied to a DancerState to determine
how much it should be displaced to resolve `collision`.

`center` and `displacement` are two element Vectors.

`playmates` is a Vector of Vectors of `DancerState`s where the
elements of each inner vector are working together.
"""
struct MoveApart
    center::Vector
    displacement::Vector

    function MoveApart(center::Vector, displacement::Vector)
        @assert length(center) == 2
        @assert length(displacement) == 2
        new(center, displacement)
    end
end

function MoveApart(collision::Collision, playmates)
    @assert all(playmates) do pms
        all(pms) do pm
            pm isa DancerState
        end
    end
    playmates_a = playmates[findfirst(playmates) do pm
                                collision.a in pm
                            end]
    playmates_b = playmates[findfirst(playmates) do pm
                                collision.b in pm
                            end]
    other_a = first(setdiff(Set(playmates_a), Set([collision.a])))
    other_b = first(setdiff(Set(playmates_b), Set([collision.b])))
    displacement_amount = COUPLE_DISTANCE / 2
    if distance(collision.a, other_a) > distance(collision.a, other_b)
        displacement_amount += distance(collision.a, collision.b)
    end
    uv = normalize!(location(other_b) - location(other_a))
    MoveApart(center(dancer_states(collision)),
              displacement_amount * uv)
end


"""
    (mp::MoveApart)(ds::DancerState)

For the given DancerState, determine how much `mp` should displace it.
"""
function (mp::MoveApart)(ds::DancerState)
    loc = location(ds)
    # What side of the center is the DancerState:
    side = sign(dot(loc - mp.center, mp.displacement))
    side * mp.displacement
end


"""
    move_apart(mps::Vector{MoveApart}, ds::DancerState)::DancerState

Applies all of the MoveApart displacements to the specified
DancerState.
"""
function move_apart(mps::Vector{MoveApart}, ds::DancerState)::DancerState
    new_loc = location(ds)
    for mp in mps
        new_loc += mp(ds)
    end
    # We splice te DancerSTate that we move_apart from out of the
    # dancer history since its location was just a temporary
    # calculation aid.
    DancerState(ds.previous, ds.time, ds.direction, new_loc...)
end


"""
    breathe(collisions::Vector{Collision}, playmates::Vector{Vector{DancerState}}, everyone::Vector)::Vector{DancerStates}

Moves the dancers apart such that those in `collisions` no longer
overlap.  Those grouped together in `playmates` are moved together,
and remain fixed relative to one another.  `everyone` includes all
DancerStates that are to be affected.
"""
function breathe(collisions::Vector,
                 playmates::Vector,
                 everyone::Vector
                 )::Vector{DancerState}
    mps = map(collisions) do c
        MoveApart(c, playmates)
    end
    map(everyone) do ds
        move_apart(mps, ds)
    end
end

