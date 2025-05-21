# Rules for lines of couples facing in either direction down the line.


export FacingTandemCouples, FacingTandemCouplesRule
export BeforeEightChain, BeforeEightChainRule
export BeforeTradeBy, BeforeTradeByRule
export CompletedDoublePassThru, CompletedDoublePassThruRule


"""
FacingTandemCouples is a formation of eight dancers (four couples)
lined up, and is the starting formation for the "double pass thru"
call.  This formation is more commonly known as "Double Pass Thru".
```
→→←←
→→←←
```
"""
struct FacingTandemCouples <: EightDancerFormation
    tandem_couples1::TandemCouples
    tandem_couples2::TandemCouples
    centers::FacingCouples
end

@resumable function(f::FacingTandemCouples)()
    for ds in f.tandem_couples1()
        @yield ds
    end
    for ds in f.tandem_couples2()
        @yield ds
    end
end

handedness(::FacingTandemCouples) = NoHandedness()

@rule SquareDanceFormationRule.FacingTandemCouplesRule(tc1::TandemCouples,
                                                       tc2::TandemCouples,
                                                       centers::FacingCouples,
                                                       ::FacingTandemCouples,
                                                       ::FormationContainedIn) begin
    @rejectif tc1 == tc2
    # Disambiguate TandemCouples to avoid duplicate symetric
    # formations:
    @rejectif direction(tc2) < direction(tc1)
    @continueif timeof(tc1) == timeof(tc2)
    if (tc1.leaders == centers.couple1 &&
        tc2.leaders == centers.couple2)
        f = FacingTandemCouples(tc1, tc2, centers)
        emit(f)
        emit(FormationContainedIn(tc1, f))
        emit(FormationContainedIn(tc2, f))
        emit(FormationContainedIn(centers, f))
    end
end

@doc """
FacingTandemCouplesRule is the rule for recognizing the FacingTandemCouples
formation.
""" FacingTandemCouplesRule



"""
BeforeEightChain is a formation of eight dancers (four couples)
lined up, and is the starting formation for the "eight chain thru"
call.  It can result from doing "centers pass thru" from a
FacingTandemCouples formation.
```
→←→←
→←→←
```
"""
struct BeforeEightChain <: EightDancerFormation
    facing_couples1::FacingCouples
    facing_couples2::FacingCouples
    centers::BackToBackCouples
end

@resumable function(f::BeforeEightChain)()
    for ds in f.facing_couples1()
        @yield ds
    end
    for ds in f.facing_couples2()
        @yield ds
    end
end

handedness(::BeforeEightChain) = NoHandedness()

@rule SquareDanceFormationRule.BeforeEightChainRule(fc1::FacingCouples,
                                                    fc2::FacingCouples,
                                                    centers::BackToBackCouples,
                                                    ::BeforeEightChain,
                                                    ::FormationContainedIn) begin
    @rejectif fc1 == fc2
    @continueif timeof(fc1) == timeof(fc2)
    if centers.couple1 == fc2.couple1 &&
        centers.couple2 == fc1.couple2
        f = BeforeEightChain(fc1, fc2, centers)
        emit(f)
        emit(FormationContainedIn(fc1, f))
        emit(FormationContainedIn(fc2, f))
        emit(FormationContainedIn(centers, f))
    end
end

@doc """
BeforeEightChainRule is the rule for recognizing BeforeEightChain
formations.
""" BeforeEightChainRule


"""
BeforeTradeBy is a formation of eight dancers (four couples) lined
up, and is the starting formation for the call "trade by".  It can
result from doing a "centers pass thru" from a BeforeEightChain
formation.
```
←→←→
←→←→
```
"""
struct BeforeTradeBy <: EightDancerFormation
    bbcouples1::BackToBackCouples
    bbcouples2::BackToBackCouples
    centers::FacingCouples
end

@resumable function(f::BeforeTradeBy)()
    for ds in f.bbcouples1()
        @yield ds
    end
    for ds in f.bbcouples2()
        @yield ds
    end
end

handedness(::BeforeTradeBy) = NoHandedness()

@rule SquareDanceFormationRule.BeforeTradeByRule(bb1::BackToBackCouples,
                                                 bb2::BackToBackCouples,
                                                 centers::FacingCouples,
                                                 ::BeforeTradeBy,
                                                 ::FormationContainedIn) begin
    @rejectif bb1 == bb2
    @continueif timeof(bb1) == timeof(bb2)
    if (centers.couple1 == bb1.couple1 &&
        centers.couple2 == bb2.couple2)
        f = BeforeTradeBy(bb1, bb2, centers)
        emit(BeforeTradeBy(bb1, bb2, centers))
        emit(FormationContainedIn(bb1, f))
        emit(FormationContainedIn(bb2, f))
        emit(FormationContainedIn(centers, f))
    end
end

@doc """
BeforeTradeByRule is the rule for recognizing BeforeTradeBy
formations.
""" BeforeTradeByRule


"""
CompletedDoublePassThru is a formation of eight dancers (four couples)
lined up, and is the ending formation for the call "double pass thru".
It can result from doing a "centers pass thru" from a TradeBy
formation.
```
←←→→
←←→→
```
"""
struct CompletedDoublePassThru <: EightDancerFormation
    tandem_couples1::TandemCouples
    tandem_couples2::TandemCouples
    centers::BackToBackCouples
end

@resumable function(f::CompletedDoublePassThru)()
    for ds in f.tandem_couples1()
        @yield ds
    end
    for ds in f.tandem_couples2()
        @yield ds
    end
end

handedness(::CompletedDoublePassThru) = NoHandedness()

@rule SquareDanceFormationRule.CompletedDoublePassThruRule(tc1::TandemCouples,
                                                           tc2::TandemCouples,
                                                           centers::BackToBackCouples,
                                                           ::CompletedDoublePassThru,
                                                           ::FormationContainedIn) begin
    @rejectif tc1 == tc2
    # Break symetry to avoid duplicates:
    @rejectif direction(tc1) > direction(tc2)
    @continueif allequal(timeof, [ tc1, tc2, centers ])
    if (centers.couple1 == tc1.trailers &&
        centers.couple2 == tc2.trailers)
        f = CompletedDoublePassThru(tc1, tc2, centers)
        emit(f)
        emit(FormationContainedIn(tc1, f))
        emit(FormationContainedIn(tc2, f))
        emit(FormationContainedIn(centers, f))
    end
end

@doc """
CompletedDoublePassThruRule is the rule for rtecognizing
CompletedDoublePassThru formations.
""" CompletedDoublePassThruRule

