
cleanup_debug_formations(@__DIR__)

TEXT_EXAMPLE_FORMATIONS = []

include("test_two_dancers.jl")
include("test_two_by_two.jl")
include("test_bigger_waves.jl")
include("test_lines.jl")
include("test_stars.jl")
include("test_columns.jl")
include("test_couples_down_the_line.jl")
include("test_squared_set.jl")
include("test_roles.jl")

save_formation_examples()

@testset "example formations" begin
    for formation in TEXT_EXAMPLE_FORMATIONS
        f = get_formation_example(typeof(formation))
        @test f == formation
    end
end


#=
@testset "Formation jitter tests" begin
    examples = load_formation_examples()
    for (formation, dancer_states) in examples
        let
            kb = make_kb()
            receive(kb, SquareDanceReasoning.SDSquare(
                map(ds -> ds.dancer, dancer_states)))
            for ds in dancer_states
                receive(kb, ds #= jitter(ds, 1) =#)
            end
            found = askc(Collector{SquareDanceFormation}(),
                         kb, SquareDanceFormation)
            println("jitter $formation")
            @test formation in map(found) do f
                string(typeof(f))
            end
        end
    end
end
=#

