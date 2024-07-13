# This file contains primitive "building block" calls that are used to
# help define other calls.  By convention, their names begin with '_'
# so that they won't conflict with the names of other calls, whether
# already or eventually to be defined.

export _Rest, _StepToAWave, _PassBy


"""
    _Rest()

Primitive square dance call causing dancers to rest in place for the
specified time.
"""
@with_kw struct _Rest <: SquareDanceCall     # primitive
    role::Role = Everyone()
    time::Int
end

description(c::_Rest) = "$(c.role) rest for $(c.time) ticks."

can_do_from(::_Rest, ::DancerState) = 1

function perform(c::_Rest, ds::DancerState, kb::ReteRootNode)
    DancerState(ds, ds.time + c.time, ds.direction,
                ds.down, ds.left)
end


"""
    _StepToAWave(handedness::Handedness)

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
    _PassBy()

Primitive square dance call that goes from MiniWave to BackToBack.
The second half of [`PassThru`](@ref).
"""
@with_kw struct _PassBy <: SquareDanceCall
    role::Role = Everyone()
end

# Should we rename PassBy to Dosados!2?

description(c::_PassBy) = "$(c.role) pass by from MiniWave to BackToBack"

can_do_from(::_PassBy, ::MiniWave) = 1

function perform(c::_PassBy, mw::MiniWave, kb::ReteRootNode)
    pass_by(mw, 1)
end

