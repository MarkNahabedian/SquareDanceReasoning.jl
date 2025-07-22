### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ c7baac1c-5bf8-11f0-0b37-dd7d289b81e9
begin
	using Pkg
	Pkg.activate(; temp=true)
	Pkg.add("HypertextLiteral")
	using HypertextLiteral
	Pkg.add("Test")
	using Test: TestLogger
	Pkg.activate("/Users/MarkNahabedian/.julia/dev/SquareDanceReasoning.jl/")
	using SquareDanceReasoning
	using SquareDanceReasoning: elt, uncollide, canonicalize_coordinate, DANCER_COLLISION_DISTANCE
	using Rete
	using Markdown
	using XML
	using Logging
	pathof(SquareDanceReasoning)
end

# ╔═╡ ee73c7dc-1bca-468b-87fd-88dedcab816b
include(joinpath(dirname(dirname(pathof(SquareDanceReasoning))),
			"src/log_analysis_tools.jl"))

# ╔═╡ 6a685709-4b96-45fc-baee-d3c3c5e853c9
### Should we put this function in timeline.jl?
function at_history_position(ds::DancerState, position::Int)
    thispos = history_position(ds)
    if position == thispos
        ds
    elseif position < thispos
        at_history_position(ds.previous, position)
    end
end

# ╔═╡ cc605a92-d01d-428d-b912-c263e0966e90
display_xml(elt) = HypertextLiteral.Result(HypertextLiteral.Bypass(XML.write(elt)))

# ╔═╡ facf4bf8-9a4f-4ac0-b6f2-903b9208bc93
md"## Load Log"

# ╔═╡ 5b253788-d5e5-4926-b5a3-5550b8e27289
function dancer_motion(ds::DancerState, start_history_poosition::Int, end_history_position::Int)
    return (location(at_history_position(ds, end_history_position))
            - location(at_history_position(ds, start_history_poosition)))
end

# ╔═╡ 1fea3998-1291-4ad5-aa17-1ed375cc8e53
# Load log file:
begin
    LOGFILE = "/Users/MarkNahabedian/.julia/dev/SquareDanceReasoning.jl/test/test_calls/test-Hinge.binlog"
    MYLOG = deserialize_log_file(LOGFILE)
    println("$(length(MYLOG)) log entries.")
end

# ╔═╡ 754f953f-385c-4974-ac5e-8e5b7b0a7f7f
md"## Extract data from log"

# ╔═╡ f5d61759-2d3f-4063-80b1-c05eca254110
DANCER_STATES = let
    log_entry = last(filter(MYLOG) do le
                         le.message == "do_schedule finished"
                     end)
    sort(collect(values(log_entry.kwargs[:newest_dancer_states]));
	 by = ds -> ds.dancer)
end

# ╔═╡ a27420d9-7f73-471a-8035-8c95d64b1cf3
COLLISIONS = let
    log_entry = last(filter(MYLOG) do le
                         le.message == "do_schedule collisions"
                     end)
    sort(collect(values(log_entry.kwargs[:collisions]));
         by = c -> sum((c.center) .^ 2))
end

# ╔═╡ ae4595f8-9964-47e7-89b1-62ef72013a52
md"## Collision motion for each dancer"

