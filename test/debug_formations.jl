
using SquareDanceReasoning: elt
using XML


function file_name_for_testset(testset)
    if testset isa Test.FallbackTestSet
        return nothing
    end
    replace(testset.description,
            " ", "_") * ".html"
end


"""
    @debug_formations(kb)

Write an HTML file that shows the dancers locations and directions,
and list all of the formations in the knowledgebase.
"""
macro debug_formations(kb)
    filename = file_name_for_testset(Test.get_testset())
    if filename == nothing
        filename = "$(__source__.file)-$(__source__.line).html"
    end
    source_line = "At $(__source__.file):$(__source__.line)"
    esc(
        quote
            let
                kb = $kb
                dancer_states = collecting() do c
                    askc(c, kb, DancerState)
                end
                doc = elt("html",
                          elt("head"),
                          elt("body",
                              elt("h1", Test.get_testset().description),
                              elt("p", $source_line),
                              dancer_states_table(dancer_states)
                              ))
                XML.write($filename, doc)
            end
        end)
end

