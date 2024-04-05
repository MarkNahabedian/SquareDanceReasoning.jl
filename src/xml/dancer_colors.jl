
function dancer_colors_css(number_of_couples)
    colors =
        let
            incr = 360 / number_of_couples
            map(incr * (0:(number_of_couples - 1))) do hue
                # I couldn't get CSS hsl() colors to work properly in
                # Chrome, so convert to RGB:
                hsi = HSI(hue, 1.0, 1.)
                rgb = convert(RGB, hsi)
                fix(x) = round(255 * x)
                @sprintf("rgb(%d %d %d)",
                         fix(rgb.r), fix(rgb.g), fix(rgb.b))
            end
        end
    rules = map(enumerate(colors)) do (couple_number, color)
                 """\n.couple$(couple_number)swatch {
    color: $color;
}
.couple$(couple_number) {
    stroke: black;
    fill: $color
}"""                 
    end
    join(rules, "\n")
end

couple_color_swatch(dancer::Dancer) = "couple$(dancer.couple_number)swatch"
couple_color_swatch(ds::DancerState) = couple_color_swatch(ds.dancer)

dancer_color(dancer::Dancer) = "couple$(dancer.couple_number)"
dancer_color(ds::DancerState) = dancer_color(ds.dancer)

