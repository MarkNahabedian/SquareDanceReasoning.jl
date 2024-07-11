# Dancers

export Gender, Guy, Gal, Unspecified, opposite
export Dancer, couple_number
export is_original_head, is_original_side


"""
Gender represents the gender of a dancer, which might be Guy, Gal or
Unspecified.

`Unspecified` exists for when we want to emphasize gender agnosticism
in a diagram.

Gender equality: `Guy() == Guy()`, `Gal() == Gal()`, otherwise not
equal.

Use [`opposite`](@ref) to get the opposite gender.
"""
abstract type Gender end
struct Guy <: Gender end
struct Gal <: Gender end
struct Unspecified <: Gender end

Base.:(==)(::Gender, ::Gender) = false
Base.:(==)(::Guy, ::Guy) = true
Base.:(==)(::Gal, ::Gal) = true


"""
    opposite(::Gender)::Gender

Returns the opposite Gender.  `Unspecified()` is its own opposite.
"""
opposite(::Guy) = Gal()
opposite(::Gal) = Guy()
opposite(::Unspecified) = Unspecified()

GENDER_FROM_STRING = Dict{String, Gender}(
"Guy" => Guy(),
"Gal" => Gal(),
"Unspecified" => Unspecified()
)


"""
    Dancer(couple_number::Int, ::Gender)

Dancer represents a dancer.
"""
struct Dancer
    couple_number::Int
    gender::Gender
end


"""
    Base.isless(::Dancer, ::Dancer)::Bool

Provides a total ordering for dancers.
"""
function Base.isless(d1::Dancer, d2::Dancer)::Bool
    if d1.couple_number == d2.couple_number
        isless(d1.gender, d2.gender)
    else
        d1.couple_number < d2.couple_number
    end
end

Base.isless(::Guy, ::Guy) = false
Base.isless(::Gal, ::Gal) = false
Base.isless(::Unspecified, ::Unspecified) = false
Base.isless(::Guy, ::Gal) = true
Base.isless(::Gal, ::Guy) = false
Base.isless(::Unspecified, ::Guy) = true
Base.isless(::Unspecified, ::Gal) = true
Base.isless(::Guy, ::Unspecified) = false
Base.isless(::Gal, ::Unspecified) = false


"""
    is_original_head(::Dancer)::Bool

returns true if the dancer was originally in a head position.
"""
is_original_head(d::Dancer)::Bool = isodd(d.couple_number)


"""
    is_original_side(::Dancer)::Bool

returns true if the dancer was originally in a side position.
"""
is_original_side(d::Dancer)::Bool = iseven(d.couple_number)

