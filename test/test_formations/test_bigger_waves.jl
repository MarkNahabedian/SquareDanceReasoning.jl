
@testset "test right hand wave of four" begin
    dancers = make_dancers(2)
    kb = BasicReteNode("root")
    install(kb, TwoDancerFormationsRule)
    install(kb, WaveOfFourRule)
    ensure_IsaMemoryNode(kb, Dancer)
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    @test length(kb.outputs) == 11
    for dancer in dancers
        receive(kb, dancer)
    end
    receive(kb, DancerState(dancers[1], 0, 1//2, 0, 1))
    receive(kb, DancerState(dancers[2], 0,    0, 0, 2))
    receive(kb, DancerState(dancers[3], 0, 1//2, 0, 3))
    receive(kb, DancerState(dancers[4], 0,    0, 0, 4))
    # First make sure we have the MiniWaves:
    let
        m = find_memory_for_type(kb, RHMiniWave)
        @test length(m.memory) == 2
    end
    let
        m = find_memory_for_type(kb, LHMiniWave)
        @test length(m.memory) == 1
    end
    let
        m = find_memory_for_type(kb, RHWaveOfFour)
        @test length(m.memory) == 1
        f = first(m.memory)
        @test handedness(f) == RightHanded()
        @test f.wave1.a.dancer == dancers[2]
        @test f.wave1.b.dancer == dancers[1]
        @test f.wave2.a.dancer == dancers[4]
        @test f.wave2.b.dancer == dancers[3]
    end
end

@testset "test left hand wave of four" begin
    dancers = make_dancers(2)
    kb = BasicReteNode("root")
    install(kb, TwoDancerFormationsRule)
    install(kb, WaveOfFourRule)
    ensure_IsaMemoryNode(kb, Dancer)
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    @test length(kb.outputs) == 11
    for dancer in dancers
        receive(kb, dancer)
    end
    receive(kb, DancerState(dancers[1], 0,    0, 0, 1))
    receive(kb, DancerState(dancers[2], 0, 1//2, 0, 2))
    receive(kb, DancerState(dancers[3], 0,    0, 0, 3))
    receive(kb, DancerState(dancers[4], 0, 1//2, 0, 4))
    # First make sure we have the MiniWaves:
    let
        m = find_memory_for_type(kb, RHMiniWave)
        @test length(m.memory) == 1
    end
    let
        m = find_memory_for_type(kb, LHMiniWave)
        @test length(m.memory) == 2
    end
    let
        m = find_memory_for_type(kb, LHWaveOfFour)
        @test length(m.memory) == 1
        f = first(m.memory)
        @test handedness(f) == LeftHanded()
        @test f.wave1.a.dancer == dancers[3]
        @test f.wave1.b.dancer == dancers[4]
        @test f.wave2.a.dancer == dancers[1]
        @test f.wave2.b.dancer == dancers[2]
    end
end

