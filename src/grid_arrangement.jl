export grid_arrangement


const ARROW_DIRECTIONS = Dict(
    " " => 0,      # Placeholder for missing dancer
    "←" => 3//4,
    "↑" => 1//2,
    "→" => 1//4,
    "↓" => 0//4)

function arrows_to_directions(arrows::Vector{String})
    allsame(x) = all(y -> y == first(x), x)
    @assert allsame(map(length, arrows)) "All direction strings must be the same ength"
    rows = map(arrows) do arrow_string
        map(split(arrow_string, "")) do arrow
            ARROW_DIRECTIONS[arrow]
        end
    end
    downcount = length(rows)
    leftcount = length(rows[1])
    directions = Array{Rational, 2}(undef, (downcount, leftcount))
    for down in 1:downcount
        for left in 1:leftcount
            directions[down, left] = rows[down][left]
        end
    end
    directions
end

function grid_arrangement(dancers::Vector{Dancer},
                          dancer_indices::Array{<:Integer, 2},
                          dancer_directions::Vector{String})
    grid_arrangement(dancers, dancer_indices,
                     arrows_to_directions(dancer_directions))
end


"""
     grid_arrangement(dancers::Vector{Dancer}, dancer_indices::Array{<:Integer, 2}, dancer_directions::Array{Rational, 2})

Returns a two dimensional array of `DancerState`s such that the
dancers are arranges in a rectangular grid of the specified
dimensions.

`dancers` is a vector of `Dancer`s indexed by `dancer_indices`.  A
dancer index can be 0 to indicate that there is no cancer in that
positriion.

`dancer_indices` and `dancer_directions` are Arrays of the same
dimensions.  This determiines the dimensions of the resulting grid.

Alternatively, dancer_directions can be a Vector of strings of Unicode
arrow characters.

The two indices of each array correspond to the `down` and `left`
coordinates respectively.

"""
function grid_arrangement(dancers::Vector{Dancer},
                          dancer_indices::Array{<:Integer, 2},
                          dancer_directions::Array{Rational, 2}
                          )::Array{Union{Nothing, DancerState}, 2}
    @assert size(dancer_indices) == size(dancer_directions)
    result = Array{Union{Nothing, DancerState}, 2}(nothing,
                                                   size(dancer_directions))
    for down in 1:size(dancer_indices)[1]
        for left in 1:size(dancer_indices)[2]
            if dancer_indices[down, left] != 0
                result[down, left] =
                    DancerState(dancers[dancer_indices[down, left]],
                                0, dancer_directions[down, left],
                                down, left)
            end
        end
    end
    result
end

