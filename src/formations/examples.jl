# We can collect examples for formations from the unit tests.

# We can then jiggle the positions and directions a bit and run them
# through the formation recognitioon engine to test our sensitivity to
# position noise.

# We can then generate HTML files for the documentation.

using JSON

export COLLECTED_FORMATIONS, collect_formation_examples,
    save_formation_examples, load_formation_examples

COLLECTED_FORMATIONS = Vector{SquareDanceFormation}()

function collect_formation_examples(kb::ReteRootNode)
    askc(kb, SquareDanceFormation) do f
        if (!any(COLLECTED_FORMATIONS) do example
                isa(example, typeof(f))
            end)
            push!(COLLECTED_FORMATIONS, f)
        end
    end
end


struct FormationExamplesSerialization <: JSON.CommonSerialization
end

function JSON.show_json(io::JSON.StructuralContext,
                        s::FormationExamplesSerialization,
                        f::SquareDanceFormation)
    JSON.Writer.begin_object(io)
    JSON.show_pair(io, s, "name", string(typeof(f)))
    JSON.show_pair(io, s, "dancer_states", dancer_states(f))
    JSON.Writer.end_object(io)
end

function JSON.show_json(io::JSON.StructuralContext,
                        s::FormationExamplesSerialization,
                        ds::DancerState) 
    JSON.Writer.begin_object(io)
    JSON.show_pair(io, s, "couple_number", ds.dancer.couple_number)
    JSON.show_pair(io, s, "gender", string(typeof(ds.dancer.gender)))
    JSON.show_pair(io, s, "direction", ds.direction)
    JSON.show_pair(io, s, "down", ds.down)
    JSON.show_pair(io, s, "left", ds.left)
    JSON.Writer.end_object(io)
end


function save_formation_examples()
    open(joinpath(@__DIR__, "example_formations.json"), "w") do io
        JSON.show_json(JSON.Writer.PrettyContext(io, 2),
                       FormationExamplesSerialization(),
                       sort(COLLECTED_FORMATIONS;
                            by=(f -> string(typeof(f)))))
    end
end

function load_formation_examples()
end

