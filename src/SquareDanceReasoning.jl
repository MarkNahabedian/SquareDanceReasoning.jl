module SquareDanceReasoning

using Rete

export SquareDanceRule, make_kb


"""
SquareDanceRule is the abstract supertype for all rules defined
in this package.
"""
abstract type SquareDanceRule <: Rule end

include("coordinate_system.jl")
include("dancers.jl")
include("timeline.jl")
include("relative_direction.jl")
include("geometry.jl")
include("formations/formations.jl")
include("actions/actions.jl")
include("calls/calls.jl")
include("xml/load.jl")

include("debug.jl")


"""
    make_kb()

Creates SquareDanceReasoning knowledge base with no facts, but with
all rules installed..
"""
function make_kb()
    kb = ReteRootNode("SquareDanceReasoning")
    install(kb, SquareDanceRule)
    kb
end

end
