using Base.Iterators: Stateful

export merge_sorted_iterators


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

