```@meta
CurrentModule = SquareDanceReasoning
```

# SquareDanceReasoning

Documentation for [SquareDanceReasoning](https://github.com/MarkNahabedian/SquareDanceReasoning.jl).

## Overview

[`Dancer`](@ref) represents a dancer.  A dancer is identified by its
`couple_number` and its `gender`.

The location and facing direction of a `Dancer` at a given time is
represented by [`DancerState`](@ref).  See
[Coordinate System](coordinate_system.html) to learn how dancer location
and facing direction are described.

See [Motion Primitives](motion_primitives.html) for the simplest of
operations for moving dancers around.

One of the goals of SquareDanceReasoning is to identify what formation
the dancers are in.  See [Supported Formations](formation_hierarchy.html)
for a list of the formations that SquareDanceReasoning can currently
recognize.

Some of the reasoning, including formation recognition, is performed
using a rule based expert system.  See [Rule Hierarchy](rule_hierarchy.html)
for a list of the rules that are implemented.


```@index
```

```@autodocs
Modules = [SquareDanceReasoning]
```
