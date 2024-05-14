
export DANCER_SYMBOLS_URI, dancer_symbol_uri, formation_svg, dancer_svg


"""
DANCER_SYMBOLS_URI is a Dict that shows where to look for the dancer
symbol definitions.  This depends on what directory the formation HTML
files are written to, which would determine whether the HTML will be
accessed by a "local" URL, buy a GitHub Pages URL or whatever.
"""
DANCER_SYMBOLS_URI = Dict{Vector{String}, String}(
    # We use splitpath because its protects us from Fucking MSWindows
    # deviant path separators.
    # path relative to repo root => path relative to HTML file:
    splitpath("test/test_formations") => "../../src/xml/dancer_symbols.svg",
    splitpath("test/test_actions") => "../../src/xml/dancer_symbols.svg",
    # dancer_symbols.svg gets copied there by docs/make.jl
    splitpath("docs/src/formation_drawings") => "../dancer_symbols.svg"
)


"""
    dancer_symbol_uri(html_destination)

Returns a relative URI from the specified HTML page to a location
of the dancer SVG symbols file.

`html_destination` is the path where the formation HTML file is to be
written.
"""
function dancer_symbol_uri(html_destination)
    dest = splitpath(relpath(dirname(html_destination),
                             REPO_ROOT))
    if !haskey(DANCER_SYMBOLS_URI, dest)
        error("No DANCER_SYMBOLS_URI for $html_destination, $dest")
    end
    DANCER_SYMBOLS_URI[dest]
end

gender_fragment(::Guy) = "Guy"
gender_fragment(::Gal) = "Gal"
gender_fragment(::Unspecified) = "Neutral"

#=
dancer_symbol_uri(ds::DancerState) = dancer_symbol_uri(ds.dancer)

dancer_symbol_uri(d::Dancer) =
    "$(DANCER_SYMBOLS_URI)#$(gender_fragment(d.gender))"
=#

function dancer_svg(ds::DancerState, symbol_uri_base; id=nothing)
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
        "href" => "$symbol_uri_base#$(gender_fragment(ds.dancer.gender))",
        "transform" => @sprintf("rotate(%3.0f %3.2f %3.2f)",
                                90 - 360 * ds.direction, x, y),
        "x" => x,
        "y" => y,
        "width" => DANCER_SVG_SIZE,
        "height" => DANCER_SVG_SIZE,
        "class" => dancer_color(ds))
end


"""
    formation_svg(f::SquareDanceFormation, symbol_uri_base; id=nothing)

Returns an SVG element that illustrates the formation.

`symbol_uri_base` is a relative URL to the SVG symbols file.
See [`dancer_symbol_uri`](@ref).

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
                dancer_svg(ds, symbol_uri_base)
            end...))
end


