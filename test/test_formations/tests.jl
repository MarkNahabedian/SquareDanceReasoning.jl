
include("test_two_dancers.jl")
include("test_two_by_two.jl")
include("test_bigger_waves.jl")
include("test_lines.jl")
include("test_columns.jl")
include("test_squared_set.jl")


save_formation_examples()

#=
@testset "Formation jitter tests" begin
    examples = load_formation_examples()
    for (formation, daner_states) in examples
        let
            kb = make_kb()
            receive(kb, SquareDanceReasoning.SDSquare(
                map(ds -> ds.dancer, daner_states)))
            for ds in daner_states
                receive(kb, ds #= jitter(ds, 1) =#)
            end
            found = collecting() do c
                askc(c, kb, SquareDanceFormation)
            end
            println("jitter $formation")
            @test formation in map(found) do f
                string(typeof(f))
            end
        end
    end
end
=#

