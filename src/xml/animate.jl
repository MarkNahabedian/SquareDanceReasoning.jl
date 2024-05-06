export animate

"""
    fixed(x)

truncates ludicrously small floating point numbers.
"""
fixed(x::Real) = trunc(2048 * x) / 2048

dancer_keyframe_id(d::Dancer) =
    "dancer_$(d.couple_number)_$(xml_id_letter(d.gender))"

function keyframes(timeline)
    tb = expand(TimeBounds(), timeline)
    io = IOBuffer()
    write(io, "\n")
    x(ds) = fixed(DANCER_SVG_SIZE * ds.left)
    y(ds) = fixed(DANCER_SVG_SIZE * ds.down)
    svgangle(ds) = fixed(mod(90 - 360 * ds.direction, 360))
    rot(ds) = "$(svgangle(ds))deg $(x(ds)) $(y(ds))"
    for (dancer, dss) in timeline
        println(io, "@keyframes $(dancer_keyframe_id(dancer)) {")
        for ds in dss
            println(io, "    $(fixed(percentage(tb, ds.time)))% {")
            println(io, "        x: $(x(ds)); y: $(y(ds));")
            println(io, "    }")
        end
        println(io, "}")
    end
    String(take!(io))
end


const DIRECTION_DOT_STYLE =
"""\n.DirectionDot {
    stroke: black;
    fill: black;
}
"""


function animate(timeline::Dict{Dancer, Vector{DancerState}})
    bounds = Bounds()
    for dss in values(timeline)
        bounds = expand(bounds, dss)
    end
    bounds = bump_out(bounds)
    duration = let
        t(ds) = ds.time
        dss = Iterators.flatten(values(timeline))
        maximum(t, dss) - minimum(t, dss)
    end
    duration *= 0.5
    x(ds) = fixed(DANCER_SVG_SIZE * ds.left)
    y(ds) = fixed(DANCER_SVG_SIZE * ds.down)
    svgangle(ds) = fixed(mod(90 - 360 * ds.direction, 360))
    rot(ds) = "$(svgangle(ds))deg $(x(ds)) $(y(ds))"
#=
    function rotations(sorted_dss)
        from = []
        to = []
        prev = svgangle(first(sorted_dss))
        for ds in sorted_dss
            this = svgangle(ds)
            push!(from, @sprintf("%3.0f %3.2f %3.2f",
                                   prev,
                                   x(ds), y(ds)))
            push!(to, @sprintf("%3.0f %3.2f %3.2f",
                               this,
                               x(ds), y(ds)))
            prev = this
        end
        ["from" => join(from, "; "),
         "to" => join(to, "; ") ]
    end
    =#
    elt("svg",
        "xmlns" => SVG_NAMESPACE,
        bounds_to_viewbox(bounds)...,
        elt("style",
            DIRECTION_DOT_STYLE,
            dancer_colors_css(ceil(length(keys(timeline)) / 2)),
            keyframes(timeline)),
        DANCER_SYMBOLS...,
        elt("g") do a
            for (dancer, dss) in timeline
                sorted = sort(dss; by = ds -> ds.time)
                a(elt("use",
                      "id" => dancer_keyframe_id(dancer),
                      "width" => DANCER_SVG_SIZE,
                      "height" => DANCER_SVG_SIZE,
                      "class" => dancer_color(dancer),
                      "x" => x(first(sorted)),
                      "y" => y(first(sorted)),
                      "transform" => "rotate($(rot(first(sorted))))",
                      gender_css_symbol(dancer.gender),
                      xmlComment("\n" * join(sorted, "\n") * "\n"),
#=
                      elt("animate",
                          "dur" => duration,
                          "repeatCount" => "indefinite" ,
                          "attributeName" => "x",
                          "values" => join(map(x, sorted), "; ")),
                      elt("animate",
                          "dur" => duration,
                          "repeatCount" => "indefinite" ,
                          "attributeName" => "y",
                          "values" => join(map(y, sorted), "; ")),
                      elt("animateTransform",
                          "attributeType" => "XML",
                          "dur" => duration,
                          "repeatCount" => "indefinite" ,
                          "attributeName" => "transform",
                          "type" => "rotate",
                          # "values" => join(map(rot, sorted), "; ")
                          # "from" => rot(first(sorted)),
                          # "by" => join(relative_rotations(sorted), "; ")
                          rotations(sorted)...
                              )
=#
                      ))
            end
        end
        )
end
