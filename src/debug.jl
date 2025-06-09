
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

