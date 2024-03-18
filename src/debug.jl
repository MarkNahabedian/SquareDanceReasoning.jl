
using OrderedCollections: OrderedDict
using XML

export dancer_states_table

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


#=

Table of DancerStates

Show formations in SVG:
https://marknahabedian.github.io/SquareDanceFormationDiagrams/demo.html

Maybe this should be a macro so it can report the line number and file
of the call.

Maybe this should be in tests so we can acess
Test.get_testset().description to nae the HTML file.

=#

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

