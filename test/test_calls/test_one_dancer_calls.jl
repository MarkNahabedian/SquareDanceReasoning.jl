
@testset "test Balance" begin
    kb = make_kb()
    square = make_square(2)
    receive(kb, square)
    grid = grid_arrangement(
        sort!(square.dancers),
        [ 2 1;
          3 4 ],
        [ "↓↓";
          "↑↑" ])
    receive.([kb], grid)
    original_dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                         by = ds -> ds.dancer)
    @debug_formations(kb)
    kb = do_call(kb, Balance())
    kb = do_call(kb, Balance())
    dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                by = ds -> ds.dancer)    
    for i in 1:length(original_dss)
        @test dss[i].time ≈ original_dss[i].time + 2 + 2
        @test dss[i].direction == original_dss[i].direction
        @test dss[i].down == original_dss[i].down
        @test dss[i].left == original_dss[i].left
    end
    animate(joinpath(@__DIR__, "balance.svg"), dss, 40)
end

