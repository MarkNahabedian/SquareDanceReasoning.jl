# Dancers

export Gender, Guy, Gal, Unspecified, opposite
export Dancer, OriginalPartners
export is_original_head, is_original_side
export OriginalPartnerRule, OriginalPartners, couple_number
export SDSQuare, SquareHasDancers, make_square


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


struct OriginalPartners
    guy::Dancer
    gal::Dancer

    function OriginalPartners(guy::Dancer, gal::Dancer)
        @assert guy.gender isa Guy
        @assert gal.gender isa Gal
        new(guy, gal)
    end
end

couple_number(op::OriginalPartners) = op.guy.couple_number


@rule SquareDanceRule.OriginalPartnerRule(guy::Dancer, gal::Dancer,
                                          ::OriginalPartners) begin
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

@doc """
OriginalPartnerRule is a rule that identifies the original
partners of a square dance set.
""" OriginalPartnerRule


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
    SDSquare(dancers)

SDSquare is a fact that can be asserted to the knowledge base to
inform it that the dancers form a square.
"""
struct SDSquare
    dancers::Set{Dancer}

    SDSquare(dancers) = new(Set{Dancer}(dancers))
end


"""
    other_dancers(square::SDSquare, dancers)

Returns the dancers from `square` that are not listed in the `dancers`
argument.
"""
other_dancers(square::SDSquare, dancers) =
    setdiff(square.dancers, dancers)


@rule SquareDanceRule.SquareHasDancers(square::SDSquare, ::Dancer) begin
    for dancer in square.dancers
        emit(dancer)
    end
end

@doc """
SquareHasDancers is a convenience rule for asserting the
`Dancer`s from a `SDSquare`.
""" SquareHasDancers



"""
    make_square(number_of_couples::Int)::SDSquare

Returns an SDSquare with the specified number of couples.
"""
function make_square(number_of_couples::Int)::SDSquare
    dancers = Vector{Dancer}()
    for couple_number in 1:number_of_couples
        for gender in [Guy(), Gal()]
            push!(dancers, Dancer(couple_number, gender))
        end
    end
    SDSquare(dancers)
end
