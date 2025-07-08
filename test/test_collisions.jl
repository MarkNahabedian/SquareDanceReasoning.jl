using SquareDanceReasoning: uncollide, animation_svg

@testset "test Collisions" begin
    map(filter(readdir(@__DIR__)) do filename
                (match(r"^test_collisions-[0-9]+.html$", filename) != nothing) ||
                    (match(r"^test_collisions-[0-9]+.svg$", filename) != nothing)
        end) do filename
            rm(filename; force=true)
        end
    dancers = map(1:4) do couple_number
        Dancer(couple_number, Unspecified())
    end
    function dss_from_grid(grid)::Vector{DancerState}
        dancer_states = Any[ missing, missing, missing, missing ]
        for ds in grid
            if ds isa DancerState
                dancer_states[ds.dancer.couple_number] = ds
            end
        end
        convert(Vector{DancerState}, dancer_states)
    end
    let
        grid = grid_arrangement(dancers, [1 2 0; 0 3 4],
                                [ "↓↓ ",
                                  " ↑↑" ])
        dancer_states = dss_from_grid(grid)
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
        XML.write(joinpath(dirname(@__FILE__), "test_collisions-$(@__LINE__).svg"),
                  animation_svg(dancer_states))
        @test location(dancer_states[1]) == [1.5, 0.5]
        @test location(dancer_states[2]) == [1.5, 2.5]
        @test location(dancer_states[3]) == [1.5, 1.5]
        @test location(dancer_states[4]) == [1.5, 3.5]
    end
    let
        grid = grid_arrangement(dancers, [1 2; 3 4],
                                [ "↓↓",
                                  "↑↑" ])
        dancer_states = dss_from_grid(grid)
        @debug_formations(dancer_states)
        ctr = center(dancer_states)
        dancer_states
        dancer_states = map(dancer_states) do ds
            forward(ds, 0.5, 1)
        end
        @debug_formations(dancer_states)
        collisions = find_collisions(dancer_states)
        @test length(collisions) == 2
        dancer_states = uncollide(collisions, dancer_states)
        @debug_formations(dancer_states)
        XML.write(joinpath(dirname(@__FILE__), "test_collisions-$(@__LINE__).svg"),
                  animation_svg(dancer_states))
        @test location(dancer_states[1]) == [1.5, 1]
        @test location(dancer_states[2]) == [1.5, 3]
        @test location(dancer_states[3]) == [1.5, 0]
        @test location(dancer_states[4]) == [1.5, 2]
    end
    let
        # This is taken from the way the testset "test Hinge" was failing:
        grid = grid_arrangement(dancers, [1 2; 3 4],
                                [ "↓↑",
                                  "↑↓" ])
        dancer_states = dss_from_grid(grid)
        @test map(ds -> ds.dancer.couple_number, dancer_states) == collect(1:4)
        @debug_formations(dancer_states)
        for index in [1, 3]
            ds1 = dancer_states[index]
            ds2 = dancer_states[index+1]
            rot = (index == 1) ? 1//4 : -1//4
            ctr = center([ds1, ds2])
            dancer_states[index]   = revolve(ds1, ctr, ds1.direction + rot, 1)
            dancer_states[index+1] = revolve(ds2, ctr, ds2.direction + rot, 1)            
        end
        @debug_formations(dancer_states)
        collisions = find_collisions(dancer_states)
        @test length(collisions) == 1
        dancer_states = uncollide(collisions, dancer_states)
        @test dancer_states[1].direction == 1//4
        @test dancer_states[2].direction == 3//4
        @test dancer_states[3].direction == 1//4
        @test dancer_states[4].direction == 3//4
        @test location(dancer_states[1]) == [ 1, 1.5 ]
        @test location(dancer_states[2]) == [ 0, 1.5 ]
        @test location(dancer_states[3]) == [ 2, 1.5 ]
        @test location(dancer_states[4]) == [ 3, 1.5 ]
        @debug_formations(dancer_states)
        XML.write(joinpath(dirname(@__FILE__), "test_collisions-$(@__LINE__).svg"),
                  animation_svg(dancer_states))
        @test dancer_states[1].direction == 1//4
        @test dancer_states[2].direction == 3//4
        @test dancer_states[3].direction == 1//4
        @test dancer_states[4].direction == 3//4
        @test location(dancer_states[1]) == [ 1, 1.5 ]
        @test location(dancer_states[2]) == [ 0, 1.5 ]
        @test location(dancer_states[3]) == [ 2, 1.5 ]
        @test location(dancer_states[4]) == [ 3, 1.5 ]
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

