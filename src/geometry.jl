export Bounds, expand, in_bounds, bump_out, center


"""
    Bounds(dss::Vector{DancerState};
                        margin = COUPLE_DISTANCE / 2)

represents the bounding rectangle surrounding the specified
`DancerSTate`s.  If `margin` is 0 then Bounds surrponds just the
centers of the dancers.

By default, `margin` is `COUPLE_DISTANCE / 2` so that Bounds describes
the space actually occupied by the dancers.
"""
mutable struct Bounds
    min_down
    max_down
    min_left
    max_left

    Bounds() =
        new(typemax(Float32),
            typemin(Float32),
            typemax(Float32),
            typemin(Float32))

    Bounds(min_down, max_down, min_left, max_left) =
        new(min_down, max_down, min_left, max_left)
end


function Bounds(dancer_states)
    @assert length(dancer_states) >= 1
    bounds = Bounds()
    expand(bounds, dancer_states)
    bounds
end


"""
    expand(bounds::Bounds, dancer_states)::Bounds

`bounds` is modified to encompass the additional `DancerState`s.
"""
function expand(bounds::Bounds, dancer_states)::Bounds
    for ds in dancer_states
        if bounds.min_left > ds.left
            bounds.min_left = ds.left
        end
        if bounds.max_left < ds.left
            bounds.max_left = ds.left
        end
        if bounds.min_down > ds.down
            bounds.min_down = ds.down
        end
        if bounds.max_down < ds.down
            bounds.max_down = ds.down
        end
    end
    bounds
end
    


"""
    in_bounds(bounds::Bounds, ds::DancerState)::Bool

Returns true if the specified DancerState it located within `bounds`.
"""
function in_bounds(bounds::Bounds, ds::DancerState)::Bool
    if ds.down < bounds.min_down return false end
    if ds.down > bounds.max_down return false end
    if ds.left < bounds.min_left return false end
    if ds.left > bounds.max_left return false end    
    return true
end


"""
    bump_out(bounds::Bounds, amount)

Returns a new Bounds object that is expanded at each edge by `amount`.
"""
bump_out(bounds::Bounds, amount) =
    Bounds(bounds.min_down - amount,
           bounds.max_down + amount,
           bounds.min_left - amount,
           bounds.max_left + amount)


"""
    bump_out(bounds::Bounds)

Returns a new Bounds object that is expanded by `COUPLE_DISTANCE / 2`
on each edge so that instead of encompassing the centers of each
`Dancer` it encompasses whole dancers.
"""
bump_out(bounds::Bounds) = bump_out(bounds, COUPLE_DISTANCE / 2)


"""
    center(dss)

returns the center of the specified `DancerState`s as a two element
Vector of down and left coordinates.
"""
center(dss) = sum(location, dss) / length(dss)

