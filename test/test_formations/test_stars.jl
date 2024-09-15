
@testset "test Star" begin
    offset = 0.6
    square = make_square(2)
    let  #Not a star, they dont overlap
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
            askc(Collector{DancerState}(), kb, DancerState)))
        stars = askc(Collector{Star}(), kb, Star)
        @test length(stars) == 0
    end
    let  # right handed
        kb = make_kb()
        receive(kb, square)
        dss = [
            DancerState(square[1], 0, 0,     0,      offset),
            DancerState(square[3], 0, 1//2,  0,     -offset),
            DancerState(square[2], 0, 1//4, -offset, 0),
            DancerState(square[4], 0, 3//4,  offset, 0),
        ]
        receive.([kb], dss)
        @debug_formations(kb)
        @test 2 == askc(Counter(), kb, RHMiniWave)
        @test 0 == askc(Counter(), kb, LHMiniWave)
        @test 0 == length(find_collisions(
            askc(Collector{DancerState}(), kb, DancerState)))
        stars = askc(Collector{Star}(), kb, Star)
        @test length(stars) == 1
        star = stars[1]
        @test handedness(star) isa RightHanded
        @test star.mw1.a.dancer == square[1]
        @test star.mw1.b.dancer == square[3]
        @test star.mw2.a.dancer == square[2]
        @test star.mw2.b.dancer == square[4]
    end
    let  # left handed
        kb = make_kb()
        receive(kb, square)
        dss = [
            DancerState(square[1], 0, 0,     0,     -offset),
            DancerState(square[3], 0, 1//2,  0,      offset),
            DancerState(square[2], 0, 1//4,  offset, 0),
            DancerState(square[4], 0, 3//4, -offset, 0),
        ]
        receive.([kb], dss)
        @debug_formations(kb)
        @test 0 == askc(Counter(), kb, RHMiniWave)
        @test 2 == askc(Counter(), kb, LHMiniWave)
        @test 0 == length(find_collisions(
            askc(Collector{DancerState}(), kb, DancerState)))
        stars = askc(Collector{Star}(), kb, Star)
        @test length(stars) == 1
        star = stars[1]
        @test handedness(star) isa LeftHanded
        @test star.mw1.a.dancer == square[1]
        @test star.mw1.b.dancer == square[3]
        @test star.mw2.a.dancer == square[2]
        @test star.mw2.b.dancer == square[4]
    end
end

