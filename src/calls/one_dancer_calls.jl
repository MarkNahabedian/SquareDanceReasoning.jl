using Random

export Balance

"""
    Balance(; role=Everyone(), time=2)

Implements the Balance square dance call, except that dancers just
jiggle in place.  Maybe it should be renamed _Identify.
"""
@with_kw_noshow struct Balance <: SquareDanceCall
    role::Role = Everyone()
    time::Int = 2
end

as_text(c::Balance) = "$(as_text(c.role)) Balance"

can_do_from(::Balance, ::DancerState) = 1

function perform(c::Balance, ds::DancerState, kb::ReteRootNode)
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