# ╔═╡ 71701b45-c691-412a-ae34-6f3257e0da93
let
    doc = elt("table",
              elt("tr",
                  elt("th", "Dancer"),
                  elt("th", "Location @ 2"),
                  elt("th", "Location @ 3"),
                  elt("th", "location delta"),
                  elt("th", "Collision 1 motion"),
                  elt("th", "Collision 2 motion"),
                  elt("th", "Collision 3 motion"),
                  elt("th", "total motion"),
                  elt("th", "match?")),
              map(DANCER_STATES) do ds
                  ds2 = at_history_position(ds, 2)
                  ds3 = at_history_position(ds, 3)
                  collisioon_motion = canonicalize_coordinate.(uncollide.(COLLISIONS, [ds2]))
                  total_collision_motion = sum(collisioon_motion)
                  loc(l) = "$(canonicalize_coordinate(l[1])) $(canonicalize_coordinate(l[2]))"
                  elt("tr",
                      elt("td",
                          ds.dancer.couple_number,
                          repr(typeof(ds.dancer.gender);
                               context=(:module => SquareDanceReasoning))),
                      elt("td", loc(location(ds2))),
                      elt("td", loc(location(ds3))),
                      elt("td", loc(location(ds3) - location(ds2))),
                      elt("td", loc(collisioon_motion[1])),
                      elt("td", loc(collisioon_motion[2])),
                      elt("td", loc(collisioon_motion[3])),
                      elt("td", loc(total_collision_motion)),
                      elt("td", (canonicalize_coordinate.((location(ds3) - location(ds2)))
                                 == total_collision_motion)))
              end...)
	display_xml(doc)
end

# ╔═╡ aa1a8ff3-f288-4373-9265-65dcec8cfdf5
function collisions_svg(collisions)
    scale = SquareDanceReasoning.DANCER_SVG_SIZE
    dot_radius = 0.1 * scale
    elt("g", "class" => "collisions_svg",
        map(collisions) do collision
			@assert collision.center[2] isa Real
            elt("g",
				XML.Comment("\n" *
					        repr(collision;
				                 context=(:module => SquareDanceReasoning))
				            * "\n"),
                elt("circle",
                    :cx => collision.center[1] * scale,
                    :cy => collision.center[2] * scale,
                    :r => dot_radius,
                    :fill => "gray",
                    :stroke => "gray",
                    "fill-opacity" => 1.0,
                    "stroke-width" => "1px",
                    "stroke-opacity" => 1.0),
                elt("line",
                    :x1 => collision.center[1] * scale,
                    :y1 => collision.center[2] * scale,
                    :x2 => (collision.center[1] + collision.sideways[1]) * scale,
                    :y2 => (collision.center[2] + collision.sideways[2]) * scale,
                    :stroke => "darkgray",
                    "stroke-opacity" => 1.0,
                    "stroke-width" => "1px"))
        end...)
end

# ╔═╡ b500f40e-d9c3-43b5-9ff9-c711997e064c
function add_collisions_to_animation(collisions, animation)
    function walk(node)
        if nodetype(node) in (XML.Text,
                              XML.CData,
                              XML.Comment,
                              XML.ProcessingInstruction,
                              XML.Declaration,
                              XML.DTD)
            node
        elseif nodetype(node) == XML.Element
            # if node is the svg element then we want to append an
            # additional child, otherwise just copy:
            if tag(node) == "svg"
                elt(tag(node),
                    attributes(node),
                    children(node)...,
		    collisions_svg(collisions))
            else
                node
            end
        else
            error("Unexpected node type $(nodetype(node))")
        end
    end
    walk(animation)
end

# ╔═╡ def87e1a-94a7-4bda-935a-863ef600e680
md"""

it looks like the biggest problem is with Dancer 2 Gal.

2 Gal is involved in 2 collisions, neither of which is a same direction collision.
"""

# ╔═╡ fc234395-35f9-4291-9d42-7d1775396ed5
display_xml(
    add_collisions_to_animation(COLLISIONS,
	                            animation_svg(DANCER_STATES; bpm=60)))

# ╔═╡ 289809de-db88-4dde-b24c-0b2e6c31c43f
md"""
Starting formation:
"""

# ╔═╡ d047c9e6-542e-4cb0-82cc-c0d5004391ed
let
    drawing = add_collisions_to_animation(COLLISIONS,
		                          formation_svg(
                                              at_history_position.(DANCER_STATES, [1]),
                                              ""))
    XML.write(joinpath(dirname(dirname(pathof(SquareDanceReasoning))),
                       "CHECK_COLLISIONS.svg"),
              drawing)
    display_xml(drawing)
end

# ╔═╡ e5b41819-ced0-4c64-88e8-962e7f768aba
COLLISIONS

