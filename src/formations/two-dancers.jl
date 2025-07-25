
export Couple, FaceToFace, BackToBack,
    Tandem, MiniWave, RHMiniWave, LHMiniWave, _MaybeDiamondPoints
export TwoDancerFormationsRule


"""
    Couple(beau::DancerState, belle::DancerState)

Couple represents a formation of two dancers both
facing the same direction.
"""
struct Couple <: TwoDancerFormation
    beau::DancerState
    belle::DancerState
end

@resumable function(f::Couple)()
    @yield f.beau
    @yield f.belle
end

handedness(::Couple) = NoHandedness()

direction(f::Couple) = direction(f.beau)    

those_with_role(c::Couple, ::Beaus) = [ c.beau ]
those_with_role(c::Couple, ::Belles) = [ c.belle ]


"""
FaceToFace represents a formation of two dancers facing each other.
"""
struct FaceToFace <: TwoDancerFormation
    a::DancerState
    b::DancerState

    function FaceToFace(a, b)
        if a.direction < b.direction
            new(a, b)
        else
            new(b, a)
        end
    end
end

@resumable function(f::FaceToFace)()
    @yield f.a
    @yield f.b
end

handedness(::FaceToFace) = NoHandedness()

those_with_role(c::FaceToFace, ::Trailers) = [ c.a, c.b ]


"""
BackToBack represents a formation of two dancers with their backs
facing each other.
"""
struct BackToBack <: TwoDancerFormation
    a::DancerState
    b::DancerState

    function BackToBack(a, b)
        if a.direction < b.direction
            new(a, b)
        else
            new(b, a)
        end
    end
end

@resumable function(f::BackToBack)()
    @yield f.a
    @yield f.b
end

handedness(::BackToBack) = NoHandedness()

those_with_role(c::BackToBack, ::Leaders) = [ c.a, c.b ]


"""
    Tandem(leaderLLDancerState, trailer::DancerState)

Tandem repreents a formation of two dancers where the `trailer`
is facing the back of the `leader`.
"""
struct Tandem <: TwoDancerFormation
    leader::DancerState
    trailer::DancerState
end

@resumable function(f::Tandem)()
    @yield f.leader
    @yield f.trailer
end

handedness(::Tandem) = NoHandedness()

direction(f::Tandem) = direction(f.leader)

those_with_role(c::Tandem, ::Leaders) = [ c.leader ]
those_with_role(c::Tandem, ::Trailers) = [ c.trailer ]


"""
MiniWave is the abstract supertype for all two dancer waves.
"""
abstract type MiniWave <: TwoDancerFormation end

@resumable function(f::MiniWave)()
    @yield f.a
    @yield f.b
end


"""
RHMiniWave represents a right handed wave of two dancers.
"""
struct RHMiniWave <: MiniWave
    a::DancerState
    b::DancerState

    function RHMiniWave(a, b)
        if a.direction < b.direction
            new(a, b)
        else
            new(b, a)
        end
    end
end

handedness(::RHMiniWave) = RightHanded()

those_with_role(c::RHMiniWave, ::Beaus) = [ c.a, c.b ]


"""
LHMiniWave represents a left handed wave of two dancers.
"""
struct LHMiniWave <: MiniWave
    a::DancerState
    b::DancerState

    function LHMiniWave(a, b)
        if a.direction < b.direction
            new(a, b)
        else
            new(b, a)
        end
    end
end

handedness(::LHMiniWave) = LeftHanded()

those_with_role(c::LHMiniWave, ::Belles) = [ c.a, c.b ]


"""
_MaybeDiamondPoints is like MiniWave, but with the dancers further
apart.  _MaybeDiamondPoints allows encroaching dancers.  It is used to
help recognize Diamonds.
"""
struct _MaybeDiamondPoints <: TwoDancerFormation
    a::DancerState
    b::DancerState
end

@resumable function(f::_MaybeDiamondPoints)()
    @yield f.a
    @yield f.b
end



