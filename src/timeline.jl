
export DancerState, dancer, TimeBounds, expand, history_position
export location, direction, square_up
export DANCER_NEAR_DISTANCE, near, direction
export latest_dancer_states, history, earliest


function canonicalize_coordinate(c::Number)
    resolution = 256
    round(Int, resolution * c) / resolution
end

canonicalize_coordinate(array::Array) =  map(canonicalize_coordinate, array)


"""
    DancerState(dancer, time, direction, down, left)
    DancerState(previoous::DancerSTate, time, direction, down, left)

represents the location and facing direction of a single
dancer at a moment in time.

`time` is a number defining a temporal ordering.  It could represent a
number of beats, for example.

DancerState is also the single dancer `SquareDanceFormation`.
"""
@with_kw_noshow struct DancerState <: SquareDanceFormation
    previous::Union{Nothing, DancerState}
    dancer::Dancer
    time
    direction
    down::Float32
    left::Float32

    function DancerState(dancer::Dancer, time, direction,
                         down, left)
        @assert !isnan(down)
        @assert !isnan(left)
        new(nothing, dancer, time,
            canonicalize(direction),
            canonicalize_coordinate(down),
            canonicalize_coordinate(left))
    end
    
    function DancerState(previous::DancerState, time, direction,
                         down, left)
        @assert !isnan(down)
        @assert !isnan(left)
        new(previous, previous.dancer,
            time, canonicalize(direction),
            canonicalize_coordinate(down),
            canonicalize_coordinate(left))
    end

    # Construct a DancerState from the printed representation:
    DancerState(ignore::Int, dancer::Dancer, time, direction, down, left) =
        DancerState(dancer, time, direction, down, left)
end

dancer(ds::DancerState) = ds.dancer

location(ds::DancerState) = [ds.down, ds.left]
direction(ds::DancerState) = ds.direction

distance(s1::DancerState, s2::DancerState) =
    distance(location(s1), location(s2))

# Should DancerState be a subtype of Formation?  When we query for
# Formations we probably don't want the clutter of individual dancers,
# but it's convenient for formation_svg to wrap a single DancerState
# in SVG.
@resumable function(ds::DancerState)()
    @yield ds
end

Base.show(io::IO, ds::DancerState) =
    Base.show(io, MIME"text/plain"(), ds)

function Base.show(io::IO, ::MIME"text/plain", ds::DancerState)
    # Definition cribbed from Base._show_default(io::IO, @nospecialize(x))
    io = IOContext(io, :compact => true)
    print(io, "DancerState(")
    print(io, history_position(ds))
    for f in fieldnames(typeof(ds))
        if !(f in (:previous,))
            print(io, ", ")
            if !isdefined(ds, f)
                print(io, Base.undef_ref_str)
            else
                print(io, getfield(ds, f))
            end
        end
    end
    print(io, ")")
end

Base.in(ds::DancerState, sq::SDSquare) = in(ds.dancer, sq.dancers)


"""
    TimeBounds()

Returns an empty TimeBounds interval.
"""
mutable struct TimeBounds
    min
    max

    TimeBounds() = new(typemax(Int32), typemin(Int32))
end


function expand(tb::TimeBounds, time::Real)
    if time < tb.min
        tb.min = time
    end
    if time > tb.max
        tb.max = time
    end
    tb
end


"""
    expand(tb::TimeBounds, ds::DancerState)::TimeBounds

expands `tb` to encompass the time of the specified `DancerState`s.
"""
function expand(tb::TimeBounds, ds::DancerState)::TimeBounds
    expand(tb, ds.time)
end

function expand(tb::TimeBounds, dss)::TimeBounds
    for ds in dss
        expand(tb, ds)
    end
    tb
end


"""
    fraction(tb::TimeBounds, t)

return where `t` falls within `tb` as a fraction.
For `t == tb.min` the result would be 0.
For `t == tb.max` the result would be 100.
"""
fraction(tb::TimeBounds, t) =
    (t - tb.min) / (tb.max - tb.min)


"""
    percentage(tb::TimeBounds, t)

return where `t` falls within `tb` as a percentage.
For `t == tb.min` the result would be 0.
For `t == tb.max` the result would be 100.
"""
percentage(tb::TimeBounds, t) =
    100 * (t - tb.min) / (tb.max - tb.min)


