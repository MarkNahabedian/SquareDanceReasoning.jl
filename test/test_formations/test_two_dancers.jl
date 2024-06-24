
function two_dancer_formation_test_setup(grid_dancer_indices,
                                         grid_dancer_directions)
    square = make_square(1)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    dancers = sort(collect(square.dancers))
    grid = grid_arrangement(dancers,
                            grid_dancer_indices,
                            grid_dancer_directions)
    receive.([kb], grid)
    return kb, dancers
end


@testset "test Couple" begin
    kb, dancers = two_dancer_formation_test_setup([ 2 1; ], [ "↓↓" ])
    @test 2 == askc(counting, kb, DancerState)
    found = askc(collecting, kb, Couple)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test f isa Couple
    @test direction(f) == 0
    @test direction_equal(f.beau.direction, f.belle.direction)
    @test f.beau.dancer == dancers[1]
    @test f.belle.dancer == dancers[2]
    collect_formation_examples(kb)
end

@testset "test FaceToFace" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "→←" ])
    @test 2 == askc(counting, kb, DancerState)
    found = askc(collecting, kb, FaceToFace)
    @test 1 == length(found)
    f = found[1]
    @test f isa FaceToFace
    @test handedness(f) == NoHandedness()
    @test f.a.direction < f.b.direction
    @test f.a.direction == opposite(f.b.direction)
    @test f.a.dancer == dancers[1]
    @test f.b.dancer == dancers[2]
    collect_formation_examples(kb)
end
    
@testset "test BackToBack" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "←→" ])
    @test 2 == askc(counting, kb, DancerState)
    found = askc(collecting, kb, BackToBack)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test f isa BackToBack
    @test handedness(f) == NoHandedness()
    @test f.a.direction < f.b.direction
    @test f.a.direction == opposite(f.b.direction)
    @test f.a.dancer == dancers[2]
    @test f.b.dancer == dancers[1]
    collect_formation_examples(kb)
end

@testset "test Tandem" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "→→" ])
    @test 2 == askc(counting, kb, DancerState)
    found = askc(collecting, kb, Tandem)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test handedness(f) == NoHandedness()
    @test direction(f) == 1//4
    @test f isa Tandem
    @test f.leader.dancer == dancers[2]
    @test f.trailer.dancer == dancers[1]
    collect_formation_examples(kb)
end

@testset "test RHMiniWave" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "↑↓" ])
    @test 2 == askc(counting, kb, DancerState)
    found = askc(collecting, kb, RHMiniWave)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test handedness(f) == RightHanded()
    @test f isa RHMiniWave
    @test f.a.direction < f.b.direction
    @test f.a.dancer == dancers[2]
    @test f.b.dancer == dancers[1]
    collect_formation_examples(kb)
end

@testset "test LHMiniWave" begin
    kb, dancers = two_dancer_formation_test_setup([ 1 2; ], [ "↓↑" ])
    @test 2 == askc(counting, kb, DancerState)
    found = askc(collecting, kb, LHMiniWave)
    @test 1 == length(found)
    f = found[1]
    @test length(dancer_states(f)) == 2
    @test handedness(f) == LeftHanded()
    @test f isa LHMiniWave
    @test f.a.direction < f.b.direction
    @test f.a.dancer == dancers[1]
    @test f.b.dancer == dancers[2]
    collect_formation_examples(kb)
end

