
using SquareDanceReasoning
using InteractiveUtils
using Rete: Rule, emits

const INDENT = "  "

function generate_formation_hierarchy()
    open(joinpath(@__DIR__, "src", "formation_hierarchy.md"),
         "w") do io
             println(io, "# Hierarchy of Supported Square Dance Formations")
             println(io,
                     "\nThese are the formations that are currently supported, and the roles supported for those formations:\n")
             function walk(f, level)
                 if isconcretetype(f)
                     roles = FORMATION_ROLES[f]
                     roletext = if isempty(roles)
                         ""
                     else
                         ": " * join(map(roles) do role
                                         "`$role`"
                                     end, ", ")
                     end
                     ref = if isconcretetype(f)
                         "formation_drawings/$f.md"
                     else
                         "(@ref)"
                     end
                     println(io, repeat(INDENT, level),
                             " - [`$f`]($ref)",
                             roletext)
                 else
                     println(io, repeat(INDENT, level),
                             " - $f")
                 end
                 for st in sort(subtypes(f); by=string)
                     walk(st, level + 1)
                 end
             end
             walk(SquareDanceFormation, 1)
         end
end

function generate_rule_hierarchy()
    noref = [ Rule ]
    open(joinpath(@__DIR__, "src", "rule_hierarchy.md"),
         "w") do io
             println(io, "# Hierarchy of Knowledge Base Rules")
             println(io,
                     "\nThese are the knowledge base rules we use:\n")
             function walk(t, level)
                 println(io, repeat(INDENT, level),
                         if t in noref
                             " - **$t**"
                         else
                             " - **[`$t`](@ref)**"
                         end, ": ",
                         join(map(emits(t)) do e
                                      "[`$e`](@ref)"
                                  end, ", "))
                 for st in sort(subtypes(t); by=string)
                     walk(st, level + 1)
                 end
             end
             walk(Rule, 1)
         end
end


function calls_and_formations_dict()
    result = Dict{Type, Vector{Type}}()
    for m in methods(can_do_from)
        if m.nargs != 3
            continue
        end
        (_, call, formation) = m.sig.parameters
        if !isconcretetype(call)
            continue
        end
        if !(call <: SquareDanceCall)
            continue
        end
        if !(formation <: SquareDanceFormation)
            continue
        end
        if !haskey(result, call)
            result[call] = Type[]
        end
        push!(result[call], formation)
    end
    result
end

