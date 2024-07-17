
#=
@testset "test PassThru" begin
    # Make a square of four couples, 8 Dancers:
    square = make_square(4)
    # Make a knowledge base with all of the square dancer reasoning
    # rules installed:
    kb = make_kb()
    # Assert the square, dancers and their initial positions to the
    # knowledge base:
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 2 4 6 8;
                              1 3 5 7 ],
                            [ "↓↓↓↓";
                              "↑↑↑↑" ])
    receive.([kb], grid)
    # Write an HTML file so we can see what we have at thispoint:
    @debug_formations(kb)
    lines = askc(Collector{LineOfFour}(), kb, LineOfFour)
    @test length(lines) == 2
    # We currently have a hairy bug.  See the long comment at the end
    # of src/calls/two_dancer_calls.jl.  As a workaround so that this
    # testset will pass, we try role restrictions.
    # Alas, Neither Center nor End are implemented yet.
    kb = do_call(kb, PassThru(role = CoupleNumbers(1, 2)))
    kb = do_call(kb, PassThru(role = CoupleNumbers([3, 4])))
    function original_ds(ds)
        if ds.previous == nothing
            ds
        else
            original_ds(ds.previous)
        end
    end
    for ds in askc(Collector{DancerState}(), kb, DancerState)
        println(location_history(ds))
        #=
        ods = original_ds(ds)
        @test ods.direction == ds.direction
        @test ods.left == ds.left
        odsf = forward(ods, COUPLE_DISTANCE, 0)
        @test odsf.down == ds.down
        =#
    end
    @debug_formations(kb)
    animate(joinpath(@__DIR__, "pass_thru.svg"),
            askc(Collector{DancerState}(), kb, DancerState),
            40)
end
=#
