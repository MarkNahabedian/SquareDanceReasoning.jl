# Formations of four dancers that are two dancers wide and two high.

export FacingCouples, BackToBackCouples, TandemCouples, CoupleBoxRule
export BoxOfFour, RHBoxOfFour, LHBoxOfFour, BoxOfFourRule


"""
    TwoDifferentCouples

TwoDifferentCouples is a preliminary fact that supports the rules for
finding FacingCouples, BackToBackCouples and TandemCouples.
"""
struct TwoDifferentCouples <: TemporalFact
    couple1::Couple
    couple2::Couple
end


@rule SquareDanceFormationRule.TwoDifferentCouplesRule(kb::SDRKnowledgeBase,
                                                       couple1::Couple,
                                                       couple2::Couple,
                                                       ::TwoDifferentCouples) begin
    # Different couples:
    @rejectif couple1 == couple2
    # Contemporary:
    @continueif timeof(couple1) == timeof(couple2)
    # Symetry disambiguation
    @rejectif direction(couple1) > direction(couple2)
    # No other dancers in the way:
    @rejectif encroached_on([couple1, couple2], kb)
    @rejectif encroached_on([ couple1, couple2 ], kb)
    emit(TwoDifferentCouples(couple1, couple2))
end


"""
FacingCouples is a formation that includes two `Couple` formations
that are facing each other.
"""
struct FacingCouples <: FourDancerFormation
    couple1::Couple
    couple2::Couple
end

@resumable function(f::FacingCouples)()
    for f2 in f.couple1()
        @yield f2
    end
    for f2 in f.couple2()
        @yield f2
    end
end

handedness(::FacingCouples) = NoHandedness()

@rule SquareDanceFormationRule.FacingCouplesRule(tdc::TwoDifferentCouples,
                                                 f2f1::FaceToFace,
                                                 f2f2::FaceToFace,
                                                 ::FacingCouples,
                                                 ::FormationContainedIn) begin
    couple1 = tdc.couple1
    couple2 = tdc.couple2
    @continueif timeof(couple1) == timeof(couple2)
    if (f2f1.a in couple1 &&
        f2f1.b in couple2 &&
        f2f2.a in couple1 &&
        f2f2.b in couple2)
        f = FacingCouples(couple1, couple2)
        emit(f)
        emit(FormationContainedIn(couple1, f))
        emit(FormationContainedIn(couple2, f))
        emit(FormationContainedIn(f2f1, f))
        emit(FormationContainedIn(f2f2, f))
    end
end

@doc """
FacingCouplesRule is the rule for identifying the FacingCouples
formation.
""" FacingCouplesRule


"""
BackToBackCouples is a formation that includes two `Couple` formations
that have their backs to each other.
"""
struct BackToBackCouples <: FourDancerFormation
    couple1::Couple
    couple2::Couple
end

@resumable function(f::BackToBackCouples)()
    for f2 in f.couple1()
        @yield f2
    end
    for f2 in f.couple2()
        @yield f2
    end
end

handedness(::BackToBackCouples) = NoHandedness()
    
@rule SquareDanceFormationRule.BackToBackCouplesRule(tdc::TwoDifferentCouples,
                                                     b2b1::BackToBack,
                                                     b2b2::BackToBack,
                                                     ::BackToBackCouples,
                                                     ::FormationContainedIn) begin
    couple1 = tdc.couple1
    couple2 = tdc.couple2
    @continueif timeof(couple1) == timeof(couple2)
    if (b2b1.a in couple1 &&
        b2b1.b in couple2 &&
        b2b2.a in couple1 &&
        b2b2.b in couple2)
        f = BackToBackCouples(couple1, couple2)
        emit(f)
        emit(FormationContainedIn(couple1, f))
        emit(FormationContainedIn(couple2, f))
        emit(FormationContainedIn(b2b1, f))
        emit(FormationContainedIn(b2b2, f))
    end
end

