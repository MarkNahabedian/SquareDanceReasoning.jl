
@testset "every role has an obverse whose obverse is the role" begin
    for roletype in subtypes(Role)
        if roletype == ObverseRole
            continue
        end
        fnc = length(fieldnames(roletype))
        if fnc == 0
            role = roletype()
            @test role == obverse(obverse(role))
        elseif fnc == 1
            role = roletype(DancerState[])
            @test role == obverse(obverse(role))
        else
            error("$roletype has an untestable number of fields")
        end
    end
end
