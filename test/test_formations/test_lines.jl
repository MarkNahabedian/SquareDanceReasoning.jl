
@testset "lines of four" begin
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    dancers = sort(collect(square.dancers))
    for ds in make_line(dancers[1:4], 0, 0)
        receive(kb, ds)
    end
    for ds in make_line(dancers[5:8], 0.5, 1)
        receive(kb, ds)
    end
    @debug_formations(kb)
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
    
@testset "two faced lines" begin
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    dancers = collect(square.dancers)
    # Rught hand two faced line:  ↑↑↓↓
    receive(kb, DancerState(dancers[1], 0, 1//2, 0, 1))
    receive(kb, DancerState(dancers[2], 0, 1//2, 0, 2))
    receive(kb, DancerState(dancers[3], 0,    0, 0, 3))
    receive(kb, DancerState(dancers[4], 0,    0, 0, 4))
    # Left hand two faced line    ↓↓↑↑
    receive(kb, DancerState(dancers[5], 0,    0, 1, 1))
    receive(kb, DancerState(dancers[6], 0,    0, 1, 2))
    receive(kb, DancerState(dancers[7], 0, 1//2, 1, 3))
    receive(kb, DancerState(dancers[8], 0, 1//2, 1, 4))
    @debug_formations(kb)
    # First make sure we have the Couples:
    let
        m = find_memory_for_type(kb, Couple)
        @test length(m.memory) == 4
    end
    let
        m = find_memory_for_type(kb, TwoFacedLine)
        lines = collecting() do c
            askc(c, m)
        end
        line_offset = 0
        for line in lines
            @test length(dancer_states(line)) == 4
            if handedness(line) == RightHanded()
                @test handedness(line.centers) == RightHanded()
                @test line.b.beau.dancer == dancers[line_offset + 1]
                @test line.b.belle.dancer == dancers[line_offset + 2]
                @test line.a.belle.dancer == dancers[line_offset + 3]
                @test line.a.beau.dancer == dancers[line_offset + 4]
            else
                @test handedness(line.centers) == LeftHanded()
                @test line.a.belle.dancer == dancers[line_offset + 1]
                @test line.a.beau.dancer == dancers[line_offset + 2]
                @test line.b.beau.dancer == dancers[line_offset + 3]
                @test line.b.belle.dancer == dancers[line_offset + 4]
            end
            line_offset += 4
        end
        # We should also have two FaceToFace and two BackToBack
        # couples:
        let
            m = find_memory_for_type(kb, FaceToFace)
            @test length(m.memory) == 2
        end
        let
            m = find_memory_for_type(kb, BackToBack)
            @test length(m.memory) == 2
        end
    end
end

