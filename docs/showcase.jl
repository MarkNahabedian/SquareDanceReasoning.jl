using Rete
using SquareDanceReasoning
using XML
using Logging: with_logger, NullLogger


SHOWCASE_DIR = joinpath(@__DIR__, "src", "Showcase")

SHOWCASE_HTML_FILES = []

function showcase(filename::String, title::String,
                  initial_kb,
                  choreography::Vector{SquareDanceCall})
    mkpath(SHOWCASE_DIR)
    animation_file = joinpath(SHOWCASE_DIR,
                              filename * ".svg")
    md_file = joinpath(SHOWCASE_DIR,
                       filename * ".md")
    let
        kb = initial_kb
        with_logger(NullLogger()) do
            for call in choreography
                kb = do_call(kb, call)
            end
        end
        animate(animation_file,
                askc(Collector{DancerState}(), kb, DancerState),
                80)
    end
    open(md_file, "w") do io
        println(io, "# $title")
        println(io)
        _, ap = splitdir(animation_file)
        println(io, """```@raw html\n<img src="$ap" alt="animation of $title" />\n```""")
        println(io)
        println(io, "```")
        for call in choreography
            println(IOContext(io,
                              :compact => false),
                    call)
        end
        println(io, "```")
    end
    push!(SHOWCASE_HTML_FILES,
          (title, "$filename.md"))
end


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
let
    # Build an index file
    open(joinpath(SHOWCASE_DIR, "index.md"), "w") do io
        println(io, "# Showcase of Animated Choreography")
        println(io)
        println(io,
                """The goal of the SquareDanceReasoning package
                is to simulate Modern Westrern Square Dance
                choreography and generate animations.  Here we have
                example animations along with the Julia code that
                describes the choregraphy.""")
        println(io)
        for (title, filename) in SHOWCASE_HTML_FILES
            println(io, "- [$title]($filename)")
        end
    end
end

