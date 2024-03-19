
using OrderedCollections: OrderedDict
using XML


# elt copied from PanelCutting.jl.

"""
    elt(f, tagname::AbstractString, things...)
    elt(tagname::AbstractString, things...)

Return an XML element.  `f` is called with a single argument: either
an XML.AbstractXMLNode or a Pair describing an XML attribute to be added to the
resulting element.
"""
function elt(f::Function, tagname::AbstractString, things...)
    attributes = OrderedDict()
    children = Vector{Union{String, XML.AbstractXMLNode}}()
    function add_thing(s)
        if s isa Pair
            attributes[Symbol(s.first)] = string(s.second)
        elseif s isa AbstractString
            push!(children, s)
        elseif s isa Number
            push!(children, string(s))
        elseif s isa XML.AbstractXMLNode
            push!(children, s)
        elseif s isa Nothing
            # Ignore
        else
            error("unsupported XML content: $s")
        end
    end
    for thing in things
        add_thing(thing)
    end
    f(add_thing)
    Node(XML.Element, tagname, attributes, nothing, children)
end

elt(tagname::AbstractString, things...) = elt(identity, tagname, things...)


const SVG_NAMESPACE = "http://www.w3.org/2000/svg"

const FORMATIONS_JAVASCRIPT_URL =
    "https://raw.githubusercontent.com/MarkNahabedian/SquareDanceFormationDiagrams/master/dancers.js"


function dancer_states_table(dancer_states)
    dancer_state_row(ds::DancerState) =
        elt("tr",
            elt("td", string(ds.dancer)),
            elt("td", ds.time),
            elt("td", ds.direction),
            elt("td", ds.down),
            elt("td", ds.left))
    elt("div", 
        "class" => "DancerState-table",
        elt("table",
            elt("thread",
                elt("tr",
                    elt("th", "dancer"),
                    elt("th", "time"),
                    elt("th", "direction"),
                    elt("th", "down"),
                    elt("th", "left")),
            elt("tbody",
                map(dancer_state_row,
                    sort(dancer_states; by = ds -> ds.dancer))...))))
end


formation_id_string(d::Dancer) =
    "$(d.couple_number)$(xml_id_letter(d.gender))"

formation_id_string(ds::DancerState) =
    formation_id_string(ds.dancer)

formation_id_string(f::SquareDanceFormation) =
    *(string(typeof(f)), "-",
      join(map(formation_id_string, dancer_states(f)), "-"))


function dancer_formations_html(kb::ReteRootNode)
    formations_by_type = Dict{Type, Vector{SquareDanceFormation}}()
    askc(kb, SquareDanceFormation) do fact
        if !haskey(formations_by_type, typeof(fact))
            formations_by_type[typeof(fact)] =
                Vector{SquareDanceFormation}()
        end
        push!(formations_by_type[typeof(fact)], fact)
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


#=
    <div class="example">
      <div class="name">Squared Set</div>
      <div>
	<pre class="draw">
new Floor([
    new Dancer(3, 1, 0, "1", Dancer.gender.GUY),
    new Dancer(2, 1, 0, "1", Dancer.gender.GAL),
    new Dancer(1, 2, 1, "2", Dancer.gender.GUY),
    new Dancer(1, 3, 1, "2", Dancer.gender.GAL),
    new Dancer(2, 4, 2, "3", Dancer.gender.GUY),
    new Dancer(3, 4, 2, "3", Dancer.gender.GAL),
    new Dancer(4, 3, 3, "4", Dancer.gender.GUY),
    new Dancer(4, 2, 3, "4", Dancer.gender.GAL)
  ]).draw("squared-set");
	</pre>
	<svg id="squared-set"></svg>
      </div>
    </div>

Dancer(x, y, direction, label,
                gender=Dancer.gender.NEU,
                color="white",
               id=null)

=#

to_js(::Guy) = "Dancer.gender.GUY"
to_js(::Gal) = "Dancer.gender.GAL"
to_js(::Unspecified) = "Dancer.gender.NEU"

xml_id_letter(::Guy) = "m"
xml_id_letter(::Gal) = "f"
xml_id_letter(::Unspecified) = "u"

xml_id(d::Dancer) = "dancer$(d.couple_number)$(xml_id_letter(d.gender))"

to_js(ds::DancerState)::String = *(
    "new Dancer(",
    join([
        string(ds.down),
        string(ds.left),
        string(float(ds.direction * 4)),
        string(ds.dancer.couple_number),
        "gender=$(to_js(ds.dancer.gender))",
        "id=\"$(xml_id(ds.dancer))\""
    ], ", "),
    ")")

function to_js(ds::Vector, svg_id)::String
    @assert all(map(x -> x isa DancerState, ds))
    *(
        # svg_id is the id of the SVG element to draw in.
        "new Floor([\n",
        join(map(to_js, ds), ",\n"),
        "\n]).draw(\"$svg_id\");\n")
end

to_js(f::SquareDanceFormation, svg_id) =
    to_js(dancer_states(f), svg_id)

function formation_debug_html(source,   # ::LineNumberNode,
                              testset,  # Test.AbstractTestSet
                              kb::ReteRootNode)
    desc = testset.description
    dancer_states = collecting() do c
        askc(c, kb, DancerState)
    end
#     source_line = "At $(source.file):$(source.line)"
    elt("html",
        elt("head",
            elt("title", desc),
            elt("script",
                "type" => "text/javascript",
                "src" => FORMATIONS_JAVASCRIPT_URL),
            elt("script",
                "type" => "text/javascript",
                XML.CData("\n" * to_js(dancer_states, "floor")))),
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
                    "width" => 300,
                    "height" => 300))
            ))
end
