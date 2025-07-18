
export circulate_paths, CirculateStation, CirculatePath, next_station


"""
    circulate_paths(::SquareDanceFormation) = CirculatePath[]

For the specified square dance formation, return the
[`CirculatePath`](@ref)s for that formation.

`circulate_paths` should be specialized for each formation from which
a "circulate" call can be called.
"""
circulate_paths(::SquareDanceFormation) = CirculatePath[]



"""
    CirculateStation(direction, down, left)
    CirculateStation(::DancerState)
    CirculateStation(::DancerState, direction)
    CirculateStation(::CirculateStation, new_direction)

A CirculateStation represents one point along a [`CirculatePath`](@ref).
"""
struct CirculateStation
    direction::Real
    down::Real
    left::Real

    CirculateStation(direction, down, left) =
        new(canonicalize(direction), down, left)
    
    CirculateStation(ds::DancerState) =
        CirculateStation(ds.direction, ds.down, ds.left)

    CirculateStation(ds::DancerState, direction) =
        CirculateStation(direction, ds.down, ds.left)

    CirculateStation(station::CirculateStation, new_direction) =
        CirculateStation(new_direction, station.down, station.left)
end


location(station::CirculateStation) = [ station.down, station.left ]

function halfway(station1::CirculateStation, station2::CirculateStation)
    loc1 = location(station1)
    loc2 = location(station2)
    ctr = center([loc1, loc2])
    if station1.direction == station2.direction
        return CirculateStation(station1.direction, ctr...)
    else
        radius = distance(loc1, loc2) / 2
        return CirculateStation(station1.direction
                                + abs((station2.direction
                                       - station1.direction) / 2),
                                (ctr + radius * unit_vector(station1.direction))...)
    end
end


"""
    CirculatePath(::Vector(DancerState})

CirculatePath represents one path in a "circulate" call.

[`circulate_paths`](@ref) can return multime `CirculatePath`s.

Each `CirculatePath` is constructed from a sequence of
[`DancerState`](@ref)s that represent each whole circulate step along
the circulate path.

The [`CirculateStation'](@ref)s along a `CirculatePath` are sorted in
promenade (counterclockwise) order.  The order of the stations is
independent of dancer facing direction.

Intermediate "half circulate" stations are automatically intercolated.
"""
struct CirculatePath
    stations::Vector{CirculateStation}

    function CirculatePath(dss::Vector{DancerState})
        c = center(dss)
        directions = Dict()
        for ds in dss
            directions[direction(c, ds)] = ds
        end
        return new(
            interpolate_half_circulate_stations(
                map(sort(collect(keys(directions)))) do dir
                    ds = directions[dir]
                    forward_direction = direction(c, move(location(ds), ds.direction, 1))
                    CirculateStation(ds,
                                     if forward_direction > dir
                                         ds.direction
                                     else
                                         opposite(ds.direction)
                                     end)
                end))
    end
end

function interpolate_half_circulate_stations(stations::Vector{CirculateStation})
    halfsies = []
    station_count = length(stations)
    index(i) = mod1(i, station_count)
    for i in 1:(station_count)
        this = stations[i]
        push!(halfsies, this)
        next = stations[index(i + 1)]
        push!(halfsies, halfway(this, next))
    end
    halfsies
end


"""
    next_station(path::CirculatePath, ds::DancerState)

Returns the next [`CirculateStation`](@ref) or `nothing` for the
`Dancer` specified by `DancerState` along `path`.
"""
function next_station(path::CirculatePath, ds::DancerState)
    station_index = -1
    for i in 1:length(path.stations)
        s = path.stations[i]
        if s.down == ds.down && s.left == ds.left
            station_index = i
            break
        end
    end
    if station_index < 0
        return nothing
    end
    this_station = path.stations[station_index]
    next_station = if this_station.direction == ds.direction
        return path.stations[mod1(station_index + 1, length(path.stations))]
    else
        next = path.stations[mod1(station_index - 1, length(path.stations))]
        return CirculateStation(next, opposite(next.direction))
    end
end

function next_station(paths::Vector{CirculatePath}, ds::DancerState)
    for path in paths
        s = next_station(path, ds)
        if s != nothing
            return s
        end
    end
    return nothing
end


# Create the successor DancerState from the specified CirculateStation:
DancerState(ds::DancerState, time_delta, station::CirculateStation) =
    DancerState(ds, ds.time + time_delta,
                station.direction, station.down, station.left)

