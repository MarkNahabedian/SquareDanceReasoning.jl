# Dancers

export Gender, Guy, Gal, Unspecified, opposite
export Dancer, couple_number
export is_original_head, is_original_side
export corner_couple_number


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


"""
    Guy()

The *guy* gender, represented by a square in our SVG diagrams.
"""
struct Guy <: Gender end


"""
    Gal()

The *gal* gender, represented by a circle in our SVG diagrams.
"""
struct Gal <: Gender end


"""
    Unspecified

Unspecified gender is provided just for gender neutral diagraming,
where it appears as a square with rounded corners.  It is not
supported widely through this codebase.  For example original partner
and original corner are do not support it.

Note that 

```
Unspecified() != Unspecified()
```

and

```
opposite(Unspecified())
```

returns `Unspecified()`.
"""
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

Base.isless(::Gender, ::Gender) = false
Base.isless(::Guy, ::Gal) = true
Base.isless(::Unspecified, ::Guy) = true
Base.isless(::Unspecified, ::Gal) = true


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


"""
    corner_couple_number(::Dancer)

Returns the couple number of the dancer's corner.  Since this function
has no way of knowing the number of daners in the "square", the value
returned nmight require numeric rapping.
"""
corner_couple_number(d::Dancer) =
    return d.couple_number + (
        d.gender isa Guy ? -1 :
            d.gender isa Gal ? 1 :
            error("Unsupported gender")
    )

