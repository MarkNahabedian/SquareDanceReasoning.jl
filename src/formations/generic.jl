
export SquareDanceFormation, dancers, handedness
export TwoDancerFormation, FourDancerFormation, EightDancerFormation
export SquareDanceFormationRule
export dancer_states
export handedness, Handedness, NoHandedness, RightHanded, LeftHanded


"""
    SquareDanceFormationRule

the group for all rules relating to square dance formations.
"""
abstract type SquareDanceFormationRule <: SquareDanceRule end

abstract type SquareDanceFormation end
abstract type TwoDancerFormation <: SquareDanceFormation end
abstract type FourDancerFormation <: SquareDanceFormation end
abstract type EightDancerFormation <: SquareDanceFormation end


"""
    dancer_states(formation)

Returns a list of the `DancerState`s in the formation, in no
particular order.
"""
function dancer_states end


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

