using Logging

@testset "test quarter turns" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        dss = [ DancerState(Dancer(1, Guy()), 0, 0, 0, 0),
                DancerState(Dancer(2, Gal()), 0, 0, 0, 1),
                DancerState(Dancer(3, Unspecified()), 0, 0, 0, 2)
                ]
        @test as_text(FaceRight()) == "Everyone quarter right, 1 ticks."
        @test as_text(FaceLeft()) == "Everyone quarter left, 1 ticks."
        @test as_text(_GenderedRoll(; role=Centers())) ==
            "Centers Guy quarter right, Gal quarter left."
        kb = make_kb()
        receive.([kb], dss)
        kb = do_call(kb, FaceRight())
        kb = do_call(kb, FaceLeft())
        kb = do_call(kb, _GenderedRoll())
        dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                    by = ds -> ds.dancer)
        hist = map(direction_history, dss)
        @test hist == [
            (Dancer(1, Guy()), [
                0 => 0, 1 => 3//4, 2 => 0, 4 => 3//4]),
            (Dancer(2, Gal()), [
                0 => 0, 1 => 3//4, 2 => 0, 4 => 1//4 ]),
            (Dancer(3, Unspecified()), [
                0 => 0, 1 => 3//4, 2 => 0, 4 => 0 ])
        ]
        for ds in dss
            @test ds.down == 0
        end
        @test dss[1].left == 0
        @test dss[2].left == 1
        @test dss[3].left == 2
        animate(joinpath(@__DIR__, "quarter_turns.svg"), dss, 500)
    end
end

@testset "test AndRoll" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        @test as_text(AndRoll()) == "Everyone roll."
        logger = TestLogger()
        # No history:
        ds1 = DancerState(Dancer(1, Guy()), 1, 0, 0, 1)
        @test can_roll(ds1) == 0
        # no rotation:
        ds2 = forward(DancerState(Dancer(2, Guy()), 0, 0, 0, 2),
                      1, 1)
        @test can_roll(ds2) == 0
        # quarter left:
        ds3 = rotate(DancerState(Dancer(3, Guy()), 0, 0, 0, 3),
                     1//4, 1)
        @test can_roll(ds3) == 1//4
        # quarter right:
        ds4 = rotate(DancerState(Dancer(4, Guy()), 0, 0, 0, 4),
                     -1//4, 1)
        @test can_roll(ds4) == -1//4
        # 180 turn:
        ds5 = rotate(DancerState(Dancer(5, Guy()), 0, 0, 0, 5),
                     1//2, 1)
        @test_throws CanRollAmbiguityException can_roll(ds5)
        kb = make_kb()
        receive(kb, ds1)
        receive(kb, ds2)
        receive(kb, ds3)
        receive(kb, ds4)
        receive(kb, ds5)
        @debug_formations(kb)
        with_logger(logger) do
            @test isempty(logger.logs)
            kb = do_call(kb, AndRoll())
            found_CanRollAmbiguityException = false
            for m in logger.logs
                if m.message isa CanRollAmbiguityException
                    found_CanRollAmbiguityException = true
                end
            end
            @test found_CanRollAmbiguityException
        end
        @debug_formations(kb)
        dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                    by = ds -> ds.dancer.couple_number)
        @test dss[1].direction == 0
        @test dss[2].direction == 0
        @test dss[3].direction == 1//2
        @test dss[4].direction == 1//2
        @test dss[5].direction == 1//2
        rolled_by(dss) = canonicalize(dss.direction - dss.previous.direction)
        @test rolled_by(dss[3]) == rolled_by(dss[3].previous)
        @test rolled_by(dss[4]) == rolled_by(dss[4].previous)
    end
end

using SquareDanceReasoning: uturnback1

@testset "test uturnback1" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        ctr = [0, 1]
        expect = [
            (Dancer(1, Guy()), Any[0 => 0//1, 1 => 3//4, 2 => 1//2, 3 => 1//4]),
            (Dancer(1, Guy()), Any[0 => 0//1, 1 => 0//1, 2 => 1//4, 3 => 1//2]),
            (Dancer(1, Guy()), Any[0 => 0//1, 1 => 1//4, 2 => 1//2, 3 => 3//4]),
            (Dancer(2, Guy()), Any[0 => 1//4, 1 => 0//1, 2 => 3//4, 3 => 1//2]),
            (Dancer(2, Guy()), Any[0 => 1//4, 1 => 1//4, 3 => 3//4]),
            (Dancer(2, Guy()), Any[0 => 1//4, 1 => 1//2, 2 => 3//4, 3 => 0//1]),
            (Dancer(3, Guy()), Any[0 => 1//2, 1 => 1//4, 2 => 0//1, 3 => 3//4]),
            (Dancer(3, Guy()), Any[0 => 1//2, 1 => 1//2, 2 => 1//4, 3 => 0//1]),
            (Dancer(3, Guy()), Any[0 => 1//2, 1 => 3//4, 2 => 0//1, 3 => 1//4]),
            (Dancer(4, Guy()), Any[0 => 3//4, 1 => 1//2, 2 => 1//4, 3 => 0//1]),
            (Dancer(4, Guy()), Any[0 => 3//4, 1 => 3//4, 3 => 1//4]),
            (Dancer(4, Guy()), Any[0 => 3//4, 1 => 0//1, 2 => 1//4, 3 => 1//2])
        ]
        expect_index = 1
        for i in 1:4
            startdir = (i-1)//4
            for rot in [ -1//4, 0, 1//4 ]
                ds = rotate(DancerState(Dancer(i, Guy()), 0, startdir, 0, 0),
                            rot, 1)
                ds2 = uturnback1(ds, ctr)
                @test direction_history(ds2) == expect[expect_index]
                expect_index += 1
            end
        end
    end
end

@testset "test UTurnBack from Couples" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        @test as_text(UTurnBack()) == "Everyone U Turn Back"
        kb = make_kb()
        square = make_square(4)
        receive(kb, square)
        receive.([kb], square_up(square))
        @debug_formations(kb)
        kb = do_call(kb, UTurnBack())
        dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                    by = ds -> ds.dancer)
        @test dss[1].previous.direction == 3//4
        @test dss[1].direction == 1//2
        @test dss[2].previous.direction == 1//4
        @test dss[2].direction == 1//2
        @test dss[3].previous.direction == 0//4
        @test dss[3].direction == 3//4
        @test dss[4].previous.direction == 1//2
        @test dss[4].direction == 3//4
        @test dss[5].previous.direction == 1//4
        @test dss[5].direction == 0
        @test dss[6].previous.direction == 3//4
        @test dss[6].direction == 0
        @test dss[7].previous.direction == 1//2
        @test dss[7].direction == 1//4
        @test dss[8].previous.direction == 0//4
        @test dss[8].direction == 1//4
        @debug_formations(kb)
        animate(joinpath(@__DIR__, "UTurnBack_Couples.svg"),
                dss, 50)
    end
end

@testset "tast UTurnBack, AndRoll" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        logger = TestLogger()
        kb = make_kb()
        square = make_square(4)
        receive(kb, square)
        grid = grid_arrangement(
            sort!(square.dancers),
            [ 0 3 0 1 2;
              5 0 0 0 6;
              0 7 8 4 0 ],
            [ " → ↑↓";
              "←   ←"
              " ↑↑← ";
              ])
        receive.([kb], grid)
        dss = askc(Collector{DancerState}(), kb, DancerState)
        receive(kb, SDSquare(map(ds -> ds.dancer, dss)))
        receive.([kb], dss)
        @debug_formations(kb)
        kb = do_call(kb, UTurnBack())
        @debug_formations(kb)
        with_logger(logger) do
            kb = do_call(kb, AndRoll())
            cae_messages = []
            for m in logger.logs
                if m.message isa CanRollAmbiguityException
                    push!(cae_messages, m)
                end
            end
            @test length(cae_messages) == 2
            @test sort!((map(cae_messages) do logrec
                             logrec.message.dancer_state.dancer
                         end)) == [ Dancer(3, Guy()),
                                    Dancer(3, Gal()) ]
        end
        @debug_formations(kb)
        dss = sort!(askc(Collector{DancerState}(), kb, DancerState);
                    by = ds -> ds.dancer)
        @test direction_history(dss[1]) ==
            (Dancer(1, Guy()), [ 0 => 1//2, 1 => 1//4, 2 => 0, 4 => 3//4 ])
        @test direction_history(dss[2]) ==
            (Dancer(1, Gal()), [ 0 => 0, 1 => 3//4, 2 => 1//2, 4 => 1//4 ])
        @test direction_history(dss[3]) ==
            (Dancer(2, Guy()), [ 0 => 1//4, 1 => 0, 2 => 3//4, 4 => 1//2 ])
        @test direction_history(dss[4]) ==
            (Dancer(2, Gal()), [ 0 => 3//4, 1 => 1//2, 2 => 1//4, 4 => 0 ])
        @test direction_history(dss[5]) ==
            (Dancer(3, Guy()), [ 0 => 3//4, 2 => 1//4, 4 => 1//4 ])
        @test direction_history(dss[6]) ==
            (Dancer(3, Gal()), [ 0 => 3//4, 2 => 1//4, 4 => 1//4 ])
        @test direction_history(dss[7]) ==
            (Dancer(4, Guy()), [ 0 => 1//2, 1 => 1//4, 2 => 0, 4 => 3//4 ])
        @test direction_history(dss[8]) ==
            (Dancer(4, Gal()), [ 0 => 1//2, 1 => 3//4, 2 => 0, 4 => 1//4 ])
        animate(joinpath(@__DIR__, "UTurnBack_AndRoll.svg"), dss, 50)
    end
end

@testset "test _FaceOriginalPartner" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        logger = TestLogger()
        kb = make_kb()
        square = make_square(4)
        receive(kb, square)
        dss = square_up(square)
        receive.([kb], dss)
        @debug_formations(kb)
        kb = do_call(kb, _FaceOriginalPartner())
        @debug_formations(kb)
        couples = Dict{Int, Vector{DancerState}}()
        askc(kb, DancerState) do ds
            cn = ds.dancer.couple_number
            if !haskey(couples, cn)
                couples[cn] = []
            end
            push!(couples[cn], ds)
        end
        for (cn, dss) in couples
            (ds1, ds2) = dss
            @test ds1.direction == opposite(ds2.direction)
            @test ds1.down == ds1.previous.down
            @test ds1.left == ds1.previous.left
            @test ds2.down == ds2.previous.down
            @test ds2.left == ds2.previous.left
        end
    end
end

@testset "test _FaceOriginalCorner" begin
    log_to_file(@__DIR__, log_file_name_for_testset(Test.get_testset())) do
        logger = TestLogger()
        kb = make_kb()
        square = make_square(4)
        receive(kb, square)
        dss = square_up(square)
        receive.([kb], dss)
        @debug_formations(kb)
        kb = do_call(kb, _FaceOriginalCorner())
        @debug_formations(kb)
        # corners is keyed by the Guy's couple number
        corners = Dict{Int, Vector{DancerState}}()
        askc(kb, DancerState) do ds
            if ds.dancer.gender isa Guy
                gcn = ds.dancer.couple_number
            elseif ds.dancer.gender isa Gal
                gcn = mod1(corner_couple_number(ds.dancer), 4)
            else
                error("Unsupported gender")
            end
            if !haskey(corners, gcn)
                corners[gcn] = []
            end
            push!(corners[gcn], ds)
        end
        for (cn, dss) in corners
            (ds1, ds2) = dss
            @test ds1.direction == opposite(ds2.direction)
            @test ds1.down == ds1.previous.down
            @test ds1.left == ds1.previous.left
            @test ds2.down == ds2.previous.down
            @test ds2.left == ds2.previous.left
        end
    end
end

