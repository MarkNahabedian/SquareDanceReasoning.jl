## Dancers, their Positions and Faciing Directions


### Dancer

[`Dancer`](@ref) represents a single square dancer.  Each `Dancer` has
a `couple_number` and a `gender`.

`gender` is one of `Guy()`, `Gal()`, or `Unspecified()` -- these are
instances of singleton subtypes of the abstract supertype `Gender`.

Within a square, dancers have an absolute ordering that matches their
order in a squared set.

```@example
sort(make_square(4).dancers)
```

The [`OriginalPartners`](@ref) fact is inferred by
``OriginalPartnerRule](@ref)`, which matches partners by
`couple_number`.

[`SDSquare`](@ref) notes which dancers are in the same square.

[`make_square`](@ref) takes a number of couples and returns an
`SDSquare` of twice than many dancers.

When asserting an `SDSquare` to the nowledge base, the
[`SquareHasDancers`](@ref) rule adds the square's `Dancer`s as well.


### DancerState

The location and facing direction of a `Dancer` are represented in a
`DancerState`, which has these properties

- `previous`: the `DancerState` which "moved" to become this one.

- `dancer`: the [`Dancer`](@ref) that this `DancerState` stores the
  locaton and facing direction for at a given time.

- `time`: a timestamp which should monotonicly DECREASE as one
  follows the `previous` chain.

- `direction`: the facing direction of the dancer at `time`.

- `down` and `left`: the location of the dancer at `time`.

See the [Coordinate System section](coordinate_system.md) for how
`direction`, `down` and `left` are represented.

