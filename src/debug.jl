
using OrderedCollections: OrderedDict
using XML
using Colors
using Printf

export dbgprint, write_formation_html_file

# NOTE that for $ string substitution, that is not done with this
# IOContext and is not compact.
function dbgprint(things...)
    println(IOContext(stdout,
                      :limit => false,
                      :compact => true),
            things...)
end


const FORMATION_STYLESHEET = """
/* FORMATION_STYLESHEET */

svg {
    background-color: "gray";
}
table {
    empty-cells: show;
}
.DancerState-table th {
    text-align: center;
    margin-left: 8em;
    margin-right: 8em;
}
.DancerState-table td {
    text-align: center;
    margin-left: 8em;
    margin-right: 8em;
}

#floor {
    margin-top: 0.3in;
    margin-bottom: 0.3in;
    margin-left: 0.3in;
}

.DirectionDot {
    stroke: black;
    fill: black;
}
"""

const DANCER_SELECTION_STYLESHEET = """
/* DANCER_SELECTION_STYLESHEET */

@namespace svgns $SVG_NAMESPACE;

li.formation {
    border-width: 2;
    border-style: none;
}

.formation:hover {
    border-style: solid;
    border-color: blue;
}

.formation.selected {
    border-width: 2px;
    border-style: solid;
    border-color: yellow;
}

@keyframes blink-selected-dancer {
    50% {
        fill-opacity: 0.1;
    }
}

#floor .dancer.selected {
    animation-name: blink-selected-dancer;
    animation-duration: 0.7s;
    animation-fill-mode: none;
    animation-iteration-count: infinite;
}

"""


function dancer_states_table(dancer_states, symbol_uri_base)
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
            #=
            elt("td", "class" => "$(couple_color_swatch(ds))",
                # Full block unicode character
                "\u2588\u2588\u2588")
            =#
            elt("td", formation_svg(ds, symbol_uri_base;
                                    id = nothing,
                                    margin=COUPLE_DISTANCE/2))
            )
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
                    elt("th", "symbol")),
            elt("tbody",
                map(dancer_state_row,
                    sort(dancer_states; by = ds -> ds.dancer))...))))
end


formation_id_string(d::Dancer) =
    "$(d.couple_number)$(xml_id_letter(d.gender))"

formation_id_string(ds::DancerState) =
    formation_id_string(ds.dancer)

formation_id_string(f::Collision) =
    *(string(typeof(f)), "-",
      join(map(formation_id_string, f()), "-"))

formation_id_string(f::SquareDanceFormation) =
    *(string(typeof(f)), "-",
      join(map(formation_id_string, f()), "-"))

### NOTE THAT SVG DANCERS DON'T HAVE IDS YET!!!

function formation_onclick(f)
    selection_ids = map(formation_id_string, dancer_states(f))
    selection_ids_js = "[" *
        join(map(sid -> "\"$sid\"", selection_ids),
             ", ") *
        "]"
    """select_dancers(event, $selection_ids_js)"""
end

function dancer_formations_html(formations_by_type::Dict{Type, Vector})
    ks = sort(collect(keys(formations_by_type)); by = string)
    elt("ul") do a
        for key in ks
            a(elt("li", string(key),
                  elt("ul") do a
                      for f in sort(formations_by_type[key];
                                    by = formation_id_string)
                          a(elt("li",
                                "class" => "formation",
                                formation_id_string(f),
                                "onclick" => formation_onclick(f)))
                      end
                  end))
        end
    end
end

function dancer_placement_svg(ds::DancerState)
    # We arrage the coordinates so that increasing down corresponds
    # with increasing SVG Y, and increasing left corresponds with
    # increasing SVG X.  This is no longer a right handed cartesioan
    # coordinate system because the default SVG coordinate system is
    # left handed.
    x = DANCER_SVG_SIZE * ds.left
    y = DANCER_SVG_SIZE * ds.down
    elt("use",
        "transform" => @sprintf("rotate(%3.0f %3.2f %3.2f)",
                                90 - 360 * ds.direction, x, y),
        "x" => x,
        "y" => y,
        "width" => DANCER_SVG_SIZE,
        "height" => DANCER_SVG_SIZE,
        "class" => dancer_color(ds),
        gender_css_symbol(ds.dancer.gender)
        )
end

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

function formation_debug_html(source,   # ::LineNumberNode,
                              testset,  # Test.AbstractTestSet
                              output_path,
                              kb::SDRKnowledgeBase)
    formation_debug_html(source,
                         testset,
                         output_path,
                         get_formations_by_type(kb))
end    

function formation_debug_html(source,   # ::LineNumberNode,
                              testset,  # Test.AbstractTestSet
                              output_path,
                              formations::Vector{<:SquareDanceFormation})
    formations_by_type = Dict{Type, Vector}()
    for f in formations
        if !haskey(formations_by_type, typeof(f))
            formations_by_type[typeof(f)] = []
        end
        push!(formations_by_type[typeof(f)], f)
    end
    formation_debug_html(source,
                         testset,
                         output_path,
                         formations_by_type)    
end

function formation_debug_html(source,   # ::LineNumberNode,
                              testset,  # Test.AbstractTestSet
                              output_path,
                              formations::Dict{Type, Vector})
    write_formation_html_file(testset.description, output_path,
                              formations)
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
