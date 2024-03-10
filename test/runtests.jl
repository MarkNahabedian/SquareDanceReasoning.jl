using SquareDanceReasoning
using Test
using Rete


@testset "directions" begin
    @test opposite(DIRECTION0) == DIRECTION2
    @test opposite(DIRECTION1) == DIRECTION3
    @test quarter_left(DIRECTION0) == DIRECTION1
    @test quarter_right(DIRECTION0) == DIRECTION3
    @test canonicalize(5 * DIRECTION1) == DIRECTION1
end

@testset "gender" begin
    @test Guy() == Guy()
    @test Gal() == Gal()
    @test Unspecified() != Unspecified()
    @test Guy() != Gal()
    @test Unspecified() != Guy()
    @test Unspecified() != Gal()
    @test Unspecified() != Unspecified()
    @test opposite(Guy()) == Gal()
    @test opposite(Gal()) == Guy()
    @test opposite(Unspecified()) isa Unspecified
    @test Unspecified() < Guy()
    @test Guy() < Gal()
end

@testset "dancers" begin
    dancers = make_dancers(4)
    @test length(dancers) == 8
    @test is_original_head(dancers[1])
    @test !is_original_side(dancers[1])
    @test !is_original_head(dancers[4])
    @test is_original_side(dancers[4])
end

@testset "square up" begin
    ds = square_up(make_dancers(4))
    @test length(ds) == 8
    @test isapprox(sum(location, ds), [0.0 0.0]; atol=0.001)
end

@testset "OriginalPartners" begin
    kb = Rete.BasicReteNode("root")
    install(kb, OriginalPartnerRule)
    op_node = ensure_IsaMemoryNode(kb, OriginalPartners)
    dancers = make_dancers(4)
    for d in dancers
        receive(kb, d)
    end
    original_partners = collecting() do c
        askc(c, op_node)
    end
    @test length(original_partners) == 4
    for op in original_partners
        @test op.guy.couple_number == op.gal.couple_number
    end
    @test Set(map(couple_number, original_partners)) == Set(1:4)
end

