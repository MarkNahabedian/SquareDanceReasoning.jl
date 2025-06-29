
@testset "test Star" begin
    offset = 0.6
    square = make_square(2)
    let  # Not a star, they dont overlap
        kb = make_kb()
        receive(kb, square)
        dss = [
            DancerState(square[1], 0, 0,     2,      offset),
            DancerState(square[3], 0, 1//2,  2,     -offset),
            DancerState(square[2], 0, 1//4, -offset, 2),
            DancerState(square[4], 0, 3//4,  offset, 2),
        ]
        receive.([kb], dss)
        @debug_formations(kb)
        @test 2 == askc(Counter(), kb, RHMiniWave)
        @test 0 == askc(Counter(), kb, LHMiniWave)
        @test 0 == length(find_collisions(
            askc(Collector{DancerState}(), kb)))
        stars = askc(Collector{Star}(), kb)
        @test length(stars) == 0
    end
    let  # right handed
        kb = make_kb()
        receive(kb, square)
        dss = polar_arrangement(square.dancers, [0, 0], 0.6, 0, right_hand_in)
        receive.([kb], dss)
        @debug_formations(kb)
        @test 2 == askc(Counter(), kb, RHMiniWave)
        @test 0 == askc(Counter(), kb, LHMiniWave)
        @test 0 == length(find_collisions(
            askc(Collector{DancerState}(), kb)))
        stars = askc(Collector{Star}(), kb)
        @test length(stars) == 1
        star = stars[1]
        @test handedness(star) isa RightHanded
        @test star.mw2.b.dancer == square[1]
        @test star.mw1.a.dancer == square[2]
        @test star.mw2.a.dancer == square[3]
        @test star.mw1.b.dancer == square[4]
    end
    let  # left handed
        kb = make_kb()
        receive(kb, square)
        dss = polar_arrangement(square.dancers, [0, 0], 0.6, 0, left_hand_in)
        receive.([kb], dss)
        @debug_formations(kb)
        @test 0 == askc(Counter(), kb, RHMiniWave)
        @test 2 == askc(Counter(), kb, LHMiniWave)
        @test 0 == length(find_collisions(
            askc(Collector{DancerState}(), kb)))
        stars = askc(Collector{Star}(), kb)
        @test length(stars) == 1
        star = stars[1]
        @test handedness(star) isa LeftHanded
        @test star.mw2.a.dancer == square[1]
        @test star.mw1.b.dancer == square[2]
        @test star.mw2.b.dancer == square[3]
        @test star.mw1.a.dancer == square[4]
    end
end

@testset "test Diamond" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset());
                min_level = Debug - 1) do
        square = make_square(2)
        radius(i) = iseven(i) ? 0.5 : 1.0
        let  # right handed
            kb = make_kb()
            receive(kb, square)
            dss = polar_arrangement(square.dancers, [0, 0], radius, 0, right_hand_in)
            receive.([kb], dss)
            @debug_formations(kb)
            @test 1 == askc(Counter(), kb, RHMiniWave)
            @test 1 == askc(Counter(), kb, _MaybeDiamondPoints)
            @test 0 == askc(Counter(), kb, LHMiniWave)
            @test 0 == length(find_collisions(
                askc(Collector{DancerState}(), kb)))
            diamonds = askc(Collector{Diamond}(), kb)
            @test length(diamonds) == 1
            diamond = diamonds[1]
            @test handedness(diamond) isa RightHanded
            @test diamond.centers.b.dancer == square[1]
            @test diamond.points.a.dancer == square[2]
            @test diamond.centers.a.dancer == square[3]
            @test diamond.points.b.dancer == square[4]
        end
    end
end

