
export SquaredSet, SquaredSetFormationRule
export CircleOfEight, CircleOfEightFormationRule

"""
    SquaredSet(couples1::FacingCouples, couples2::FacingCouples)

SquaredSet represents a squared set of eight dancers.
"""
struct SquaredSet <: EightDancerFormation
    couples1::FacingCouples
    couples2::FacingCouples
end

@resumable function(f::SquaredSet)()
    for ds in f.couples1()
        @yield ds
    end
    for ds in f.couples2()
        @yield ds
    end
end

handedness(::SquaredSet) = NoHandedness()


@rule SquareDanceFormationRule.SquaredSetFormationRule(fc1::FacingCouples, fc2::FacingCouples, ::SquaredSet) begin
    if (direction(fc1.couple1) + 1//4) != direction(fc2.couple1)
        return
    end
    emit(SquaredSet(fc1, fc2))
end

@doc """
SquaredSetFormationRule is the rule for identifying a
[`SquaredSet`](@ref).
""" SquaredSetFormationRule


"""
CircleOfEight represents eight dancers in a circle facing inward.
"""
struct CircleOfEight <: EightDancerFormation
    ds1::DancerState
    ds2::DancerState
    ds3::DancerState
    ds4::DancerState
    ds5::DancerState
    ds6::DancerState
    ds7::DancerState
    ds8::DancerState
end

@resumable function(f::CircleOfEight)()
    @yield f.ds1
    @yield f.ds2
    @yield f.ds3
    @yield f.ds4
    @yield f.ds5
    @yield f.ds6
    @yield f.ds7
    @yield f.ds8
end


# 8! invocations of this rule, YIKES!
#
# Is there a divide and conquor approach?
#
# How do we know where the center is if we don't have all of the
# dancers?
@rule SquareDanceFormationRule.CircleOfEightFormationRule(sq::SDSquare, ds1::DancerState, ds2::DancerState, ds3::DancerState, ds4::DancerState, ds5::DancerState, ds6::DancerState, ds7::DancerState, ds8::DancerState, ::CircleOfEight) begin
    dss = [ ds1, ds2, ds3, ds4, ds5, ds6, ds7, ds8 ]
    howmany = length(dss)
    # All in same square:
    for ds in dss
        if !in(ds, sq)
            return
        end
    end
    # No two the same:
    for i in 1:(howmany - 1)
        for j in (i+1):howmany
            if dss[i] == dss[j]
                return
            end
        end
    end
    c = center(dss)
    # same distance:
    let
        distances = map(dss) do ds
            distance(c, location(ds))
        end
        avg = sum(distances) / howmany
        for d in distances
            if abs(d - avg) / avg > .1
                return
            end
        end
    end
    let
        directions = map(dss) do ds
            direction(c, ds)
        end
        # in order?
        if !issorted(directions)
            return
        end
        # evenly spaced?
        deltas = []
        for i in 0:(howmany - 1)
            push!(deltas,
                  canonicalize(directions[((i+1) % howmany) + 1] -
                      directions[i + 1]))
        end
        for d in deltas
            if abs(d - 1 / howmany) > 1//32
                return
            end
        end
    end
    emit(CircleOfEight(dss...))
end

@doc """
CircleOfEightFormationRule is the rule for recognizing eight dancers
in a circle: [`CircleOfEight`](@ref).
""" CircleOfEightFormationRule

