# This file contains primitive "building block" calls that are used to
# help define other calls.  By convention, their names begin with '_'
# so that they won't conflict with the names of other calls, whether
# already or eventually to be defined.

export _Rest, _GenderedRoll, _StepToAWave, _UnStepToAWave,
    _BackToAWave


"""
    _Rest(; role=Everyone(), time)

Primitive square dance call causing dancers to rest in place for the
specified time.
"""
@with_kw struct _Rest <: SquareDanceCall
    role::Role = Everyone()
    # Allow timing to be specified since this primitive might be used
    # in other calls, like SquareThru
    time::Int
end

description(c::_Rest) = "$(c.role) rest for $(c.time) ticks."

can_do_from(::_Rest, ::DancerState) = 1

function perform(c::_Rest, ds::DancerState, kb::ReteRootNode)
    DancerState(ds, ds.time + c.time, ds.direction,
                ds.down, ds.left)
end


"""
    _GenderedRoll(; role=Everyone(), time=2)

The second part of calls like StarThru and SlideThru.  Guy turn one
quarter to the right, Gal turn one quarter to the left.
"""
@with_kw struct _GenderedRoll <: SquareDanceCall
    role::Role = Everyone()
    time::Int = 2
end

description(c::_GenderedRoll) = "$(c.role) Guy quarter right, Gal quarter left."

can_do_from(::_GenderedRoll, ::DancerState) = 1

function perform(c::_GenderedRoll, ds::DancerState, kb::ReteRootNode)
    # The timing of QuarterIn is 2.  Since this is combined with other
    # calls we leave the timing as a parameter.
    if ds.dancer.gender isa Guy
        rotate(ds, -1//4, c.time)
    elseif ds.dancer.gender isa Gal
        rotate(ds, 1//4, c.time)
    else
        ds
    end
end


"""
    _StepToAWave(; role=Everyone(), handedness=RightHanded())

Primitive square dance call that goes from FaceToFace to a MiniWave of
the specified handedness.  The first half of [`PassThru`](@ref).
"""
@with_kw struct _StepToAWave <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()
end

descirption(c::_StepToAWave) = "$(c.role) Step To a Wave"

can_do_from(::_StepToAWave, ::FaceToFace) = 1

function perform(c::_StepToAWave, f::FaceToFace, kb::ReteRootNode)
    step_to_a_wave(f, 1, c.handedness)
end


"""
    _UnStepToAWave(; role=Everyone())

Primitive square dance call that goes from a MiniWave to FaceToFace.
The first half of [`PassThru`](@ref).
"""
@with_kw struct _UnStepToAWave <: SquareDanceCall
    role::Role = Everyone()
end

descirption(c::_UnStepToAWave) = "$(c.role) Un Step To a Wave"

can_do_from(::_UnStepToAWave, ::MiniWave) = 1

function perform(c::_UnStepToAWave, f::MiniWave, kb::ReteRootNode)
    un_step_to_a_wave(f, 1)
end


"""
    _BackToAWave, handedness(; role=Everyone(), handedness=RightHanded())

Primitive square dance call that goes from BackToBack to a MiniWave of
the specified handedness.
The third quarter of [`Dosados`](@ref).
"""
@with_kw struct _BackToAWave <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()    
end

descirption(c::_BackToAWave) = "$(c.role) Backup to a Wave"

can_do_from(::_BackToAWave, ::BackToBack) = 1

function perform(c::_BackToAWave, f::BackToBack, kb::ReteRootNode)
    back_to_a_wave(f, 1, c.handedness)
end

