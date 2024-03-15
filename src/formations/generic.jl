
export SquareDanceFormation, dancers, handedness
export TwoDancerFormation, FourDancerFormation, EightDancerFormation
export SquareDanceFormationRule
export handedness, Handedness, NoHandedness, RightHanded, LeftHanded


"""
    SquareDanceFormationRule

the group for all rules relating to square dance formations.
"""
abstract type SquareDanceFormationRule end

abstract type SquareDanceFormation end
abstract type TwoDancerFormation <: SquareDanceFormation end
abstract type FourDancerFormation <: SquareDanceFormation end
abstract type EightDancerFormation <: SquareDanceFormation end


"""
    dancers(formation)

Returns a list of the dancers in the formation, in no particular
order.
"""
function dancers end


"""
    Handedness

square dance formations have a handedness, one of RightHanded(),
LeftHanded() or NoHandedness().

`opposite` of a handedness returns the other handedness.
NoHandednessis its own opposite.
"""
abstract type Handedness end
struct RightHanded <: Handedness end
struct LeftHanded <: Handedness end
struct NoHandedness <: Handedness end

opposite(::RightHanded) = LeftHanded()
opposite(::LeftHanded) = RightHanded()
opposite(::NoHandedness) = NoHandedness()


"""
    handedness(formation)

returns the handedness of a square dance formation: one of
RightHanded(), LeftHanded() or NoHandedness()
"""
function handedness end

