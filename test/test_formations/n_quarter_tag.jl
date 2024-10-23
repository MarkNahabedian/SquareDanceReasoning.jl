
@testset "test QuarterTag" begin
    square = make_square(4)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 0 4 3 0;
                              5 2 6 1;
                              0 7 8 0],
                            [ " ↓↓ ",
                              "↑↓↑↓",
                              " ↑↑ " ])
    map(grid) do ds
        if ds != nothing
            receive(kb, ds)
        end
    end
    @debug_formations(kb)
    #=
    write_formation_html_file("test QuarterTag",
                              joinpath(@__DIR__, "QuarterTag.html"),
                              kb)
    =#
    @test askc(Counter(), kb, SquareDanceReasoning.QTWCT) == 1
    f = askc(Collector{QuarterTag}(), kb, QuarterTag)
    @test length(f) == 1
    f = first(f)
    @test length(dancer_states(f)) == 8
    @test handedness(f) == RightHanded()
    wave_dancers = map(ds -> ds.dancer, dancer_states(f.wave))
    @test square[1] in wave_dancers
    @test square[2] in wave_dancers
    @test square[5] in wave_dancers
    @test square[6] in wave_dancers
    @test square[2] == f.tandem1.leader.dancer
    @test square[4] == f.tandem1.trailer.dancer
    @test square[6] == f.tandem2.leader.dancer
    @test square[8] == f.tandem2.trailer.dancer
    @test f.tandem1.trailer == f.couple1.belle
    @test f.tandem2.trailer == f.couple2.belle
    @test f.f2f1.a == f.tandem1.leader
    @test f.f2f2.b == f.tandem2.leader
    @test f.f2f1.b == f.couple2.beau
    @test f.f2f2.a == f.couple1.beau
end

                 
@testset "test ThreeQuarterTag" begin
    square = make_square(4)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 0 5 6 0;
                              7 4 8 3;
                              0 2 1 0],
                            [ " ↑↑ ",
                              "↑↓↑↓",
                              " ↓↓ " ])
    map(grid) do ds
        if ds != nothing
            receive(kb, ds)
        end
    end
    @debug_formations(kb)
    #=
    write_formation_html_file("test ThreeQuarterTag",
                              joinpath(@__DIR__, "ThreeQuarterTag.html"),
                              kb)
    =#
    @test askc(Counter(), kb, SquareDanceReasoning.QTWCT) == 1
    f = askc(Collector{ThreeQuarterTag}(), kb, ThreeQuarterTag)
    @test length(f) == 1
    f = first(f)
    @test length(dancer_states(f)) == 8
    @test handedness(f) == RightHanded()
    wave_dancers = map(ds -> ds.dancer, dancer_states(f.wave))
    @test square[3] in wave_dancers
    @test square[4] in wave_dancers
    @test square[7] in wave_dancers
    @test square[8] in wave_dancers
    @test square[2] == f.tandem1.leader.dancer
    @test square[4] == f.tandem1.trailer.dancer
    @test square[6] == f.tandem2.leader.dancer
    @test square[8] == f.tandem2.trailer.dancer
    @test f.tandem1.leader == f.couple1.belle
    @test f.tandem2.leader == f.couple2.belle
    @test f.b2b1.a == f.tandem1.trailer
    @test f.b2b2.b == f.tandem2.trailer
    @test f.b2b1.b == f.couple2.beau
    @test f.b2b2.a == f.couple1.beau
end

