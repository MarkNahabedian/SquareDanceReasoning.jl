
using SquareDanceReasoning: Basic1, Basic2, Mainstream, Plus,
    Advanced1, Challenge3B

cleanup_debug_formations(@__DIR__)

@testset "Callerlab programs" begin
    @test isless(Basic2(), Advanced1())
    @test isless(Mainstream(), Challenge3B())
    @test !isless(Plus(), Basic1())
end

include("test_rotate_in_place.jl")
# include("test_pass_thru.jl")


