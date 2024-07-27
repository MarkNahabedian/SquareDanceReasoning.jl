
export dancers, handedness
export TwoDancerFormation, FourDancerFormation, EightDancerFormation
export SquareDanceFormationRule
export dancer_states
export handedness, Handedness, NoHandedness, RightHanded, LeftHanded
export update_from


"""
    SquareDanceFormationRule

the group for all rules relating to square dance formations.
"""
abstract type SquareDanceFormationRule <: SquareDanceRule end


"""
TwoDancerFormation is the abstract supertype of all square dance
formations involving two dancers.
"""
abstract type TwoDancerFormation <: SquareDanceFormation end


"""
FourDancerFormation is the abstract supertype of all square dance
formations involving four dancers.
"""
abstract type FourDancerFormation <: SquareDanceFormation end


"""
EightDancerFormation is the abstract supertype of all square dance
formations involving eight dancers.
"""
abstract type EightDancerFormation <: SquareDanceFormation end


"""
    dancer_states(formation)::Vector{DancerState}

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


"""
    direction(formation)
If all of the dancers of formation are facing in the same direction
then return that direction.  Otherwise get a no such method error.
"""
function direction end


Base.in(ds::DancerState, f::SquareDanceFormation)::Bool =
    in(ds, dancer_states(f))

center(f::SquareDanceFormation) = center(dancer_states(f))


"""
   update_from(formation::SquareDanceFormation, newest::Vector{DancerState})

Return a new formation of the same type as `formation` but with its
component `DancerState`s taken from `newest`, matching by `Dancer`.
"""
function update_from end

function update_from(formation, dss::Vector{DancerState})
    d = Dict{Dancer, DancerState}()
    for ds in dss
        d[ds.dancer] = ds
    end
    update_from(formation, d)
end

update_from(f::DancerState, dict::Dict{Dancer, DancerState}) =
    dict[f.dancer]

update_from(f::SquareDanceFormation, dict::Dict{Dancer, DancerState}) =
    typeof(f)(map(fieldnames(typeof(f))) do fieldname
                  update_from(getfield(f, fieldname), dict)
              end...)

update_from(f::Vector{<:SquareDanceFormation},
            dict::Dict{Dancer, DancerState}) =
                map(f) do elt
                    update_from(elt, dict)
                end

