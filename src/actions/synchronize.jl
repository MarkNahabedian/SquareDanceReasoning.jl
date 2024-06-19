
export Synchronized, synchronize

struct Synchronized
    time
end


"""
    synchronize(root::ReteRootNode)

Posts a Synchronized fact to the knowledge base corresponding to the
latest time among all `DancerState`s in the knowledge base.

For and DancerState that is behind that time, a new DancerState is
asserted for the latest time.

It is recommended that `synchronize` should be called after every call
or each part of a call.
"""
function synchronize(root::ReteRootNode)
    latest_dss = latest_dancer_states(root)
    latest = maximum(ds -> ds.time, values(latest_dss))
    for ds in values(latest_dss)
        if ds.time < latest
            receive(root, DancerState(ds.dancer,
                                      latest,
                                      ds.direction,
                                      ds.down,
                                      ds.left))
        end
    end
    # Synchronized must be after the updated DancerStates, since it
    # will serve as a rule forward trigger.
    receive(root, Synchronized(latest))
end

