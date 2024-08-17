using SquareDanceReasoning: playmate

function two_dancer_formation_test_setup(grid_dancer_indices,
                                         grid_dancer_directions)
    square = make_square(1)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    grid = grid_arrangement(square,
                            grid_dancer_indices,
                            grid_dancer_directions)
    receive.([kb], grid)
    return kb, square.dancers
end


@testset "test Couple" begin
    kb, dancers = two_dancer_formation_test_setup([ 2 1; ], [ "↓↓" ])
    @test 2 == askc(Counter(), kb, DancerState)
    found = askc(Collector{Couple}(), kb, Couple)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test f isa Couple
    @test direction(f) == 0
    @test f.beau.direction == f.belle.direction
    @test f.beau.dancer == dancers[1]
    @test f.belle.dancer == dancers[2]
    @test playmate(f.beau.dancer, f) == f.belle.dancer
    @test playmate(f.belle.dancer, f) == f.beau.dancer
    collect_formation_examples(kb)
end

@testset "test FaceToFace" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "→←" ])
    @test 2 == askc(Counter(), kb, DancerState)
    found = askc(Collector{FaceToFace}(), kb, FaceToFace)
    @test 1 == length(found)
    f = found[1]
    @test f isa FaceToFace
    @test handedness(f) == NoHandedness()
    @test f.a.direction < f.b.direction
    @test f.a.direction == opposite(f.b.direction)
    @test f.a.dancer == dancers[1]
    @test f.b.dancer == dancers[2]
    @test playmate(f.a.dancer, f) == f.b.dancer
    @test playmate(f.b.dancer, f) == f.a.dancer
    collect_formation_examples(kb)
end
    
@testset "test BackToBack" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "←→" ])
    @test 2 == askc(Counter(), kb, DancerState)
    found = askc(Collector{BackToBack}(), kb, BackToBack)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test f isa BackToBack
    @test handedness(f) == NoHandedness()
    @test f.a.direction < f.b.direction
    @test f.a.direction == opposite(f.b.direction)
    @test f.a.dancer == dancers[2]
    @test f.b.dancer == dancers[1]
    @test playmate(f.a.dancer, f) == f.b.dancer
    @test playmate(f.b.dancer, f) == f.a.dancer
    collect_formation_examples(kb)
end

@testset "test Tandem" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "→→" ])
    @test 2 == askc(Counter(), kb, DancerState)
    found = askc(Collector{Tandem}(), kb, Tandem)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test handedness(f) == NoHandedness()
    @test direction(f) == 1//4
    @test f isa Tandem
    @test f.leader.dancer == dancers[2]
    @test f.trailer.dancer == dancers[1]
    @test playmate(f.leader.dancer, f) == f.trailer.dancer
    @test playmate(f.trailer.dancer, f) == f.leader.dancer
    collect_formation_examples(kb)
end

@testset "test RHMiniWave" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "↑↓" ])
    @test 2 == askc(Counter(), kb, DancerState)
    found = askc(Collector{RHMiniWave}(), kb, RHMiniWave)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test handedness(f) == RightHanded()
    @test f isa RHMiniWave
    @test f.a.direction < f.b.direction
    @test f.a.dancer == dancers[2]
    @test f.b.dancer == dancers[1]
    @test playmate(f.a.dancer, f) == f.b.dancer
    @test playmate(f.b.dancer, f) == f.a.dancer
    collect_formation_examples(kb)
end

@testset "test LHMiniWave" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "↓↑" ])
    @test 2 == askc(Counter(), kb, DancerState)
    found = askc(Collector{LHMiniWave}(), kb, LHMiniWave)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test handedness(f) == LeftHanded()
    @test f isa LHMiniWave
    @test f.a.direction < f.b.direction
    @test f.a.dancer == dancers[1]
    @test f.b.dancer == dancers[2]
    @test playmate(f.a.dancer, f) == f.b.dancer
    @test playmate(f.b.dancer, f) == f.a.dancer
    collect_formation_examples(kb)
end

@testset "test two dancer encroaching" begin
    square = make_square(2)
    kb = make_kb()
    receive(kb, square)
    grid = grid_arrangement(square, [ 1 2 3 4; ], [ "↓↓↓↓" ])
    receive.([kb], grid)
    found = askc(Collector{Couple}(), kb, Couple)    
    @test length(found) == 3
end

