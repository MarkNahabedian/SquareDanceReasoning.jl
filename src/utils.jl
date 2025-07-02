using Base.Iterators: Stateful
using LoggingExtras: FormatLogger
using Serialization

export merge_sorted_iterators
export log_to_file, deserialize_log_file, DeserializedLogRecord


"""
    merge_sorted_iterators(iters)

Merges the contents of the sorted iterables into a single iterator
producing those unique elements in order.
"""
@resumable function merge_sorted_iterators(iters...)
    iters = map(Stateful, iters)
    previous = Missing()
    while true
        iters = filter(iters) do i
            !isempty(i)
        end
        if isempty(iters)
            return
        end
        firsts = something.(peek.(iters))
        _, idx = findmin(firsts)
        v = popfirst!(iters[idx])
        if !((!isa(previous, Missing)) && v == previous)
            previous = v
            @yield v
        end
    end
end


function log_to_file(body, dir, filename;
                     always_write = false,
                     min_level=Info)
    # always_write and min_level are obsolete.
    filepath = joinpath(dir, filename)
    rm(filepath; force=true)
    open(filepath, "w") do io
        logger = FormatLogger(serialize, io)
        with_logger(body, logger)
    end
end

const DeserializedLogRecord =
    @NamedTuple{level::Base.CoreLogging.LogLevel,
                message::String,
                _module::Module,
                group::Any,
                id::Symbol,
                file::String,
                line::Int64,
                kwargs::AbstractDict}

function deserialize_log_file(filepath)::Vector{DeserializedLogRecord}
    log = DeserializedLogRecord[]
    open(filepath, "r") do io
        while(!eof(io))
            push!(log, deserialize(io))
        end
    end
    log
end

