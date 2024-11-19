# Dancer roles.

export Everyone, Noone, Role, Guys, Gals,
    OriginalHeads, OriginalSides,
    CurrentHeads, CurrentSides,
    Beaus, Belles, Centers, Ends, VeryCenters, AllButVeryCenters,
    Leaders, Trailers,
    DiamondCenters, Points,
    ObverseRole, CoupleNumbers, DesignatedDancers

export obverse, those_with_role, supported_roles


"""
    Role

is the abstract supertype for all square dance role types.
"""
abstract type Role end


"""
FormationContextRole

is the abstract supertype for square dance roles which are defined by
a dancer's context in a particular formation.
"""
abstract type FormationContextRole <: Role end


struct Everyone <: Role end
struct Noone <: Role end
struct Guys <: Role end
struct Gals <: Role end    
struct OriginalHeads <: Role end
struct OriginalSides <: Role end
struct CurrentHeads <: Role end
struct CurrentSides <: Role end
struct Beaus <: FormationContextRole end
struct Belles <: FormationContextRole end
struct Centers <: FormationContextRole end
struct VeryCenters <: FormationContextRole end
struct AllButVeryCenters <: FormationContextRole end
struct Ends <: FormationContextRole end
struct Leaders <: FormationContextRole end
struct Trailers <: FormationContextRole end
struct DiamondCenters <: FormationContextRole end
struct Points <: FormationContextRole end

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

obverse(::OriginalHeads) = OriginalSides()
obverse(::OriginalSides) = OriginalHeads()

obverse(::CurrentHeads) = CurrentSides()
obverse(::CurrentSides) = CurrentHeads()

obverse(::Beaus) = Belles()
obverse(::Belles) = Beaus()

obverse(::VeryCenters) = AllButVeryCenters()
obverse(::AllButVeryCenters) = VeryCenters()

obverse(::Centers) = Ends()
obverse(::Ends) = Centers()

obverse(::Leaders) = Trailers()
obverse(::Trailers) = Leaders()

obverse(::DiamondCenters) = Points()
obverse(::Points) = DiamondCenters()
    
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

those_with_role(f::SquareDanceFormation, ::OriginalHeads) =
    filter(ds -> is_original_head(ds.dancer),
           dancer_states(f))

those_with_role(f::SquareDanceFormation, ::OriginalSides) =
    filter(ds -> is_original_side(ds.dancer),
           dancer_states(f))

those_with_role(f::SquareDanceFormation, ::CurrentHeads) =
    filter(dancer_states(f)) do ds
        (ds.direction == 0) || (ds.direction == 1//2)
    end

those_with_role(f::SquareDanceFormation, ::CurrentSides) =
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
as_text(::OriginalHeads) = "OriginalHeads"
as_text(::OriginalSides) = "OriginalSides"
as_text(::CurrentHeads) = "CurrentHeads"
as_text(::CurrentSides) = "CurrentSides"
as_text(::Beaus) = "Beaus"
as_text(::Belles) = "Belles"
as_text(::Centers) = "Centers"
as_text(::Ends) = "Ends"
as_text(::Leaders) = "Leaders"
as_text(::Trailers) = "Trailers"
as_text(::DiamondCenters) = "Centers of your diamonds"
as_text(::Points) = "Points"


those_with_role(f::OneByFourFormation, ::Centers) = dancer_states(f.centers)
those_with_role(f::OneByFourFormation, ::Ends) =
    setdiff(dancer_states(f), f.centers())

