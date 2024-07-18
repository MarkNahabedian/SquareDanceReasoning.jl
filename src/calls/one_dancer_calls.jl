using Random

export Balance

@with_kw struct Balance <: SquareDanceCall
    role::Role = Everyone()
    time::Int = 2
end

description(c::Balance) = "$(c.role) Balance"

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

