
@testset "every role has an obverse whose obverse is the role" begin
    function walk(roletype)
        if !isconcretetype(roletype)
            return
        end
        if roletype == ObverseRole
            return
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
    walk(Role)
end

@testset "Test as_text for Roles" begin
    @test as_text(Everyone()) == "Everyone"
    @test as_text(Noone()) == "Noone"
    @test as_text(Guys()) == "Guys"
    @test as_text(Gals()) == "Gals"
    @test as_text(OriginalHeads()) == "OriginalHeads"
    @test as_text(OriginalSides()) == "OriginalSides"
    @test as_text(CurrentHeads()) == "CurrentHeads"
    @test as_text(CurrentSides()) == "CurrentSides"
    @test as_text(Beaus()) == "Beaus"
    @test as_text(Belles()) == "Belles"
    @test as_text(Centers()) == "Centers"
    @test as_text(Ends()) == "Ends"
    @test as_text(Leaders()) == "Leaders"
    @test as_text(Trailers()) == "Trailers"
    @test as_text(DiamondCenters()) == "Centers of your diamonds"
    @test as_text(Points()) == "Points"
    @test as_text(ObverseRole(Centers())) == "Ends"
    @test as_text(CoupleNumbers([1, 3])) == "CoupleNumbers 1, 3"
    @test as_text(DesignatedDancers([Dancer(3, Guy()),
                                     Dancer(2, Gal())])) ==
                                         "Dancers Gal#2, Guy#3"
end