@doc """
BackToBackCouplesRule is the rule for identifying the
BackToBackCouples formation.
""" BackToBackCouplesRule


"""
TandemCouples is a formation for two Couples in Tandem.
"""
struct TandemCouples <: FourDancerFormation
    leaders::Couple
    trailers::Couple
end

@resumable function(f::TandemCouples)()
    for f2 in f.leaders()
        @yield f2
    end
    for f2 in f.trailers()
        @yield f2
    end
end

handedness(::TandemCouples) = NoHandedness()

direction(f::TandemCouples) = direction(f.leaders)

@rule SquareDanceFormationRule.TandemCouplesRule(tdc::TwoDifferentCouples,
                                                 tandem1::Tandem,
                                                 tandem2::Tandem,
                                                 ::TandemCouples,
                                                 ::FormationContainedIn) begin
    leaders = tdc.couple1
    trailers = tdc.couple2
    @continueif timeof(leaders) == timeof(trailers)
    if (tandem1.leader in leaders &&
        tandem1.trailer in trailers &&
        tandem2.leader in leaders &&
        tandem2.trailer in trailers)
        f = TandemCouples(leaders, trailers)
        emit(f)
        emit(FormationContainedIn(leaders, f))
        emit(FormationContainedIn(trailers, f))
        emit(FormationContainedIn(tandem1, f))
        emit(FormationContainedIn(tandem2, f))
    end
end

@doc """
TandemCouplesRule is the rule for identifying the
TandemCouples formation.
""" TandemCouplesRule


"""
BoxOfFour is the abstract supertype for RHBoxOfFour and LHBoxOfFour.
"""
abstract type BoxOfFour <: FourDancerFormation end

@resumable function(f::BoxOfFour)()
    for f2 in f.miniwave1()
        @yield f2
    end
    for f2 in f.miniwave2()
        @yield f2
    end
end

handedness(b::BoxOfFour) = handedness(b.miniwave1)

function circulate_paths(f::BoxOfFour)
    [
        CirculatePath([
            f.tandem1.trailer,
            f.tandem1.leader,
            f.tandem2.trailer,
            f.tandem2.leader
        ])
    ]
end


"""
RHBoxOfFour represents a right handed "box circulate" formation.
"""
struct RHBoxOfFour <: BoxOfFour
    miniwave1::RHMiniWave
    miniwave2::RHMiniWave
    tandem1::Tandem
    tandem2::Tandem
end


"""
LHBoxOfFour represents a left handed "box circulate" formation.
"""
struct LHBoxOfFour <: BoxOfFour
    miniwave1::LHMiniWave
    miniwave2::LHMiniWave
    tandem1::Tandem
    tandem2::Tandem
end


@rule SquareDanceFormationRule.BoxOfFourRule(mw1::MiniWave,
                                             mw2::MiniWave,
                                             t1::Tandem,
                                             t2::Tandem,
                                             ::RHBoxOfFour,
                                             ::LHBoxOfFour,
                                             ::FormationContainedIn) begin
    @rejectif mw1 == mw2
    @rejectif t1 == t2
    @continueif timeof(mw1) == timeof(mw2)
    if !(handedness(mw1) == handedness(mw2))
        return
    end
    # Disambiguate tandems by facing direction:
    if direction(t1) > direction(t2)
        return
    end
    if (t1.leader in mw1() &&
        t1.trailer in mw2() &&
        t2.leader in mw2() &&
        t2.trailer in mw1())
        if handedness(mw1) == RightHanded()
            box = RHBoxOfFour(mw1, mw2, t1, t2)
            emit(box)
        else
            box = LHBoxOfFour(mw1, mw2, t1, t2)
            emit(box)
        end
        emit(FormationContainedIn(mw1, box))
        emit(FormationContainedIn(mw2, box))
        emit(FormationContainedIn(t1, box))
        emit(FormationContainedIn(t2, box))
    end
end

@doc """
BoxOfFourRule is the rule for identifying right or left handed "box
circulate" formations.
""" BoxOfFourRule
