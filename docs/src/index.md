```@meta
CurrentModule = SquareDanceReasoning
```

# SquareDanceReasoning

Documentation for [SquareDanceReasoning](https://github.com/MarkNahabedian/SquareDanceReasoning.jl).

This document is intended as a guide to programmers and theory of
operation.  Once it is working well enough and made sufficiently
usable, I might write a users' guide for square dance choreographers.


## Overview

[`Dancer`](@ref) represents a dancer.  A dancer is identified by its
`couple_number` and its `gender`.

The location and facing direction of a `Dancer` at a given time is
represented by [`DancerState`](@ref).  See
[Coordinate System](@ref) to learn how dancer location
and facing direction are described.

See [Motion Primitives](@ref) for the simplest of operations for
moving dancers around.

One of the goals of SquareDanceReasoning is to identify what formation
the dancers are in.
See [Hierarchy of Supported Square Dance Formations](@ref)
for a list of the formations that SquareDanceReasoning can currently
recognize.

Some of the reasoning, including formation recognition, is performed
using a rule based expert system.
See [Hierarchy of Knowledge Base Rules](@ref)
for a list of the rules that are implemented.

To facilitate recognizing formations, the relative position predicates
[`in_front_of`](@ref), [`behind`](@ref), [`left_of`](@ref), and
[`right_of`](@ref) are provided.



## Index
```@index
```

## Definitions

```@autodocs
Modules = [SquareDanceReasoning]
```
