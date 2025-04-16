using SquareDanceReasoning
using Logging
using Test
using Serialization

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
                    record.kwargs[:cdc].call)
        elseif record.message == "do_schedule expand_cdc"
            cdc = record.kwargs[:cdc]
            println(" expand ", record.kwargs[:now], "\t",
                    cdc.call, "\t",
                    [ds.dancer for ds in cdc.formation()])
        elseif record.message == "do_schedule expand_parts returned"
            e = record.kwargs[:e]
            if !isa(e, SquareDanceCall)
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
            println(" + " , new_entry[1], "\t", new_entry[2])
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
                queue = [ pair for pair in record.kwargs[:sched].queue ]
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

