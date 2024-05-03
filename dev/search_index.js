var documenterSearchIndex = {"docs":
[{"location":"fortmations.html#Formations","page":"-","title":"Formations","text":"","category":"section"},{"location":"fortmations.html","page":"-","title":"-","text":"Much of the reasoning in this package is to identify formations given the locations and facing directions of dancers.","category":"page"},{"location":"fortmations.html","page":"-","title":"-","text":"A formation might consist of 2, 4, 6, or 8 dancers.","category":"page"},{"location":"fortmations.html","page":"-","title":"-","text":"For each kind of formation an immutable struct is defined which can be asserted in and by the knowledge base.","category":"page"},{"location":"fortmations.html","page":"-","title":"-","text":"All formations have a way to iterate over its dancers.  A formation might also divide its dancers into roles, for example, beaus and belles or centers and ends.","category":"page"},{"location":"fortmations.html","page":"-","title":"-","text":"A formation might have a facing direction if all of its dancers are facing the same way.","category":"page"},{"location":"motion_primitives.html#Motion-Primitives","page":"Motion Primitives","title":"Motion Primitives","text":"","category":"section"},{"location":"motion_primitives.html","page":"Motion Primitives","title":"Motion Primitives","text":"How the dancers move while performing a call can be described in terms of motion primitives.","category":"page"},{"location":"motion_primitives.html","page":"Motion Primitives","title":"Motion Primitives","text":"These are the motion primitives:","category":"page"},{"location":"motion_primitives.html","page":"Motion Primitives","title":"Motion Primitives","text":"forward\nbackward\nrightward\nleftward\nrotate\nrevolve","category":"page"},{"location":"formation_hierarchy.html#Hierarchy-of-Supported-Square-Dance-Formations","page":"Supported Formations","title":"Hierarchy of Supported Square Dance Formations","text":"","category":"section"},{"location":"formation_hierarchy.html","page":"Supported Formations","title":"Supported Formations","text":"These are the formations that are currently supported:","category":"page"},{"location":"formation_hierarchy.html","page":"Supported Formations","title":"Supported Formations","text":"SquareDanceFormation\nEightDancerFormation\nWaveOfEight\nLHWaveOfEight\nRHWaveOfEight\nFourDancerFormation\nColumnOfFour\nLineOfFour\nTwoFacedLine\nWaveOfFour\nLHWaveOfFour\nRHWaveOfFour\nTwoDancerFormation\nBackToBack\nCouple\nFaceToFace\nMiniWave\nLHMiniWave\nRHMiniWave\nTandem","category":"page"},{"location":"future_work/multiple_sets_of_dancers.html#Multiple-Sets-of-Dancers","page":"-","title":"Multiple Sets of Dancers","text":"","category":"section"},{"location":"future_work/multiple_sets_of_dancers.html","page":"-","title":"-","text":"At some point we might want to model more that one set of dancers at a time.  We would want to associate each dancer with the set they are in.  We want to keep Dancer immutable though.","category":"page"},{"location":"future_work/multiple_sets_of_dancers.html","page":"-","title":"-","text":"We might provide each dancer with a field for the coordinates of its flagpole center.  That would allow us to identify which dancers are in the same set.","category":"page"},{"location":"coordinate_system.html#Coordinate-System","page":"Coordinate System","title":"Coordinate System","text":"","category":"section"},{"location":"coordinate_system.html","page":"Coordinate System","title":"Coordinate System","text":"Here we describe the coordinate system used to describe the location and facing direction of each dancer.","category":"page"},{"location":"coordinate_system.html","page":"Coordinate System","title":"Coordinate System","text":"The coordinate system provides a down coordinate and a left coordinate.  Down and left are with respect to the caller's point of view.  Down is a dancer's distance down the floor – away from the caller.  Left is the dancer's position from the right hand side of the set (from the caller's point of view) toward the caller's left.","category":"page"},{"location":"coordinate_system.html","page":"Coordinate System","title":"Coordinate System","text":"If one pictures the caller as being at the left hand edge of one's field of view, then direction, down and left form the angle, X axis and Y axis of a normal right handed cartesean coordinate system.","category":"page"},{"location":"coordinate_system.html","page":"Coordinate System","title":"Coordinate System","text":"Direction is how angles are measured in our coordinate system.  It might describe a direction of motion, the facing direction of a dancer, the direction of a dancer from another dancer's point of view, etc. Direction can be absolute or relative.","category":"page"},{"location":"coordinate_system.html","page":"Coordinate System","title":"Coordinate System","text":"Directions are expressed as fractions of a full circle, so a change in direction of 180 degrees is expressed as a change in Direction of 1/2.  Direction increases in promenade direction – counter clockwise.  An attempt is made to store directions as rational numbers to avoid excessive floating point digits.","category":"page"},{"location":"coordinate_system.html","page":"Coordinate System","title":"Coordinate System","text":"Direction 0 is the direction that the caller is facing and the facing direction of couple number one in a squared set.  In a squared set, the facing direction of couple number two would be 1/4, that of couple number three: 1/2, and that of couple number four: 3/4.","category":"page"},{"location":"coordinate_system.html#Definitions-Relating-to-the-Coordinate-system","page":"Coordinate System","title":"Definitions Relating to the Coordinate system","text":"","category":"section"},{"location":"coordinate_system.html","page":"Coordinate System","title":"Coordinate System","text":"FULL_CIRCLE\ncanonicalize\ndirection_equal\nopposite\nquarter_left\nquarter_right\nCOUPLE_DISTANCE\ndistance","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"CurrentModule = SquareDanceReasoning","category":"page"},{"location":"index.html#SquareDanceReasoning","page":"Home","title":"SquareDanceReasoning","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"Documentation for SquareDanceReasoning.","category":"page"},{"location":"index.html#Overview","page":"Home","title":"Overview","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"Dancer represents a dancer.  A dancer is identified by its couple_number and its gender.","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"The location and facing direction of a Dancer at a given time is represented by DancerState.  See Coordinate System to learn how dancer location and facing direction are described.","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"See Motion Primitives for the simplest of operations for moving dancers around.","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"One of the goals of SquareDanceReasoning is to identify what formation the dancers are in. See Hierarchy of Supported Square Dance Formations for a list of the formations that SquareDanceReasoning can currently recognize.","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"Some of the reasoning, including formation recognition, is performed using a rule based expert system. See Hierarchy of Knowledge Base Rules for a list of the rules that are implemented.","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"Modules = [SquareDanceReasoning]","category":"page"},{"location":"index.html#SquareDanceReasoning.COUPLE_DISTANCE","page":"Home","title":"SquareDanceReasoning.COUPLE_DISTANCE","text":"COUPLE_DISTANCE is the distance between (the center reference points of) two dancers standing side by side, face to face, or back to back.\n\n\n\n\n\n","category":"constant"},{"location":"index.html#SquareDanceReasoning.FULL_CIRCLE","page":"Home","title":"SquareDanceReasoning.FULL_CIRCLE","text":"FULL_CIRCLE represents a change in direction of 360 degrees.\n\n\n\n\n\n","category":"constant"},{"location":"index.html#SquareDanceReasoning.BackToBack","page":"Home","title":"SquareDanceReasoning.BackToBack","text":"BackToBack represents a formation of two dancers with their backs facing each other.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.Bounds","page":"Home","title":"SquareDanceReasoning.Bounds","text":"Bounds(dss::Vector{DancerState};\n                    margin = COUPLE_DISTANCE / 2)\n\nrepresents the bounding rectangle surrounding the specified DancerSTates.  If margin is 0 then Bounds surrponds just the centers of the dancers.\n\nBy default, margin is COUPLE_DISTANCE / 2 so that Bounds describes the space actually occupied by the dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.Collision","page":"Home","title":"SquareDanceReasoning.Collision","text":"Collision notes that two dancers are occupying the same space.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.CollisionRule","page":"Home","title":"SquareDanceReasoning.CollisionRule","text":"CollisionRule is a rule for detecting when two DancerStates occupy the same space.  It asserts Collision.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.ColumnOfFour","page":"Home","title":"SquareDanceReasoning.ColumnOfFour","text":"ColumnOfFour(lead::Tandem, tail::Tandem, centers::Tandem)\n\nRepresents a column of four dancers, each facing the back of the dancer in front of them.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.ColumnOfFourRule","page":"Home","title":"SquareDanceReasoning.ColumnOfFourRule","text":"ColumnOfFourRule is the rule for identifying ColumnOfFour formations.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.Couple","page":"Home","title":"SquareDanceReasoning.Couple","text":"Couble(beau::DancerState, belle::DancerState)\n\nCouple represents a formation of two dancers both facing the same direction.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.Dancer","page":"Home","title":"SquareDanceReasoning.Dancer","text":"Dancer(couple_number::Int, ::Gender)\n\nDancer represents a dancer.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.DancerState","page":"Home","title":"SquareDanceReasoning.DancerState","text":"DancerState(dancer, time, direction, down, left)\nDancerState(previoous::DancerSTate, time, direction, down, left)\n\nrepresents the location and facing direction of a single dancer at a moment in time.\n\ntime is a number defining a temporal ordering.  It could represent a number of beats, for example.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.EightDancerFormation","page":"Home","title":"SquareDanceReasoning.EightDancerFormation","text":"EightDancerFormation is the abstract supertype of all square dance formations involving eight dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.FaceToFace","page":"Home","title":"SquareDanceReasoning.FaceToFace","text":"FaceToFace represents a formation of two dancers facing each other.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.FourDancerFormation","page":"Home","title":"SquareDanceReasoning.FourDancerFormation","text":"FourDancerFormation is the abstract supertype of all square dance formations involving four dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.Gender","page":"Home","title":"SquareDanceReasoning.Gender","text":"Gender represents the gender of a dancer, which might be Guy, Gal or Unspecified.\n\nUnspecified exists for when we want to emphasize gender agnosticism in a diagram.\n\nGender equality: Guy() == Guy(), Gal() == Gal(), otherwise not equal.\n\nUse opposite to get the opposite gender.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.Handedness","page":"Home","title":"SquareDanceReasoning.Handedness","text":"Handedness\n\nsquare dance formations have a handedness, one of RightHanded(), LeftHanded() or NoHandedness().\n\nopposite of a handedness returns the other handedness. NoHandednessis its own opposite.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.LHMiniWave","page":"Home","title":"SquareDanceReasoning.LHMiniWave","text":"LHMiniWave represents a left handed wave of two dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.LHWaveOfEight","page":"Home","title":"SquareDanceReasoning.LHWaveOfEight","text":"LHWaveOfEight represents a right handed wave of eight dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.LHWaveOfFour","page":"Home","title":"SquareDanceReasoning.LHWaveOfFour","text":"LHWaveOfFour represents a left handed wave of four dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.LineOfFour","page":"Home","title":"SquareDanceReasoning.LineOfFour","text":"LineOfFour represents a line of four dancerrs all facing in the same direction.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.LineOfFourRule","page":"Home","title":"SquareDanceReasoning.LineOfFourRule","text":"LineOfFourRule is the rule for iderntifying a LineOfFour formation.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.MiniWave","page":"Home","title":"SquareDanceReasoning.MiniWave","text":"MiniWave is the abstract supertype for all two dancer waves.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.OriginalPartnerRule","page":"Home","title":"SquareDanceReasoning.OriginalPartnerRule","text":"OriginalPartnerRule is a rule that identifies the original partners of a square dance set.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.RHMiniWave","page":"Home","title":"SquareDanceReasoning.RHMiniWave","text":"RHMiniWave represents a right handed wave of two dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.RHWaveOfEight","page":"Home","title":"SquareDanceReasoning.RHWaveOfEight","text":"RHWaveOfEight represents a right handed wave of eight dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.RHWaveOfFour","page":"Home","title":"SquareDanceReasoning.RHWaveOfFour","text":"RHWaveOfFour represents a right handed wave of four dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.SDSquare","page":"Home","title":"SquareDanceReasoning.SDSquare","text":"SDSquare(dancers)\n\nSDSquare is a fact that can be asserted to the knowledge base to inform it that the dancers form a square.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.SquareDanceFormation","page":"Home","title":"SquareDanceReasoning.SquareDanceFormation","text":"SquareDanceFormation is the abstract supertype of all square dance formations.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.SquareDanceFormationRule","page":"Home","title":"SquareDanceReasoning.SquareDanceFormationRule","text":"SquareDanceFormationRule\n\nthe group for all rules relating to square dance formations.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.SquareDanceRule","page":"Home","title":"SquareDanceReasoning.SquareDanceRule","text":"SquareDanceRule is the abstract supertype for all rules defined in this package.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.SquareHasDancers","page":"Home","title":"SquareDanceReasoning.SquareHasDancers","text":"SquareHasDancers is a convenience rule for asserting the Dancers from a SDSquare.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.Tandem","page":"Home","title":"SquareDanceReasoning.Tandem","text":"Tandem(leaderLLDancerState, trailer::DancerState)\n\nTandem repreents a formation of two dancers where the trailer is facing the back of the leader.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.TimeBounds","page":"Home","title":"SquareDanceReasoning.TimeBounds","text":"TimeBounds()\n\nReturns an empty TimeBounds interval.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.TwoDancerFormation","page":"Home","title":"SquareDanceReasoning.TwoDancerFormation","text":"TwoDancerFormation is the abstract supertype of all square dance formations involving two dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.TwoDancerFormationsRule","page":"Home","title":"SquareDanceReasoning.TwoDancerFormationsRule","text":"TwoDancerFormationsRule is the rule for identifying all two dancer formations: Couple, FaceToFace, BackToBack, Tandem, RHMiniWave, and LHMiniWave.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.TwoFacedLine","page":"Home","title":"SquareDanceReasoning.TwoFacedLine","text":"TwoFacedLine represents a two faced line formation.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.TwoFacedLineRule","page":"Home","title":"SquareDanceReasoning.TwoFacedLineRule","text":"TwoFacedLineRule is the rule for identifying TwoFacedLine formations.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.WaveOfEight","page":"Home","title":"SquareDanceReasoning.WaveOfEight","text":"WaveOfEight is the abstract supertype for right and left handed waves of eight dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.WaveOfEightRule","page":"Home","title":"SquareDanceReasoning.WaveOfEightRule","text":"WaveOfEightRule is the rule for identifying waves of eight dancers: RHWaveOfEight and LHWaveOfEight.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.WaveOfFour","page":"Home","title":"SquareDanceReasoning.WaveOfFour","text":"WaveOfFour is the abstract supertype for right and left handed waves of four dancers.\n\n\n\n\n\n","category":"type"},{"location":"index.html#SquareDanceReasoning.WaveOfFourRule","page":"Home","title":"SquareDanceReasoning.WaveOfFourRule","text":"WaveOfFourRule is the rule for identifying waves of four dancers: RHWaveOfFour and LHWaveOfFour.\n\n\n\n\n\n","category":"type"},{"location":"index.html#Base.isless-Tuple{Dancer, Dancer}","page":"Home","title":"Base.isless","text":"Base.isless(::Dancer, ::Dancer)::Bool\n\nProvides a total ordering for dancers.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.backward-Tuple{DancerState, Any, Any}","page":"Home","title":"SquareDanceReasoning.backward","text":"backward(ds::DancerState, distance, time_delta)::DancerState\n\nMove the Dancer identified by ds backward (based on ds.direction) the specified distance by returning a new dancer state.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.behind-Tuple{DancerState, DancerState}","page":"Home","title":"SquareDanceReasoning.behind","text":"behind(focus::DancerState, other::DancerState)::Bool\n\nreturns true if other is behind focus. \n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.bump_out-Tuple{Bounds, Any}","page":"Home","title":"SquareDanceReasoning.bump_out","text":"bump_out(bounds::Bounds, amount)\n\nReturns a new Bounds object that is expanded at each edge by amount.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.bump_out-Tuple{Bounds}","page":"Home","title":"SquareDanceReasoning.bump_out","text":"bump_out(bounds::Bounds)\n\nReturns a new Bounds object that is expanded by COUPLE_DISTANCE / 2 on each edge so that instead of encompassing the centers of each Dancer it encompasses whole dancers.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.can_roll-Tuple{DancerState}","page":"Home","title":"SquareDanceReasoning.can_roll","text":"can_roll(ds::DancerState)\n\nDetermine whether the modifier \"and roll\" can be applied to the DancerState.  If the dancer can roll then can_roll returns a non-zero rotation value.\n\nThis is not useful for \"and roll as if you could\".\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.canonicalize-Tuple{Any}","page":"Home","title":"SquareDanceReasoning.canonicalize","text":"canonicalize(direction)\n\ncanonicalizes the direction to be between 0.0 and 1.0.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.center-Tuple{Any}","page":"Home","title":"SquareDanceReasoning.center","text":"center(dss)\n\nreturns the center of the specified DancerStates as a two element Vector of down and left coordinates.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.dancer_states","page":"Home","title":"SquareDanceReasoning.dancer_states","text":"dancer_states(formation)::Vector{DancerState}\n\nReturns a list of the DancerStates in the formation, in no particular order.\n\n\n\n\n\n","category":"function"},{"location":"index.html#SquareDanceReasoning.dancer_timelines-Tuple{Any}","page":"Home","title":"SquareDanceReasoning.dancer_timelines","text":"dancer_timelines(kb)::Dict{Dancer, Vector{DancerState}}\n\nreturns a dictionary, keyed by Dancer, whose values are the DancerStates associated with that dancer.  Those DancerStates are sorted by time.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.direction-Tuple{DancerState, DancerState}","page":"Home","title":"SquareDanceReasoning.direction","text":"direction(focus::DancerState, other::DancerState)\n\nreturns the direction that other is from the point of view of focus.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.direction_equal-Tuple{Any, Any}","page":"Home","title":"SquareDanceReasoning.direction_equal","text":"direction_equal(direction1, direction2)::Bool =\n\nreturns true if direction1 and direction2 are roughly equal.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.distance-Tuple{Any, Any}","page":"Home","title":"SquareDanceReasoning.distance","text":"distance(p1, p2)\n\nreturns the distance between the two points represented by vectors.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.elt-Tuple{Function, AbstractString, Vararg{Any}}","page":"Home","title":"SquareDanceReasoning.elt","text":"elt(f, tagname::AbstractString, things...)\nelt(tagname::AbstractString, things...)\n\nReturn an XML element.  f is called with a single argument: either an XML.AbstractXMLNode or a Pair describing an XML attribute to be added to the resulting element.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.expand-Tuple{Bounds, Any}","page":"Home","title":"SquareDanceReasoning.expand","text":"expand(bounds::Bounds, dancer_states)::Bounds\n\nbounds is modified to encompass the additional DancerStates.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.expand-Tuple{TimeBounds, DancerState}","page":"Home","title":"SquareDanceReasoning.expand","text":"expand(tb::TimeBounds, ds::DancerState)::TimeBounds\n\nexpands tb to encompass the time of the specified DancerStates.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.fixed-Tuple{Real}","page":"Home","title":"SquareDanceReasoning.fixed","text":"fixed(x)\n\ntruncates ludicrously small floating point numbers.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.forward-Tuple{DancerState, Any, Any}","page":"Home","title":"SquareDanceReasoning.forward","text":"forward(ds::DancerState, distance, time_delta)::DancerState\n\nMove the Dancer identified by ds forward (based on ds.direction) the specified distance by returning a new dancer state.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.handedness","page":"Home","title":"SquareDanceReasoning.handedness","text":"handedness(formation)\n\nreturns the handedness of a square dance formation: one of RightHanded(), LeftHanded() or NoHandedness()\n\n\n\n\n\n","category":"function"},{"location":"index.html#SquareDanceReasoning.in_bounds-Tuple{Bounds, DancerState}","page":"Home","title":"SquareDanceReasoning.in_bounds","text":"in_bounds(bounds::Bounds, ds::DancerState)::Bool\n\nReturns true if the specified DancerState it located within bounds.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.in_front_of-Tuple{DancerState, DancerState}","page":"Home","title":"SquareDanceReasoning.in_front_of","text":"in_front_of(focus::DancerState, other::DancerState)::Bool\n\nreturns true if other is in front of focus. \n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.is_original_head-Tuple{Dancer}","page":"Home","title":"SquareDanceReasoning.is_original_head","text":"is_original_head(::Dancer)::Bool\n\nreturns true if the dancer was originally in a head position.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.is_original_side-Tuple{Dancer}","page":"Home","title":"SquareDanceReasoning.is_original_side","text":"is_original_side(::Dancer)::Bool\n\nreturns true if the dancer was originally in a side position.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.left_of-Tuple{DancerState, DancerState}","page":"Home","title":"SquareDanceReasoning.left_of","text":"left_of(focus::DancerState, other::DancerState)::Bool\n\nreturns true if other is to the left of focus. \n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.leftward-Tuple{DancerState, Any, Any}","page":"Home","title":"SquareDanceReasoning.leftward","text":"leftward(ds::DancerState, distance, time_delta)::DancerState\n\nMove the Dancer identified by ds to the left (based on ds.direction) to the right the specified distance by returning a new dancer state.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.make_square-Tuple{Int64}","page":"Home","title":"SquareDanceReasoning.make_square","text":"make_square(number_of_couples::Int)::SDSquare\n\nReturns an SDSquare with the specified number of couples.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.near-Tuple{DancerState, DancerState}","page":"Home","title":"SquareDanceReasoning.near","text":"near(::DancerState, ::DancerState)\n\nreturns true if the two DancerStates are for different dancers and are close enough together (within DANCERNEARDISTANCE).\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.opposite-Tuple{Any}","page":"Home","title":"SquareDanceReasoning.opposite","text":"opposite(direction)\n\nreturns the direction opposite to the given one.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.opposite-Tuple{Guy}","page":"Home","title":"SquareDanceReasoning.opposite","text":"opposite(::Gender)::Gender\n\nReturns the opposite Gender.  Unspecified() is its own opposite.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.other_dancers-Tuple{SquareDanceReasoning.SDSquare, Any}","page":"Home","title":"SquareDanceReasoning.other_dancers","text":"other_dancers(square::SDSquare, dancers)\n\nReturns the dancers from square that are not listed in the dancers argument.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.percentage-Tuple{TimeBounds, Any}","page":"Home","title":"SquareDanceReasoning.percentage","text":"percentage(tb::TimeBounds, t)\n\nreturn where t falls within tb as a percentage. For t == tb.min the result would be 0. For t == tb.max the result would be 100.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.quarter_left-Tuple{Any}","page":"Home","title":"SquareDanceReasoning.quarter_left","text":"quarter_left(direction)\n\nreturns the direction that's a quarter turn left from the given direction.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.quarter_right-Tuple{Any}","page":"Home","title":"SquareDanceReasoning.quarter_right","text":"quarter_right(direction)\n\nreturns the direction that's a quarter turn right from the given direction.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.revolve-Tuple{DancerState, Any, Any, Any}","page":"Home","title":"SquareDanceReasoning.revolve","text":"revolve(ds::DancerState, center, new_direction, time_delta)::DancerState\n\nRevolves the Dancer identified by ds around center (a two element Vector of down and leftcoordinates) until theDancer's new facing direction isnewdirection.  A newDancerState is returned.  `timedelta` is the duration of the revolution operation.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.right_of-Tuple{DancerState, DancerState}","page":"Home","title":"SquareDanceReasoning.right_of","text":"right_of(focus::DancerState, other::DancerState)::Bool\n\nreturns true if other is to the right of focus. \n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.rightward-Tuple{DancerState, Any, Any}","page":"Home","title":"SquareDanceReasoning.rightward","text":"rightward(ds::DancerState, distance, time_delta)::DancerState\n\nMove the Dancer identified by ds to the right (based on ds.direction) to the right the specified distance by returning a new dancer state.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.rotate-Tuple{DancerState, Any, Any}","page":"Home","title":"SquareDanceReasoning.rotate","text":"rotate(ds::DancerState, rotation, time_delta)::DancerState\n\nRotates the dancer idntified by the DancerState in place by rotation.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.square_up-Tuple{Vector{Dancer}}","page":"Home","title":"SquareDanceReasoning.square_up","text":"square_up(dancers; initial_time = 0)\n\nreturns a list of DancerStates for the initial squared set.\n\n\n\n\n\n","category":"method"},{"location":"index.html#SquareDanceReasoning.synchronize-Tuple{Rete.ReteRootNode}","page":"Home","title":"SquareDanceReasoning.synchronize","text":"synchronize(root::ReteRootNode)\n\nPosts a Synchronized fact to the knowledge base corresponding to the latest time among all DancerStates in the knowledge base.\n\nFor and DancerSTate that is behind that time, a new DancerState is asserted for the latest time.\n\nIt is recommended that synchronize should be called after every call or each part of a call.\n\n\n\n\n\n","category":"method"},{"location":"rule_hierarchy.html#Hierarchy-of-Knowledge-Base-Rules","page":"Rule Hierarchy","title":"Hierarchy of Knowledge Base Rules","text":"","category":"section"},{"location":"rule_hierarchy.html","page":"Rule Hierarchy","title":"Rule Hierarchy","text":"These are the knowledge base rules we use:","category":"page"},{"location":"rule_hierarchy.html","page":"Rule Hierarchy","title":"Rule Hierarchy","text":"Rule\nSquareDanceRule\nCollisionRule\nOriginalPartnerRule\nSquareDanceFormationRule\nColumnOfFourRule\nLineOfFourRule\nTwoDancerFormationsRule\nTwoFacedLineRule\nWaveOfEightRule\nWaveOfFourRule\nSquareHasDancers","category":"page"}]
}
