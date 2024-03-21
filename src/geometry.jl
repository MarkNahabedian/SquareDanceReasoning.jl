export Bounds, center


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
    center(dss::Vector{DancerState})

returns the center of the specified `DancerState`s as a two element
Vector of down and left coordinates.
"""
center(dss::Vector{DancerState}) =
    sum(location, dss) / length(dss)

