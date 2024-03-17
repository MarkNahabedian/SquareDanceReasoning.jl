
using SquareDanceReasoning
using InteractiveUtils

function generate_formation_hierarchy()
    indent = "    "
    open(joinpath(@__DIR__, "src", "formation_hierarchy.md"),
         "w") do io
             println(io, "# Hierarchy of Supported Square Dance Formations")
             println(io,
                     "\nThese are the formations that are currently supported:\n")
             function walk(f, level)
                 println(io, repeat(indent, level),
                         "[`$f`](@ref)")
                 for st in sort(subtypes(f); by=string)
                     walk(st, level + 1)
                 end
             end
             walk(SquareDanceFormation, 1)
         end
end

