# Rules for 


export FacingTandemCouples, FacingTandemCouplesRule
export BeforeEightChain, BeforeEightChainRule
export AfterEightChainOne, AfterEightChainOneRule
export CompletedDoublePassThru, CompletedDoublePassThruRule


"""
FacingTandemCouples is a formation of eight dancers (four
couples) lined up, and is the starting formation for the "double pass
thru" call.
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
                                                       ::FacingTandemCouples) begin
    if tc1 == tc2
        return
    end
    # Disambiguate TandemCouples to avoid duplicate symetric
    # formations:
    if direction(tc2) < direction(tc1)
        return
    end
    if (tc1.leaders == centers.couple1 &&
        tc2.leaders == centers.couple2)
        emit(FacingTandemCouples(tc1, tc2, centers))
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
                                                    ::BeforeEightChain) begin
    if fc1 == fc2
        return
    end
    if centers.couple1 == fc2.couple1 &&
        centers.couple2 == fc1.couple2
        emit(BeforeEightChain(fc1, fc2, centers))
    end
end

@doc """
BeforeEightChainRule is the rule for recognizing BeforeEightChain
formations.
""" BeforeEightChainRule


"""
AfterEightChainOne is a formation of eight dancers (four couples) lined
up, and is the starting formation for the call "trade by".  It can
result from doing a "centers pass thru" from a BeforeEightChain
formation.
```
←→←→
←→←→
```
"""
struct AfterEightChainOne <: EightDancerFormation
    bbcouples1::BackToBackCouples
    bbcouples2::BackToBackCouples
    centers::FacingCouples
end

@resumable function(f::AfterEightChainOne)()
    for ds in f.bbcouples1()
        @yield ds
    end
    for ds in f.bbcouples2()
        @yield ds
    end
end

handedness(::AfterEightChainOne) = NoHandedness()

@rule SquareDanceFormationRule.AfterEightChainOneRule(bb1::BackToBackCouples,
                                                      bb2::BackToBackCouples,
                                                      centers::FacingCouples,
                                                      ::AfterEightChainOne) begin
    if bb1 == bb2
        return
    end
    if (centers.couple1 == bb1.couple1 &&
        centers.couple2 == bb2.couple2)
        emit(AfterEightChainOne(bb1, bb2, centers))
    end
end

@doc """
AfterEightChainOneRule is the rule for recognizing AfterEightChainOne
formations.
""" AfterEightChainOneRule


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
                                                           ::CompletedDoublePassThru) begin
    if tc1 == tc2
        return
    end
    # Break symetry to avoid duplicates:
    if direction(tc1) > direction(tc2)
        return
    end
    if (centers.couple1 == tc1.trailers &&
        centers.couple2 == tc2.trailers)
        emit(CompletedDoublePassThru(tc1, tc2, centers))
    end
end

@doc """
CompletedDoublePassThruRule is the rule for rtecognizing
CompletedDoublePassThru formations.
""" CompletedDoublePassThruRule

