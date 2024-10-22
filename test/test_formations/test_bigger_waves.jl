
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
    square = make_square(2)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    for ds in make_wave(square.dancers, 1//2)
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
        @test f.wave1.a.dancer == square[2]
        @test f.wave1.b.dancer == square[1]
        @test f.wave2.a.dancer == square[4]
        @test f.wave2.b.dancer == square[3]
    end
    collect_formation_examples(kb)
end

@testset "test left hand wave of four" begin
    square = make_square(2)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    for ds in make_wave(square.dancers, 0)
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
        @test f.wave1.a.dancer == square[3]
        @test f.wave1.b.dancer == square[4]
        @test f.wave2.a.dancer == square[1]
        @test f.wave2.b.dancer == square[2]
    end
    collect_formation_examples(kb)
end

@testset "test right hand wave of eight" begin
    square = make_square(4)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    for ds in make_wave(square.dancers, 1//2)
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
        push!(TEXT_EXAMPLE_FORMATIONS, f)
        @test handedness(f) == RightHanded()
        @test f.wave1.wave1.a.dancer == square[2]
        @test f.wave1.wave1.b.dancer == square[1]
        @test f.wave1.wave2.a.dancer == square[4]
        @test f.wave1.wave2.b.dancer == square[3]
        @test f.wave2.wave1.a.dancer == square[6]
        @test f.wave2.wave1.b.dancer == square[5]
        @test f.wave2.wave2.a.dancer == square[8]
        @test f.wave2.wave2.b.dancer == square[7]
    end
    collect_formation_examples(kb)
end
