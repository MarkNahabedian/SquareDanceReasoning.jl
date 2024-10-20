using Rete
using SquareDanceReasoning
using Logging: with_logger
using LoggingExtras: FileLogger

# For debugging:
using SquareDanceReasoning: write_formation_html_file

function safe_logger(filename)
    # println("environment:\n", ENV)
    # We apparently can't write to a FileLogger in a GitHub action.
    #
    # Thanks a whole fucking lot Google Gemeni: isdefined only works
    # for Symbol keys and the keys in ENV are Strings, so isdefined
    # was always returning false.
    if haskey(ENV, "GITHUB_ACTION")
        SimpleLogger()
    else
        FileLogger(joinpath( @__DIR__,
                             "src", "Showcase",
                             filename * ".log"))
    end
end

let
    filename = "SquareThru_from_FacingCouples"
    start_time = time()
    with_logger(safe_logger(filename)) do
        square = make_square(2)
        kb = make_kb()
        receive(kb, square)
        grid = grid_arrangement(square.dancers,
                                [ 4 3;
                                  1 2 ],
                                [ "↓↓";
                                  "↑↑" ])
        receive.([kb], grid)
        showcase(filename,
                 "Square Thru",
                 kb,
                 SquareDanceCall[
                     SquareThru(),
                     _Rest(time = 2)
                 ]
                 )
    @info "Elapsed time: $(time() - start_time) seconds."
    end
end


#=
let
    filename = "SquareThru_from_SquaredSet"
    start_time = time()
    with_logger(safe_logger(filename)) do
        square = make_square(4)
        kb = make_kb()
        receive(kb, square)
        receive.([kb], square_up(square))
        write_formation_html_file("Squared Set",
                                  abspath("src/formation_drawings/squared_set.html"),
                                  kb)
        dbgctx = @CallEngineDebugContext("src/Showcase",
                                         "SquareThru_from_SquaredSet")
        showcase(filename,
                 "Heads Square Thru from a squared set",
                 kb,
                 SquareDanceCall[
                     SquareThru(role = OriginalHead()),
                     _Rest(time = 2)
                 ];
                 inhibit_call_engine_logging = false,
                 dbgctx = dbgctx
                 )
    @info "Elapsed time: $(time() - start_time) seconds."
    end
end
=#


# This sould be the last expression in this file.
make_showcase_index_file()

