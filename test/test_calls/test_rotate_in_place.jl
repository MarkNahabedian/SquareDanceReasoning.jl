
#=
@testset "DEBUG missing previous using single dancer" begin
    ds = DancerState(Dancer(1, Guy()), 0, 0, 0, 0)
    kb = make_kb()
    receive(kb, SDSquare([ds.dancer]))
    receive(kb, ds)
    call = _Rest(; time=2)
    # receive(kb, call)
    # askc(println, kb, CanDoCall)
    askc(println, kb, DancerState)
    kb_stats(kb)
    kb = do_call(kb, call)
    dss = askc(Collector{DancerState}(), kb, DancerState)
    @test dss[1].previous.time + 2 == dss[1].time
    call = UTurnBack()
    # receive(kb, call)
    # askc(println, kb, CanDoCall)
    kb = do_call(kb, call)
    dss = askc(Collector{DancerState}(), kb, DancerState)
end
=#

@testset "test rotate in place calls" begin
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    receive.([kb], square_up(square.dancers))
    @debug_formations(kb)
    for ds in askc(Collector{DancerState}(), kb, DancerState)
        @test ds.previous == nothing
    end
    kb = do_call(kb, _Rest(; time=2))
    # verify there was no movement
    for ds in askc(Collector{DancerState}(), kb, DancerState)
        println("no previous?: $ds")
        @test ds.time == 2
        @test ds.direction == ds.previous.direction
        @test ds.down == ds.previous.down
        @test ds.left == ds.previous.left
    end
    kb = do_call(kb, UTurnBack())
    # verify opposite direction
    for ds in askc(Collector{DancerState}(), kb, DancerState)
        @test ds.direction == opposite(ds.previous.direction)
        @test ds.down == ds.previous.down
        @test ds.left == ds.previous.left
    end    
    @debug_formations(kb)
    kb = do_call(kb, AndRoll())
    # verify roll
    for ds in askc(Collector{DancerState}(), kb, DancerState)
        roll = if ds.dancer.gender == Guy()
            quarter_right
        else
            quarter_left
        end
        @test ds.direction == opposite(ds.previous.direction)
        @test ds.down == ds.previous.down + roll
        @test ds.left == ds.previous.left + roll
    end    
    @debug_formations(kb)
    kb = do_call(kb, _Rest(; time=2))
    
    animate(joinpath(@__DIR__, "UTurnBackAndRoll.svg"),
            askc(Collector{DancerState}(), kb, DancerState),
            40)
end

