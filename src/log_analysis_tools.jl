using SquareDanceReasoning
using Rete
using Logging
using Test
using Serialization
using DataStructures
using XML

using SquareDanceReasoning: elt

using SquareDanceReasoning: ScheduledCall

#=
A Note about serializing logs:

When including a mutable object in the log, the contents of that
object will be as it was when the log entry is serialized, not when
the log entry was created.  To log the proper information one should
either do a deep copy or extract the immutable data one might need for
inclusion in the log entry.

=#

function analysis1(logfile::String)
    analysis1(deserialize(logfile))
end


function analysis1(log)
    function print_schedule(queue)
        for pair in queue
            println("\t", pair[2], "\t", pair[1])
        end
    end
    for record in log
        if record.message == "do_schedule while loop"
            println("@ ", record.kwargs[:now])
            print_schedule(record.kwargs[:queue])
        elseif record.message == "do_schedule performing"
            println(" perform ", record.kwargs[:now], "\t",
                    record.kwargs[:cdc]scheduled_call..call)
        elseif record.message == "do_schedule expand_cdc"
            cdc = record.kwargs[:cdc]
            println(" expand ", record.kwargs[:now], "\t",
                    cdc.scheduled_call.call, "\t",
                    [ds.dancer for ds in cdc.formation()])
        elseif record.message == "do_schedule expand_parts returned"
            e = record.kwargs[:e]
            if !isa(e, SortedSet{ScheduledCall})
                println(" expansion:")
                for step in e
                    println("\t$step")
                end
            end
        elseif record.message == "do_schedule perform returned"
            println(" perform returned:")
            for ds in sort(dancer_states(record.kwargs[:f]); by = ds -> ds.dancer)
                println("\t$(ds.dancer)\t$(ds.time):\t$(ds.direction)\t$(ds.down)\t$(ds.left)")               
            end
        elseif record.message == "scheduling"
            new_entry = record.kwargs[:new_entry]
            println(" + $new_entry")
        elseif record.message == "updated schedule"
            println(" schedule: ")
            print_schedule(record.kwargs[:queue])
        elseif record.message == "The dancers are ahead of the schedule"
            println(" !!!\tlatest: ", record.kwargs[:latest],
                    "\tsched_now: ",
                    record.kwargs[:sched_now])
        elseif record.level == Logging.Error
            println("Error: $(record.kwargs[:error])")
            println("\tschedule:")
            let
                queue = [ sc for sc in record.kwargs[:sched] ]
                print_schedule(queue)
            end
            println("\tcall history:")
            for (now, cdc) in record.kwargs[:call_history]
                println("\t\t$now\t$cdc")
            end
            println("\tdancer history:")
            let
                newest_dancer_states = record.kwargs[:newest_dancer_states]
                for dancer in sort(collect(keys(newest_dancer_states)))
                    println("\t\t$dancer")
                    history(newest_dancer_states[dancer]) do ds
                        println("\t\t\t$(ds.time):\t$(ds.direction)\t$(ds.down)\t$(ds.left)")
                    end
                end
            end
        end
    end
end

function find_rule_failures(log; rule=missing,
                            tests=["@reject", "@rejectinf", "@continueif"])
    filter(log) do le
        (le.level == Logging.Debug) &&
        (le.message in tests) &&
            (rule isa Missing || rule == le.message)
    end
end


################################################################################
# HTML Log Analysis:

global LOG_ANALYSIS_CSS = """
.error {
    margin-top: 40px;
    border-style: solid;
    border-width: 10px;
    border-color: orange;
}

table {
    border: solid;
    border-collapse: collapse;
}
caption {
    caption-side: top;
}
th {
    border: solid;
    boorder-collapse: collapse;
}
td {
    border: solid;
    boorder-collapse: collapse;
    margin: 0;
    align: left;
    padding-left: 1em;
    padding-right: 1em;
    vertical-aligh: top;
}
td.time {
    align: right;
}
p.time {
    font-weight: bold;
    border-style: solid;
    border-width: 6px;
    border-color: green;
}
"""


struct HTMLLogAnalysisReport end

function objrepr(::HTMLLogAnalysisReport, obj)
    repr("text/plain", obj;
         context = (:module => SquareDanceReasoning))
end

function html_for_call_schedule(report::HTMLLogAnalysisReport, queue)
    elt("table",
        "class" => "schedule",
        elt("caption","Schedule"),
        [
            elt("tr",
                elt("td", objrepr(report, sc.when)),
                elt("td", objrepr(report, sc.call)))
            for sc in queue
                ]...)
end

function html_for_call_history(report::HTMLLogAnalysisReport,
                               rec::LogRecord)
    elt("table",
        "class" => "call-history",
        elt("caption", "Call History"),
        [
            elt("tr",
                elt("td",
                    "class" => "time",
                    objrepr(report, now)),
                elt("td",
                    objrepr(report, cdc)))
            for (now, cdc) in rec.kwargs[:call_history]
                ]...)
end

