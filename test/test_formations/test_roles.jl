
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
    @test as_text(OriginalHead()) == "OriginalHead"
    @test as_text(OriginalSide()) == "OriginalSides"
    @test as_text(CurrentHead()) == "CurrentHead"
    @test as_text(CurrentSide()) == "CurrentSide"
    @test as_text(Beau()) == "Beaus"
    @test as_text(Belle()) == "Belles"
    @test as_text(Center()) == "Centers"
    @test as_text(End()) == "Ends"
    @test as_text(Leader()) == "Leaders"
    @test as_text(Trailer()) == "Trailers"
    @test as_text(DiamondCenter()) == "Centers of your diamonds"
    @test as_text(Point()) == "Points"
    @test as_text(ObverseRole(Center())) == "Ends"
    @test as_text(CoupleNumbers([1, 3])) == "CoupleNumbers 1, 3"
    @test as_text(DesignatedDancers([Dancer(3, Guy()),
                                     Dancer(2, Gal())])) ==
                                         "Dancers Gal#2, Guy#3"
end

