
export QuarterIn, QuarterOut

function quarter_inout_helper(c, ds1::DancerState, ds2::DancerState)
    function turn(ds1, ds2)
        DancerState(ds1, ds1.time + 2,
                    direction(ds1, ds2),
                    ds1.down, ds1.left)
    end
    if c isa QuarterIn
        return FaceToFace(turn(ds1, ds2), turn(ds2, ds1))
    elseif c isa QuarterOut
        return BackToBack(turn(ds1, ds2), turn(ds2, ds1))
    else
        error("$c unsupported by quarter_inout_helper")
    end
end


"""
    QuarterIn(; role=Everyone())

CalllerLab Advanced 1 call.

Timing: CallerLab: 2.
"""
@with_kw_noshow struct QuarterIn <: SquareDanceCall
    role::Role = Everyone()
end

can_do_from(::QuarterIn, ::Couple) = 1
can_do_from(::QuarterIn, ::MiniWave) = 1

perform(c::QuarterIn, f::Couple, kb::SDRKnowledgeBase) =
    quarter_inout_helper(c, f.beau, f.belle)

perform(c::QuarterIn, f::MiniWave, kb::SDRKnowledgeBase) =
    quarter_inout_helper(c, f.a, f.b)


"""
    QuarterOut(; role=Everyone())

CalllerLab Advanced 1 call.

Timing: CallerLab: 2.
"""
@with_kw_noshow struct QuarterOut <: SquareDanceCall
    role::Role = Everyone()
end

can_do_from(::QuarterOut, ::Couple) = 1
can_do_from(::QuarterOut, ::MiniWave) = 1

perform(c::QuarterOut, f::Couple, kb::SDRKnowledgeBase) =
    quarter_inout_helper(c, f.beau, f.belle)

perform(c::QuarterOut, f::MiniWave, kb::SDRKnowledgeBase) =
    quarter_inout_helper(c, f.a, f.b)

