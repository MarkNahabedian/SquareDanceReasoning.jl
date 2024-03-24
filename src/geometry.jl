export Bounds, in_bounds, center


"""
    Bounds(dss::Vector{DancerState};
                        margin = COUPLE_DISTANCE / 2)

represents the bounding rectangle surrounding the specified
`DancerSTate`s.  If `margin` is 0 then Bounds surrponds just the
centers of the dancers.

By default, `margin` is `COUPLE_DISTANCE / 2` so that Bounds describes
the space actually occupied by the dancers.
"""
struct Bounds
    min_down
    max_down
    min_left
    max_left

    Bounds(min_down, max_down, min_left, max_left) =
        new(min_down, max_down, min_left, max_left)

    function Bounds(dss::Vector{DancerState};
                    margin=COUPLE_DISTANCE/2)
        @assert length(dss) >= 1
        min_down = nothing
        max_down = nothing
        min_left = nothing
        max_left = nothing
        for ds in dss
            if min_left == nothing || min_left > ds.left
                min_left = ds.left
            end
            if max_left == nothing || max_left < ds.left
                max_left = ds.left
            end
            if min_down == nothing || min_down > ds.down
                min_down = ds.down
            end
            if max_down == nothing || max_down < ds.down
                max_down = ds.down
            end
        end
        min_down -= margin
        max_down += margin
        min_left -= margin
        max_left += margin
        new(min_down, max_down, min_left, max_left)
    end
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


bump_out(bounds::Bounds, amount) =
    Bounds(bounds.min_down - amount,
           bounds.max_down + amount,
           bounds.min_left - amount,
           bounds.max_left + amount)




"""
    center(dss::Vector{DancerState})

returns the center of the specified `DancerState`s as a two element
Vector of down and left coordinates.
"""
center(dss::Vector{DancerState}) =
    sum(location, dss) / length(dss)

