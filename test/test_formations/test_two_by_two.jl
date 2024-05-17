
@testset "test FacingCouples" begin
    square = make_square(2)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    dancers = sort(collect(square.dancers))
    receive(kb, DancerState(dancers[1], 0, 1//4, 1, 1))
    receive(kb, DancerState(dancers[2], 0, 1//4, 2, 1))
    receive(kb, DancerState(dancers[3], 0, 3//4, 2, 2))
    receive(kb, DancerState(dancers[4], 0, 3//4, 1, 2))
    @debug_formations(kb)
    @test 2 == counting() do c
        askc(c, kb, Couple)
    end
    fc = collecting() do c
        askc(c, kb, FacingCouples)
    end
    @test length(fc) == 1
    fc = fc[1]
    @test length(dancer_states(fc)) == 4
    @test handedness(fc) == NoHandedness()
    @test fc.couple1.beau.dancer == dancers[1]
    @test fc.couple1.belle.dancer == dancers[2]
    @test fc.couple2.beau.dancer == dancers[3]
    @test fc.couple2.belle.dancer == dancers[4]
    collect_formation_examples(kb)
end


@testset "test BackToBackCouples" begin
    square = make_square(2)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    dancers = sort(collect(square.dancers))
    receive(kb, DancerState(dancers[1], 0, 1//4, 1, 2))
    receive(kb, DancerState(dancers[2], 0, 1//4, 2, 2))
    receive(kb, DancerState(dancers[3], 0, 3//4, 2, 1))
    receive(kb, DancerState(dancers[4], 0, 3//4, 1, 1))
    @debug_formations(kb)
    @test 2 == counting() do c
        askc(c, kb, Couple)
    end
    bb = collecting() do c
        askc(c, kb, BackToBackCouples)
    end
    @test length(bb) == 1
    bb = bb[1]
    @test length(dancer_states(bb)) == 4
    @test handedness(bb) == NoHandedness()
    @test bb.couple1.beau.dancer == dancers[1]
    @test bb.couple1.belle.dancer == dancers[2]
    @test bb.couple2.beau.dancer == dancers[3]
    @test bb.couple2.belle.dancer == dancers[4]
    collect_formation_examples(kb)
end

@testset "test TandemCouples" begin
    square = make_square(2)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    dancers = sort(collect(square.dancers))
    receive(kb, DancerState(dancers[1], 0, 1//4, 1, 2)) # leader, beau
    receive(kb, DancerState(dancers[2], 0, 1//4, 2, 2)) # leader, belle
    receive(kb, DancerState(dancers[3], 0, 1//4, 1, 1)) # trailer, beau
    receive(kb, DancerState(dancers[4], 0, 1//4, 2, 1)) # trailer, belle
    @debug_formations(kb)
    @test 2 == counting() do c
        askc(c, kb, Couple)
    end
    tc = collecting() do c
        askc(c, kb, TandemCouples)
    end
    @test length(tc) == 1
    tc = tc[1]
    @test length(dancer_states(tc)) == 4
    @test handedness(tc) == NoHandedness()
    @test direction(tc) == 1//4
    @test tc.leaders.beau.dancer == dancers[1]
    @test tc.leaders.belle.dancer == dancers[2]
    @test tc.trailers.beau.dancer == dancers[3]
    @test tc.trailers.belle.dancer == dancers[4]
    collect_formation_examples(kb)
end

@testset "Test RHBoxOfFour" begin
    square = make_square(2)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    dancers = sort(collect(square.dancers))
    receive(kb, DancerState(dancers[1], 0, 0//4, 1, 2)) # tandem1, trailer
    receive(kb, DancerState(dancers[2], 0, 0//4, 2, 2)) # tandem1, leader
    receive(kb, DancerState(dancers[3], 0, 2//4, 2, 1)) # tandem2, trailer
    receive(kb, DancerState(dancers[4], 0, 2//4, 1, 1)) # tandem2, leader
    @debug_formations(kb)
    @test 2 == counting() do c
        askc(c, kb, Tandem)
    end
    @test 2 == counting() do c
        askc(c, kb, RHMiniWave)
    end
    box = collecting() do c
        askc(c, kb, RHBoxOfFour)
    end
    @test length(box) == 1
    box = box[1]
    @test length(dancer_states(box)) == 4
    @test handedness(box) == RightHanded()
    @test box.tandem1.leader.dancer == dancers[2]
    @test box.tandem2.leader.dancer == dancers[4]
    @test box.tandem1.trailer.dancer == dancers[1]
    @test box.tandem2.trailer.dancer == dancers[3]
    collect_formation_examples(kb)
end

@testset "Test LHBoxOfFour" begin
    square = make_square(2)
    kb = make_kb()
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    dancers = sort(collect(square.dancers))
    receive(kb, DancerState(dancers[1], 0, 0//4, 1, 1)) # tandem1, trailer
    receive(kb, DancerState(dancers[2], 0, 0//4, 2, 1)) # tandem1, leader
    receive(kb, DancerState(dancers[3], 0, 2//4, 2, 2)) # tandem2, trailer
    receive(kb, DancerState(dancers[4], 0, 2//4, 1, 2)) # tandem2, leader
    @debug_formations(kb)
    @test 2 == counting() do c
        askc(c, kb, Tandem)
    end
    @test 2 == counting() do c
        askc(c, kb, LHMiniWave)
    end
    box = collecting() do c
        askc(c, kb, LHBoxOfFour)
    end
    @test length(box) == 1
    box = box[1]
    @test length(dancer_states(box)) == 4
    @test handedness(box) == LeftHanded()
    @test box.tandem1.leader.dancer == dancers[2]
    @test box.tandem2.leader.dancer == dancers[4]
    @test box.tandem1.trailer.dancer == dancers[1]
    @test box.tandem2.trailer.dancer == dancers[3]
    collect_formation_examples(kb)
end

