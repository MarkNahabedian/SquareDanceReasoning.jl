# Formations of four dancers that are two dancers wide and two high.

export FacingCouples, BackToBackCouples, TandemCouples, CoupleBoxRule
export BoxOfFour, RHBoxOfFour, LHBoxOfFour, BoxOfFourRule


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


@rule SquareDanceFormationRule.CoupleBoxRule(kb::SDRKnowledgeBase,
                                             couple1::Couple,
                                             couple2::Couple,
                                             ::FacingCouples,
                                             ::BackToBackCouples,
                                             ::TandemCouples,
                                             ::FormationContainedIn) begin
    if couple1 == couple2
        return
    end
    # Symetry disambiguation
    if direction(couple1) > direction(couple2)
        return
    end
    # No other dancers in the way:
    if encroached_on([couple1, couple2], kb)
        return
    end
    if encroached_on([ couple1, couple2 ], kb)
        return
    end
    local f
    if ((direction(couple1) == direction(couple2)) &&
        in_front_of(couple2.beau, couple1.beau) &&
        in_front_of(couple2.belle, couple1.belle))
        f = TandemCouples(couple1, couple2)
        emit(f)
    elseif direction(couple1) == opposite(direction(couple2))
        if (in_front_of(couple1.beau, couple2.belle) &&
            in_front_of(couple2.belle, couple1.beau) &&
            in_front_of(couple1.belle, couple2.beau) &&
            in_front_of(couple2.beau, couple1.belle))
            f = FacingCouples(couple1, couple2)
            emit(f)
        elseif (behind(couple1.beau, couple2.belle) &&
            behind(couple2.belle, couple1.beau) &&
            behind(couple1.belle, couple2.beau) &&
            behind(couple2.beau, couple1.belle))
            f = BackToBackCouples(couple1, couple2)
            emit(f)
        end
    end
    if @isdefined f    
        emit(FormationContainedIn(couple1, f))
        emit(FormationContainedIn(couple2, f))
    end
end

@doc """
CoupleBoxRule is the rule for identifying two couples arranged in a
two by two box.
""" CoupleBoxRule


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
    if mw1 == mw2
        return
    end
    if t1 == t2
        return
    end
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
