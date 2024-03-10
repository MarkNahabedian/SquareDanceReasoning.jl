module SquareDanceReasoning

using Rete

abstract type SquareDanceRule <: Rule end

include("coordinate_system.jl")
include("dancers.jl")
include("timeline.jl")

end
