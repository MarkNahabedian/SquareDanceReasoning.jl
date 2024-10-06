
using OrderedCollections: OrderedDict
using XML
using Colors
using Printf

export dbgprint

# NOTE that for $ string substitution, that is not done with this
# IOContext and is not compact.
function dbgprint(things...)
    println(IOContext(stdout,
                      :limit => false,
                      :compact => true),
            things...)
end


const FORMATION_STYLESHEET = """
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
.DirectionDot {
    stroke: black;
    fill: black;
}
"""


function dancer_states_table(dancer_states, symbol_uri_base)
    dancer_state_row(ds::DancerState) =
        elt("tr",
            elt("td", formation_id_string(ds),
                "onclick" => formation_onclick(ds)),
            elt("td", string(ds.dancer)),
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
      join(map(formation_id_string, dancer_states(f)), "-"))

formation_id_string(f::SquareDanceFormation) =
    *(string(typeof(f)), "-",
      join(map(formation_id_string, dancer_states(f)), "-"))

### NOTE THAT SVG DANCERS DON'T HAVE IDS YET!!!

function formation_onclick(f)
    selection_ids = map(formation_id_string, dancer_states(f))
    selection_ids_js = "[" *
        join(map(sid -> "\"$sid\"", selection_ids),
             ", ") *
        "]"
    """console.log(\"click on DancerState \", $selection_ids_js)"""
end

function dancer_formations_html(kb::ReteRootNode)
    formations_by_type = Dict{Type, Vector}()
    askc(kb, Union{SquareDanceFormation,
                   Collision}) do fact
        if !haskey(formations_by_type, typeof(fact))
            formations_by_type[typeof(fact)] = []
        end
        # Some formations are stored in memory nodes for their
        # supertypes as well.  Avoid duplicates:
        if !in(fact, formations_by_type[typeof(fact)])
             push!(formations_by_type[typeof(fact)], fact)
        end
    end
    ks = sort(collect(keys(formations_by_type)); by = string)
    elt("ul") do a
        for key in ks
            a(elt("li", string(key),
                  elt("ul") do a
                      for f in sort(formations_by_type[key];
                                    by = formation_id_string)
                          a(elt("li",
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

function formation_debug_html(source,   # ::LineNumberNode,
                              testset,  # Test.AbstractTestSet
                              output_path,
                              kb::ReteRootNode)
    write_formation_html_file(testset.description, output_path, kb)
end


# Write an HTML file that describes the DancerStates and concluded
# formations
function write_formation_html_file(title, output_path, kb::ReteRootNode)
    symbol_uri_base = collateral_file_relpath("dancer_symbols.svg",
                                              output_path)
    dancer_states = askc(Collector{DancerState}(), kb, DancerState)
    bounds = bump_out(Bounds(dancer_states))
    doc =
        elt("html",
            elt("head",
                elt("meta", "charset" => "utf-8"),
                # Adding a base element seems to break the Documenter
                # navigation links.  elt("base", "href" => docbase),
                elt("title", title),
                elt("style", "\n",
                    FORMATION_STYLESHEET,
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
                    dancer_formations_html(kb))
                ))
    XML.write(output_path, doc)
end
