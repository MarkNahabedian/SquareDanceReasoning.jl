# This file contains primitive "building block" calls that are used to
# help define other calls.  By convention, their names begin with '_'
# so that they won't conflict with the names of other calls, whether
# already or eventually to be defined.

export _Rest, _GenderedRoll, StepToAWave, _UnStepToAWave,
    _BackToAWave
export _FaceOriginalPartner, _FaceOriginalCorner
export _EndAt


"""
    _Rest(; role=Everyone(), time)

Primitive square dance call causing dancers to rest in place for the
specified time.

Timing: as specified in the parameter.
"""
@with_kw_noshow struct _Rest <: SquareDanceCall
    role::Role = Everyone()
    # Allow timing to be specified since this primitive might be used
    # in other calls, like SquareThru
    time::Int
end

as_text(c::_Rest) = "$(as_text(c.role)) rest for $(c.time) ticks."

can_do_from(::_Rest, ::DancerState) = 1

function perform(c::_Rest, ds::DancerState, kb::SDRKnowledgeBase)
    DancerState(ds, ds.time + c.time, ds.direction,
                ds.down, ds.left)
end


"""
    _FaceOriginalPartner(; role=Everyone(), time=0)

Primitive square dance call which causes a dancer to face its
original partner.

Timing: as specified in the parameter.
"""
@with_kw_noshow struct _FaceOriginalPartner <: SquareDanceCall
    role::Role = Everyone()
    # This call should take negligible time as it can be performed as
    # part of the previous action, but there's a test in the call
    # engine that a call has elapsed time.  We eventually need a
    # workaround, perhaps a way of the call engine to ask the call for
    # its duration.
    time::Int = 1
end

as_text(c::_FaceOriginalPartner) =
    "$(as_text(c.role)) face your original partner."

can_do_from(::_FaceOriginalPartner, ::DancerState) = 1

function perform(c::_FaceOriginalPartner, ds::DancerState, kb::SDRKnowledgeBase)
    square = let
        found = nothing
        askc(kb, SDSquare) do sdsquare
            if ds.dancer in sdsquare
                if found == nothing
                    found = sdsquare
                else
                    error("$(ds.dancer) in more than one SDSquare")
                end
            end
        end
        found
    end
    partner = nothing
    askc(kb, DancerState) do ds1
        if ((ds1.dancer in square) &&
            (ds1.dancer.couple_number == ds.dancer.couple_number) &&
            (ds1.dancer.gender == opposite(ds.dancer.gender)))
            if partner == nothing
                partner = ds1
            else
                error("more than one partner for $ds")
            end
        end
    end
    DancerState(ds, ds.time + c.time,
                direction(ds, partner),
                ds.down, ds.left)
end


"""
    _FaceOriginalCorner(; role=Everyone(), time=0)

Primitive square dance call which causes a dancer to face its
original corner.

Timing: as specified in the parameter.
"""
@with_kw_noshow struct _FaceOriginalCorner <: SquareDanceCall
    role::Role = Everyone()
    time::Int = 1
end

as_text(c::_FaceOriginalCorner) =
    "$(as_text(c.role)) face your original corner."

can_do_from(::_FaceOriginalCorner, ::DancerState) = 1

function perform(c::_FaceOriginalCorner, ds::DancerState, kb::SDRKnowledgeBase)
    square = let
        found = nothing
        askc(kb, SDSquare) do sdsquare
            if ds.dancer in sdsquare
                if found == nothing
                    found = sdsquare
                else
                    error("$(ds.dancer) in more than one SDSquare")
                end
            end
        end
        found
    end
    ncouples = length(square) / 2
    ccn = mod1(corner_couple_number(ds), ncouples)
    corner = nothing
    askc(kb, DancerState) do ds1
        if ((ds1.dancer in square) &&
            (ds1.dancer.couple_number == ccn) &&
            (ds1.dancer.gender == opposite(ds.dancer.gender)))
            if corner == nothing
                corner = ds1
            else
                error("more than one corner for $ds1")
            end
        end
    end
    DancerState(ds, ds.time + c.time,
                direction(ds, corner),
                ds.down, ds.left)
end


"""
    _GenderedRoll(; role=Everyone(), time=2)

The second part of calls like StarThru and SlideThru.  Guy turn one
quarter to the right, Gal turn one quarter to the left.

Timing: as specified in the parameter.  Defaults to 2.  CallerLab says
the timing for StarThru is 4, so thisseems reasonable.
"""
@with_kw_noshow struct _GenderedRoll <: SquareDanceCall
    role::Role = Everyone()
    time::Int = 2
end

