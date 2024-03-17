
using SquareDanceReasoning
using InteractiveUtils

const INDENT = "    "

function generate_formation_hierarchy()
    open(joinpath(@__DIR__, "src", "formation_hierarchy.md"),
         "w") do io
             println(io, "# Hierarchy of Supported Square Dance Formations")
             println(io,
                     "\nThese are the formations that are currently supported:\n")
             function walk(f, level)
                 println(io, repeat(INDENT, level),
                         "[`$f`](@ref)")
                 for st in sort(subtypes(f); by=string)
                     walk(st, level + 1)
                 end
             end
             walk(SquareDanceFormation, 1)
         end
end

function generate_rule_hierarchy()
    open(joinpath(@__DIR__, "src", "rule_hierarchy.md"),
         "w") do io
             println(io, "# Hierarchy of Knowledge Base Rules")
             println(io,
                     "\nThese are the knowledge base rules we use:\n")
             function walk(t, level)
                 println(io, repeat(INDENT, level),
                         "[`$t`](@ref)")
                 for st in sort(subtypes(t); by=string)
                     walk(st, level + 1)
                 end
             end
             walk(SquareDanceRule, 1)
         end
end

