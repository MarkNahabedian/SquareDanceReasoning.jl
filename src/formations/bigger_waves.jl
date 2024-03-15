
export WaveOfFour, WaveOfEight, RHWaveOfFour, LHWaveOfFour
export WaveOfFourRule

abstract type WaveOfFour <: FourDancerFormation end
abstract type WaveOfEight <: EightDancerFormation end

dancers(f::WaveOfFour) = [ dancers(f.wave1)...,
                           dancers(f.wave2)... ]

handedness(f::WaveOfFour) = handedness(f.wave1)

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

