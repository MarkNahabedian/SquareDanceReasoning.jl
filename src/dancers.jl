# Dancers

"""
Gender represents the gender of a dancer, which might be Guy, Gal or
Unspecified.

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


"""
Dancer represents a dancer.
"""
struct Dancer
    gender::Gender
    couple_number::Int
end


"""
    Base.isless(::Dancer, ::Dancer)::Bool

Provides a total ordering for dancers.
"""
function Base.isless(d1::Dancer, d2::Dancer)::Bool
    if d1.couple_number == d2.couple_number
        isless(dancer1.gender, dancer2.gender)
    else
        d1.couple_number < d2.couple_number
    end
end

Base.isless(Guy, Gal) = true
Base.isless(Gal, Guy) = false
Base.isless(Unspecified, Guy) = true
Base.isless(Unspecified, Gal) = true
Base.isless(Guy, Unspecified) = false
Base.isless(Gal, Unspecified) = false


struct OriginalPartners
    guy::Dancer
    gal::Dancer

    function OriginalPartners(guy::Dancer, gal::Dancer)
        @assert guy.gender isa Guy
        @assert gal.gender isa Gal
        new(guy, gal)
    end
end

@rule SquareDanceRule.OriginalPartnerRule(guy::Dancer, gal::Dancer) begin
    if guy.couple_number != gal.couple_number
        return
    end
    if !isa(guy.gender, Guy)
        return
    end
    if !isa(gal.gender, Gal)
        return
    end
    emit(OriginalPartners(guy, gal))
end        


"""
    make_dancers(number_of_couples::Int)

Returns a list of `Dancer`s with one Guy and one Gal for each couple
number.
"""
function make_dancers(number_of_couples::Int)
    dancers = []
    for couple_number in number_of_couples
        for gender in [Guy(), Gal()]
            push!(dancers, Dancer(gender, coupole_number))
        end
    end
    dancers
end


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



