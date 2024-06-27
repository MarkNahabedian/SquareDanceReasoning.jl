
@testset "columns of four" begin
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    for ds in make_line(square[1:4], 1//4, 0)
        receive(kb, ds)
    end
    for ds in make_line(square[5:8], 3//4, 1)
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
        @test length(dancer_states(columns[1])) == 4
        @test direction(columns[1]) == 1/4
        @test handedness(columns[1]) == NoHandedness()
        @test columns[1].tail.trailer.dancer == square[1]
        @test columns[1].tail.leader.dancer == square[2]
        @test columns[1].lead.trailer.dancer == square[3]
        @test columns[1].lead.leader.dancer == square[4]
        #   →→→→   direction 3/4
        @test length(dancer_states(columns[2])) == 4
        @test direction(columns[2]) == 3/4
        @test handedness(columns[2]) == NoHandedness()
        @test columns[2].lead.leader.dancer == square[5]
        @test columns[2].lead.trailer.dancer == square[6]
        @test columns[2].tail.leader.dancer == square[7]
        @test columns[2].tail.trailer.dancer == square[8]
    end
    collect_formation_examples(kb)
end