# ╔═╡ 1b13f3c5-94a1-44f3-81f4-f551c29776e4
md"""
The change to the collision constructor helped a lot.

Is there a way to avoid moving 1 Guy?  How would we know not to bother moving him?

Has 1` Gal` collided with `2 Gal` after the `uncollide`?

$(distance(DANCER_STATES[2], DANCER_STATES[4]) < DANCER_COLLISION_DISTANCE)
"""

# ╔═╡ 0fa56a1e-0ec3-48d9-bdf6-ad1c47ef3aaa
let
    dancer_index = 4
    ds = DANCER_STATES[dancer_index].previous
    println(ds)
    dancer_string = repr(ds.dancer; context=(:module => SquareDanceReasoning))
    html = elt("div",
               dancer_string,
               elt("ul",
                   map(enumerate(COLLISIONS)) do (i, c)
                       elt("li",
                           (ds == c.a || ds == c.b) ? "is" : "is not",
                           "in collision $i:  motioon:",
                           string(canonicalize_coordinate(uncollide(c, ds))))
                   end...) )
    display_xml(html)
end

# ╔═╡ 7b797e0f-468a-44af-8528-6b300bec1254
md"""
Snapshot at the time of collision:
"""

# ╔═╡ 569f9132-a892-43ce-a219-75473aad4042
display_xml(
    add_collisions_to_animation(COLLISIONS,
		                formation_svg(
                                    at_history_position.(DANCER_STATES, [2]),
                                    "")))

# ╔═╡ f8b0cb31-d319-4b4c-bb2d-00f11dcd20b4
md"""
The "test Hinge" testset is failing several tests:

```
test Hinge: Test Failed at /Users/MarkNahabedian/.julia/dev/SquareDanceReasoning.jl/test/test_calls/test_two_dancer_calls.jl:34
  Expression: 2 == askc(Counter(), kb, Couple)
   Evaluated: 2 == 1
```
and

```
test Hinge: Test Failed at /Users/MarkNahabedian/.julia/dev/SquareDanceReasoning.jl/test/test_calls/test_two_dancer_calls.jl:36
  Expression: 1 == askc(Counter(), kb, LHMiniWave)
   Evaluated: 1 == 0
```

What are we getting and what is missing?

`1 Guy` and `1 Gal` are not a Couple because `1 Gal` is too low.  WHAT CAN WE DO ABOUT THAT?

Why are we missing the couple 2 `LHMiniWave`?
"""

# ╔═╡ aa43d961-2a82-4fcc-b68f-f287661987a0
let
    ds1 = DANCER_STATES[3]
    ds2 = DANCER_STATES[4]
    println(ds1, "\n", ds2)
    println("\n", :(encroached_on([ds1, ds2], DANCER_STATES)), "\t",
	    encroached_on([ds1, ds2], DANCER_STATES))
    println("\n", :(left_of(ds1, ds2) && left_of(ds2, ds1)), "\t", 
	    left_of(ds1, ds2) && left_of(ds2, ds1))
end

# ╔═╡ d8195bf2-1a7f-4f3e-8589-1fd87d412b40
md"""
### Lets look at each of these missing two dancer formations individually
"""

# ╔═╡ b835c44c-5206-4abc-a1e0-a5c7c8a68388
# Given some DancerStates, run the formation inference engine and report the failres
function why_no_formations(dss::Vector{DancerState})
    local formations
    logger = TestLogger()
    with_logger(logger) do
        Logging.disable_logging(Logging.Debug - 1)
        kb = make_kb()
        receive(kb, SDSquare(map(ds -> ds.dancer, dss)))
        receive.([kb], dss)
        println("$(askc(Counter(), kb, SquareDanceFormation)) formations.")
	formations = askc(Collector{SquareDanceFormation}(), kb)
    end
    println("$(length(logger.logs)) log entries.")
    return (formations,
	     filter(logger.logs) do log_entry
        	 log_entry.message in ("@reject", "@rejectif", "@continueif")
             end)
end

# ╔═╡ 746b1e58-7f68-4e7d-a0bc-ba82c2a82e3f
md"""
#### Couple 2 LHMiniWave
"""

