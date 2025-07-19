export CallTextEntry, CALL_TEXT_EXAMPLES, note_call_text,
    write_call_text_examples, CALL_TEXT_EXAMPLES_FILE

struct CallTextEntry
    call::SquareDanceCall
    text::AbstractString
end

CALL_TEXT_EXAMPLES = Dict{Type, Vector{CallTextEntry}}()


"""
    note_call_text(call::SquareDanceCall)

Record the call and its [`as_text`](@ref) to a database.
Returns the call.
"""
function note_call_text(call::SquareDanceCall)
    t = typeof(call)
    if !haskey(CALL_TEXT_EXAMPLES, t)
        CALL_TEXT_EXAMPLES[t] = CallTextEntry[]
    end
    if !in(call, CALL_TEXT_EXAMPLES[t])
        push!(CALL_TEXT_EXAMPLES[t], CallTextEntry(call, as_text(call)))
    end
    call
end


function check_for_as_text_methods()
    # Does evert SquareDanceCall have an as_text method?
    as_text_methods = map(methods(as_text)) do method
        method.sig.parameters[2]
    end
    calls = []
    function walk(call::Type{<:SquareDanceCall})
        if isconcretetype(call)
            push!(calls, call)
        else
            for c in subtypes(call)
                walk(c)
            end
        end
    end
    walk(SquareDanceCall)
    missing_methods = setdiff(calls, as_text_methods)
    if !isempty(missing_methods)
        @warn("These calls do not have as_text methods: " *
            join(missing_methods, ", "))
    end
end

const CALL_TEXT_EXAMPLES_FILE =
    joinpath(dirname(dirname(pathof(SquareDanceReasoning))),
             "test", "test_calls",
             "CALL_TEXT_EXAMPLES.serialized")

function write_call_text_examples()
    let
        open(CALL_TEXT_EXAMPLES_FILE, "w") do io
            serialize(io, CALL_TEXT_EXAMPLES)
        end
    end
end

