
@testset "Squared Set" begin
    square = make_square(4)
    kb = ReteRootNode("root")
    install(kb, SquareDanceRule)
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    receive(kb, square)
    for ds in square_up(square)
        receive(kb, ds)
    end
    @debug_formations(kb)
end

