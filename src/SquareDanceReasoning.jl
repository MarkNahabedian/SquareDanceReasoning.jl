module SquareDanceReasoning

using InteractiveUtils
using DataStructures
using Parameters
using Printf
using IterTools
using Logging
using LoggingExtras
using OrderedCollections
using ResumableFunctions
using LinearAlgebra: dot, normalize, normalize!
using Base.Iterators: flatten
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

Each concrete subtype can be callled to get an iterator over all of
the [`DancerState`](@ref)s of the formation.
"""
abstract type SquareDanceFormation <: TemporalFact end


include("utils.jl")
include("coordinate_system.jl")
include("handedness.jl")
include("dancers.jl")
include("SDSquare.jl")
include("knowledgebase.jl")
include("timeline.jl")
include("relative_direction.jl")
include("geometry.jl")
include("formations/formations.jl")
include("grid_arrangement.jl")
include("polar_arrangement.jl")
include("circulate.jl")
include("actions/actions.jl")
include("calls/calls.jl")
include("xml/load.jl")
include("showcase.jl")

include("json_serialization.jl")
include("debug.jl")

end  # module
