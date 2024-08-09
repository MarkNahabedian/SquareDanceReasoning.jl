
using SquareDanceReasoning: Basic1, Basic2, Mainstream, Plus,
    Advanced1, Challenge3B

cleanup_debug_formations(@__DIR__)

function direction_history(ds::DancerState)
    hist = []
    SquareDanceReasoning.history(ds) do ds1
        push!(hist, ds1.time => ds1.direction)
    end
    (ds.dancer, hist)
end

function location_history(ds::DancerState)
    hist = []
    SquareDanceReasoning.history(ds) do ds1
        push!(hist, ds1.time => location(ds1))
    end
    (ds.dancer, hist)
end

function history(ds::DancerState)
    hist = []
    SquareDanceReasoning.history(ds) do ds1
        push!(hist, ds1.time => (ds1.direction, location(ds1)...))
    end
    (ds.dancer, hist)    
end


@testset "Callerlab programs" begin
    @test isless(Basic2(), Advanced1())
    @test isless(Mainstream(), Challenge3B())
    @test !isless(Plus(), Basic1())
end

@testset "test get_call_options with WaveOfEight" begin
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 1 2 3 4 5 6 7 8 ],
                            [ "↑↓↑↓↑↓↑↓" ])
    receive.([kb], grid)
    @debug_formations(kb)
    @test 4 == askc(Counter(), kb, RHMiniWave)
    @test 3 == askc(Counter(), kb, LHMiniWave)
    @test 1 == askc(Counter(), kb, RHWaveOfEight)
    receive(kb, StepThru())
    options = SquareDanceReasoning.get_call_options(StepThru(), kb)
    @test 4 == length(options)
    @test all(options) do cdc
        cdc.formation isa RHMiniWave
    end
end


include("test_rotate_in_place.jl")
include("test_one_dancer_calls.jl")
include("test_two_dancer_calls.jl")
include("test_pass_thru.jl")
include("test_quarter_in_out.jl")

