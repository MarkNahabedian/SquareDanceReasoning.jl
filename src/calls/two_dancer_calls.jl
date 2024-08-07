export StepThru, StepToAWave, PassThru, PullBy, Dosados, Hinge

#= Some two dancer calls to implement:

HalfSashay, RollawayWithAHalfSashay
Primitive FaceYourPartner
primitive FaceYourCorner
SlideThru
StarThru expands to SlideThru
PartnerTrade
Primitive FinishPartnerTrade
Run
BoxTheGnat espands to StepToAWave, revolve around the your center -1/4, AndRoll
=#


"""
    StepThru(; role=Everyone())

CallerLab Basic 1 square dance call that goes from MiniWave to
BackToBack.
"""
@with_kw struct StepThru <: SquareDanceCall
    role::Role = Everyone()
end

# Should we rename PassBy to Dosados!2?

description(c::StepThru) = "$(c.role) pass by from MiniWave to BackToBack"

can_do_from(::StepThru, ::MiniWave) = 1

function perform(c::StepThru, mw::MiniWave, kb::ReteRootNode)
    pass_by(mw, 1)
end


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

"""
@with_kw struct PullBy <: SquareDanceCall
    role::Role = Everyone()
    handedness::Union{RightHanded, LeftHanded} = RightHanded()
end

can_do_from(::PullBy, ::FaceToFace) = 1

# Can't do this yet because expand_parts doesn't know the formation.
# I suppose we could make _StepToAWave a no-op from MiniWave.
# MAybe expand_parts should get a single CanDoCall rather than a vector?
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


"""
    Hinge(; role=Everyone(), tile=2)

CallerLab Mainstream call.
"""
@with_kw struct Hinge <: SquareDanceCall
    role::Role = Everyone()
    # Taminations says timing is 2, but for Trade from a MiniWave the
    # total timing is 3 rather than 4.
    time::Int = 2
end

can_do_from(::Hinge, ::MiniWave) = 1
can_do_from(::Hinge, ::Couple) = 1

function perform(c::Hinge, mw::MiniWave, kb::ReteRootNode)
    c = center(mw)
    rot = begin
        if handedness(mw) isa RightHanded
            - 1//4
        elseif handedness(mw) isa LeftHanded
            1//4
        end
    end
    r = typeof(mw)(revolve(mw.a, c, mw.a.direction + rot, 2),
                   revolve(mw.b, c, mw.b.direction + rot, 2))
    r
end

function perform(c::Hinge, couple::Couple, kb::ReteRootNode)
    # Taminations says timing is 2.
    c = center(couple)
    cpl = RHMiniWave(let
                         dir = couple.beau.direction - 1//4
                         (d, l) = revolve(location(couple.beau),
                                          c, -1//4,
                                          COUPLE_DISTANCE)
                         DancerState(couple.beau, couple.beau.time + 2,
                                     couple.beau.direction - 1//4,
                                     d, l)
                     end,
                     DancerState(couple.belle, couple.belle.time + 2,
                                 couple.belle.direction + 1//4,
                                 c...))
    cpl
end

