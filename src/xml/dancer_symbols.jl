
xml_id_letter(::Guy) = "m"
xml_id_letter(::Gal) = "f"
xml_id_letter(::Unspecified) = "u"

xml_id(d::Dancer) = "dancer$(d.couple_number)$(xml_id_letter(d.gender))"


gender_css_symbol(::Guy) = "href" => "#Guy"
gender_css_symbol(::Gal) = "href" => "#Gal"
gender_css_symbol(::Unspecified) = "href" => "#Neutral"

const DANCER_SVG_SIZE = 20

