using SquareDanceReasoning
using Documenter

DocMeta.setdocmeta!(SquareDanceReasoning, :DocTestSetup, :(using SquareDanceReasoning); recursive=true)

makedocs(;
    modules=[SquareDanceReasoning],
    authors="MarkNahabedian <naha@mit.edu> and contributors",
    repo="https://github.com/MarkNahabedian/SquareDanceReasoning.jl/blob/{commit}{path}#{line}",
    sitename="SquareDanceReasoning.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://MarkNahabedian.github.io/SquareDanceReasoning.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Coordinate System" => "coordinate_system.md"
    ],
)

deploydocs(;
    repo="github.com/MarkNahabedian/SquareDanceReasoning.jl",
    devbranch="main",
)
