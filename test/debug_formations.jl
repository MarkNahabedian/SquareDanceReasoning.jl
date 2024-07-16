
using SquareDanceReasoning: formation_debug_html
using XML


function file_name_for_source_location(source::LineNumberNode)
    path, _ = splitext(string(source.file))
    "$path-$(source.line).html"
end

function cleanup_debug_formations(dir)
    for f in readdir(dir; join=false)
        if occursin(r"test_[a-zA-Z_]+-[0-9]+.html", f)
            rm(joinpath(dir, f); force=true)
        end
    end
end


"""
    @debug_formations(kb)

Write an HTML file that shows the dancers locations and directions,
and list all of the formations in the knowledgebase.
"""
macro debug_formations(kb)
    esc(
        quote
            formation_debug_html($__source__,
                                 Test.get_testset(),
                                 $(file_name_for_source_location(__source__)),
                                 $kb)
        end)
end

