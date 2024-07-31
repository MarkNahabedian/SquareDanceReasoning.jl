export StepToAWave, PassThru, PullBy, Dosados

#= Some two dancer calls to implement:

HalfSashay, RollawayWithAHalfSashay
Primitive FaceYourPartner
primitive FaceYourCorner
PartnerHinge from couple or miniwave
SlideThru
StarThru expands to SlideThru
PartnerTrade
Primitive FinishPartnerTrade
Run
BoxTheGnat espands to StepToAWave, revolve around the your center -1/4, AndRoll
=#


"""
    PassThru(; role=Everyone())

CallerLab Basic 1 call.

`PassThru` is only proper from `FaceToFace` or from `RHMiniWave`
(because of the "Icean Wave Rule").  For `LHMiniWave`, use
[`StepThru`](@ref).
"""
@with_kw struct PassThru <: SquareDanceCall
    role::Role = Everyone()
end

can_do_from(::PassThru, ::FaceToFace) = 1

can_do_from(::PassThru, mw::RHMiniWave) = 1

#=
TODO:
Caller lab: From a Squared Set, Heads Pass Thru is proper. It ends
with the Heads back on Squared Set spots. See Squared Set Convention.

We might not be able to implement this until expand_parts knows the
formation and initial daner locations.
=#

expand_parts(c::PassThru, options::Vector{CanDoCall}) = [
    _StepToAWave(role = c.role,
                 handedness = RightHanded()),
    StepThru()
]


"""
    PullBy(; role=Everyone(), handedness=RightHanded())

CallerLab Basic 1 call.

Since SquareDanceReasoning doesn't model hand styling, this is the
same as [`PassThru`](@ref).
"""
@with_kw struct PullBy <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()
end

can_do_from(::PullBy, ::FaceToFace) = 1

# can_do_from(c::PullBy, mw::MiniWave) =
#     (c.handedness == mw.handedness) ? 1 : 0

expand_parts(c::PullBy, options::Vector{CanDoCall}) = [
    _StepToAWave(role = c.role,
                 handedness = c.handedness),
    StepThru()
]


"""
    Dosados(; role=Everyone(), handedness=RightHanded())

CallerLab Basic1 call.
"""
@with_kw struct Dosados <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()
end

can_do_from(::Dosados, ::FaceToFace) = 1

expand_parts(c::Dosados, options::Vector{CanDoCall}) = [
    _StepToAWave(; role = c.role,
                 handedness = c.handedness),
    StepThru(),
    _BackToAWave(; handedness = opposite(c.handedness)),
    _UnStepToAWave()
]
