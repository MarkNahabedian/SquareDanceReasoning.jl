## Implementing a Square Dance Call

Each square dance call is represented by a struct that is a subtype
of [`SquareDanceCall](@ref)`.

It should have an [`as_text](@ref)` method which provides a
description of the call -- what a caller might say.

It should have a [`can_do_from`](@ref) method.

It should either have a struct field named `role` which can be used to
restrict the call to only apply to certain dancers.  If it is not
appropriate for the call to be restricted to a role (for example, the
latter parts of a multi-part call), then the call should instead
implement a [`restricted_to`](@ref) method that returns a vector of
`DancerState`s for the dancers that will perform the call.

It should either have a [`perform`](@ref) method or an
[`expand_parts`](@ref) method.

Se the source code for examples.
