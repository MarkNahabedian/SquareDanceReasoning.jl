
using XML
using Colors
using Printf

const SVG_NAMESPACE = "http://www.w3.org/2000/svg"

function bounds_to_viewbox(bounds::Bounds)
    # bounds is in terms of coordinate system units:
    width = DANCER_SVG_SIZE * abs(bounds.max_left - bounds.min_left)
    height = DANCER_SVG_SIZE * abs(bounds.max_down - bounds.min_down)
    [
        "viewBox" =>
            @sprintf("%3.3f %3.3f %3.3f %3.3f",
                     DANCER_SVG_SIZE * bounds.min_left,
                     DANCER_SVG_SIZE * bounds.min_down,
                     width, height),
        "width" => "$width$SVG_SIZE_UNITS",
        "height" => "$height$SVG_SIZE_UNITS"
    ]
end


include("collateral_files.jl")
include("elt.jl")
include("dancer_symbols.jl")
include("dancer_colors.jl")
include("formation_svg.jl")
include("formation_html.jl")
include("animate.jl")
include("containment_graph.jl")

