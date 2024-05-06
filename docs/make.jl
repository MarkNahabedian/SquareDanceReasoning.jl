using SquareDanceReasoning
using Documenter

DocMeta.setdocmeta!(SquareDanceReasoning, :DocTestSetup, :(using SquareDanceReasoning); recursive=true)


# Generate the formation hierarchy
include("formation_hierarchy.jl")
generate_formation_hierarchy()
generate_rule_hierarchy()


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
        "Motion Primitives" => "motion_primitives.md",
        "Supported Formations" => "formation_hierarchy.md",  # autogenerated
        "Rule Hierarchy" => "rule_hierarchy.md"              # autogenerated
    ],
)

deploydocs(;
    repo="github.com/MarkNahabedian/SquareDanceReasoning.jl",
    devbranch="main",
)