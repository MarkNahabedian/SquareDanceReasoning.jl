module SquareDanceReasoning

using Rete

export SquareDanceRule

abstract type SquareDanceRule <: Rule end

include("coordinate_system.jl")
include("dancers.jl")
include("timeline.jl")
include("relative_direction.jl")
include("geometry.jl")
include("formations/formations.jl")

include("debug.jl")

end
