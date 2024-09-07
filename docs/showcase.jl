using Rete
using SquareDanceReasoning

# For debugging:
using SquareDanceReasoning: write_formation_html_file

let
    square = make_square(2)
    kb = make_kb()
    receive(kb, square)
    grid = grid_arrangement(square.dancers,
                            [ 4 3;
                              1 2 ],
                            [ "↓↓";
                              "↑↑" ])
    receive.([kb], grid)
    showcase("SquareThru_from_FacingCouples",
             "Square Thru",
             kb,
             SquareDanceCall[
                 SquareThru(),
                 _Rest(time = 2)
             ]
             )
end

let
    square = make_square(4)
    kb = make_kb()
    receive(kb, square)
    receive.([kb], square_up(square))
    write_formation_html_file("Squared Set",
                              abspath("src/formation_drawings/squared_set.html"),
                              kb)
    showcase("SquareThru_from_SquaredSet",
             "Heads Square Thru from a squared set",
             kb,
             SquareDanceCall[
                 SquareThru(role = OriginalHead()),
                 _Rest(time = 2)
             ];
             inhibit_call_engine_logging = false
             )
end


# This sould be the last expression in this file.
make_showcase_index_file()

