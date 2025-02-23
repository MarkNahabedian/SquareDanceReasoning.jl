
@testset "lines of four" begin
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    grid = grid_arrangement(square, [ 1 2 3 4; 5 6 7 8 ],
                            [ "↓↓↓↓", "↑↑↑↑" ])
    receive.([kb], grid)
    @debug_formations(kb)
    # First make sure we have the Couples:
    let
        m = find_memory_for_type(kb, Couple)
        @test length(m.memory) == 6
    end
    let
        lines = askc(Collector{LineOfFour}(), kb, LineOfFour)
        lines = sort(lines; by = f -> direction(f))
        @test direction(lines[1]) == 0
        @test direction(lines[2]) == 1//2
        @test length(lines) == 2
        handedness(lines[1]) == NoHandedness()
        @test length(dancer_states(lines[1])) == 4
        @test lines[1].a.belle.dancer == square[1]
        @test lines[1].a.beau.dancer == square[2]
        @test lines[1].b.belle.dancer == square[3]
        @test lines[1].b.beau.dancer == square[4]
        handedness(lines[2]) == NoHandedness()
        @test length(dancer_states(lines[2])) == 4
        @test lines[2].b.beau.dancer == square[5]
        @test lines[2].b.belle.dancer == square[6]
        @test lines[2].a.beau.dancer == square[7]
        @test lines[2].a.belle.dancer == square[8]
        let
            f = lines[1]
            @test Set(dancer.(those_with_role(f, kb, Centers()))) ==
                Set([ square[2], square[3] ])
            @test Set(dancer.(those_with_role(f, kb, Ends()))) ==
                Set([ square[1], square[4] ])
        end

        # We should also have four FaceToFace formations
        @test askc(Counter(), kb, FaceToFace) == 4
    end
    @test askc(Counter(), kb, FormationContainedIn) == 38
    collect_formation_examples(kb)
end
    
@testset "two faced lines" begin
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 1 2 3 4;
                              5 6 7 8 ],
                            [ "↑↑↓↓";
                              "↓↓↑↑" ])
    receive.([kb], grid)
    @debug_formations(kb)
    # First make sure we have the Couples:
    @test askc(Counter(), kb, Couple) == 4
    let
        lines = askc(Collector{TwoFacedLine}(), kb)
        for line in lines
            @test length(dancer_states(line)) == 4
            if handedness(line) == RightHanded()
                line_offset = 0
                @test handedness(line.centers) == RightHanded()
                @test line.b.beau.dancer == square[line_offset + 1]
                @test line.b.belle.dancer == square[line_offset + 2]
                @test line.a.belle.dancer == square[line_offset + 3]
                @test line.a.beau.dancer == square[line_offset + 4]
            else
                line_offset = 4
                @test handedness(line.centers) == LeftHanded()
                @test line.a.belle.dancer == square[line_offset + 1]
                @test line.a.beau.dancer == square[line_offset + 2]
                @test line.b.beau.dancer == square[line_offset + 3]
                @test line.b.belle.dancer == square[line_offset + 4]
            end
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
        @test askc(Counter(), kb, FormationContainedIn) == 34
    end
    collect_formation_examples(kb)
end

@testset "inverted lines of four" begin
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 1 2 3 4;
                              5 6 7 8 ],
                            [ "↑↓↓↑";
                              "↓↑↑↓" ])
    receive.([kb], grid)
    @debug_formations(kb)
    lines = askc(Collector{InvertedLineOfFour}(), kb)
    @test length(lines) == 2
    for line in lines
        @test length(dancer_states(line)) == 4
        @test line.a.a.direction == 0
        @test line.a.b.direction == 1//2
        @test line.b.a.direction == 0
        @test line.b.b.direction == 1//2
    end
end

