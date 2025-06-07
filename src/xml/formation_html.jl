
export write_formation_html_file


function get_formations_by_type(kb::SDRKnowledgeBase)
    formations_by_type = Dict{Type, Vector}()
    let
        function f(fact)
            if !haskey(formations_by_type, typeof(fact))
                formations_by_type[typeof(fact)] = []
            end
            push!(formations_by_type[typeof(fact)], fact)
        end
        askc(f, kb, SquareDanceFormation)
    end
    formations_by_type
end


function write_formation_html_file(title, output_path,
                                   kb::SDRKnowledgeBase)
    write_formation_html_file(title, output_path,
                              get_formations_by_type(kb))
end

# Write an HTML file that describes the DancerStates and concluded
# formations
function write_formation_html_file(title, output_path,
                                   formations::Dict{Type, Vector})
    let
        collisions = find_collisions(DancerState[formations[DancerState]...])
        if !isempty(collisions)
            formations[Collision] = collisions
        end
    end
    symbol_uri_base = collateral_file_relpath("dancer_symbols.svg",
                                              output_path)
    dancer_states = formations[DancerState]
    bounds = bump_out(Bounds(dancer_states))
    selection_script = collateral_file_relpath("dancer_selection.js",
                                               output_path)
    doc =
        elt("html",
            elt("head",
                elt("meta", "charset" => "utf-8"),
                # Adding a base element seems to break the Documenter
                # navigation links.  elt("base", "href" => docbase),
                elt("title", title),
                elt("script",
                    "",                           # force close tag.
                    "type" => "text/javascript",
                    "src" => "$selection_script"),
                elt("style", "\n",
                    FORMATION_STYLESHEET,
                    DANCER_SELECTION_STYLESHEET,
                    dancer_colors_css(ceil(length(dancer_states) / 2)),
                    "\n")),
            elt("body",
                elt("h1", title),
                elt("div",
                    elt("h2", "Dancer Location and Facing Direction"),
                    dancer_states_table(dancer_states, symbol_uri_base)),
                elt("div",
                    elt("svg",
                        "id" => "floor",
                        "xmlns" => SVG_NAMESPACE,
                        bounds_to_viewbox(bounds)...,
                        elt("g",
                            map(dancer_states) do ds
                                dancer_svg(ds, symbol_uri_base)
                            end...))),
                elt("div",
                    elt("h2", "Inferred Formations"),
                    # Should say if KB was available to inferr
                    # fromatiosn from.
                    dancer_formations_html(formations))
                ))
    XML.write(output_path, doc)
end

