# Dancer roles.

export Role, Guys, Gals, OriginalHead, OriginalSide,
    CurrentHead, CurrentSide,
    Beau, Belle, Center, End,
    Leader, Trailer, Point, CoupleNumbers

export those_with_role

abstract type Role end
struct Everyone <: Role end
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
struct Point <: Role end

# NOTE that sometimes roles are used to restrict which formations are
# participating and sometimes they are used to designate which dancer
# is acting.  Consider "center couples (restrict) belles (designate)
# run", which should not be confised with "center belle run around the
# end" (restrict, restrict, designate).


"""
    those_with_role(::SquareDanceFormation, ::Role)

For the specified formation returns `DancerState`s or subformations
whose dancers fill the specified role.
"""
those_with_role(::SquareDanceFormation, ::Role) = []
those_with_role(f::SquareDanceFormation, ::Everyone) = f

those_with_role(::DancerState, ::Role) = []
those_with_role(f::DancerState, ::Everyone) = f

those_with_role(f::DancerState, ::Guys) =
    if f.dancer.gender isa Guy
        f
    else
        []
    end

those_with_role(f::DancerState, ::Gals) =
    if f.dancer.gender isa Gal
        f
    else
        []
    end

those_with_role(ds::DancerState, ::OriginalHead) =
    is_original_head(ds) ? [ds] : []

those_with_role(ds::DancerState, ::OriginalSide) =
    is_original_side(ds) ? [ds] : []

those_with_role(ds::DancerState, ::CurrentHead) =
    (direction_equal(ds.direction, 0) ||
    direction_equal(ds.direction, 1//2)) ? [ds] : []

those_with_role(ds::DancerState, ::CurrentSide) =
    (direction_equal(ds.direction, 1//4) ||
    direction_equal(ds.direction, 3//4)) ? [ds] : []


struct CoupleNumbers <: Role
    numbers::Vector{Integer}

    CoupleNumbers(numbers...) =
        new(numbers)
end

those_with_role(ds::DancerState, cn::CoupleNumbers) =
    if ds.dancer.couple_number in cn.numbers
        ds
    else
        []
    end

