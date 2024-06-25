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
    dancers::Set{Dancer}

    SDSquare(dancers) = new(Set{Dancer}(dancers))
end


Base.in(dancer::Dancer, sq::SDSquare) = in(dancer, sq.dancers)

dancers(s::SDSquare) = sort(collect(s.dancers))


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

