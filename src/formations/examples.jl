# We can collect examples for formations from the unit tests.

# We can then jiggle the positions and directions a bit and run them
# through the formation recognitioon engine to test our sensitivity to
# position noise.

# We can then generate HTML files for the documentation.

using JSON

export COLLECTED_FORMATIONS, collect_formation_examples,
    save_formation_examples, load_formation_examples,
    json_to_formation,
    formation_example_dancer_states,
    generate_example_formation_diagrams,
    get_formation_example


COLLECTED_FORMATIONS = Vector{SquareDanceFormation}()

function collect_formation_examples(kb::SDRKnowledgeBase)
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

struct AbbreviatedDancerStateSerialization <: JSON.CommonSerialization
end

function JSON.show_json(io::JSON.StructuralContext,
                        s::Union{FormationExamplesSerialization,
                                 AbbreviatedDancerStateSerialization},
                        f::SquareDanceFormation)
    JSON.Writer.begin_object(io)
    JSON.show_pair(io, s, "_TYPE_", string(nameof(typeof(f))))
    if !isa(s, AbbreviatedDancerStateSerialization)
        JSON.show_pair(io, s, "DancerStates",
                       Dict(map(dancer_states(f)) do ds
                                formation_id_string(ds) => ds
                            end))
    end
    for field in fieldnames(typeof(f))
        JSON.show_pair(io, AbbreviatedDancerStateSerialization(),
                       field, getproperty(f, field))
    end
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

function JSON.show_json(io::JSON.StructuralContext,
                        s::AbbreviatedDancerStateSerialization,
                        ds::DancerState)
    write(io, "\"$(formation_id_string(ds))\"")
end

FORMATIONS_EXAMPLE_FILE = joinpath(@__DIR__, "example_formations.json")

function save_formation_examples()
    open(FORMATIONS_EXAMPLE_FILE, "w") do io
        JSON.show_json(
            JSON.Writer.PrettyContext(io, 2),
            FormationExamplesSerialization(),
            [ "This file is automatically generated by the function save_formation_examples",
              # Skip DancerState (a single dancer formation) because
              # it's too easy to build by hand and it breaks the JSON
              # file.
              sort(filter(f -> !isa(f, DancerState),
                          COLLECTED_FORMATIONS);
                   by=(f -> string(nameof(typeof(f)))))...
                       ])
    end
end

function json_to_formation(json)
    t = formation_name_to_type(json["_TYPE_"])
    dancer_states = Dict()
    for (k, ds) in json["DancerStates"]
        dancer_states[k] = DancerState(
            Dancer(ds["couple_number"],
                   GENDER_FROM_STRING[ds["gender"]]),
            0,
            ds["direction"],
            ds["down"],
            ds["left"])
    end
    for (k, ds) in json["DancerStates"]
        dancer_states[k] = DancerState(
            Dancer(ds["couple_number"],
                   GENDER_FROM_STRING[ds["gender"]]),
            0,
            ds["direction"],
            ds["down"],
            ds["left"])
    end
    function json_to_formation1(json)
        if json in keys(dancer_states)
            return dancer_states[json]
        end
        t = formation_name_to_type(json["_TYPE_"])
        t(map(fieldnames(t)) do fn
              json_to_formation1(json[string(fn)])
          end...)
    end
    json_to_formation1(json)
end

CACHED_FORMATION_EXAMPLES = Dict{String, SquareDanceFormation}()

function load_formation_examples(; force=false)
    if !force && !isempty(CACHED_FORMATION_EXAMPLES)
        return CACHED_FORMATION_EXAMPLES
    end
    parsed = JSON.parsefile(FORMATIONS_EXAMPLE_FILE)
    for formation in parsed
        if formation isa AbstractString
            continue
        end
        f = json_to_formation(formation)
        CACHED_FORMATION_EXAMPLES[string(nameof(typeof(f)))] = f
    end
    CACHED_FORMATION_EXAMPLES
end

function generate_example_formation_diagrams(dir)
    for formation in values(load_formation_examples())
        dss = dancer_states(formation)
        kb = make_kb()
        receive(kb, SquareDanceReasoning.SDSquare(
            map(ds -> ds.dancer, dss)))
        for ds in dss
            receive(kb, ds)
        end
        name = string(nameof(typeof(formation)))
        write_formation_html_file(name,
                                  joinpath(dir, "$name.html"),
                                  kb)
    end
end

get_formation_example(ft::Type{<:SquareDanceFormation}) =
    get_formation_example(nameof(ft))

get_formation_example(name::Symbol) =
    get_formation_example(string(name))

function get_formation_example(name::String)
    if !haskey(CACHED_FORMATION_EXAMPLES, name)
        load_formation_examples()
    end
    CACHED_FORMATION_EXAMPLES[name]
end

