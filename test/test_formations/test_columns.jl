
@testset "columns of four" begin
    dancers = make_dancers(4)
    kb = ReteRootNode("root")
    install(kb, SquareDanceFormationRule)
    ensure_IsaMemoryNode(kb, Dancer)
    for dancer in dancers
        receive(kb, dancer)
    end
    for ds in make_line(dancers[1:4], 1//4, 0)
        receive(kb, ds)
    end
    for ds in make_line(dancers[5:8], 3//4, 1)
        receive(kb, ds)
    end
    @debug_formations(kb)
    # First make sure we have the Tandems:
    let
        m = find_memory_for_type(kb, Tandem)
        @test length(m.memory) == 6
    end
    let
        m = find_memory_for_type(kb, ColumnOfFour)
        columns = collecting() do c
            askc(c, m)
        end
        @test length(columns) == 2
        columns = sort(columns; by = f -> f.lead.leader.direction)
        #   ←←←←   direction 1//4
        @test columns[1].tail.trailer.direction == 1/4
        @test handedness(columns[1]) == NoHandedness()
        @test columns[1].tail.trailer.dancer == dancers[1]
        @test columns[1].tail.leader.dancer == dancers[2]
        @test columns[1].lead.trailer.dancer == dancers[3]
        @test columns[1].lead.leader.dancer == dancers[4]
        #   →→→→   direction 3/4
        @test columns[2].tail.trailer.direction == 3/4
        @test handedness(columns[2]) == NoHandedness()
        @test columns[2].lead.leader.dancer == dancers[5]
        @test columns[2].lead.trailer.dancer == dancers[6]
        @test columns[2].tail.leader.dancer == dancers[7]
        @test columns[2].tail.trailer.dancer == dancers[8]
    end
end

