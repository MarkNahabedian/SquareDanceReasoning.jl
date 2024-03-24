
using OrderedCollections: OrderedDict
using XML
using Colors
using Printf

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
    "https://marknahabedian.github.io/SquareDanceFormationDiagrams/dancers.js"

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

function dancer_colors_css(number_of_couples)
    colors =
        let
            incr = 360 / number_of_couples
            map(incr * (0:(number_of_couples - 1))) do hue
                # I couldn't get CSS hsl() colors to work properly in
                # Chrome, so convert to RGB:
                hsi = HSI(hue, 1.0, 1.)
                rgb = convert(RGB, hsi)
                fix(x) = round(255 * x)
                @sprintf("rgb(%d %d %d)",
                         fix(rgb.r), fix(rgb.g), fix(rgb.b))
            end
        end
    rules = map(enumerate(colors)) do (couple_number, color)
                 """.couple$(couple_number)swatch {
    color: $color;
}
.couple$(couple_number) {
    stroke: black;
    fill: $color
}"""                 
    end
    join(rules, "\n")
end

couple_color_swatch(dancer::Dancer) = "couple$(dancer.couple_number)swatch"
couple_color_swatch(ds::DancerState) = couple_color_swatch(ds.dancer)

daner_color(dancer::Dancer) = "couple$(dancer.couple_number)"
daner_color(ds::DancerState) = daner_color(ds.dancer)

global DANCER_SYMBOLS = nothing

function load_dancer_symbols()
    doc = XML.read(joinpath(@__DIR__, "dancer_symbols.svg"), Node)
    filter(children(children(doc)[1])) do node
        XML.nodetype(node) == XML.Element && tag(node) == "symbol"
    end
end

function __init__()
    if DANCER_SYMBOLS == nothing
        global DANCER_SYMBOLS = load_dancer_symbols()
    end
end


function dancer_states_table(dancer_states)
    dancer_state_row(ds::DancerState) =
        elt("tr",
            elt("td", formation_id_string(ds)),
            elt("td", string(ds.dancer)),
            elt("td", ds.time),
            elt("td", ds.direction),
            elt("td", ds.down),
            elt("td", ds.left),
            elt("td", "class" => "$(couple_color_swatch(ds))",
                "\u2588\u2588\u2588"))
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
                    elt("th", "couple color")),
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


xml_id_letter(::Guy) = "m"
xml_id_letter(::Gal) = "f"
xml_id_letter(::Unspecified) = "u"

xml_id(d::Dancer) = "dancer$(d.couple_number)$(xml_id_letter(d.gender))"


gender_css_symbol(::Guy) = "href" => "#Guy"
gender_css_symbol(::Gal) = "href" => "#Gal"
gender_css_symbol(::Unspecified) = "href" => "#Neutral"

const DANCER_SVG_SIZE = 20


function bounds_to_viewbox(bounds::Bounds)
    bounds = bump_out(bounds, 2)
    width = abs(DANCER_SVG_SIZE * (bounds.max_left - bounds.min_left))
    height = abs(DANCER_SVG_SIZE * (bounds.max_down - bounds.min_down))
    [
        "viewBox" =>
            @sprintf("%3.3f %3.3f %3.3f %3.3f",
                     DANCER_SVG_SIZE * bounds.min_left,
                     DANCER_SVG_SIZE * bounds.min_down,
                     width, height),
        "width" => width,
        "height" => height
    ]
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
        "class" => daner_color(ds),
        gender_css_symbol(ds.dancer.gender)
        )
end

function formation_debug_html(source,   # ::LineNumberNode,
                              testset,  # Test.AbstractTestSet
                              kb::ReteRootNode)
    desc = testset.description
    dancer_states = collecting() do c
        askc(c, kb, DancerState)
    end
    bounds = Bounds(Vector{DancerState}(dancer_states))
#     source_line = "At $(source.file):$(source.line)"
    elt("html",
        elt("head",
            elt("meta", "charset" => "utf-8"),
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
                    DANCER_SYMBOLS...,
                    elt("g",
                        dancer_placement_svg.(dancer_states)...)))
            ))
end
