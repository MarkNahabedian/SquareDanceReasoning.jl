using SquareDanceReasoning: uncollide, animation_svg

@testset "test Collisions" begin
    dancers = map(1:4) do couple_number
        Dancer(couple_number, Unspecified())
    end
    let
        dancer_states = map(dancers) do dancer
            i = dancer.couple_number - 1
            DancerState(dancer, 0, (i>>1) * 1//2, i >> 1, [1, 2, 2, 3][i+1])
        end
        @debug_formations(dancer_states)
        ctr = center(dancer_states)
        dancer_states
        dancer_states = map(dancer_states) do ds
            forward(ds, 0.5, 1)
        end
        @debug_formations(dancer_states)
        collisions = find_collisions(dancer_states)
        @test length(collisions) == 1
        dancer_states = uncollide(collisions, dancer_states)
        @debug_formations(dancer_states)
        println(joinpath(dirname(@__FILE__), "test_collisions-$(@__LINE__)"))
        XML.write(joinpath(dirname(@__FILE__), "test_collisions-$(@__LINE__).svg"),
                  animation_svg(dancer_states))
        @test location(dancer_states[1]) == [0.5, 0.5]
        @test location(dancer_states[2]) == [0.5, 1.5]
        @test location(dancer_states[3]) == [0.5, 2.5]
        @test location(dancer_states[4]) == [0.5, 3.5]
    end
    #=
    # This gets us 5 collisions.  Might we have legitimate situations where
    # we get more collisions than we need to fix the result?
    let
        dancer_states = map(dancers) do dancer
            i = dancer.couple_number - 1
            DancerState(dancer, 0, i * 1//2, i >> 1, i & 1)
        end
        @debug_formations(dancer_states)
        ctr = center(dancer_states)
        dancer_states = map(dancer_states) do ds
            if ds.dancer.couple_number in (2, 3)
                DancerState(ds, ds.time + 1, ds.direction, ctr...)
            else
                DancerState(ds, ds.time + 1, ds.direction, ctr[1], ds.left)
            end
        end
        @debug_formations(dancer_states)
        collisions = find_collisions(dancer_states)
        println(collisions)
        dancer_states = uncollide(collisions, dancer_states)
        @debug_formations(dancer_states)
    animate(joinpath(@__DIR__, "test_collisions-$(@__LINE__)"),
            dancer_states)
    end
    =#
end

#=
Collision[
    Collision(DancerState(2, Dancer(1, Unspecified()), 1, 0//1, 0.5, 0.0),
              DancerState(2, Dancer(2, Unspecified()), 1, 1//2, 0.5, 0.5),
              Float32[0.5, 0.25], [3.061616997868383e-17, 0.5]), 

    Collision(DancerState(2, Dancer(1, Unspecified()), 1, 0//1, 0.5, 0.0),
              DancerState(2, Dancer(3, Unspecified()), 1, 0//1, 0.5, 0.5),
              Float32[0.5, 0.25], [3.061616997868383e-17, 0.5]), 
    Collision(DancerState(2, Dancer(3, Unspecified()), 1, 0//1, 0.5, 0.5),
              DancerState(2, Dancer(2, Unspecified()), 1, 1//2, 0.5, 0.5),
              Float32[0.5, 0.5], [3.061616997868383e-17, 0.5]), 
    Collision(DancerState(2, Dancer(2, Unspecified()), 1, 1//2, 0.5, 0.5),
              DancerState(2, Dancer(4, Unspecified()), 1, 1//2, 0.5, 1.0),
              Float32[0.5, 0.75], [-9.184850993605148e-17, -0.5]), 

    Collision(DancerState(2, Dancer(3, Unspecified()), 1, 0//1, 0.5, 0.5),
              DancerState(2, Dancer(4, Unspecified()), 1, 1//2, 0.5, 1.0),
              Float32[0.5, 0.75], [3.061616997868383e-17, 0.5])
]
=#

