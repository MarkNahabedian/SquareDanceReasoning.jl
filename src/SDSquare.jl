export SDSQuare, SquareHasDancers, make_square


"""
    SDSquare(dancers)

SDSquare represents the dancers in a square.

`make_square(number_of_dancers)` will return an `SDSquare`.

SDSquare is a fact that can be asserted to the knowledge base to
inform it that the dancers form a square.

`other_dancers(::SDSquare, dancers)` returns the set of `Dancer`s
that are in the SDSquare but are not in `dancers`.
"""
struct SDSquare
    dancers

    SDSquare(dancers) = new(sort(dancers))
end


# SDSquare is indexable:
Base.getindex(s::SDSquare, i) = getindex(s.dancers, i)
Base.firstindex(s::SDSquare) = firstindex(s.dancers)
Base.lastindex(s::SDSquare) = lastindex(s.dancers)

# SDSquare is iterable:
Base.iterate(s::SDSquare) = iterate(s.dancers)
Base.IteratorSize(::Type{SDSquare}) = Base.HasLength()
Base.IteratorEltype(::Type{SDSquare}) = Base.HasEltype()
Base.eltype(::Type{SDSquare}) = Dancer
Base.length(s::SDSquare) = length(s.dancers)

Base.in(dancer::Dancer, sq::SDSquare) = in(dancer, sq.dancers)

# dancers(s::SDSquare) = sort(collect(s.dancers))


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