@rule SquareDanceFormationRule.TwoDancerFormationsRule(kb::SDRKnowledgeBase,
                                                       sq::AllPresent,
                                                       ds1::DancerState,
                                                       ds2::DancerState,
                                                       ::Couple,
                                                       ::FaceToFace,
                                                       ::BackToBack,
                                                       ::Tandem,
                                                       ::RHMiniWave,
                                                       ::LHMiniWave,
                                                       ::_MaybeDiamondPoints,
                                                       ::FormationContainedIn) begin
    RULE_DECLARATIONS(FORWARD_TRIGGERS(sq))
    # Not the same dancer:
    @rejectif ds1.dancer == ds2.dancer
    # Contemporary:
    # WHAT ABOUT THE CASE WHERE ds1.time == ds1.previous.time?  We
    # trust that the call engine only includes the newest DancerState
    # for a given Dancer.
    @continueif ds1.time == ds2.time
    # In the same square:
    @continueif ds1 in sq.expected
    @continueif ds2 in sq.expected
    # Rather than using near, make sure there are no other dancers
    # between these two.  We need to relax this for diamond points though.
    encroacher =  encroached_on([ds1, ds2], kb)
    # We must put all of the tests within the predicate of each
    # conditional clause rather than using @rejectif or @continueif in
    # the body because we want all branches of the conditional tree to
    # be considered.  If we need more logging, we can assert an ad-hoc
    # fact for each branch of the conditional and then have a rulle
    # for each such fact.  Combinatorics should not be a problem since
    # each rule will on;y take one fact as input.
    if direction(ds1) == direction(ds2) && encroacher isa Nothing
        # Couple or Tandem?
        if right_of(ds1, ds2) && left_of(ds2, ds1)
            let
                cpl = Couple(ds1, ds2)
                emit(cpl)
                emit(FormationContainedIn(ds1, cpl))
                emit(FormationContainedIn(ds2, cpl))
            end
            return
        end
        if in_front_of(ds1, ds2) && behind(ds2, ds1)
            let
                tdm = Tandem(ds2, ds1)
                emit(tdm)
                emit(FormationContainedIn(ds1, tdm))
                emit(FormationContainedIn(ds2, tdm))
            end
            return
        end
    elseif (direction(ds1) == opposite(direction(ds2))
            && encroacher isa Nothing
            && direction(ds2) < direction(ds1))
        # FaceToFace, BackToBack or MiniWave We break symetry using
        # dancer facing direction instead of dancer order.
        if in_front_of(ds1, ds2) && in_front_of(ds2, ds1)
            let
                ftf = FaceToFace(ds1, ds2)
                emit(ftf)
                emit(FormationContainedIn(ds1, ftf))
                emit(FormationContainedIn(ds2, ftf))
            end
            return
        end
        if behind(ds1, ds2) && behind(ds2, ds1)
            let
                btb = BackToBack(ds1, ds2)
                emit(btb)
                emit(FormationContainedIn(ds1, btb))
                emit(FormationContainedIn(ds2, btb))
            end
            return
        end
        if right_of(ds1, ds2) && right_of(ds2, ds1)
            let
                mw = RHMiniWave(ds1, ds2)
                emit(mw)
                emit(FormationContainedIn(ds1, mw))
                emit(FormationContainedIn(ds2, mw))
            end
            return
        end
        if left_of(ds1, ds2) && left_of(ds2, ds1)
            let
                mw = LHMiniWave(ds1, ds2)
                emit(mw)
                emit(FormationContainedIn(ds1, mw))
                emit(FormationContainedIn(ds2, mw))
            end
            return
        end
    elseif ((right_of(ds1, ds2) && left_of(ds2, ds1)
             || right_of(ds1, ds2) && right_of(ds2, ds1)
             || left_of(ds1, ds2) && left_of(ds2, ds1)
             || left_of(ds1, ds2) && right_of(ds2, ds1))
            && (2 * COUPLE_DISTANCE <= distance(ds1, ds2) < 4 * COUPLE_DISTANCE)
            # Since we allow for the points to have the same facing
            # direction, we need an additional way to break symetry:
            && (ds1.direction < ds2.direction
                || (ds1.direction == ds2.direction &&
                    ds1.dancer.couple_number < ds2.dancer.couple_number)))
        f = _MaybeDiamondPoints(ds1, ds2)
        emit(f)
        emit(FormationContainedIn(ds1, f))
        emit(FormationContainedIn(ds2, f))
    end
end

@doc """
    TwoDancerFormationsRule

TwoDancerFormationsRule is the rule for identifying all two dancer
formations: [`Couple`](@ref), [`FaceToFace`](@ref),
[`BackToBack`](@ref), [`Tandem`](@ref), [`RHMiniWave`](@ref), and
[`LHMiniWave`](@ref).
""" TwoDancerFormationsRule



############################################################
# playmate is used by breathe.

function playmate(ds::Dancer,
                  v::Vector{<:TwoDancerFormation})::Union{Nothing, Dancer}
    for f in v
        pm = playmate(ds, f)
        if pm != nothing
            return pm
        end
    end
    nothing
end


"""
    playmate(ds::Dancer, f::TwoDancerFormation)::Union{Nothing, Dancer}

If the `Dancer` is part of the formation then return the other
`Dancer` in the formation, otherwise return `nothing`.
"""
function playmate end

let
    function walk(t)
        for st in subtypes(t)
            if isconcretetype(st)
                fn = fieldnames(st)
                @assert length(fn) == 2
                eval(:(function playmate(d::Dancer, f::$st)
                           if d == f.$(fn[1]).dancer
                               f.$(fn[2]).dancer
                           elseif d == f.$(fn[2]).dancer
                               f.$(fn[1]).dancer
                           else
                               nothing
                           end
                       end))
            else
                walk(st)
            end
        end
    end
    walk(TwoDancerFormation)
end

