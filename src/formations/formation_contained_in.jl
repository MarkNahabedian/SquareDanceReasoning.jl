export FormationContainedIn, show_formation_containment

"""
    FormationContainedIn(contained, container)

A fact in the knowledgebase that says that `contained` is a
sub-formation of `container`.
"""
struct FormationContainedIn <: TemporalFact
    contained::SquareDanceFormation
    container::SquareDanceFormation
end

function Base.isless(fci1::FormationContainedIn, fc12::FormationContainedIn)
    isless(formation_id_string(fci1),
           formation_id_string(fc12))
end

#=
Base.isless(a::Some{FormationContainedIn}, b::Some{FormationContainedIn}) = 
    Base.isless(something(a), something(b))
=#

formation_id_string(fci::FormationContainedIn) =
    formation_id_string(fci.contained) *
    "<" *
    formation_id_string(fci.container)

# A special type of memory node for storing FormationContainedIn facts
# so that contained-in relationships can be looked up in a hash table
# indexed by bot contained formation and container formation, rather
# that using the askc mechanism.

struct FormationContainedInMemoryNode <: Rete.AbstractMemoryNode
    inputs::Set{AbstractReteNode}
    outputs::Set{AbstractReteNode}
    contained_to_container::Dict{SquareDanceFormation,
                                 SortedSet{FormationContainedIn}}
    container_to_contained::Dict{SquareDanceFormation,
                                 SortedSet{FormationContainedIn}}

    FormationContainedInMemoryNode() =
        new(Set{AbstractReteNode}(),
            Set{AbstractReteNode}(),
            Dict{SquareDanceFormation,
                 SortedSet{SquareDanceFormation}}(),
            Dict{SquareDanceFormation,
                 SortedSet{SquareDanceFormation}}())
end

Rete.inputs(node::FormationContainedInMemoryNode) = node.inputs

Rete.outputs(node::FormationContainedInMemoryNode) = node.outputs

Rete.label(n::FormationContainedInMemoryNode) =
    "FormationContainedInMemoryNode"

Rete.is_memory_for_type(::FormationContainedInMemoryNode,
                        ::Type{<:FormationContainedIn}) = true


# @rule typically creates a `Rete.install` method for each rule.  That
# method calls `Rete.ensure_memory_node, which calls
# `Rete.find_memory_for_type`.  We define this method to suppress the
# creation of a standard `Rete.IsaMemoryNode` node for
# `FormationContainedIn` facts.
function Rete.find_memory_for_type(root::SDRKnowledgeBase,
                                   typ::Type{FormationContainedIn})
    root.formations_contained_in
end

function Rete.receive(node::FormationContainedInMemoryNode,
                      fact::FormationContainedIn)
    if !haskey(node.contained_to_container, fact.contained)
        node.contained_to_container[fact.contained] =
            SortedSet{FormationContainedIn}()
    end
    if !haskey(node.container_to_contained, fact.container)
        node.container_to_contained[fact.container] =
            SortedSet{FormationContainedIn}()
    end
    push!(node.contained_to_container[fact.contained], fact)
    push!(node.container_to_contained[fact.container], fact)
    emit(node, fact)
end


# FormationContainedInMemoryNode needs a custom `Rete.askc` method:
function Rete.askc(continuation::Function,
                   node::FormationContainedInMemoryNode)
    for fact in merge_sorted_iterators(values(node.container_to_contained)...,
                                       values(node.contained_to_container)...)
        @assert fact isa FormationContainedIn
        continuation(fact)
    end
end


"""
    show_formation_containment(kb::SDRKnowledgeBase)

For debugging, show the memory of the FormationContainedInMemoryNode.
"""
show_formation_containment(kb::SDRKnowledgeBase) =
    show_formation_containment(kb.formations_contained_in)

function show_formation_containment(node::FormationContainedInMemoryNode)
    # Maybe should sort containers by size and name.
    for (container, contained) in node.container_to_contained
        println("\n", container, "\n\t", contained)
    end
    println()
end

