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
            attributes[Symbol(s.first)] = XML.escape(string(s.second))
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


function xmlComment(text::AbstractString)
    XML.Comment(text)
end

