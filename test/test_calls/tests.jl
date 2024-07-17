
using SquareDanceReasoning: Basic1, Basic2, Mainstream, Plus,
    Advanced1, Challenge3B

cleanup_debug_formations(@__DIR__)

function direction_history(ds::DancerState)
    hist = []
    function dh(ds)
        if ds == nothing
            return
        end
        dh(ds.previous)
        push!(hist, ds.time => ds.direction)
    end
    dh(ds)
    (ds.dancer, hist)
end

function location_history(ds::DancerState)
    hist = []
    function lh(ds)
        if ds == nothing
            return
        end
        lh(ds.previous)
        push!(hist, ds.time => location(ds))
    end
    lh(ds)
    (ds.dancer, hist)
end


@testset "Callerlab programs" begin
    @test isless(Basic2(), Advanced1())
    @test isless(Mainstream(), Challenge3B())
    @test !isless(Plus(), Basic1())
end

include("test_rotate_in_place.jl")

# include("test_pass_thru.jl")


