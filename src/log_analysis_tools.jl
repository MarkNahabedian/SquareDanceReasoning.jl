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
    analysis1(deserialize_log_file(logfile))
end


function analysis1(log)
    function print_schedule(queue)
        for scheduled_call in queue
            @assert scheduled_call isa ScheduledCall
            println("\t", scheduled_call.when, "\t", scheduled_call.call)
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
                            tests=["@reject", "@rejectif", "@continueif"])
    filter(log) do le
        (le.level == Logging.Debug) &&
        (le.message in tests) &&
            (rule isa Missing || rule == le.group)
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

div {
    margin-top: 2ex;
    margin-bottom: 2ex;
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
    border-color: yellow;
}
div.now_do_this {
    border-style: solid;
    border-width: 4px;
    border-color: yellow;
}
"""


struct HTMLLogAnalysisReport end

function objrepr(::HTMLLogAnalysisReport, obj)
    repr("text/plain", obj;
         context = (:module => SquareDanceReasoning))
end

function objrepr(::HTMLLogAnalysisReport, obj::AbstractFloat)
    #    @sprintf("%.3d", obj)  This sppems tp round to integer
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
                               rec::DeserializedLogRecord)
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
                                 rec::DeserializedLogRecord)
    newest_dancer_states = rec.kwargs[:newest_dancer_states]
    elt("div",
        elt("table",
            elt("caption", "Dancer History"),
            elt("tr",
                elt("th", "dancer"),
                elt("th", "history position"),
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
                                        # history position
                                        elt("td", history_position(hist[i])),
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
            end...),
        animation_svg(collect(values(newest_dancer_states))))
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              remaining_log_records::Vector)::Vector{Node}
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
                              rec::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    html_for_log_records(report,
                         Val(Symbol(rec.message)),
                         rec,
                         remaining_log_records)
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Any,
                              log_record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    Node[]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{:Exception},
                              rec::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    err = rec.kwargs[:error]
    @assert rec.level == Logging.Error
    Node[
        elt("div",
            elt("p",
                "class" => "error",
                ("ERROR: $err")),
            elt("table",
                [
                    elt("tr",
                        elt("td", string(field)),
                        elt("td", objrepr(report, getfield(err, field))))
                    for field in fieldnames(typeof(err))
                        ]...
                ),
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
                              record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    @assert record.message == "do_schedule while loop"
    children = Node[]
    push!(children, elt("p", "class" => "time",
                        "sched.now: " * objrepr(report, record.kwargs[:now])))
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
                              m::Val{Symbol("do_schedule dequeued")},
                              record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("div",
            "class" => "now_do_this",
            "NOW_DO_THIS " * objrepr(report, record.kwargs[:now_do_this]))
    ]    
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("get_call_options formations")},
                              record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    call = record.kwargs[:call]
    formations = record.kwargs[:formations]
    Node[
        elt("div",
            elt("table",
                elt("caption", "get_call_options formations"),
                [
                    elt("tr",
                        elt("td", objrepr(report, f)))
                    for f in formations
                        ]...
                            ))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule get_call_options returned")},
                              record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    options = record.kwargs[:options]
    Node[
        elt("div",
            elt("table",
                elt("caption", "get_call_options returned"),
                [
                    elt("tr",
                        elt("td", opt.preference),
                        elt("td", objrepr(report, opt.scheduled_call)),
                        elt("td", objrepr(report, opt.formation)))
                    for opt in options
                ]...))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule performing")},
                              record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("div",
            "class" => "perform",
            "PERFORM " * objrepr(report, record.kwargs[:cdc].scheduled_call.call))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule expand_cdc")},
                              record::DeserializedLogRecord,
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
                              log_record::DeserializedLogRecord,
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
                              log_record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("table",
            "class" => "perform-returned",
            elt("caption", "Perform Returned"),
            elt("tr",
                elt("th", "history position"),
                elt("th", "dancer"),
                elt("th", "time"),
                elt("th", "direction"),
                elt("th", "down"),
                elt("th", "left")),
            [
                elt("tr",
                    elt("td", history_position(ds)),
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
                              log_record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("div", "scheduling $(log_record.kwargs[:new_entry])")
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("updated schedule")},
                              log_record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("div",
            html_for_call_schedule(report, log_record.kwargs[:queue]))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule collisions")},
                              log_record::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    collisions = log_record.kwargs[:collisions]
    Node[
        elt("div",
            elt("div", "Collisions"),
            elt("ul",
                map(collisions) do c
                    elt("li", objrepr(report, c))
                end...))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("The dancers are ahead of the schedule")},
                              log_record::DeserializedLogRecord,
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

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule formations")},
                              rec::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}                              
    formations = rec.kwargs[:formations]
    Node[
        elt("div", "do_schedule formations",
            elt("ul",
                map(formations) do f
                    elt("li", objrepr(report, f))
                end...
            ))
    ]
end

function html_for_log_records(report::HTMLLogAnalysisReport,
                              m::Val{Symbol("do_schedule finished")},
                              rec::DeserializedLogRecord,
                              remaining_log_records)::Vector{Node}
    Node[
        elt("div",
            elt("div",
                "class" => "do_schedule_finished",
                "do_schedule finished"),
            elt("div",
                html_for_call_history(report, rec)),
            elt("div",
                html_for_dancer_history(report, rec)))
    ]
end


function analysis1_html(logfile::String)
    output_file = splitext(logfile)[1] * ".html"
    open(output_file, "w") do io
        XML.write(io, analysis1_html(deserialize_log_file(logfile)))
    end
end

function analysis1_html(log::Vector{DeserializedLogRecord})
    elt("html",
        elt("head",
            elt("style", LOG_ANALYSIS_CSS)),
        elt("body",
            html_for_log_records(HTMLLogAnalysisReport(), log)...))
end

function report1(logfile::String)
    output_file = splitext(logfile)[1] * ".html"
    report1(deserialize_log_file(logfile), output_file)
end

function report1(log, output_file)
    doc = analysis1_html(log)
    open(output_file, "w") do io
        XML.write(output_file, doc)
    end
end

