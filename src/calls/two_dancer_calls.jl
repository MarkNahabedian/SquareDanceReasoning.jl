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

#=

For PassThru from facing lines of 4, expand_parts returns
_StepToAWave, _PassBy.  After _StepToAWave there are two right handed
and one left handed miniwaves. get_call_options detects the overlap
between the center LHMiniWave and the two RHMiniWaves.  How do we
exclude the center LHMiniWave from consideration.

This is also an issue for SquareThru, where we want to identify the
groups of participating dancers doing the SquareThru, possibly using
the DesignatedDancers role.

From facing lines of 4, PassThru should make a DesignatedDancers group
for each FaceToFace formation and propagate those as the role for each
part in expand_call.

What we'd have is 4 FaceToFace formations that need to
"simultaneously" do _StepToAWave and then simultaneously do _PassBy.

Another approach might be to specificallly implement PassThru for
FacingCouples and FacingLinesOfFour with higher priorities than
FaceToFace.

=#

