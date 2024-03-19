
function make_wave(dancers, initial_direction)
    direction = initial_direction
    down = 0
    left = 1
    map(dancers) do dancer
        ds = DancerState(dancer, 0, direction, down, left)
        left += 1
        direction = opposite(direction)
        ds
    end
end
    

@testset "test right hand wave of four" begin
    dancers = make_dancers(2)
    kb = ReteRootNode("root")
    install(kb, TwoDancerFormationsRule)
    install(kb, WaveOfFourRule)
    ensure_IsaMemoryNode(kb, Dancer)
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    @test length(kb.outputs) == 11
    for dancer in dancers
        receive(kb, dancer)
    end
    for ds in make_wave(dancers, 1//2)
        receive(kb, ds)
    end
    @debug_formations(kb)
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
        @test length(dancer_states(f)) == 4
        @test handedness(f) == RightHanded()
        @test f.wave1.a.dancer == dancers[2]
        @test f.wave1.b.dancer == dancers[1]
        @test f.wave2.a.dancer == dancers[4]
        @test f.wave2.b.dancer == dancers[3]
    end
end

@testset "test left hand wave of four" begin
    dancers = make_dancers(2)
    kb = ReteRootNode("root")
    install(kb, TwoDancerFormationsRule)
    install(kb, WaveOfFourRule)
    ensure_IsaMemoryNode(kb, Dancer)
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    @test length(kb.outputs) == 11
    for dancer in dancers
        receive(kb, dancer)
    end
    for ds in make_wave(dancers, 0)
        receive(kb, ds)
    end
    @debug_formations(kb)
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
        @test length(dancer_states(f)) == 4
        @test handedness(f) == LeftHanded()
        @test f.wave1.a.dancer == dancers[3]
        @test f.wave1.b.dancer == dancers[4]
        @test f.wave2.a.dancer == dancers[1]
        @test f.wave2.b.dancer == dancers[2]
    end
end

@testset "test right hand wave of eight" begin
    dancers = make_dancers(4)
    kb = ReteRootNode("root")
    install(kb, TwoDancerFormationsRule)
    install(kb, WaveOfFourRule)
    install(kb, WaveOfEightRule)
    ensure_IsaMemoryNode(kb, Dancer)
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    @test length(kb.outputs) == 14
    for dancer in dancers
        receive(kb, dancer)
    end
    for ds in make_wave(dancers, 1//2)
        receive(kb, ds)
    end
    # First make sure we have the MiniWaves:
    let
        m = find_memory_for_type(kb, RHMiniWave)
        @test length(m.memory) == 4
    end
    let
        m = find_memory_for_type(kb, LHMiniWave)
        @test length(m.memory) == 3
    end
    let
        m = find_memory_for_type(kb, RHWaveOfEight)
        @test length(m.memory) == 1
        f = first(m.memory)
        @test handedness(f) == RightHanded()
        @test f.wave1.wave1.a.dancer == dancers[2]
        @test f.wave1.wave1.b.dancer == dancers[1]
        @test f.wave1.wave2.a.dancer == dancers[4]
        @test f.wave1.wave2.b.dancer == dancers[3]
        @test f.wave2.wave1.a.dancer == dancers[6]
        @test f.wave2.wave1.b.dancer == dancers[5]
        @test f.wave2.wave2.a.dancer == dancers[8]
        @test f.wave2.wave2.b.dancer == dancers[7]
    end
end
