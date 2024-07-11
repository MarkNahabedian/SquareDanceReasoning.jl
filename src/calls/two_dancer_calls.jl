export StepToAWave, PassThru

#= SOme two daner calls to implement:

HalfSashay, RollawayWithAHalfSashay
Primitive FaceYourPartner
primitive FaceYourCorner
PartnerHinge from couple or miniwave
SlideThru
StarThru expands to SlideThru
PartnerTrade
Primitive FinishPartnerTrade
Dosados expands to StepToAWave, _PassBy, Dosados!3,  UnStepToAWave
Dosados!3. handedness
Primitive UnStepToAWave
Run
BoxTheGnat espands to StepToAWave, revolve around the your center -1/4, AndRoll
=#


"""
    PassThru()

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

