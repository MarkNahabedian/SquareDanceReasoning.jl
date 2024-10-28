
export WaveOfFour, WaveOfEight, RHWaveOfFour, LHWaveOfFour
export RHWaveOfEight, LHWaveOfEight
export WaveOfFourRule, WaveOfEightRule


"""
WaveOfFour is the abstract supertype for right and left handed
waves of four dancers.
"""
abstract type WaveOfFour <: OneByFourFormation end


"""
WaveOfEight is the abstract supertype for right and left handed
waves of eight dancers.
"""
abstract type WaveOfEight <: EightDancerFormation end

@resumable function(f::WaveOfFour)()
    for ds in f.wave1()
        @yield ds
    end
    for ds in f.wave2()
        @yield ds
    end
end

@resumable function(f::WaveOfEight)()
    for ds in f.wave1()
        @yield ds
    end
    for ds in f.wave2()
        @yield ds
    end
end

handedness(f::WaveOfFour) = handedness(f.wave1)
handedness(f::WaveOfEight) = handedness(f.wave1)

those_with_role(f::WaveOfEight, ::VeryCenter) = dancer_states(f.centers)
those_with_role(f::WaveOfEight, r::AllButVeryCenter) =
    setdiff(dancer_states(f), those_with_role(f, obverse(r)))
those_with_role(f::WaveOfEight, r::Union{Center, End}) = [
    those_with_role(f.wave1, r)...,
    those_with_role(f.wave2, r)... ]


"""
RHWaveOfFour represents a right handed wave of four dancers.
"""
struct RHWaveOfFour <: WaveOfFour
    wave1::RHMiniWave
    wave2::RHMiniWave
    centers::LHMiniWave
end


"""
LHWaveOfFour represents a left handed wave of four dancers.
"""
struct LHWaveOfFour <: WaveOfFour
    wave1::LHMiniWave
    wave2::LHMiniWave
    centers::RHMiniWave
end


"""
RHWaveOfEight represents a right handed wave of eight dancers.
"""
struct RHWaveOfEight <: WaveOfEight
    wave1::RHWaveOfFour
    wave2::RHWaveOfFour
    centers::LHMiniWave
end


"""
LHWaveOfEight represents a right handed wave of eight dancers.
"""
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
        @assert !isa(handedness(wave1), NoHandedness)
    end
    emit(constructor(wave1, wave2, centers))
end

@doc """
WaveOfFourRule is the rule for identifying waves of four
dancers: [`RHWaveOfFour`](@ref) and [`LHWaveOfFour`](@ref).
""" WaveOfFourRule


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
        @assert !isa(handedness(wave1), NoHandedness)
    end
    emit(constructor(wave1, wave2, centers))
end

@doc """
WaveOfEightRule is the rule for identifying waves of eight dancers:
[`RHWaveOfEight`](@ref) and [`LHWaveOfEight`](@ref).
""" WaveOfEightRule
