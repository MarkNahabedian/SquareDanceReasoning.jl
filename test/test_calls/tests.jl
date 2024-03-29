
@testset "Callerlab programs" begin
    @test isless(Basic2(), Advanced1())
    @test isless(Mainstream(), Challenge3B())
    @test !isless(Plus(), Basic1())
end

