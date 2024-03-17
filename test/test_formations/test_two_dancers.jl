
using SquareDanceReasoning: TwoDancerFormationsRule

@testset "test two dancer formations" begin
    dancers = make_dancers(6)
    kb = ReteRootNode("root")
    install(kb, TwoDancerFormationsRule)
    ensure_IsaMemoryNode(kb, Dancer)
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    @test length(kb.outputs) == 8
    for dancer in dancers
        receive(kb, dancer)
    end
    # Couple
    receive(kb, DancerState(dancers[1], 0, 0, 0, 1))
    receive(kb, DancerState(dancers[2], 0, 0, 0, 2))
    # FaceToFace
    receive(kb, DancerState(dancers[3], 0, 1//4, 2, 1))
    receive(kb, DancerState(dancers[4], 0, 3//4, 2, 2))
    # BackToBack
    receive(kb, DancerState(dancers[5], 0, 3//4, 4, 1))
    receive(kb, DancerState(dancers[6], 0, 1//4, 4, 2))
    # Tandem
    receive(kb, DancerState(dancers[7], 0, 1//4, 6, 1))
    receive(kb, DancerState(dancers[8], 0, 1//4, 6, 2))    
    # RHMiniWave
    receive(kb, DancerState(dancers[9],  0, 1//2, 8, 1))
    receive(kb, DancerState(dancers[10], 0,    0, 8, 2))
    # LHMiniWave
    receive(kb, DancerState(dancers[11], 0,    0, 10, 1))
    receive(kb, DancerState(dancers[12], 0, 1//2, 10, 2))
    let
        m = find_memory_for_type(kb, Couple)
        @test length(m.memory) == 1
        f = first(m.memory)
        @test f isa Couple
        @test direction_equal(f.beau.direction, f.belle.direction)
        @test f.beau.dancer == dancers[2]
        @test f.belle.dancer == dancers[1]
    end
    let
        m = find_memory_for_type(kb, FaceToFace)
        @test length(m.memory) == 1
        f = first(m.memory)
        @test f isa FaceToFace
        @test handedness(f) == NoHandedness()
        @test f.a.direction < f.b.direction
        @test f.a.dancer == dancers[3]
        @test f.b.dancer == dancers[4]
    end
    let
        m = find_memory_for_type(kb, BackToBack)
        @test length(m.memory) == 1
        f = first(m.memory)
        @test f isa BackToBack
        @test handedness(f) == NoHandedness()
        @test f.a.direction < f.b.direction
        @test f.a.dancer == dancers[6]
        @test f.b.dancer == dancers[5]
    end
    let
        m = find_memory_for_type(kb, Tandem)
        @test length(m.memory) == 1
        f = first(m.memory)
        @test handedness(f) == NoHandedness()
        @test f isa Tandem
        @test f.leader.dancer == dancers[8]
        @test f.trailer.dancer == dancers[7]
    end
    let
        m = find_memory_for_type(kb, RHMiniWave)
        @test length(m.memory) == 1
        f = first(m.memory)
        @test handedness(f) == RightHanded()
        @test f isa RHMiniWave
        @test f.a.direction < f.b.direction
        @test f.a.dancer == dancers[10]
        @test f.b.dancer == dancers[9]
    end
    let
        m = find_memory_for_type(kb, LHMiniWave)
        @test length(m.memory) == 1
        f = first(m.memory)
        @test handedness(f) == LeftHanded()
        @test f isa LHMiniWave
        @test f.a.direction < f.b.direction
        @test f.a.dancer == dancers[11]
        @test f.b.dancer == dancers[12]
    end
end

