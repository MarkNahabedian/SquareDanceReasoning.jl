export NQuarterTag, QuarterTag, ThreeQuarterTag
export QuarterTagRule, ThreeQuarterTagRule


"""
QTWCT is an intermediate result to sypport the rules for recognizing
QuarterTag and ThreeQuarterTag.
"""
struct QTWCT
    wave::WaveOfFour
    couple1::Couple
    couple2::Couple
    tandem1::Tandem
    tandem2::Tandem
end    

@rule SquareDanceFormationRule.QTWCTRule(wave::WaveOfFour,
                                         couple1::Couple,
                                         couple2::Couple,
                                         tandem1::Tandem,
                                         tandem2::Tandem,
                                         ::QTWCT) begin
    @rejectif couple1 == couple2
    @rejectif tandem1 == tandem2
    @continueif timeof(wave) == timeof(couple1) == timeof(couple2)
    # Break Couple symetry:
    @rejectif direction(couple2) < direction(couple1)
    # BreaK Tandem symetry:
    @rejectif direction(tandem2) < direction(tandem1)
    # The first argument of intersect can't be an iterator:
    @rejectif length(intersect(dancer_states(wave.centers),
                        tandem1())) != 1
    @rejectif length(intersect(dancer_states(wave.centers),
                        tandem2())) != 1
    emit(QTWCT(wave, couple1, couple2, tandem1, tandem2))
end

@doc """
QTWCTRule is a rule that provides a precursor fact for
QuarterTagRule and ThreeQuarterTagRule.
""" QTWCTRule




"""
NQuarterTag is the abstract supertype for QuarterTag and
ThreeQuarterTag formations.
"""
abstract type NQuarterTag <: EightDancerFormation end

handedness(f::NQuarterTag) = handedness(f.wave)

@resumable function(f::NQuarterTag)()
    for ds in f.couple1()
        @yield ds
    end
    for ds in f.wave()
        @yield ds
    end
    for ds in f.couple2()
        @yield ds
    end
end


"""
QuarterTag represents a quarter tag formation.
"""
struct QuarterTag <: NQuarterTag
    wave::WaveOfFour
    couple1::Couple
    couple2::Couple
    tandem1::Tandem
    tandem2::Tandem
    f2f1::FaceToFace
    f2f2::FaceToFace
end


@rule SquareDanceFormationRule.QuarterTagRule(q::QTWCT,
                                              f2f1::FaceToFace,
                                              f2f2::FaceToFace,
                                              ::QuarterTag,
                                              ::FormationContainedIn) begin

    @rejectif f2f1 == f2f2
    # The leader of each tandem is in the center of the wave
    centers = q.wave.centers()
    @continueif q.tandem1.leader in centers
    @continueif q.tandem2.leader in centers
    # Match the FaceToFace subformations with their related tandems:
    @continueif q.tandem1.leader in f2f1()
    @continueif q.tandem2.leader in f2f2()
    qt = QuarterTag(q.wave, q.couple1, q.couple2,
                    q.tandem1, q.tandem2,
                    f2f1, f2f2)
    emit(qt)
    emit(FormationContainedIn(q.wave, qt))
    emit(FormationContainedIn(q.couple1, qt))
    emit(FormationContainedIn(q.couple2, qt))
    emit(FormationContainedIn(q.tandem1, qt))
    emit(FormationContainedIn(q.tandem2, qt))
    emit(FormationContainedIn(f2f1, qt))
    emit(FormationContainedIn(f2f2, qt))
end

@doc """
QuarterTagRule is the rule for identifying
[`QuarterTag`](@ref) formations.
""" QuarterTagRule



"""
ThreeQuarterTag represents a three quarter tag formation.
"""
struct ThreeQuarterTag <: NQuarterTag
    wave::WaveOfFour
    couple1::Couple
    couple2::Couple
    tandem1::Tandem
    tandem2::Tandem
    b2b1::BackToBack
    b2b2::BackToBack
end


@rule SquareDanceFormationRule.ThreeQuarterTagRule(q::QTWCT,
                                                   b2b1::BackToBack,
                                                   b2b2::BackToBack,
                                                   ::ThreeQuarterTag,
                                                   ::FormationContainedIn) begin
    @rejectif b2b1 == b2b2
    # The leader of each tandem is in the center of the wave
    centers = dancer_states(q.wave.centers)
    @continueif q.tandem1.trailer in centers
    @continueif q.tandem2.trailer in centers
    # Match the BackToBack subformations with their related tandems:
    @continueif q.tandem1.trailer in b2b1()
    @continueif q.tandem2.trailer in b2b2()
    qt = ThreeQuarterTag(q.wave, q.couple1, q.couple2,
                         q.tandem1, q.tandem2,
                         b2b1, b2b2)
    emit(qt)
    emit(FormationContainedIn(q.wave, qt))
    emit(FormationContainedIn(q.couple1, qt))
    emit(FormationContainedIn(q.couple2, qt))
    emit(FormationContainedIn(q.tandem1, qt))
    emit(FormationContainedIn(q.tandem2, qt))
    emit(FormationContainedIn(b2b1, qt))
    emit(FormationContainedIn(b2b2, qt))
end

@doc """
ThreeQuarterTagRule is the rule for identifying
[`ThreeQuarterTag`](@ref) formations.
""" ThreeQuarterTagRule

