
@testset "test forward motion" begin
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION1, 1, 1)
        ds1 = forward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down == ds1.down
        @test ds0.left + 2 == ds1.left
        @test can_roll(ds1) == 0
    end
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION2, 1, 1)
        ds1 = forward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down - 2 == ds1.down
        @test ds0.left == ds1.left
        @test can_roll(ds1) == 0
    end
end

@testset "test backward motion" begin
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION1, 1, 1)
        ds1 = backward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down == ds1.down
        @test ds0.left - 2 == ds1.left
        @test can_roll(ds1) == 0
    end
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION2, 1, 1)
        ds1 = backward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down + 2 == ds1.down
        @test ds0.left == ds1.left
        @test can_roll(ds1) == 0
    end
end

@testset "test leftward motion" begin
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION1, 1, 1)
        ds1 = leftward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down - 2 == ds1.down
        @test ds0.left == ds1.left
        @test can_roll(ds1) == 0
    end
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION2, 1, 1)
        ds1 = leftward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down == ds1.down
        @test ds0.left - 2 == ds1.left
        @test can_roll(ds1) == 0
    end
end

@testset "test rightward motion" begin
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION1, 1, 1)
        ds1 = rightward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down + 2 == ds1.down
        @test ds0.left == ds1.left
        @test can_roll(ds1) == 0
    end
    let
        ds0 = DancerState(Dancer(1, Unspecified()),
                         0, DIRECTION2, 1, 1)
        ds1 = rightward(ds0, 2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds0.direction == ds1.direction
        @test ds0.down == ds1.down
        @test ds0.left + 2 == ds1.left
        @test can_roll(ds1) == 0
    end
end

@testset "test revolve" begin
    let
        # turn in place:
        ds0 = DancerState(Dancer(1, Unspecified()),
                          0, DIRECTION1, 1, 1)
        ds1 = revolve(ds0, [1, 1], DIRECTION2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds1.direction == DIRECTION2
        @test ds1.down == ds0.down
        @test ds1.left == ds0.left
        @test can_roll(ds1) == DIRECTION2 - DIRECTION1
    end
    let
        # Revolve around a another point:
        ds0 = DancerState(Dancer(1, Unspecified()),
                          0, DIRECTION1, 1, 0)
        ds1 = revolve(ds0, [0, 0], DIRECTION2, 1)
        @test ds0.dancer == ds1.dancer
        @test ds0.time + 1 == ds1.time
        @test ds1.direction == DIRECTION2
        @test isapprox(ds1.down, 0; atol=0.0001)
        @test isapprox(ds1.left, 1; atol=0.0001)
        @test can_roll(ds1) == DIRECTION2 - DIRECTION1
    end
end

@testset "test animate" begin
    ds = DancerState(Dancer(1, Unspecified()),
                     0, 0, 0, -1)
    center = [0, 0]
    for d in (1:32)//32
        ds = revolve(ds, center, d, 0.5)
    end
    animate(joinpath(@__DIR__, "revolve-singe-dancer.svg"),
            [ds], 60)
end

@testset "test synchronize" begin
    kb = ReteRootNode("root")
    # Don't install all of the rules until we can control the forward
    # triggers.
    install(kb, SquareHasDancers)
    synced = ensure_memory_node(kb, Synchronized)
    ensure_memory_node(kb, Dancer)
    dancer_states = ensure_memory_node(kb, DancerState)
    latest_sync = BackwardExtremumNode(>,
                                       s -> s.time,
                                       "Latest Synchronized")
    connect(synced, latest_sync)
    dancers = [ Dancer(1, Unspecified()) ]
    receive(kb, dancers[1])
    receive(kb, DancerState(dancers[1], 0, DIRECTION0, 1, 1))
    synchronize(kb)
    function get_latest_sync()
        syncs = collecting() do c
            askc(c, latest_sync)
        end
        @test length(syncs) == 1
        syncs[1]
    end
    function dss_at(time)
        dss = collecting() do c
            askc(kb, DancerState) do ds
                if ds.time == time
                    c(ds)
                end
            end
        end
        @test length(dss) == length(dancers)
        dss
    end
    @test get_latest_sync().time == 0
    f(ds) = forward(ds, 1, 1)
    b(ds) = backward(ds, 1, 1)
    l(ds) = leftward(ds, 1, 1)
    r(ds) = rightward(ds, 1, 1)
    rot(ds) = rotate(ds, 1//4, 1)
    for (i, step) in enumerate([
        # spin in place
        (motion = rot, new_dir = DIRECTION1, new_down = 1, new_left = 1),
        (motion = rot, new_dir = DIRECTION2, new_down = 1, new_left = 1),
        (motion = rot, new_dir = DIRECTION3, new_down = 1, new_left = 1),
        (motion = rot, new_dir = DIRECTION0, new_down = 1, new_left = 1),
        # box without changiing facing direction
        (motion = f,   new_dir = DIRECTION0, new_down = 2, new_left = 1),
        (motion = l,   new_dir = DIRECTION0, new_down = 2, new_left = 2),
        (motion = b,   new_dir = DIRECTION0, new_down = 1, new_left = 2),
        (motion = r,   new_dir = DIRECTION0, new_down = 1, new_left = 1),
        # box, rotating 1/4 left:
        (motion = rot, new_dir = DIRECTION1, new_down = 1, new_left = 1),
        (motion = f,   new_dir = DIRECTION1, new_down = 1, new_left = 2),
        (motion = rot, new_dir = DIRECTION2, new_down = 1, new_left = 2),
        (motion = f,   new_dir = DIRECTION2, new_down = 0, new_left = 2),
        (motion = rot, new_dir = DIRECTION3, new_down = 0, new_left = 2),
        (motion = f,   new_dir = DIRECTION3, new_down = 0, new_left = 1),
        (motion = rot, new_dir = DIRECTION0, new_down = 0, new_left = 1),
        (motion = f,   new_dir = DIRECTION0, new_down = 1, new_left = 1)
        ])
        receive(kb, step.motion(dss_at(get_latest_sync().time)[1]))
        synchronize(kb)
        ds = dss_at(get_latest_sync().time)[1]
        @test ds.direction == step.new_dir
        @test isapprox(ds.down, step.new_down; atol=0.0001)
        @test isapprox(ds.left, step.new_left; atol=0.0001)
    end
    # Write an animation
    latest = latest_dancer_states(kb)
    animate(joinpath(@__DIR__, "facing-0-box.svg"),
            latest, 60)
end

@testset "test synchronize 2" begin
    kb = ReteRootNode("root")
    # Don't install all of the rules until we can control the forward
    # triggers.
    install(kb, SquareHasDancers)
    synced = ensure_memory_node(kb, Synchronized)
    dancer_states = ensure_memory_node(kb, DancerState)
    latest_sync = BackwardExtremumNode(>,
                                       s -> s.time,
                                       "Latest Synchronized")
    connect(synced, latest_sync)
    function get_latest_sync()
        syncs = collecting() do c
            askc(c, latest_sync)
        end
        @test length(syncs) == 1
        syncs[1]
    end
    function dss_at(time)
        dss = collecting() do c
            askc(kb, DancerState) do ds
                if ds.time == time
                    c(ds)
                end
            end
        end
        if length(dss) != 8
            println(dss)
        end
        @assert length(dss) == 8
        dss
    end
    square = make_square(4)
    receive(kb, square)
    dss = square_up(square)
    for ds in dss
        receive(kb, ds)
    end
    @test length(dancer_states.memory) == 8
    synchronize(kb)
    @test get_latest_sync().time == 0
    # Quarter right:
    map(dss) do ds
        receive(kb, rotate(ds, quarter_right(0), 1))
    end
    dss = dss_at(1)
    @test length(dancer_states.memory) == 16
    synchronize(kb)
    @test get_latest_sync().time == 1
    # Single file promenade (full circle: 16 beats):
    steps = 16
    c = center(dss)
    for step in 1:steps
        # latest DancerStates:
        dss = dss_at(get_latest_sync().time)
        @assert length(dss) == 8
        for ds in dss
            receive(kb, revolve(ds, c,
                                ds.direction + FULL_CIRCLE / steps,
                                1))
        end
        synchronize(kb)
        @test get_latest_sync().time == step + 1
    end
    @test sort(collecting() do c
                   askc(synced) do s
                       c(s.time)
                   end
               end) == 0:17
    # Write an animation
    latest = latest_dancer_states(kb)
    animate(joinpath(@__DIR__, "single_file_prropmenade.svg"),
            latest, 60)
end

