
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
    @test as_text(Everyone()) == "everyone"
    @test as_text(Noone()) == "noone"
    @test as_text(Guys()) == "guys"
    @test as_text(Gals()) == "gals"
    @test as_text(OriginalHeads()) == "original heads"
    @test as_text(OriginalSides()) == "original sides"
    @test as_text(CurrentHeads()) == "current heads"
    @test as_text(CurrentSides()) == "current sides"
    @test as_text(Beaus()) == "beaus"
    @test as_text(Belles()) == "belles"
    @test as_text(Centers()) == "centers"
    @test as_text(Ends()) == "ends"
    @test as_text(Leaders()) == "leaders"
    @test as_text(Trailers()) == "trailers"
    @test as_text(DiamondCenters()) == "centers of your diamonds"
    @test as_text(Points()) == "points"
    @test as_text(ObverseRole(Centers())) == "ends"
    @test as_text(CoupleNumbers([1, 3])) == "couple numbers 1, 3"
    @test as_text(DesignatedDancers([Dancer(3, Guy()),
                                     Dancer(2, Gal())])) ==
                                         "dancers gal#2, guy#3"
end

