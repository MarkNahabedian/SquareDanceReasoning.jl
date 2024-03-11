## Formations

Much of the reasoning in this package is to identify formations given
the locations and facing directions of dancers.

A formation might consist of 2, 4, 6, or 8 dancers.

For each kind of formation an immutable struct is defined which can be
asserted in and by the knowledge base.

All formations have a way to iterate over its dancers.  A formation
might also divide its dancers into roles, for example, *beaus* and
*belles* or *centers* and *ends*.

A formation might have a facing direction if all of its dancers are
facing the same way.

