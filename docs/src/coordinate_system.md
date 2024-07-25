## Coordinate System

Here we describe the coordinate system used to describe the location
and facing direction of each dancer.

The coordinate system provides a *down* coordinate and a *left*
coordinate.  Down and left are with respect to the caller's point of
view.  Down is a dancer's distance down the floor -- away from the
caller.  Left is the dancer's position from the right hand side of the
set (from the caller's point of view) toward the caller's left.

If one pictures the caller as being at the left hand edge of one's
field of view, then *direction*, *down* and *left* form the angle, X
axis and Y axis of a normal right handed cartesean coordinate system.

*Direction* is how angles are measured in our coordinate system.  It
might describe a direction of motion, the facing direction of a dancer,
the direction of a dancer from another dancer's point of view, etc.
Direction can be absolute or relative.

Directions are expressed as fractions of a full circle, so a change in
direction of 180 degrees is expressed as a change in Direction of
1/2.  Direction increases in promenade direction -- counter
clockwise.  An attempt is made to store directions as rational numbers
to avoid excessive floating point digits.

Direction 0 is the direction that the caller is facing and the
facing direction of couple number one in a squared set.  In a squared
set, the facing direction of couple number two would be 1/4, that of
couple number three: 1/2, and that of couple number four: 3/4.


### Definitions Relating to the Coordinate system

- [`FULL_CIRCLE`](@ref)
- [`canonicalize`](@ref)
- [`opposite`](@ref)
- [`quarter_left`](@ref)
- [`quarter_right`](@ref)
- [`COUPLE_DISTANCE`](@ref)
- [`distance`](@ref)