# ╔═╡ f9c30a44-d713-4b9a-842e-c6402aad6f94
why_no_formations(DANCER_STATES[3:4])

# ╔═╡ e26a8e78-62f2-4887-986d-2885c97c7911
md"""
#### Couple 1 Couple

It looks like collision 1 is responsible for the asymetric movement.

1 Gal is not a direct participant in collision 1.
"""

# ╔═╡ 06365357-d1de-49cd-8722-81b7212b57ab
COLLISIONS[1]

# ╔═╡ 07e30fe5-033b-4c54-b545-44c3eaf9b1b2
let
    ds = DANCER_STATES[1]
    ds, uncollide(COLLISIONS[1], ds)
end

# ╔═╡ db85fba7-dc9f-4bfa-8203-e7e744e9665c
let
    ds = DANCER_STATES[2]
    ds, uncollide(COLLISIONS[1], ds)
end

# ╔═╡ 4b586f65-53d9-45a5-83ae-cf034e9a8511
md"""

Changing the first test in `uncollide(collision::Collision, ds::DancerState)` from

```
	location(ds) == collision.center
```

to

```
	ds == collision.a || ds == collision.b
```

fixes the problem with the "test Hinge" testset.
"""

# ╔═╡ Cell order:
# ╟─c7baac1c-5bf8-11f0-0b37-dd7d289b81e9
# ╟─ee73c7dc-1bca-468b-87fd-88dedcab816b
# ╟─6a685709-4b96-45fc-baee-d3c3c5e853c9
# ╟─cc605a92-d01d-428d-b912-c263e0966e90
# ╟─facf4bf8-9a4f-4ac0-b6f2-903b9208bc93
# ╟─5b253788-d5e5-4926-b5a3-5550b8e27289
# ╟─1fea3998-1291-4ad5-aa17-1ed375cc8e53
# ╟─754f953f-385c-4974-ac5e-8e5b7b0a7f7f
# ╟─f5d61759-2d3f-4063-80b1-c05eca254110
# ╟─a27420d9-7f73-471a-8035-8c95d64b1cf3
# ╟─ae4595f8-9964-47e7-89b1-62ef72013a52
# ╟─71701b45-c691-412a-ae34-6f3257e0da93
# ╟─aa1a8ff3-f288-4373-9265-65dcec8cfdf5
# ╟─b500f40e-d9c3-43b5-9ff9-c711997e064c
# ╟─def87e1a-94a7-4bda-935a-863ef600e680
# ╟─fc234395-35f9-4291-9d42-7d1775396ed5
# ╟─289809de-db88-4dde-b24c-0b2e6c31c43f
# ╟─d047c9e6-542e-4cb0-82cc-c0d5004391ed
# ╟─e5b41819-ced0-4c64-88e8-962e7f768aba
# ╟─1b13f3c5-94a1-44f3-81f4-f551c29776e4
# ╟─0fa56a1e-0ec3-48d9-bdf6-ad1c47ef3aaa
# ╟─7b797e0f-468a-44af-8528-6b300bec1254
# ╟─569f9132-a892-43ce-a219-75473aad4042
# ╟─f8b0cb31-d319-4b4c-bb2d-00f11dcd20b4
# ╟─aa43d961-2a82-4fcc-b68f-f287661987a0
# ╟─d8195bf2-1a7f-4f3e-8589-1fd87d412b40
# ╠═b835c44c-5206-4abc-a1e0-a5c7c8a68388
# ╟─746b1e58-7f68-4e7d-a0bc-ba82c2a82e3f
# ╟─f9c30a44-d713-4b9a-842e-c6402aad6f94
# ╠═e26a8e78-62f2-4887-986d-2885c97c7911
# ╟─06365357-d1de-49cd-8722-81b7212b57ab
# ╟─07e30fe5-033b-4c54-b545-44c3eaf9b1b2
# ╟─db85fba7-dc9f-4bfa-8203-e7e744e9665c
# ╟─4b586f65-53d9-45a5-83ae-cf034e9a8511
