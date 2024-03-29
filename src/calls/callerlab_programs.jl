
abstract type CallerLabProgram end

let
    programs = :(Basic1,
                 Basic2,
                 Mainstream,
                 Plus,
                 Advanced1,
                 Advanced2,
                 Challenge1,
                 Challenge2,
                 Challenge3A,
                 Challenge3B,
                 Challenge4).args
    map(programs) do program
        eval(:(struct $program <: CallerLabProgram end))
    end
    global const CALLERLAB_PROGRAM_ORDERING =
        map(eval, programs)
end

function Base.isless(a::CallerLabProgram,
                     b::CallerLabProgram)::Bool
    ordinal(x) = findfirst(y -> y == typeof(x),
                           CALLERLAB_PROGRAM_ORDERING)
    ordinal(a) < ordinal(b)
end


# Whether a call can be applied to a particular formation is
# restricted by Callerlab program level.  How do we represent and
# implement those restrictions?

