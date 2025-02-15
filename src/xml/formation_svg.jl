
export formation_svg, dancer_svg, wrap_with_document_and_xml_declaration


gender_fragment(::Guy) = "Guy"
gender_fragment(::Gal) = "Gal"
gender_fragment(::Unspecified) = "Neutral"

function dancer_svg(ds::DancerState, symbol_uri_base; id=missing)
    # We arrage the coordinates so that increasing down corresponds
    # with increasing SVG Y, and increasing left corresponds with
    # increasing SVG X.  This is no longer a right handed cartesioan
    # coordinate system because the default SVG coordinate system is
    # left handed.
    x = DANCER_SVG_SIZE * ds.left
    y = DANCER_SVG_SIZE * ds.down

    elt("use",
        if id isa Missing || id isa Nothing
            [ "id" => formation_id_string(ds) ]
        elseif !(id isa Nothing)
            [ "id" => "$id.$(formation_id_string(ds))" ]
        else
            []
        end...,
        "href" => "$symbol_uri_base#$(gender_fragment(ds.dancer.gender))",
        "transform" => @sprintf("rotate(%3.0f %3.2f %3.2f)",
                                90 - 360 * ds.direction, x, y),
        "x" => x,
        "y" => y,
        "width" => DANCER_SVG_SIZE,
        "height" => DANCER_SVG_SIZE,
        "class" => "dancer $(dancer_color(ds))")
end


"""
    formation_svg(f::SquareDanceFormation, symbol_uri_base; id=nothing)

Returns an SVG element that illustrates the formation.

`symbol_uri_base` is a relative URL to the SVG symbols file.
See [`collateral_file_relpath`](@ref).

If `id` is specified, it will be the XML Id of the drawing.

If margin is specified, its the additional space that surrounds the
formation.
"""
function formation_svg(f, symbol_uri_base; id=nothing,
                       margin=COUPLE_DISTANCE / 2)
    dss = dancer_states(f)
    bounds = bump_out(Bounds(dss), margin)
    elt("svg",
        # "id" => "floor",
        "xmlns" => SVG_NAMESPACE,
        bounds_to_viewbox(bounds)...,
        elt("g",
            map(dss) do ds
                dancer_svg(ds, symbol_uri_base; id=id)
            end...))
end


function wrap_with_document_and_xml_declaration(content)
    XML.Document(XML.Declaration(; version="1.0", encoding="UTF-8", standalone="no"),
                 content)
end

