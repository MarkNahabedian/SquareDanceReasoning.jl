
@testset "Squared Set" begin
    dancers = make_dancers(4)
    kb = ReteRootNode("root")
    install(kb, SquareDanceRule)
    ensure_IsaMemoryNode(kb, Dancer)
    # println(map(m -> typeof(m).parameters[1], collect(kb.outputs)))
    for dancer in dancers
        receive(kb, dancer)
    end
    for ds in square_up(dancers)
        receive(kb, ds)
    end
    @debug_formations(kb)
end