"""
    square_up(dancers; initial_time = 0)

returns a list of `DancerState`s for the initial squared set.
"""
function square_up(dancers::Vector{Dancer};
                   center = [0.0, 0.0],
                   initial_time = 0)::Vector{DancerState}
    dancers = sort(dancers)
    couple_circle_fraction = 2 * FULL_CIRCLE / length(dancers)
    rad(fracangle) = 2 * pi * fracangle
    # Compute distance of "toe line" of dancers from center:
    toe_distance = COUPLE_DISTANCE / tan(rad(couple_circle_fraction / 2))
    ref_distance = toe_distance + COUPLE_DISTANCE / 2
    results = Vector{DancerState}()
    for dancer in dancers
        couple_fracangle = opposite((dancer.couple_number - 1) *
            couple_circle_fraction)
        couple_direction_vector = [ cos(rad(couple_fracangle)),
                                    sin(rad(couple_fracangle)) ]
        gender_vector = let
            d = if dancer.gender == Guy()
                - 1//4
            elseif dancer.gender == Gal()
                1//4
            else
                error("$(Unspecified()) gender not supported by square_up.")
            end
            [ cos(rad(couple_fracangle + d)),
              sin(rad(couple_fracangle + d)) ]
        end
        dancer_vector = center + ref_distance * couple_direction_vector +
            (COUPLE_DISTANCE / 2) * gender_vector
        push!(results,
              DancerState(dancer,
                          initial_time,
                          opposite(couple_fracangle),
                          Float32.(dancer_vector)...))
    end
    results
end


square_up(square::SDSquare;  initial_time = 0) =
    square_up(collect(square.dancers); initial_time)


DANCER_NEAR_DISTANCE = 1.2 * COUPLE_DISTANCE

"""
    near(::DancerState, ::DancerState)

returns true if the two DancerStates are for different dancers and are
close enough together (within DANCER_NEAR_DISTANCE).
"""
function near(d1::DancerState, d2::DancerState)::Bool
    if d1.dancer == d2.dancer
        return false
    end
    distance(d1, d2) < DANCER_NEAR_DISTANCE
end


function latest_dancer_states(root::SDRKnowledgeBase)::Dict{Dancer, DancerState}
    latest_dss = Dict{Dancer, DancerState}()
    askc(root, DancerState) do ds
        if !haskey(latest_dss, ds.dancer)
            latest_dss[ds.dancer] = ds
        end
        if latest_dss[ds.dancer].time < ds.time
            latest_dss[ds.dancer] = ds
        end
    end
    latest_dss
end


"""
    latest_dancer_states(kb)::Dict{Dancer, DancerState}

Return a Dict that provides the latest `DancerState` for each
`Dancer`.
"""
function latest_dancer_states(kb)::Dict{Dancer, DancerState}
    result = Dict{Dancer, DancerState}()
    askc(kb, DancerState) do ds
        if haskey(result, ds.dancer)
            if ds.time > result[ds.dancer].time
                result[ds.dancer] = ds
            end
        else
            result[ds.dancer] = ds
        end
    end
    result
end


function expand(tb::TimeBounds,
                timeline::Dict{Dancer, Vector{DancerState}})::TimeBounds
    for dss in values(timeline)
        expand(tb, dss)
    end
    tb
end


"""
    history(f, ds::DancerState)

Calls f on `ds` and all of its `previous` DancerStates in
chronological order.
"""
function history(f, ds::DancerState)
    if ds.previous !== nothing
        history(f, ds.previous)
    end
    f(ds)
end


function history(ds::DancerState)
    Collector{DancerState}()() do c
        history(c, ds)
    end
end

function history_position(ds::DancerState)
    let count = 0
        history(ds) do ds
            count += 1
        end
        count
    end
end


"""
    earliest(ds::DancerState)

Returns the earliest DancerState in the specified `DancerState`'s
`previous` chain.
"""
function earliest(ds::DancerState)
    while ds.previous != nothing
        ds = ds.previous
    end
    ds
end


corner_couple_number(ds::DancerState) = corner_couple_number(ds.dancer)

