# Dancer roles.

export Everyone, Noone, Role, Guys, Gals,
    OriginalHead, OriginalSide,
    CurrentHead, CurrentSide,
    Beau, Belle, Center, End, VeryCenter, AllButVeryCenter,
    Leader, Trailer,
    DiamondCenter, Point,
    ObverseRole, CoupleNumbers, DesignatedDancers

export obverse, those_with_role, supported_roles


"""
Role is the abstract supertype for all square dance role types.
"""
abstract type Role end


"""
FormationContextRole is the abstract supertype for square dance roles
which are defined by a dancer's context in a particular formation.
"""
abstract type FormationContextRole <: Role end


struct Everyone <: Role end
struct Noone <: Role end
struct Guys <: Role end
struct Gals <: Role end    
struct OriginalHead <: Role end
struct OriginalSide <: Role end
struct CurrentHead <: Role end
struct CurrentSide <: Role end
struct Beau <: FormationContextRole end
struct Belle <: FormationContextRole end
struct Center <: FormationContextRole end
struct VeryCenter <: FormationContextRole end
struct AllButVeryCenter <: FormationContextRole end
struct End <: FormationContextRole end
struct Leader <: FormationContextRole end
struct Trailer <: FormationContextRole end
struct DiamondCenter <: FormationContextRole end
struct Point <: FormationContextRole end

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

obverse(::VeryCenter) = AllButVeryCenter()
obverse(::AllButVeryCenter) = VeryCenter()

obverse(::Center) = End()
obverse(::End) = Center()

obverse(::Leader) = Trailer()
obverse(::Trailer) = Leader()

obverse(::DiamondCenter) = Point()
obverse(::Point) = DiamondCenter()
    
"""
    ObverseRole(::role)

For roles like CoupleNumbers or DesignatedDancers we can't determine
the obverse until we know all of the dancers involved.  This serves
as a "place holder" until we can determine which dancers have the role
that is obverse to the specified `Role`.
"""
struct ObverseRole <: Role
    role::Role
end

obverse(r::Role) = ObverseRole(r)
obverse(o::ObverseRole) = o.role

as_text(r::ObverseRole) = as_text(obverse(r.role))


"""
    supported_roles(formation)

Returns a list of the [`Role`](@!ref)s that are supported by `formation`.
"""
function supported_roles(f::Type{<:SquareDanceFormation})
    supported = []
    default_method = which(those_with_role, (SquareDanceFormation, Role))
    if isconcretetype(f)
        function walk(role)
            if isconcretetype(role)
                if which(those_with_role, (f, role)) != default_method
                    push!(supported, role)
                end
            else
                for st in subtypes(role)
                    walk(st)
                end
            end
        end
        walk(FormationContextRole)
    end
    supported
end

those_with_role(f::SquareDanceFormation, o::ObverseRole) =
    typeof(o.role)(setdiff(those_with_role(f, Everyone()),
                           those_with_role(f, o.role)))


"""
    those_with_role(::SquareDanceFormation, ::Role)

For the specified formation, returns `DancerState`s whose dancers fill
the specified role.
"""
those_with_role(::SquareDanceFormation, ::Role) = DancerState[]
those_with_role(f::SquareDanceFormation, ::Everyone) = dancer_states(f)
those_with_role(f::SquareDanceFormation, ::Noone) = DancerState[]

those_with_role(f::SquareDanceFormation, ::Guys) =
    filter(dancer_states(f)) do ds
        ds.dancer.gender isa Guy
    end

those_with_role(f::SquareDanceFormation, ::Gals) =
    filter(dancer_states(f)) do ds
        ds.dancer.gender isa Gal
    end

those_with_role(f::SquareDanceFormation, ::OriginalHead) =
    filter(ds -> is_original_head(ds.dancer),
           dancer_states(f))

those_with_role(f::SquareDanceFormation, ::OriginalSide) =
    filter(ds -> is_original_side(ds.dancer),
           dancer_states(f))

those_with_role(f::SquareDanceFormation, ::CurrentHead) =
    filter(dancer_states(f)) do ds
        (ds.direction == 0) || (ds.direction == 1//2)
    end

those_with_role(f::SquareDanceFormation, ::CurrentSide) =
    filter(dancer_states(f)) do ds
        (ds.direction == 1//4) || (ds.direction == 3//4)
    end


struct CoupleNumbers <: Role
    numbers::Vector{Integer}

    CoupleNumbers(numbers::Integer...) =
        new([numbers...])
    CoupleNumbers(numbers::Vector{<:Integer}) =
        new(numbers)
    CoupleNumbers(dss::Vector{DancerState}) =
        new(unique(map(ds -> ds.dancer.couple_number, dss)))
end

those_with_role(f::SquareDanceFormation, cn::CoupleNumbers) =
    filter(dancer_states(f)) do ds
        ds.dancer.couple_number in cn.numbers
    end

as_text(r::CoupleNumbers) =
    """CoupleNumbers $(join(r.numbers, ", "))"""

struct DesignatedDancers <: Role
    dancers::Vector{Dancer}

    DesignatedDancers(dancers::Vector{Dancer}) = new(sort(dancers))
    DesignatedDancers(dss::Vector{DancerState}) =
        DesignatedDancers(map(ds -> ds.dancer, dss))
end

those_with_role(f::SquareDanceFormation, r::DesignatedDancers) =
    filter(dancer_states(f)) do ds
        ds.dancer in r.dancers
    end

as_text(d::Dancer) = "$(nameof(typeof(d.gender)))#$(d.couple_number)"

as_text(r::DesignatedDancers) =
    """Dancers $(join(map(as_text, r.dancers), ", "))"""


as_text(::Everyone) = "Everyone"
as_text(::Noone) = "Noone"
as_text(::Guys) = "Guys"
as_text(::Gals) = "Gals"
as_text(::OriginalHead) = "OriginalHead"
as_text(::OriginalSide) = "OriginalSides"
as_text(::CurrentHead) = "CurrentHead"
as_text(::CurrentSide) = "CurrentSide"
as_text(::Beau) = "Beaus"
as_text(::Belle) = "Belles"
as_text(::Center) = "Centers"
as_text(::End) = "Ends"
as_text(::Leader) = "Leaders"
as_text(::Trailer) = "Trailers"
as_text(::DiamondCenter) = "Centers of your diamonds"
as_text(::Point) = "Points"

