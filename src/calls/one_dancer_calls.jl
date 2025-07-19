using Random

export Identify

"""
    Identify(; role=Everyone(), time=2)

Implements the Identify square dance call, by having dancers
jiggle in place.
"""
@with_kw_noshow struct Identify <: SquareDanceCall
    role::Role = Everyone()
    time::Int = 2
end

as_text(c::Identify) = "$(as_text(c.role)) identify"

note_call_text(Identify(; role = OriginalSides()))

can_do_from(::Identify, ::DancerState) = 1

function perform(c::Identify, ds::DancerState, kb::SDRKnowledgeBase)
    inc = 0.1
    how_far = 2//10 * COUPLE_DISTANCE
    home = location(ds)
    tend = ds.time + c.time
    ds1 = ds
    while ds1.time < tend
        dir = rand(0:16)//16
        v = how_far * [ cos(2 * pi * dir),
                        sin(2 * pi * dir) ]
        ds1 = DancerState(ds1, ds1.time + inc, ds.direction, (home + v)...)
        ds1 = DancerState(ds1, ds1.time + inc, ds.direction, home...)
    end
    return ds1
end

