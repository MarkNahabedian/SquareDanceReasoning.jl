export SDRKnowledgeBase


"""
    SDRKnowledgeBase(label)

The type for the root node of our knowledgebase.
"""
struct SDRKnowledgeBase <: AbstractReteRootNode
    inputs::Set{AbstractReteNode}
    outputs::Set{AbstractReteNode}
    label::String
    formations_contained_in    # ::FormationContainedInMemoryNode

    function SDRKnowledgeBase(label::String)
        kb = new(Set{AbstractReteNode}(),
                 Set{AbstractReteNode}(),
                 label,
                 # Special memory for FormationContainedInMemoryNode facts:
                 FormationContainedInMemoryNode())
        connect(kb, kb.formations_contained_in)
        kb
    end
end

Rete.CanInstallRulesTrait(::Type{<:SDRKnowledgeBase}) = CanInstallRulesTrait()

Rete.inputs(kb::SDRKnowledgeBase) = kb.inputs

Rete.outputs(kb::SDRKnowledgeBase) = kb.outputs

Rete.label(node::SDRKnowledgeBase) = node.label


"""
    make_kb()

Creates SquareDanceReasoning knowledge base with no facts, but with
all rules installed.
"""
function make_kb()
    kb = SDRKnowledgeBase("SquareDanceReasoning 1")
    install(kb, SquareDanceRule)
    # Make the knowledge base self-aware:
    ensure_memory_node(kb, typeof(kb))
    receive(kb, kb)
    kb
end


"""
    make_kb(kb::SDRKnowledgeBase)

Makes a copy of the knowledge base, but without any
[`TemporalFact`](@ref)s.
"""
function make_kb(kb::SDRKnowledgeBase)
    i = parse(Int, split(kb.label, " ")[2])
    kb2 = SDRKnowledgeBase("SquareDanceReasoning $(i+1)")
    install(kb2, SquareDanceRule)
    ensure_memory_node(kb2, typeof(kb2))
    receive(kb2, kb2)
    # Copy the non-temporal facts:
    copy_facts.([kb], [kb2],
                [ SDSquare, Dancer, OriginalPartners ])
    kb2
end

