using SquareDanceReasoning
using Rete
using Logging
using Test
using Serialization
using DataStructures
using XML
using LightXML

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

function analysis1_html(log)
    doc = XMLDocument()
    stack = Stack{Any}()
    push!(stack, create_root(doc, "html"))
    function element(body, tag)
        e = new_child(first(stack), tag)
        push!(stack, e)
        body(e)
        pop!(stack)
    end
    function attr(name, value)
        set_attribute(first(stack), name, value)
    end
    s(obj) = repr("text/plain", obj;
                  context = (:module => SquareDanceReasoning))
    function paragraph(text)
        element("p") do p
            add_text(p, text)
        end
    end
    function add_schedule(queue)
        element("table") do tbl
            attr("class", "schedule")
            element("caption") do cap
                add_text(cap, "Schedule")
            end
            for sc in queue
                element("tr") do row
                    element("td") do td
                        add_text(td, s(sc.when))
                    end
                    element("td") do td
                        add_text(td, s(sc.call))
                    end
                end
            end
        end
    end
    element("head") do head
        element("style") do style
            add_text(style, LOG_ANALYSIS_CSS)
        end
    end
    element("body") do body
        for record in log
            if record.message == "do_schedule while loop"
                if attribute(first(stack), "class") == "at-time"
                    pop!(stack)
                end
                push!(stack,
                      element("div") do elt
                          attr("class", "at-time")
                          element("p") do p
                              attr("class", "time")
                              add_text(p, "time: " * s(record.kwargs[:now]))
                          end
                          add_schedule(record.kwargs[:queue])
                          elt
                      end)
            elseif record.message == "do_schedule performing"
                element("div") do elt
                    attr("class", "perform")
                    add_text(elt, "PERFORM " * s(record.kwargs[:cdc].scheduled_call.call))
                end
            elseif record.message == "do_schedule expand_cdc"
                let
                    cdc = record.kwargs[:cdc]
                    element("div") do elt
                        attr("class", "expand")
                        add_text(elt, "EXPAND " * s(cdc.scheduled_call.call) * "\n" *
                                 s([ds.dancer for ds in cdc.formation()]))
                    end
                end
            elseif record.message == "do_schedule expand_parts returned"
                let
                    e = record.kwargs[:e]
                    if !isa(e, SquareDanceCall)
                        element("table") do tbl
                            attr("class", "call-expansion")
                            element("caption") do cap
                                add_text(cap, "Call Expansion")
                            end
                            if e isa SortedSet{ScheduledCall}
                                for step in e
                                    element("tr") do row
                                        element("td") do td
                                            add_text(td, s(step))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            elseif record.message == "do_schedule perform returned"
                element("table") do tbl
                    attr("class", "perform-returned")
                    element("caption") do cap
                        add_text(cap, "Perform Returned")
                    end
                    element("tr") do tr
                        element("th") do th
                            add_text(th, "dancer")
                        end
                        element("th") do th
                            add_text(th, "time")
                        end
                        element("th") do th
                            add_text(th, "direction")
                        end
                        element("th") do th
                            add_text(th, "down")
                        end
                        element("th") do th
                            add_text(th, "left")
                        end
                    end
                    for ds in sort(dancer_states(record.kwargs[:f]); by = ds -> ds.dancer)
                        element("tr") do tr
                            element("td") do td
                                add_text(td, s(ds.dancer))
                            end
                            element("td") do td
                                add_text(td, s(ds.time))
                            end  
                            element("td") do td
                                add_text(td, s(ds.direction))
                            end  
                            element("td") do td
                                add_text(td, s(ds.down))
                            end  
                            element("td") do td
                                add_text(td, s(ds.left))
                            end  
                        end
                    end
                end
            elseif record.message == "scheduling"
                element("div") do div
                    let
                        new_entry = record.kwargs[:new_entry]
                        add_text(div, "scheduling $new_entry")
                    end
                end
            elseif record.message == "updated schedule"
                element("div") do div
                    add_schedule(record.kwargs[:queue])
                end
            elseif record.message == "The dancers are ahead of the schedule"
                element("div") do div
                    element("div") do div
                        add_text(div, "Dancers Ahead Of Schedule")
                    end
                    element("div") do div
                        add_text(div, "latest: " *
                            s(record.kwargs[:latest]))
                    end
                    element("div") do div
                        add_text(div, "sched_now: " *
                            s(record.kwargs[:sched_now]))
                    end
                end
            elseif record.level == Logging.Error
                element("div") do div
                    element("p") do p
                        attr("class", "error")
                        add_text(p, "ERROR: " * s(record.kwargs[:error]))
                    end
                    element("div") do e
                        paragraph("Schedule:")
                        add_schedule([ sc for sc in record.kwargs[:sched] ])
                    end
                    element("div") do e
                        element("table") do tbl
                            element("caption") do cap
                                add_text(cap, "Call History")
                            end
                            attr("class", "call-history")
                            for (now, cdc) in record.kwargs[:call_history]
                                element("tr") do row
                                    element("td") do td
                                        attr("class", "time")
                                        add_text(td, s(now))
                                    end
                                    element("td") do td
                                        add_text(td, s(cdc))
                                    end
                                end
                            end
                        end
                    end
                    let
                        newest_dancer_states = record.kwargs[:newest_dancer_states]
                        element("table") do tbl
                            element("caption") do cap
                                add_text(cap, "Dancer History")
                            end
                            element("tr") do tr
                                element("th") do th
                                    add_text(th, "dancer")
                                end
                                element("th") do th
                                    add_text(th, "time")
                                end
                                element("th") do th
                                    add_text(th, "direction")
                                end
                                element("th") do th
                                    add_text(th, "down")
                                end
                                element("th") do th
                                    add_text(th, "left")
                                end
                            end
                            for dancer in sort(collect(keys(newest_dancer_states)))
                                hist = history(newest_dancer_states[dancer])
                                for i in 1:length(hist)
                                    element("tr") do row
                                        # dancer:
                                        if i == 1
                                            element("td") do td
                                                attr("rowspan", "$(length(hist))")
                                                add_text(td, s(dancer))
                                            end
                                        end
                                        # time:
                                        element("td") do td
                                            add_text(td, s(hist[i].time))
                                        end
                                        # direction:
                                        element("td") do td
                                            add_text(td, s(hist[i].direction))
                                        end
                                        # down:
                                        element("td") do td
                                            add_text(td, s(hist[i].down))
                                        end
                                        # left:
                                        element("td") do td
                                            add_text(td, s(hist[i].left))
                                        end                                        
                                    end
                                end                                    
                            end
                        end
                    end
                end
            end
        end     # end of log record loop
    end
    doc
end


function report1(logfile::String)
    output_file = splitext(logfile)[1] * ".html"
    report1(deserialize(logfile), output_file)
end

function report1(log, output_file)
    doc = analysis1_html(log)
    open(output_file, "w") do io
        print(io, doc)
    end
end

# LightXML doesn't directly support creating comments:
function new_comment(content::AbstractString)
    p = ccall((:xmlNewComment, LightXML.libxml2),
              LightXML.Xptr, (LightXML.Cstring,), content)
    return XMLNode(p)
end

