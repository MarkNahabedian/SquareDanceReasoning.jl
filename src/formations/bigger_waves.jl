
export WaveOfFour, WaveOfEight, RHWaveOfFour, LHWaveOfFour
export RHWaveOfEight, LHWaveOfEight
export WaveOfFourRule, WaveOfEightRule

abstract type WaveOfFour <: FourDancerFormation end
abstract type WaveOfEight <: EightDancerFormation end

dancer_states(f::WaveOfFour) = [ dancers(f.wave1)...,
                                 dancers(f.wave2)... ]

dancer_states(f::WaveOfEight) = [ dancers(f.wave1)...,
                                  dancers(f.wave2)... ]

handedness(f::WaveOfFour) = handedness(f.wave1)
handedness(f::WaveOfEight) = handedness(f.wave1)

struct RHWaveOfFour <: WaveOfFour
    wave1::RHMiniWave
    wave2::RHMiniWave
    centers::LHMiniWave
end

struct LHWaveOfFour <: WaveOfFour
    wave1::LHMiniWave
    wave2::LHMiniWave
    centers::RHMiniWave
end

struct RHWaveOfEight <: WaveOfEight
    wave1::RHWaveOfFour
    wave2::RHWaveOfFour
    centers::LHMiniWave
end

struct LHWaveOfEight <: WaveOfEight
    wave1::LHWaveOfFour
    wave2::LHWaveOfFour
    very_centers::RHMiniWave
end


@rule SquareDanceFormationRule.WaveOfFourRule(wave1::MiniWave,
                                              wave2::MiniWave,
                                              centers::MiniWave,
                                              ::RHWaveOfFour,
                                              ::LHWaveOfFour) begin
    if wave1 == wave2
        return
    end
    if !(handedness(wave1) == handedness(wave2) &&
         handedness(wave1) == opposite(handedness(centers)) &&
         handedness(wave2) == opposite(handedness(centers)))
        return
    end
    # How do we break symery between wave1 and wave2?  They will only
    # connect to centers one way.
    if centers.a != wave1.a
        return
    end
    if centers.b != wave2.b
        return
    end
    if handedness(wave1) == RightHanded()
        constructor = RHWaveOfFour
    elseif handedness(wave1) == LeftHanded()
        constructor = LHWaveOfFour
    else
        error("Non-handed MiniWave!")
    end
    emit(constructor(wave1, wave2, centers))
end


# Note that the Rete will have memory nodes for WaveOfFour as well as
# RHWaveOfFour and LHWaveOfFour.
@rule SquareDanceFormationRule.WaveOfEightRule(wave1::WaveOfFour,
                                               wave2::WaveOfFour,
                                               centers::MiniWave,
                                               ::RHWaveOfEight,
                                               ::LHWaveOfEight) begin
    if wave1 == wave2
        return
    end
    if !(handedness(wave1) == handedness(wave2) &&
         handedness(wave1) == opposite(handedness(centers)) &&
         handedness(wave2) == opposite(handedness(centers)))
        return
    end
    # how do we know which miniwave to check?  Nearness to center?
    # Ends of the RHMiniWaves are wave1.b and wave2.a
    if centers.a != wave1.wave2.a
        return
    end
    if centers.b != wave2.wave1.b
        return
    end
    if handedness(wave1) == RightHanded()
        constructor = RHWaveOfEight
    elseif handedness(wave1) == LeftHanded()
        constructor = LHWaveOfEight
    else
        error("Non-handed MiniWave!")
    end
    emit(constructor(wave1, wave2, centers))
end

