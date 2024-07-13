module SquareDanceReasoning

using InteractiveUtils
using Parameters
using Logging
using LinearAlgebra: dot, normalize, normalize!
using Rete

export SquareDanceRule, TemporalFact, SquareDanceFormation, make_kb


REPO_ROOT = abspath(joinpath(@__DIR__, ".."))


"""
SquareDanceRule is the abstract supertype for all rules defined
in this package.
"""
abstract type SquareDanceRule <: Rule end


"""
    TemporalFact

Abstract supertype for any facts that have a temporal dependence.
"""
abstract type TemporalFact end


"""
SquareDanceFormation is the abstract supertype of all square dance
formations.
"""
abstract type SquareDanceFormation <: TemporalFact end


include("coordinate_system.jl")
include("dancers.jl")
include("SDSquare.jl")
include("timeline.jl")
include("relative_direction.jl")
include("geometry.jl")
include("formations/formations.jl")
include("grid_arrangement.jl")
include("actions/actions.jl")
include("calls/calls.jl")
include("xml/load.jl")

include("debug.jl")


"""
    make_kb()

Creates SquareDanceReasoning knowledge base with no facts, but with
all rules installed.
"""
function make_kb()
    kb = ReteRootNode("SquareDanceReasoning 1")
    install(kb, SquareDanceRule)
    # Make the knowledge base self-aware:
    ensure_memory_node(kb, typeof(kb))
    receive(kb, kb)
    kb
end


"""
    make_kb(kb::ReteRootNode)

Makes a copy of the knowledge base, but without any of the temporal
facts.
"""
function make_kb(kb::ReteRootNode)
    i = parse(Int, split(kb.label, " ")[2])
    kb2 = ReteRootNode("SquareDanceReasoning $(i+1)")
    install(kb2, SquareDanceRule)
    ensure_memory_node(kb2, typeof(kb2))
    receive(kb2, kb2)
    # Copy the non-temporal facts:
    copy_facts.([kb], [kb2],
                [ SDSquare, Dancer, OriginalPartners ])
    kb2
end

end  # module
