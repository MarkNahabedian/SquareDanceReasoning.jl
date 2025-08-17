
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
    relevant_formation = nothing
    for (k, v) in formations
        if length(v) == 1
            if (relevant_formation == nothing
                || (length(dancer_states(relevant_formation)) <
                    length(dancer_states(v[1]))))
                relevant_formation = v[1]
            end
        end
    end
    roles = dancer_state_roles(relevant_formation)
    @assert roles isa AbstractDict{DancerState, Set{Role}}
    let
        collisions = find_collisions(DancerState[formations[DancerState]...])
        if !isempty(collisions)
            formations[Collision] = collisions
        end
    end
    symbol_uri_base = collateral_file_relpath("dancer_symbols.svg",
                                              output_path)
    dss = formations[DancerState]
    bounds = bump_out(Bounds(dss))
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
                    dancer_colors_css(ceil(length(dss) / 2)),
                    "\n")),
            elt("body",
                elt("h1", title),
                elt("div",
                    elt("h2", "Dancer Location and Facing Direction"),
                    dancer_states_table(dss, symbol_uri_base, roles)),
                elt("div",
                    # Should we just be using formation_svg here?
                    elt("svg",
                        "id" => "floor",
                        "xmlns" => SVG_NAMESPACE,
                        bounds_to_viewbox(bounds)...,
                        elt("g",
                            map(dss) do ds
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

function dancer_states_table(dancer_states, symbol_uri_base,
                             roles::AbstractDict{DancerState, Set{Role}})
    dancer_state_row(ds::DancerState) =
        elt("tr",
            elt("td", formation_id_string(ds),
                "class" => "formation",
                "onclick" => formation_onclick(ds)),
            elt("td", string(ds.dancer),
                "class" => "formation",
                "onclick" => formation_onclick(ds)),
            elt("td", ds.time),
            elt("td", ds.direction),
            elt("td", ds.down),
            elt("td", ds.left),
            elt("td", formation_svg(ds, symbol_uri_base;
                                    id = nothing,
                                    margin=COUPLE_DISTANCE/2)),
            elt("td",
                join(sort([string(nameof(typeof(r)))
                           for r in roles[ds]]),
                     ", ")))
    elt("div", 
        "class" => "DancerState-table",
        elt("table",
            elt("thead",
                elt("tr",
                    elt("th", "id"),
                    elt("th", "dancer"),
                    elt("th", "time"),
                    elt("th", "direction"),
                    elt("th", "down"),
                    elt("th", "left"),
                    elt("th", "symbol"),
                    elt("th", "roles")),
            elt("tbody",
                map(dancer_state_row,
                    sort(dancer_states; by = ds -> ds.dancer))...))))
end

