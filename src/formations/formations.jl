
export SquareDanceFormation, dancers

abstract type SquareDanceFormation end

"""
    dancers(formation)

Returns a list of the dancers in the formation, in no particular
order.
"""
function dancers end


include("two-dancers.jl")

