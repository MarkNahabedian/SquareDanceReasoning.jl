
@rule SquareDanceFormationRule.CatchConflictingDancerStates(ds1::DancerState,
                                                            ds2::DancerState) begin
    @rejectif ds1 == ds2
    @rejectif ds1.time != ds2.time
    if ds1.dancer == ds2.dancer
        error("CatchConflictingDancerStates $ds1, ds2")
    end
end

@doc """
    CatchConflictingDancerStates

Throws an error if there are two different `DancerState`s that concern
the same Dancer.
""" CatchConflictingDancerStates