function html_for_dancer_history(report::HTMLLogAnalysisReport,
                                 rec::LogRecord)
    newest_dancer_states = rec.kwargs[:newest_dancer_states]
    elt("table",
        elt("caption", "Dancer History"),
        elt("tr",
            elt("th", "dancer"),
            elt("th", "time"),
            elt("th", "direction"),
            elt("th", "down"),
            elt("th", "left")),
        let
            rows = []
            for dancer in sort(collect(keys(newest_dancer_states)))
                hist = history(newest_dancer_states[dancer])
                for i in 1:length(hist)
                    push!(rows, elt("tr",
                                    # dancer:
                                    if i == 1
                                        [ elt("td",
                                              "rowspan" =>"$(length(hist))",
                                              objrepr(report, dancer)) ]
                                    else
                                        []
                                    end...,
                                    # time:
                                    elt("td", objrepr(report, hist[i].time)),
                                    # direction:
                                    elt("td", objrepr(report, hist[i].direction)),
                                    # down:
                                    elt("td", objrepr(report, hist[i].down)),
                                    # left:
                                    elt("td", objrepr(report, hist[i].left))))
                end
            end
            rows
        end...)
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              remaining_log_records::Vector{LogRecord})::Vector{Node}
    children = Node[]
    while !isempty(remaining_log_records)
        rec = popfirst!(remaining_log_records)
        push!(children,
              html_for_log_records(report,
                                   rec,
                                   remaining_log_records)...)
    end
    Node[
        elt("div",
            "class" => "top",
            children...)
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              rec::LogRecord,
                              remaining_log_records)::Vector{Node}
    html_for_log_records(report,
                         Val(Symbol(rec.message)),
                         rec,
                         remaining_log_records)
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Any,
                              log_record::LogRecord,
                              remaining_log_records)::Vector{Node}
    Node[]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{:Exception},
                              rec::LogRecord,
                              remaining_log_records)::Vector{Node}
    @assert rec.level == Logging.Error
    Node[
        elt("div",
            elt("p",
                "class" => "error",
                ("ERROR: " * objrepr(report, rec.kwargs[:error]))),
            elt("div",
                html_for_call_schedule(report,
                                       [ sc for sc in rec.kwargs[:sched] ])),
            elt("div",
                html_for_call_history(report, rec)),
            elt("div",
                html_for_dancer_history(report, rec)))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule while loop")},
                              record::LogRecord,
                              remaining_log_records)::Vector{Node}
    @assert record.message == "do_schedule while loop"
    children = Node[]
    push!(children, elt("p", "class" => "time",
                        "time: " * objrepr(report, record.kwargs[:now])))
    while (!isempty(remaining_log_records) &&
           remaining_log_records[1].message != "do_schedule while loop")
        push!(children,
              html_for_log_records(report, remaining_log_records)...)
    end
    Node[
        elt("div",
            "class" => "at-time",
            children...)
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule performing")},
                              record::LogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("div",
            "class" => "perform",
            "PERFORM " * objrepr(report, record.kwargs[:cdc].scheduled_call.call))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule expand_cdc")},
                              record::LogRecord,
                              remaining_log_records)::Vector{Node}
    cdc = record.kwargs[:cdc]
    Node[
        elt("div", "class" => "expand",
            ("EXPAND " * objrepr(report, cdc.scheduled_call.call)
             * "\n" *
                 objrepr(report, [ds.dancer for ds in cdc.formation()])))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule expand_parts returned")},
                              log_record::LogRecord,
                              remaining_log_records)::Vector{Node}
    e = log_record.kwargs[:e]
    if isa(e, ScheduledCall)
        # No expansion:
        Node[]
    else
        # The call was expanded by expand_parts:
        @assert e isa Vector{ScheduledCall}
        Node[
            elt("table",
                "class" => "call-expansion",
                elt("caption", "Call Expansion"),
                [
                    elt("tr",
                        elt("td", objrepr(report, step)))
                    for step in e
                        ]...)
        ]
    end
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule perform returned")},
                              log_record::LogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("table",
            "class" => "perform-returned",
            elt("caption", "Perform Returned"),
            elt("tr",
                elt("th", "dancer"),
                elt("th", "time"),
                elt("th", "direction"),
                elt("th", "down"),
                elt("th", "left")),
            [
                elt("tr",
                    elt("td", objrepr(report, ds.dancer)),
                    elt("td", objrepr(report, ds.time)),
                    elt("td", objrepr(report, ds.direction)),
                    elt("td", objrepr(report, ds.down)),
                    elt("td", objrepr(report, ds.left)))
                for ds in sort(dancer_states(log_record.kwargs[:f]); by = ds -> ds.dancer)
                    ]...)
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("scheduling")},
                              log_record::LogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("div", "scheduling $(log_record.kwargs[:new_entry])")
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("updated schedule")},
                              log_record::LogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("div",
            html_for_call_schedule(report, log_record.kwargs[:queue]))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("The dancers are ahead of the schedule")},
                              log_record::LogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("div",
            elt("div", "Dancers Ahead Of Schedule"),
            elt("div",
                "latest: " *
                    objrepr(report, log_record.kwargs[:latest])),
            elt("div",
                "sched_now: " *
                    objrepr(report, log_record.kwargs[:sched_now])))
    ]
end

function analysis1_html(log)
    elt("html",
        elt("head",
            elt("style", LOG_ANALYSIS_CSS)),
        elt("body",
            html_for_log_records(HTMLLogAnalysisReport(), log)...))
end

function report1(logfile::String)
    output_file = splitext(logfile)[1] * ".html"
    report1(deserialize(logfile), output_file)
end

function report1(log, output_file)
    doc = analysis1_html(log)
    open(output_file, "w") do io
        XML.write(output_file, doc)
    end
end

