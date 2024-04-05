export animate

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
    x(ds) = DANCER_SVG_SIZE * ds.left
    y(ds) = DANCER_SVG_SIZE * ds.down
    rot(ds) = @sprintf("%3.0f %3.2f %3.2f",
                       90 - 360 * ds.direction,
                       x(ds), y(ds))
    elt("svg",
        "xmlns" => SVG_NAMESPACE,
        bounds_to_viewbox(bounds)...,
        DANCER_SYMBOLS...,
        elt("g") do a
            for (dancer, dss) in timeline
                sorted = sort(dss; by = ds -> ds.time)
                a(elt("use",
                      "width" => DANCER_SVG_SIZE,
                      "height" => DANCER_SVG_SIZE,
                      "class" => dancer_color(dancer),
                      gender_css_symbol(dancer.gender),
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
                          "dur" => duration,
                          "repeatCount" => "indefinite" ,
                          "attributeName" => "transform",
                          "type" => "rotate",
                          "values" => join(map(rot, sorted), "; "))
                      ))
            end
        end
        )
end

