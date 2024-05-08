
using SquareDanceReasoning: formation_debug_html
using XML


function file_name_for_source_location(source::LineNumberNode)
    path, _ = splitext(string(source.file))
    "$path-$(source.line).html"
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

