export containment_graph, DotBackend

abstract type ContainmentGraphBackend end


"""
containment_graph(kb::SDRKnowledgeBase, title, backend::ContainmentGraphBackend)

Visualizes the containment graph for the formations in `kb`.

`title` is a title for the graph.  It might be used as the base of a
file name.

`backend` says how to visualize the graph.
"""
function containment_graph(kb::SDRKnowledgeBase, title, backend::ContainmentGraphBackend)
    by_dancer_count = Dict{Int, Set{SquareDanceFormation}}()
    edges = FormationContainedIn[]
    askc(kb.formations_contained_in) do c::FormationContainedIn
        function note_formation(f::SquareDanceFormation)
            dancer_count = length(dancer_states(f))
            if !haskey(by_dancer_count, dancer_count)
                by_dancer_count[dancer_count] = Set{SquareDanceFormation}()
            end
            push!(by_dancer_count[dancer_count], f)
        end
        note_formation(c.contained)
        note_formation(c.container)
        push!(edges, c)
    end
    # Order by number of dancers, then by left coordinate of center of formation
    rows = Vector{SquareDanceFormation}[]
    for count in sort(collect(keys(by_dancer_count)); rev=true)
        row = SquareDanceFormation[]
        for formation in sort(collect(by_dancer_count[count]); by = f -> center(f)[2])
            push!(row, formation)
        end
        push!(rows, row)
    end
    backend(rows, edges)
end


# Write a GraphViz Dot file

"""
    DotBackend(directory, title)

Provides a subtype of ContainmentGraphBackend that uses GraphViz Dot.
"""
struct DotBackend <: ContainmentGraphBackend
    directory
    title
end

css_file_name(backend::DotBackend) = joinpath(backend.directory, backend.title, "stylesheet.css")

dot_file_name(backend::DotBackend) = joinpath(backend.directory, backend.title, "graph.dot")

formation_file_name(backend::DotBackend, f::SquareDanceFormation) =
    joinpath(backend.directory, formation_filename(f))

function (backend::DotBackend)(rows::Vector{Vector{SquareDanceFormation}},
                               edges::Vector{FormationContainedIn})
    dir = mkpath(joinpath(backend.directory, backend.title))
    # Write an SVG file for each formation:
    formation_filename(f) = formation_id_string(f) * ".svg"
    for row in rows
        for f in row
            svg = formation_svg(f, collateral_file_relpath("dancer_symbols.svg",
                                                           backend.directory);
                                id=formation_id_string(f))
            XML.write(joinpath(dir, formation_filename(f)),
                      wrap_with_document_and_xml_declaration(svg))
        end
    end
    # Write a CSS file:
    open(css_file_name(backend), "w") do io
        # We need the rule for .DirectionDot and for couple colors
        write(io, """.DirectionDot { stroke: black; fill: black; }\n\n""")
        write(io, dancer_colors_css(4))
    end
    # Write the dot file:
    open(dot_file_name(backend), "w") do io
        write(io, "digraph $(dotescape(backend.title)) {\n")
        write(io, """stylesheet = "stylesheet.css"\n""")
        for row in rows
            for f in row
                node_id = dotescape(formation_id_string(f))
                svg_file = formation_filename(f)
                write(io, """$node_id[image=$(dotescape(svg_file)), label=""]\n""")
            end
        end
        for edge in edges
            from = edge.container
            to = edge.contained
            write(io, "$(dotescape(formation_id_string(from))) -> $(dotescape(formation_id_string(to)))\n")
        end
        write(io, "}\n")
    end
end

"""
    dotescape(::AbstractString)::AbstractString

Escape an `ID` in the GraphViz Dot language.  'ID' is
the fundamental token in Dot.
"""
function dotescape(s::AbstractString)::AbstractString
    "\"" *
        replace(s, "\"" => "\\\"") *
        "\""
end

