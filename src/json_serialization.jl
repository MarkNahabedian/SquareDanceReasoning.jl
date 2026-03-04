# This text serialization of formations is used to write the
# "example_formations.json" file.

using JSON

export FormationJSONStyle, TopLevelFormationJSONStyle, SubFormationJSONStyle

# This JSON serialization code is used to write
# example_formations.json.  That file is used by the code in
# src/formations/examples.jl.  See save_formation_examples and
# load_formation_examples.


abstract type FormationJSONStyle <: JSON.JSONStyle end
struct TopLevelFormationJSONStyle <: FormationJSONStyle end
struct SubFormationJSONStyle <: FormationJSONStyle end


JSON.lower(style::SubFormationJSONStyle, ds::DancerState) = "$(formation_id_string(ds))"

function JSON.lower(style::TopLevelFormationJSONStyle, ds::DancerState)
    d = OrderedDict()
    d["couple_number"] = ds.dancer.couple_number
    d["gender"] = string(typeof(ds.dancer.gender))
    d["direction"] = ds.direction
    d["down"] = ds.down
    d["left"] = ds.left
    d
end

# We might want JSON.lower(style::TopLevelFormationJSONStyle,
# ds::DancerState) to control order of slot serialization.

function JSON.lower(style::FormationJSONStyle, f::SquareDanceFormation)
    d = OrderedDict()
    d["_TYPE_"] = string(nameof(typeof(f)))
    if style isa TopLevelFormationJSONStyle
        d["DancerStates"] = OrderedDict(map(f()) do ds
                                            formation_id_string(ds) =>
                                                JSON.lower(style, ds)
                                        end)
    end
    for field in fieldnames(typeof(f))
        d[field] = JSON.lower(SubFormationJSONStyle(), getproperty(f, field))
    end
    d
end

