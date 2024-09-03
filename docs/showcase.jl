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


# This sould be the last expression in this file.
make_showcase_index_file()

