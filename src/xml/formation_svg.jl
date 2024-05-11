
export formation_svg, dancer_svg

DANCER_SYMBOLS_URI = "../dancer_symbols.svg"

gender_fragment(::Guy) = "Guy"
gender_fragment(::Gal) = "Gal"
gender_fragment(::Unspecified) = "Neutral"

dancer_symbol_uri(ds::DancerState) = dancer_symbol_uri(ds.dancer)

dancer_symbol_uri(d::Dancer) =
    "$(DANCER_SYMBOLS_URI)#$(gender_fragment(d.gender))"

function dancer_svg(ds::DancerState; id=nothing)
    # We arrage the coordinates so that increasing down corresponds
    # with increasing SVG Y, and increasing left corresponds with
    # increasing SVG X.  This is no longer a right handed cartesioan
    # coordinate system because the default SVG coordinate system is
    # left handed.
    x = DANCER_SVG_SIZE * ds.left
    y = DANCER_SVG_SIZE * ds.down

    elt("use",
        if id == nothing
            []
        else
            [ "id" => id ]
            end...,
        "href" => dancer_symbol_uri(ds),
        "transform" => @sprintf("rotate(%3.0f %3.2f %3.2f)",
                                90 - 360 * ds.direction, x, y),
        "x" => x,
        "y" => y,
        "width" => DANCER_SVG_SIZE,
        "height" => DANCER_SVG_SIZE,
        "class" => dancer_color(ds))
end


"""
    formation_svg(f::SquareDanceFormation; id=nothing)

Returns an SVG element that illustrates the formation.

If `id` is specified, it will be the XML Id of the drawing.

If margin is specified, its the assitional empth space that
surrounds the formation.
"""
function formation_svg(f; id=nothing,
                       margin=COUPLE_DISTANCE / 2)
    dss = dancer_states(f)
    bounds = bump_out(Bounds(dss), margin)
    elt("svg",
        # "id" => "floor",
        "xmlns" => SVG_NAMESPACE,
        bounds_to_viewbox(bounds)...,
        elt("g",
            map(dss) do ds
                dancer_svg(ds)
            end...))
end


