
export DancerState, TimeBounds, expand
export location, direction, square_up
export DANCER_NEAR_DISTANCE, near, direction
export Collision, CollisionRule
export latest_dancer_states, dancer_timelines


"""
    DancerState(dancer, time, direction, down, left)
    DancerState(previoous::DancerSTate, time, direction, down, left)

represents the location and facing direction of a single
dancer at a moment in time.

`time` is a number defining a temporal ordering.  It could represent a
number of beats, for example.
"""
struct DancerState
    previous::Union{Nothing, DancerState}
    dancer::Dancer
    time
    direction
    down::Float32
    left::Float32

    DancerState(dancer::Dancer, time, direction,
                down, left) = new(nothing, dancer, time,
                                  canonicalize(direction),
                                  Float32(down), Float32(left))

    DancerState(previous::DancerState, time, direction,
                down, left) = new(previous, previous.dancer,
                                  time, canonicalize(direction),
                                  Float32(down), Float32(left))
end


location(ds::DancerState) = [ds.down, ds.left]
direction(ds::DancerState) = ds.direction

distance(s1::DancerState, s2::DancerState) =
    distance(location(s1), location(s2))


function Base.show(io::IO, ::MIME"text/plain", ds::DancerState)
    # Definition cribbed from Base._show_default(io::IO, @nospecialize(x))
    need_comma = false
    print(io, "DancerState(")
    for f in fieldnames(typeof(ds))
        if !(f in (:previous,))
            if need_comma
                print(io, ", ")
            end
            need_comma = true
            if !isdefined(ds, f)
                print(io, Base.undef_ref_str)
            else
                show(io, getfield(ds, f))
            end
        end
    end
    print(io, ")")
end


"""
    TimeBounds()

Returns an empty TimeBounds interval.
"""
mutable struct TimeBounds
    min
    max

    TimeBounds() = new(typemax(Int32), typemin(Int32))
end


"""
    expand(tb::TimeBounds, ds::DancerState)::TimeBounds

expands `tb` to encompass the time of the specified `DancerState`s.
"""
function expand(tb::TimeBounds, ds::DancerState)::TimeBounds
    if ds.time < tb.min
        tb.min = ds.time
    end
    if ds.time > tb.max
        tb.max = ds.time
    end
    tb
end

function expand(tb::TimeBounds, dss)::TimeBounds
    for ds in dss
        expand(tb, ds)
    end
    tb
end


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
                   center = [0.0  0.0],
                   initial_time = 0)::Vector{DancerState}
    dancers = sort(dancers)
    circle_fraction = FULL_CIRCLE / length(dancers)
    dancer_direction(dancer) =
        (dancer.couple_number - 1) * circle_fraction * 2
    angle_from_center(i) =
        opposite((i - 1) * circle_fraction - circle_fraction / 2)
    rad(angle) = 2 * pi * angle
    function unit_vector(dancer_angle)
        a = rad(dancer_angle)
        [ cos(a) sin(a) ]
    end
    results = Vector{DancerState}()
    distance_from_center =
        (COUPLE_DISTANCE / 2) +   # additional radius to account for
                                  # the size of a dancer
        (COUPLE_DISTANCE / 2) / sin(rad(circle_fraction))
    for (i, dancer) in enumerate(dancers)
        angle = angle_from_center(i)
        direction = dancer_direction(dancer)
        push!(results,
              DancerState(dancer,
                          initial_time,
                          dancer_direction(dancer),
                          Float32.(distance_from_center *
                              unit_vector(angle))...))
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


"""
    direction(focus::DancerState, other::DancerState)

returns the direction that `other` is from the point of view of
`focus`.
"""
function direction(focus::DancerState, other::DancerState)
    down, left = location(other) - location(focus)
    canonicalize(atan(left, down) / (2 * pi))
end


DANCER_COLLISION_DISTANCE = 0.8 * COUPLE_DISTANCE

struct Collision
    a::DancerState
    b::DancerState
end

dancer_states(c::Collision)::Vector{DancerState} = [c.a, c.b]

@rule SquareDanceRule.CollisionRule(a::DancerState, b::DancerState,
                                    ::Collision) begin
    if b.dancer <= a.dancer
        return
    end
    if distance(a, b) < DANCER_COLLISION_DISTANCE
        emit(Collision(a, b))
    end
end


function latest_dancer_states(root::ReteRootNode)::Dict{Dancer, DancerState}
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
    dancer_timelines(kb)::Dict{Dancer, Vector{DancerState}}

returns a dictionary, keyed by `Dancer`, whose values are the
`DancerState`s associated with that dancer.  Those `DancerState`s are
sorted by time.
"""
function dancer_timelines(kb)::Dict{Dancer, Vector{DancerState}}
    timeline = Dict{Dancer, Vector{DancerState}}()
    askc(kb, DancerState) do ds
        if !haskey(timeline, ds.dancer)
            timeline[ds.dancer] = Vector{DancerState}()
        end        
        push!(timeline[ds.dancer], ds)
    end
    for (_, dss) in timeline
        sort!(dss; by = ds -> ds.time)
    end
    timeline
end

function expand(tb::TimeBounds,
                timeline::Dict{Dancer, Vector{DancerState}})::TimeBounds
    for dss in values(timeline)
        expand(tb, dss)
    end
    tb
end

