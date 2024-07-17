# Dancer roles.

export Everyone, Role, Guys, Gals,
    OriginalHead, OriginalSide,
    CurrentHead, CurrentSide,
    Beau, Belle, Center, End,
    Leader, Trailer,
    Point,
    ObverseRole, CoupleNumbers, DesignatedDancers

export obverse, those_with_role

abstract type Role end
struct Everyone <: Role end
struct Noone <: Role end
struct Guys <: Role end
struct Gals <: Role end    
struct OriginalHead <: Role end
struct OriginalSide <: Role end
struct CurrentHead <: Role end
struct CurrentSide <: Role end
struct Beau <: Role end
struct Belle <: Role end
struct Center <: Role end
struct End <: Role end
struct Leader <: Role end
struct Trailer <: Role end
struct DiamondCenter <: Role end
struct Point <: Role end

# NOTE that sometimes roles are used to restrict which formations are
# participating and sometimes they are used to designate which dancer
# is acting.  Consider "center couples (restrict) belles (designate)
# run", which should not be confised with "center belle run around the
# end" (restrict, restrict, designate).


"""
    obverse(::Role)::Role

Each role has an `obverse` role.  (I didn't want to overload
`opposite`).  At a given time a dancer either has `role` or `role`'s
obverse.
"""
function obverse end

obverse(::Everyone) = Noone()
obverse(::Noone) = Everyone()

obverse(::Guys) = Gals()
obverse(::Gals) = Guys()

obverse(::OriginalHead) = OriginalSide()
obverse(::OriginalSide) = OriginalHead()

obverse(::CurrentHead) = CurrentSide()
obverse(::CurrentSide) = CurrentHead()

obverse(::Beau) = Belle()
obverse(::Belle) = Beau()

obverse(::Center) = End()
obverse(::End) = Center()

obverse(::Leader) = Trailer()
obverse(::Trailer) = Leader()

obverse(::DiamondCenter) = Point()
obverse(::Point) = DiamondCenter()
    
"""
    ObverseRole(::role)

For roles like CoupleNumbers or DesignatedDancers we can't determine
the obverse until we know all of the dancers involved.  TRhis servesd
as a "place holder" until we can determine which dancers have the role
that is obverse to the specified `Role`.
"""
struct ObverseRole <: Role
    role::Role
end

obverse(r::Role) = ObverseRole(r)
obverse(o::ObverseRole) = o.role

those_with_role(f::SquareDanceFormation, o::ObverseRole) =
    typeof(o.role)(setdiff(those_with_role(f, Everyone()),
                           those_with_role(f, o.role)))


"""
    those_with_role(::SquareDanceFormation, ::Role)

For the specified formation returns `DancerState`s or subformations
whose dancers fill the specified role.
"""
those_with_role(::SquareDanceFormation, ::Role) = DancerState[]
those_with_role(f::SquareDanceFormation, ::Everyone) = dancer_states(f)
those_with_role(f::Noone) = DancerState[]

those_with_role(::DancerState, ::Role) = DancerState[]
those_with_role(f::DancerState, ::Everyone) = dancer_states(f)

those_with_role(f::DancerState, ::Guys) =
    if f.dancer.gender isa Guy
        dancer_states(f)
    else
        DancerState[]
    end

those_with_role(f::DancerState, ::Gals) =
    if f.dancer.gender isa Gal
        dancer_states(f)
    else
        DancerState[]
    end

those_with_role(ds::DancerState, ::OriginalHead) =
    is_original_head(ds) ? [ds] : DancerState[]

those_with_role(ds::DancerState, ::OriginalSide) =
    is_original_side(ds) ? [ds] : DancerState[]

those_with_role(ds::DancerState, ::CurrentHead) =
    (direction_equal(ds.direction, 0) ||
    direction_equal(ds.direction, 1//2)) ? [ds] : DancerState[]

those_with_role(ds::DancerState, ::CurrentSide) =
    (direction_equal(ds.direction, 1//4) ||
    direction_equal(ds.direction, 3//4)) ? [ds] : DancerState[]


struct CoupleNumbers <: Role
    numbers::Vector{Integer}

    CoupleNumbers(numbers::Integer...) =
        new([numbers...])
    CoupleNumbers(numbers::Vector{<:Integer}) =
        new(numbers)
    CoupleNumbers(dss::Vector{DancerState}) =
        new(unique(map(ds -> ds.dancer.couple_number, dss)))
end

those_with_role(ds::DancerState, cn::CoupleNumbers) =
    if ds.dancer.couple_number in cn.numbers
        [ds]
    else
        DancerState[]
    end


struct DesignatedDancers <: Role
    dancers::Vector{Dancer}

    DesignatedDancers(dancers::Vector{Dancer}) = new(dancers)
    DesignatedDancers(dss::Vector{DancerState}) =
        new(map(ds -> ds.dancer, dss))
end

those_with_role(ds::DancerState, r::DesignatedDancers) =
    if ds.dancer in r.dancers
        [ds]
    else
        DancerState[]
    end

