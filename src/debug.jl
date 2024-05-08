
using OrderedCollections: OrderedDict
using XML
using Colors
using Printf


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


function dancer_states_table(dancer_states)
    dancer_state_row(ds::DancerState) =
        elt("tr",
            elt("td", formation_id_string(ds)),
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
            elt("td", formation_svg(ds; margin=COUPLE_DISTANCE/2))
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
                          a(elt("li", formation_id_string(f)))
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
    # ".." from the output path up to the repository root:
    docbase =
        join(repeat([".."],
                    length(
                        splitpath(
                            relpath(dirname(output_path),
                                    abspath(joinpath(
                                        pathof(SquareDanceReasoning),
                                        "../..")))))),
             "/")
    desc = testset.description
    dancer_states = collecting() do c
        askc(c, kb, DancerState)
    end
    bounds = bump_out(Bounds(dancer_states))
#     source_line = "At $(source.file):$(source.line)"
    doc =
        elt("html",
            elt("head",
                elt("meta", "charset" => "utf-8"),
                elt("base", "href" => docbase),
                elt("title", desc),
                elt("style", "\n",
                    FORMATION_STYLESHEET,
                    dancer_colors_css(ceil(length(dancer_states) / 2)),
                    "\n")),
            elt("body",
                elt("h1", desc),
                #            elt("p", source_line),
                elt("div",
                    elt("h2", "Dancer Location and Facing Direction"),
                    dancer_states_table(dancer_states)),
                elt("div",
                    elt("h2", "Formations"),
                    dancer_formations_html(kb)),
                elt("div",
                    elt("svg",
                        "id" => "floor",
                        "xmlns" => SVG_NAMESPACE,
                        bounds_to_viewbox(bounds)...,
                        elt("g",
                            dancer_svg.(dancer_states)...)))
                ))
    XML.write(output_path, doc)
end
