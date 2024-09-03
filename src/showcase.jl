using XML
using Logging: with_logger, NullLogger

export showcase, make_showcase_index_file

SHOWCASE_DIR = joinpath(@__DIR__, "..", "docs", "src", "Showcase")

SHOWCASE_HTML_FILES = []

function markdown_raw_html(html)
    if html isa XML.AbstractXMLNode
        html = XML.write(html)
    end
    "```@raw html\n$html\n```"
end

"""
    showcase(filename::String, title::String, initial_kb, choreography::Vector{SquareDanceCall}; inhibit_call_engine_logging = true)

Writes a markdown file named `filename` in the choreography Showcase
documentation directory.

`title` is the title string for the document.

`initial_kb` is the knowledgebase containing the formations that
`choreography` starts from.

`choreography` is a vector of the calls to be performed.
"""
function showcase(filename::String, title::String,
                  initial_kb,
                  choreography::Vector{SquareDanceCall};
                  inhibit_call_engine_logging = true)
    mkpath(SHOWCASE_DIR)
    md_file = joinpath(SHOWCASE_DIR,
                       filename * ".md")
    svg = let
        kb = initial_kb
        with_logger(if inhibit_call_engine_logging
                        NullLogger()
                    else
                        current_logger()
                    end
                    ) do
            for call in choreography
                kb = do_call(kb, call)
            end
        end
        animate(md_file,
                askc(Collector{DancerState}(), kb, DancerState),
                80)
    end
    open(md_file, "w") do io
        println(io, "# $title")
        println(io)
        println(io, markdown_raw_html(svg))
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


"""
    make_showcase_index_file()

Writes an index.md file for the choreography Showcase docs directory.
"""
function make_showcase_index_file()
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

