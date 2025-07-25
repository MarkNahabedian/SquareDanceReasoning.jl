# Dancer roles.

export Role, UniversalRole, FormationContextRole,
    Everyone, Noone, Guys, Gals,
    OriginalHeads, OriginalSides,
    CurrentHeads, CurrentSides,
    Beaus, Belles, Centers, Ends, VeryCenters, AllButVeryCenters,
    Leaders, Trailers,
    DiamondCenters, Points,
    ObverseRole, CoupleNumbers, DesignatedDancers

export obverse, those_with_role, supported_roles, dancer_state_roles


"""
    Role

is the abstract supertype for all square dance role types.
"""
abstract type Role end


"""
    UniversalRole

is the abstract type for those roles which might apply regardless of
what formation the daners are in.
"""
abstract type UniversalRole <: Role end


"""
FormationContextRole

is the abstract supertype for square dance roles which are defined by
a dancer's context in a particular formation.
"""
abstract type FormationContextRole <: Role end


struct Everyone <: UniversalRole end
struct Noone <: UniversalRole end
struct Guys <: UniversalRole end
struct Gals <: UniversalRole end    
struct OriginalHeads <: UniversalRole end
struct OriginalSides <: UniversalRole end
struct CurrentHeads <: UniversalRole end
struct CurrentSides <: UniversalRole end
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

function those_with_role(formation::SquareDanceFormation, kb::SDRKnowledgeBase, role::Role)
    those = those_with_role(formation, role)
    more_containers = []
    function check_containers_for(f::SquareDanceFormation)
        fcis = get(kb.formations_contained_in.contained_to_container, f, [])
        for fci in fcis
            got = those_with_role(fci.container, kb, role)
            if isempty(got)
                push!(more_containers, fci.container)
            else
                those = union(those, got)
                break
            end
        end
    end
    push!(more_containers, formation)
    while isempty(those) && !isempty(more_containers)
        check_containers_for(popfirst!(more_containers))
    end
    those
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


struct CoupleNumbers <: UniversalRole
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
    """couple numbers $(join(r.numbers, ", "))"""

struct DesignatedDancers <: UniversalRole
    dancers::Vector{Dancer}

    DesignatedDancers(dancers::Vector{Dancer}) = new(sort(dancers))
    DesignatedDancers(dss::Vector{DancerState}) =
        DesignatedDancers(map(ds -> ds.dancer, dss))
end

those_with_role(f::SquareDanceFormation, r::DesignatedDancers) =
    filter(dancer_states(f)) do ds
        ds.dancer in r.dancers
    end

as_text(d::Dancer) = "$(as_text(d.gender))#$(d.couple_number)"

as_text(::Guy) = "guy"
as_text(::Gal) = "gal"
as_text(::Unspecified) = "unspecified"

as_text(r::DesignatedDancers) =
    """dancers $(join(map(as_text, r.dancers), ", "))"""


as_text(::Everyone) = "everyone"
as_text(::Noone) = "noone"
as_text(::Guys) = "guys"
as_text(::Gals) = "gals"
as_text(::OriginalHeads) = "original heads"
as_text(::OriginalSides) = "original sides"
as_text(::CurrentHeads) = "current heads"
as_text(::CurrentSides) = "current sides"
as_text(::Beaus) = "beaus"
as_text(::Belles) = "belles"
as_text(::Centers) = "centers"
as_text(::Ends) = "ends"
as_text(::Leaders) = "leaders"
as_text(::Trailers) = "trailers"
as_text(::DiamondCenters) = "centers of your diamonds"
as_text(::Points) = "points"


those_with_role(f::OneByFourFormation, ::Centers) = dancer_states(f.centers)
those_with_role(f::OneByFourFormation, ::Ends) =
    setdiff(dancer_states(f), f.centers())


dancer_state_roles(formation::Nothing) =
    DefaultDict{DancerState, Set{Role}}(Set{Role})

"""
    dancer_state_roles(formation::SquareDanceFormatio)::AbstractDict{DancerState, Set{Role}}

Returns a dictionary mapping [`DancerState`](@ref) to a list of
[`Role`](@ref)s that the `DancerState` holds in the specified
`formation`.
"""
function dancer_state_roles(formation::SquareDanceFormation;
                            exclude_ds_roles=false)::AbstractDict{DancerState, Set{Role}}
    ignore_these = [
        # Roles that require parameters:
        ObverseRole, DesignatedDancers,
        # Roles that aren't interesting:
        Everyone,
    ]
    result = DefaultDict{DancerState, Set{Role}}(Set{Role})
    function walk_roles(role_type)
        if role_type in ignore_these
            return
        end
        if isconcretetype(role_type)
            role = role_type()
            for ds in those_with_role(formation, role)
                push!(result[ds], role)
            end
        else
            for sr in subtypes(role_type)
                walk_roles(sr)
            end
        end
    end
    walk_roles(Role)
    result
end
