using SquareDanceReasoning
using Documenter
using InteractiveUtils

DocMeta.setdocmeta!(SquareDanceReasoning, :DocTestSetup, :(using SquareDanceReasoning); recursive=true)


# Generate the formation hierarchy
include("formation_hierarchy.jl")
include("showcase.jl")
generate_formation_hierarchy()
generate_rule_hierarchy()

# Generate formation_drawings:
let
    d = joinpath(@__DIR__, "src/formation_drawings")
    formation_names = []
    mkpath(d)
    SquareDanceReasoning.generate_example_formation_diagrams(d)
    for f in readdir(joinpath(@__DIR__, d); join=true)
        _, filename = splitdir(f)
        (name, ext) = splitext(filename)
        if ext == ".html"
            doc = open(f, "r") do io
                read(io, String)
            end
            mdname = "$name.md"
            open("$(joinpath(d, mdname))", "w") do io
                println(io, "```@raw html")
                write(io, doc)
                println(io, "\n```")
            end
            rm(f)
            push!(formation_names, name)
        end
    end
    open(joinpath(d, "index.md"), "w") do io
        println(io, "# Formation Drawings\n")
        for f in formation_names
            println(io, "- [$f]($f.md)")
        end
    end
    cp(joinpath(@__DIR__, "../src/xml/dancer_symbols.svg"),
       joinpath(@__DIR__, "src/dancer_symbols.svg");
       force=true)
end

# Generate a list of supported square dance calls:
let
    d = calls_and_formations_dict()
    open(joinpath(@__DIR__, "src", "supported_square_dance_calls.md"),
         "w") do io
             println(io, "## Supported Square Dance Calls\n")
             println(io, "These are the calls that are currently implemented.")
             println(io, "They might not be implemented from all formations or all CallerLab programs.")
             println(io, "")
             for call in sort(collect(keys(d)); by = string)
                 fn = join(fieldnames(call), ", ")
                 println(io, "- **[`$call`](@ref)**: $fn")
                 for f in sort(d[call]; by = string)
                     println(io, "    - [`$f`](@ref)")
                 end
             end
         end
end

makedocs(;
    modules=[SquareDanceReasoning],
    authors="MarkNahabedian <naha@mit.edu> and contributors",
    repo="https://github.com/MarkNahabedian/SquareDanceReasoning.jl/blob/{commit}{path}#{line}",
    sitename="SquareDanceReasoning.jl",
    format=Documenter.HTML(;
        prettyurls=false,
        canonical="https://MarkNahabedian.github.io/SquareDanceReasoning.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Coordinate System" => "coordinate_system.md",
        "Dancers, Their Positions and Directions" => "dancers.md", 
        "Formations" => "formations.md",
        "Supported Formations" => "formation_hierarchy.md",  # autogenerated
        "Formation Drawings" => "formation_drawings/index.md",
        "Rule Hierarchy" => "rule_hierarchy.md",             # autogenerated
        "Motion Primitives" => "motion_primitives.md",
        "Call Processing" => "call_processing.md",
        "Supported Square Dance Calls" =>
            "supported_square_dance_calls.md",               # autogenerated
        "Choreograpy Showcase" => "Showcase/index.md"        # autogenerated
    ],
)

deploydocs(;
    repo="github.com/MarkNahabedian/SquareDanceReasoning.jl",
    devbranch="main",
)
