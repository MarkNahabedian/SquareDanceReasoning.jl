
export Handedness, NoHandedness, RightHanded, LeftHanded


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
