
function make_line(dancers, direction, down)
    left = 1
    map(dancers) do dancer
        ds = DancerState(dancer, 0, direction, down, left)
        left += 1
        ds
    end
end

@testset "lines of four" begin
    dancers = make_dancers(4)
    kb = BasicReteNode("root")
    install(kb, SquareDanceFormationRule)
    ensure_IsaMemoryNode(kb, Dancer)
    for dancer in dancers
        receive(kb, dancer)
    end
    for ds in make_line(dancers[1:4], 0, 0)
        receive(kb, ds)
    end
    for ds in make_line(dancers[5:8], 0.5, 1)
        receive(kb, ds)
    end
    # First make sure we have the Couples:
    let
        m = find_memory_for_type(kb, Couple)
        @test length(m.memory) == 6
    end
    let
        m = find_memory_for_type(kb, LineOfFour)
        lines = collecting() do c
            askc(c, m)
        end
        lines = sort(lines; by = f -> f.a.beau.direction)
        @test length(lines) == 2
        handedness(lines[1]) == NoHandedness()
        @test length(dancer_states(lines[1])) == 4
        @test lines[1].a.belle.dancer == dancers[1]
        @test lines[1].a.beau.dancer == dancers[2]
        @test lines[1].b.belle.dancer == dancers[3]
        @test lines[1].b.beau.dancer == dancers[4]
        handedness(lines[2]) == NoHandedness()
        @test length(dancer_states(lines[2])) == 4
        @test lines[2].b.beau.dancer == dancers[5]
        @test lines[2].b.belle.dancer == dancers[6]
        @test lines[2].a.beau.dancer == dancers[7]
        @test lines[2].a.belle.dancer == dancers[8]
        # We should also have four FaceToFace formations
        let
            m = find_memory_for_type(kb, FaceToFace)
            @test length(m.memory) == 4
        end
    end
end
    
