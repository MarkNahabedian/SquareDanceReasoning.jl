#=
It's been difficult generating SVG animations to show dancer
movement.  There are several different technologies available:

* using the SVG animate element, which seems to work but is deprecated

* using CSS keyframes, in which I, and apparently others, can't make
  rotation work

I've implemented both.
=#

export AnimationMethod, CSSKeyfraneomesAnimation, PureSVGAnimation
export animate, animation_svg


abstract type AnimationMethod end


"""
    CSSKeyfraneomesAnimation

As the method argument to `animate`, uses the *CSS keyframes*
to animte SVG.

In my, and others's experience,  can't get rotation to work.
"""
struct CSSKeyframesAnimation <: AnimationMethod
end


"""
    PureSVGAnimation

As the method argument to `animate`, use pure SVG `animate` animation.
Various sources suggest that SVG `animate` is deprecated, but it
works.
"""
struct PureSVGAnimation <: AnimationMethod
end


"""
    fixed(x)

truncates ludicrously small floating point numbers.
"""
fixed(x::Real) = trunc(2048 * x) / 2048

svg_x(ds) = fixed(DANCER_SVG_SIZE * ds.left)
svg_y(ds) = fixed(DANCER_SVG_SIZE * ds.down)

svg_angle(ds::DancerState) = svg_angle(ds.direction)
svg_angle(a::Number) = fixed(90 - 360 * Float32(a))

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


function animate_finish(output_file, doc)
    if endswith(output_file, ".svg")
        XML.write(output_file, doc)
    end
    doc
end


DANCERS_SYMBOLS_DEFS = nothing

function dancers_symbols_defs()
    if DANCERS_SYMBOLS_DEFS == nothing
        parsed = read(joinpath(@__DIR__, "dancer_symbols.svg"), Node)
        symbols = []
        function walk(node::Node)
            if XML.nodetype(node) == XML.Element && node.tag == "symbol"
                push!(symbols, node)
            else
                for child in XML.children(node)
                    walk(child)
                end
            end
        end
        walk(parsed)
        global DANCERS_SYMBOLS_DEFS = XML.Element("defs", symbols...)
    end
    DANCERS_SYMBOLS_DEFS
end


"""
    animate(method::AnimationMethod, output_file, dancer_states; bpm=40)

Returns an SVG document fragment that animates the motion of the
`Dancer`s in `dancer_states`.

If `output_file` ends in ".svg" then the document fragment is written
to that file. `output_file` is still needed so that the relative path
to the dancer symbols file canbe determined.

`dancer_states` should have the most recent `DancerState` for each
`Dancer`.  the `previous` property of each `DancerState` is used to
determine the `Dancer`'s motion.

`bpm` or "beats per minute" provides a time scale for the animation.
Assuming each unit of `time` in a `DancerState` is a single beat,
`bpm` is used to calculate the total duration of one cycle through the
animation.
"""
function animate(method::AnimationMethod,
                 output_file, dancer_states::Vector{DancerState};
                 bpm=40,
                 symbol_uri_base = collateral_file_relpath("dancer_symbols.svg",
                                                           output_file))
    doc = animation_svg(method, dancer_states;
                        bpm=bpm,
                        symbol_uri_base = collateral_file_relpath("dancer_symbols.svg",
                                                                  output_file))
    animate_finish(output_file, doc)
end


function animation_svg(method::CSSKeyframesAnimation,
                       dancer_states::Vector{DancerState},
                       bpm;
                       symbol_uri_base="")
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
              if symbol_uri_base == ""
                  [ dancers_symbols_defs() ]
              else
                  []
              end...,
              elt("g") do a
                  for ds in dancer_states
                      e = earliest(ds)
                      comment = IOBuffer()
                      history(ds) do ds
                          show(comment, MIME"text/plain"(), ds)
                          write(comment, "\n")
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
                                "\n")
                            ))
                  end
              end
              )
    doc
end

