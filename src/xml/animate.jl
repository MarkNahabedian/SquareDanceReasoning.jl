export animate


"""
    fixed(x)

truncates ludicrously small floating point numbers.
"""
fixed(x::Real) = trunc(2048 * x) / 2048

svg_x(ds) = fixed(DANCER_SVG_SIZE * ds.left)
svg_y(ds) = fixed(DANCER_SVG_SIZE * ds.down)

svg_angle(ds) = fixed(mod(90 - 360 * Float32(ds.direction), 360))


dancer_keyframe_id(d::Dancer) =
    "dancer_$(d.couple_number)_$(xml_id_letter(d.gender))"

function keyframes(ds::DancerState, tb::TimeBounds)
    # ds should be the most recent DancerState for a given Dancer.
    io = IOBuffer()
    write(io, "\n")
    rot(ds) = "$(svg_angle(ds)) $(svg_x(ds)) $(svg_y(ds))"
    transform(ds) = "rotate($(rot(ds)))"
    println(io, "@keyframes $(dancer_keyframe_id(ds.dancer)) {")
    history(ds) do ds
        println(io, "    $(fixed(percentage(tb, ds.time)))% {")
        println(io, "        x: $(svg_x(ds)); y: $(svg_y(ds));")
        println(io, "        transform: $(transform(ds))")
        println(io, "    }")
    end
    println(io, "}")
    String(take!(io))
end


const DIRECTION_DOT_STYLE =
"""\n.DirectionDot {
    stroke: black;
    fill: black;
}
"""

function animation_properties(dancer::Dancer, duration_seconds)
    """\n\n#$(dancer_keyframe_id(dancer)) {
    animation-name: dancer_1_u;
    animation-delay: 0.5s;
    animation-duration: $(duration_seconds)s;
    animation-direction: normal;
    animation-iteration-count: infinite;
}"""
end


animate(output_file, d::Dict{Dancer, DancerState}, bpm) =
    animate(output_file, collect(values(d)), bpm)


"""
    animate(output_file, dancer_states, bpm)

Write an SVG animation of the `dancer_states` to `output_file`.

`dancer_states` should have the most recent `DancerState` for each
`Dancer`.  the `previous` property of each `DancerState` is used to
determine the `Dancer`'s motion.

`bpm` or "beats per minute" provides a time scale for the animation.
Assuming each unit of `time` in a `DancerState` is a single beat,
`bpm` is used to calculate the total duration of one cycle through the
animation.
"""
function animate(output_file, dancer_states, bpm)
    dancer_states = sort(dancer_states; by = ds -> ds.dancer)
    number_of_couples = ceil(length(dancer_states) / 2)
    tbounds = TimeBounds()
    bounds = Bounds()
    for ds in dancer_states
        history(ds) do ds
            tbounds = expand(tbounds, ds)
            bounds = expand(bounds, ds)
        end
    end
    bounds = bump_out(bounds)
    duration_seconds = (tbounds.max - tbounds.min) / (bpm / 60)
    rot(ds) = "$(svg_angle(ds)) $(svg_x(ds)) $(svg_y(ds))"
    symbol_uri_base = dancer_symbol_uri(output_file)
    doc = elt("svg",
              "xmlns" => SVG_NAMESPACE,
              bounds_to_viewbox(bounds)...,
              elt("style",
                  DIRECTION_DOT_STYLE,
                  dancer_colors_css(number_of_couples),
                  join(map(dancer_states) do ds
                      animation_properties(ds.dancer, duration_seconds)
                  end, "\n"),
                  join(map(dancer_states) do ds
                           keyframes(ds, tbounds)
                       end,"\n")),
              elt("g") do a
                  for ds in dancer_states
                      e = earliest(ds)
                      comment = IOBuffer()
                      history(ds) do ds
                          show(comment, MIME"text/plain"(), ds)
                      end
                      a(elt("use",
                            "id" => dancer_keyframe_id(ds.dancer),
                            "href" => "$symbol_uri_base#$(gender_fragment(ds.dancer.gender))",
                            "width" => DANCER_SVG_SIZE,
                            "height" => DANCER_SVG_SIZE,
                            "class" => dancer_color(ds.dancer),
                            "x" => svg_x(e),
                            "y" => svg_y(e),
                            "transform" => "rotate($(rot(e)))",
                            xmlComment("\n" *
                                String(take!(comment)) *
                                "\n"),
                            ))
                  end
              end
              )
    XML.write(output_file, doc)
end

