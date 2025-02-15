## Formations

Much of the reasoning in this package is to identify formations given
the locations and facing directions of dancers.

A formation might consist of 1, 2, 4, 6, or 8 dancers.

For each kind of formation an immutable struct is defined which can be
asserted in and by the knowledge base.

Each formation has a way to iterate over its dancers.  The formation
object itself is the iterator.  A formation might also divide its
dancers into roles, for example, *beaus* and *belles* or *centers* and
*ends*.

A formation might have a [`direction`](@ref) if all of its dancers are
facing the same way.

Some formations might also have a [`Handedness`](@ref).


### Recognizing Formations

The [Rete package](https://github.com/MarkNahabedian/Rete.jl) is used
to implement a rules based system for recognizing formations.  As all
of the rules relating to recognizing formations are grouped together
as `SquareDanceFormationRule`s.

Most formations have a single dedicated rule for recognizing them, but
there is a single rule for recognizing two dancer formations.

For [`Couple`](@ref) and [`Tandem`](@ref) the two dancers can be
clearly distinguished by beau/belle or leader/trailer.

For [`MiniWave`](@ref) , [`FaceToFace`](@ref) or [`BackToBack`](@ref)
though, the dancers are symmetric.  We don't want the rule to assert
two different instances of the same formation type for the same pair
of dancers, so we break symmetry by putting the dancer with the lowest
value for facing direction first in the formation.

The rules for all larger formations take some combination of
`TwoDancerFormation`s as their inputs.  This reduces both coding and
combinatorial explosion of rule inputs.


### Writing and Debugging Formation Rules

Look at other unit tests in `test/test_formation` for examples of how
to test new formation recognition rules.

If you find that no formations are being asserted in your unit test,
make sure tht your test doesn't add more dancers to the knowledgebase
than are used.  [`TwoDancerFormationsRule`](@ref) requires the
[`AllPresent`](@ref) fact because [`encroached_on`](@ref) can't work
correctly until all dancers are up to date.