as_text(c::_GenderedRoll) =
    "$(as_text(c.role)) Guy quarter right, Gal quarter left."

can_do_from(::_GenderedRoll, ::DancerState) = 1

function perform(c::_GenderedRoll, ds::DancerState, kb::SDRKnowledgeBase)
    # The timing of QuarterIn is 2.  Since this is combined with other
    # calls we leave the timing as a parameter.
    if ds.dancer.gender isa Guy
        rotate(ds, -1//4, c.time)
    elseif ds.dancer.gender isa Gal
        rotate(ds, 1//4, c.time)
    else
        # The call engine (do_schedule) expects all dancers affected
        # by perform to experience the passage of time.
        DancerState(ds, ds.time + c.time, ds.direction, ds.down, ds.left)
    end
end


"""
    StepToAWave(; role=Everyone(), handedness=RightHanded())

CallerLab Basic 2 square dance call that goes from FaceToFace to a
MiniWave of the specified handedness.  The first half of
[`PassThru`](@ref).

Timing: 2.

"""
@with_kw_noshow struct StepToAWave <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()
    time = 2
end

descirption(c::StepToAWave) = "$(c.role) Step To a Wave"

can_do_from(::StepToAWave, ::FaceToFace) = 1

function perform(c::StepToAWave, f::FaceToFace, kb::SDRKnowledgeBase)
    step_to_a_wave(f, c.time, c.handedness)
end


"""
    _UnStepToAWave(; role=Everyone())

Primitive square dance call that goes from a MiniWave to FaceToFace.
The first half of [`PassThru`](@ref).

Timing: 2.
Persimably should have the same timing as [`StepToAWave`](@ref)
"""
@with_kw_noshow struct _UnStepToAWave <: SquareDanceCall
    role::Role = Everyone()
    # Might we want to add
    # handedness::Union{RightHanded, LeftHanded} = RightHanded()
    # in case we need to disambiguate which MiniWave to step back
    # from>
end

descirption(c::_UnStepToAWave) = "$(c.role) Un Step To a Wave"

can_do_from(::_UnStepToAWave, ::MiniWave) = 1

function perform(c::_UnStepToAWave, f::MiniWave, kb::SDRKnowledgeBase)
    un_step_to_a_wave(f, 1)
end


"""
    _BackToAWave, handedness(; role=Everyone(), handedness=RightHanded())

Primitive square dance call that goes from BackToBack to a MiniWave of
the specified handedness.
The third quarter of [`Dosado`](@ref).

Timing: 1.

"""
@with_kw_noshow struct _BackToAWave <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()    
end

descirption(c::_BackToAWave) = "$(c.role) Backup to a Wave"

can_do_from(::_BackToAWave, ::BackToBack) = 1

function perform(c::_BackToAWave, f::BackToBack, kb::SDRKnowledgeBase)
    back_to_a_wave(f, 1, c.handedness)
end


"""
    _EndAt(f::TwoDancerFormation, timing)

Primitive square dance call that causes the dancer to end at the
starting location of the other dancer.
"""
@with_kw_noshow struct _EndAt <: SquareDanceCall
    two_dancers::TwoDancerFormation
    time::Int = 0
end

_EndAt(two_dancers) = _EndAt(; two_dancers = two_dancers)

descirption(c::_EndAt) = "_EndAt"

call_schedule_isless(c1::_EndAt, c2::SquareDanceCall) = true

can_do_from(::_EndAt, ::DancerState) = 1

restricted_to(c::_EndAt) = DesignatedDancers(map(ds -> ds.dancer, c.two_dancers()))

function perform(c::_EndAt, ds::DancerState, ::SDRKnowledgeBase)
    fdss = dancer_states(c.two_dancers)
    i = findfirst(fdss) do ds1
        ds1.dancer == ds.dancer
    end
    other = fdss[mod1(i+1, length(fdss))]
    @assert other.dancer != ds.dancer
    #=
    # The call engine has various checks that expect that time elapsed
    # between successive dancer states.  To get around those, we
    # replace the previous DancerState when the call takkes 0 time.
    if i == 1
        return DancerState(ds.previous, # c.time == 0 && ds.previous != nothing ? ds.previous : ds,
                           ds.time + c.time, ds.direction,
                           fdss[2].down, fdss[2].left)
    elseif i == 2
        return DancerState(ds.previous, # c.time == 0 && ds.previous != nothing ? ds.previous : ds,
                           ds.time + c.time, ds.direction,
                           fdss[1].down, fdss[1].left)
    end
    =#
    # Move ds to the position that other's position in c.two_dancers:
    return DancerState(ds,
                       ds.time + c.time, ds.direction,
                       other.down, other.left)
end

