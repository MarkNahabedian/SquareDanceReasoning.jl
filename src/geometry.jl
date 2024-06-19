using Base.Iterators: flatten

export Bounds, expand, in_bounds, bump_out, encroached_on
export center


"""
    Bounds(dss::Vector{DancerState};
                        margin = COUPLE_DISTANCE / 2)

represents the bounding rectangle surrounding the specified
`DancerState`s.  If `margin` is 0 then Bounds surrounds just the
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


function Bounds(formations...)
    bounds = Bounds()
    expand(bounds, formations...)
    if bounds.min_down == typemax(Float32)
        error("No formations for Bounds")
    end
    bounds
end


"""
    expand(bounds::Bounds, ::DancerState)::Bounds

`bounds` is modified to encompass the additional `DancerState`.
"""
function expand(bounds::Bounds, ds::DancerState)::Bounds
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
    bounds
end

function expand(bounds::Bounds, formations)::Bounds
    dss = flatten(map(dancer_states, formations))
    for ds in dss
        bounds = expand(bounds, ds)
    end
    bounds
end


"""
    in_bounds(bounds::Bounds, ds::DancerState)::Bool

Returns true if the specified DancerState it located within `bounds`.

in_bounds(Bounds([ds]), ds) == true
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
    encroached_on(formations, kb)

Returns true if any of the other contemporary `DancerState`s in the
knowledge base are within the `Bounds` of the specified `formations`.
"""
function encroached_on(formations, kb)
    these = flatten(map(dancer_states, formations))
    b = bump_out(Bounds(these))
    time = first(these).time
    encroaching = false
    askc(kb, DancerState) do ds
        if !(ds in these)
            if ds.time == first(these).time
                if in_bounds(b, ds)
                    encroaching = true
                    # It would be nice to have a short-circuiting exit
                    # for askc.
                end
            end
        end
    end
    encroaching
end


"""
    center(dss)

returns the center of the specified `DancerState`s as a two element
Vector of down and left coordinates.
"""
center(dss) = sum(location, dss) / length(dss)

