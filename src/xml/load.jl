
using XML
using Colors
using Printf

const SVG_NAMESPACE = "http://www.w3.org/2000/svg"

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


include("elt.jl")
include("dancer_symbols.jl")
include("dancer_colors.jl")
include("animate.jl")