function smooth_svg_rotation(hist)
    # Returns the "value" attribute for animateTransform as a vector
    # of strings not yet joined to a single string.
    #
    # DancerState normalizes dancer rotation to a single full circle
    # rotation in the range 0 to 1..
    #
    # When we use svg_angle to convert the direction to an angle in
    # degrees in the SVG coordinate system, we might get a sucessive
    # pair of rotations like -225.0, 90.0.  This makes the animation
    # look jerkey because SVG treats that difference literally rather
    # than rotating in the shorter direction.  Since we will always
    # have enough DancerStates that there willnever be a "long"
    # rotation, we never want that behavior.
    #
    # Here we go through successive rotations and adjust to make sure
    # there are no long ones.
    accumulated = svg_angle(hist[1].direction)
    rot(a, ds) = "$a $(svg_x(ds)) $(svg_y(ds))"
    results = [rot(accumulated, hist[1])]
    for i in 2:length(hist)
        delta = svg_angle(hist[i].direction) -
                svg_angle(hist[i-1].direction)
        if delta > 180
            delta -= 360
        elseif delta < -180
            delta +=360
        end
        accumulated += delta
        push!(results, rot(accumulated, hist[i]))
    end
    results
end

function history_for_animation(ds)
    hist = DancerState[]
    history(ds) do ds1
        len = length(hist)
        # If two of ds1 have the same time, prefer
        # the one that is later in the chain:
        if len > 0 && hist[len].time == ds1.time
            hist[len] = ds1
        else
            push!(hist, ds1)
        end
    end
    hist
end

function animation_svg(method::PureSVGAnimation,
                       dancer_states::Vector{DancerState};
                       bpm=40,
                       symbol_uri_base="")
    dancer_states = sort(dancer_states; by = ds -> ds.dancer)
    # Add a pause at the end of the sequence:
    dancer_states = map(dancer_states) do ds
        DancerState(ds, ds.time + 2, ds.direction, ds.down, ds.left)
    end
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
    doc = elt("svg",
              "xmlns" => SVG_NAMESPACE,
              bounds_to_viewbox(bounds)...,
              xmlComment("\n" * string(bounds) * "\n"),
              elt("style",
                  DIRECTION_DOT_STYLE,
                  dancer_colors_css(number_of_couples)),
              if symbol_uri_base == ""
                  [ dancers_symbols_defs() ]
              else
                  []
              end...,
              elt("g", :class => "animation") do a
                  for ds in dancer_states
                      hist = history_for_animation(ds)
                      comment = IOBuffer()
                      for ds in hist
                          show(comment, MIME"text/plain"(), ds)
                          write(comment, "\n")
                      end
                      keytimes = join(map(ds -> @sprintf("%06.4f",
                                                         fixed(fraction(tbounds,
                                                                        ds.time))),
                                          hist), ";")
                      a(elt("use",
                            "id" => dancer_keyframe_id(ds.dancer),
                            "href" => "$symbol_uri_base#$(gender_fragment(ds.dancer.gender))",
                            "width" => DANCER_SVG_SIZE,
                            "height" => DANCER_SVG_SIZE,
                            "class" => dancer_color(ds.dancer),
                            elt("animate",
                                "repeatCount" => "indefinite",
                                "dur" => "$(duration_seconds)s",
                                "keyTimes" => keytimes,
                                "attributeName" => "x",
                                "values" => join(map(svg_x, hist), ";")),
                            elt("animate",
                                "repeatCount" => "indefinite",
                                "dur" => "$(duration_seconds)s",
                                "keyTimes" => keytimes,
                                "attributeName" => "y",
                                "values" => join(map(svg_y, hist), ";")),
                            elt("animateTransform",
                                "repeatCount" => "indefinite",
                                "dur" => "$(duration_seconds)s",
                                "keyTimes" => keytimes,
                                "attributeName" => "transform",
                                "type" => "rotate",
                                "values" => join(smooth_svg_rotation(hist),
                                                 ";")),
                            xmlComment("\n" * String(take!(comment)))
                            ))
                  end
              end)
    doc
end


const DEFAULT_ANIMATION_METHOD = PureSVGAnimation()

animate(output_file, dancer_states; bpm=40) =
    animate(DEFAULT_ANIMATION_METHOD, output_file, dancer_states;
            bpm=bpm,
            symbol_uri_base = collateral_file_relpath("dancer_symbols.svg",
                                                      output_file))

animation_svg(dancer_states::Vector{DancerState}; bpm=40) =
    animation_svg(DEFAULT_ANIMATION_METHOD, dancer_states; bpm=bpm)

