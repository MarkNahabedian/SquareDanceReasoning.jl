using JSON

export FormationExamplesSerialization

abstract type SDR_JSON_Serialization <: JSON.CommonSerialization end

struct FormationExamplesSerialization <: SDR_JSON_Serialization end

struct AbbreviatedDancerStateSerialization <: SDR_JSON_Serialization end

let
    standard_struct_types = [
        Gender, Handedness, Dancer, Role, SquareDanceCall
    ]
    for t in standard_struct_types
        eval(:(JSON.show_json(io::JSON.StructuralContext,
                              serialization::SDR_JSON_Serialization,
                              object::$t) =
               json_write_struct(io, serialization, object)))
    end
end

function json_write_struct(io::JSON.StructuralContext,
                           s::SDR_JSON_Serialization,
                           object)
    JSON.Writer.begin_object(io)
    JSON.show_pair(io, s, "_TYPE_", string(nameof(typeof(object))))
    for field in fieldnames(typeof(object))
        JSON.show_pair(io, s,
                       field, getproperty(object, field))
    end
    JSON.Writer.end_object(io)
end

function JSON.show_json(io::JSON.StructuralContext,
                        s::SDR_JSON_Serialization,
                        m::Module)
    JSON.Writer.begin_object(io)
    JSON.show_pair(io, s, "_TYPE_", string(nameof(typeof(m))))
    JSON.show_pair(io, s, "name", string(nameof(m)))
    JSON.Writer.end_object(io)    
end

function JSON.show_json(io::JSON.StructuralContext,
                        s::SDR_JSON_Serialization,
                        f::SquareDanceFormation)
    JSON.Writer.begin_object(io)
    JSON.show_pair(io, s, "_TYPE_", string(nameof(typeof(f))))
    # Include a lookup table of DancerState abbreviations if this is
    # the top level formation:
    if !isa(s, AbbreviatedDancerStateSerialization)
        JSON.show_pair(io, s, "DancerStates",
                       OrderedDict(map(f()) do ds
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
