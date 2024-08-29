## Processing a Square Dance Call

Every square dance call is represented by an instance of a subtype of
[`SquareDanceCall](@ref)`.  Every instance has a [`role`](@ref)` field
which can be used to restrict the call to only some dancers, for
example [`OriginalHead`](@ref) or `[`Center`](@ref).  Some calls might
have additional fields that inform a handedness
(e.g. [`PullBy`](@ref)) or a count ([`SquareThru`](@ref)).

The function [`do_call`](@ref) is the entry point for performing a
square dance call.  It is passed the current knowledge base (a
ReteRootNode) and the call to be performed.  The knowledge base
already knows the current location and facing direction of each
dancer, and has concluded all of the formations they are in.

`do_call` creates a [`CallSchedule`](@ref) and schedules the call to
that schedule. `do_call` then calls `do_schedule`, passing it the
schedule and the knowledge base.

`do_schedule` dequeues calls from the schedule.  It calls
[`get_call_options`] to identify formations in the knowledge base that
match the call's `role` filed and the result of calling
[`can_do_call'](@ref).  `do_schedule` calls [`expand_parts`](@ref)
with the call and the appropriate formation.  If there is an
expansion, those parts are placed in the schedule.  Otherwise
[`perform`](@ref) is called to perform the call.

There is a method of [`can_do_from`](@ref) for each combination of
square dance call and formation.  `can_do_from` returns a preference
number that imposes a preference order on each combination of call and
formation.  A preference value of `0` indicates that the call can not
be performed from that formation (or that it is not yet implemented).
A positive preference value is returned if the call can be performed
from that formation.  A higher preference value is preferred over a
lower one.  For example, `UTurnBack` from `Couple` is preferable to
`UTurnBack` from a single dancer (represented as a `DancerState`)
because `Couple` furter informs correct turning direction.  A call
like `AndRoll` need only be implemented for a single dancer
(`DancerState`) because the dancer's rotational flow can be determined
from there (via the `previous` chain).

`get_call_options` is pretty complicated.  Consider a right handed
tidal wave ([`RHWaveOfEight`](@ref)).  it includes `7` two dancer
formations: four [`RHMiniWave`](@ref)s and three
[`LHMiniWave`](@ref)s.  If there is only one `CanDoCall` concerning a
dancer after the preference sorting, then that `CanDoCall` will be
included in the results of `get_call_options`.  Any `CanDoCall` whose
formation includes a dancer that is already included in the result set
is discarded.  `get_call_options` loops over these two operations:
adding to the result set and eliminating overlaps, until all
`CanDoCall` objects have been considered.  `get_call_options` finally
returns those results -- a vector of `CanDoCall` objects that concern
disjoint formations.

Once `do_schedule` has processed all of the schedule entries for a
given time value, it calls [`breathe](@ref)` to spread dancers apart
if any overlap.  `do_schedule` then makes sure the dancers are all
synchronized and updates the knowledge base (actually, it creates and
populates a new one because the Rete package doesn't support
retraction).  If the schedule is not yet empty then `do_schedule`
continues as above.

