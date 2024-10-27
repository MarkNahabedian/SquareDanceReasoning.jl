
include("generic.jl")
include("catch_conflicting_dancer_states.jl")
include("attendance.jl")
include("roles.jl")
include("examples.jl")
include("two-dancers.jl")
include("bigger_waves.jl")
include("lines.jl")
include("columns.jl")
include("star_like.jl")
include("two-by-two.jl")
include("squared_set.jl")
include("couples_down_the_line.jl")
include("n_quarter_tag.jl")


FORMATION_NAME_TO_TYPE = Dict()

function formation_name_to_type(name::AbstractString)
    FORMATION_NAME_TO_TYPE[name]
end

# For each subtype of SquareDanceFormation, are any fields of type
# other than SquareDanceFormation?
let
    others = []
    function walk(t::Type)
        if t == DancerState
            return
        end
        if isconcretetype(t)
            FORMATION_NAME_TO_TYPE[string(nameof(t))] = t
            for field in fieldnames(t)
                if !(fieldtype(t, field) <: SquareDanceFormation)
                    push!(others, (t, field))
                end
            end
        end
        if isabstracttype(t)
            for st in subtypes(t)
                walk(st)
            end
        end
    end
    walk(SquareDanceFormation)
    if !isempty(others)
        @warn("Some formations have non-formation fields", others)
    end
end

