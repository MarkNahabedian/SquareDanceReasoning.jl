export StepToAWave, PassThru, Dosados

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
    PassThru(; role=Everyone(), handedness=RightHanded())

CallerLab Basic 1 call.
"""
@with_kw struct PassThru <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()
end

can_do_from(::PassThru, ::FaceToFace) = 1

expand_parts(c::PassThru) = [
    _StepToAWave(role = c.role,
                 handedness = c.handedness),
    _PassBy()
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

expand_parts(c::Dosados) = [
    _StepToAWave(; role = c.role,
                 handedness = c.handedness),
    _PassBy(),
    _BackToAWave(; handedness = opposite(c.handedness)),
    _UnStepToAWave()
]
