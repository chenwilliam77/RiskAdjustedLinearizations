using RiskAdjustedLinearizations, Test
include(joinpath(dirname(@__FILE__), "..", "..", "examples", "crw", "crw.jl"))

# Solve model
m_crw = CoeurdacierReyWinant()
m = crw(m_crw)
try
    solve!(m, m.z, m.y, m.Ψ; algorithm = :homotopy, step = .5, verbose = :none)
catch e
    local sssout = JLD2.jldopen(joinpath(dirname(@__FILE__), "..", "..", "test", "reference/crw_sss.jld2"), "r")
    update!(ral, sssout["z_rss"], sssout["y_rss"], sssout["Psi_rss"])
end

# Verify impulse responses with a zero shock is the same as simulate with no shocks
horizon = 100
@testset "Calculate impulse responses for Coeurdacier et al. (2011)" begin

    # No shocks and start from steady state
    state1, jump1 = simulate(m, horizon)
    state2, jump2 = impulse_responses(m, horizon, 1, 0.; deviations = false)

    @test state1 ≈ state2
    @test jump1 ≈ jump2
    @test state1 ≈ repeat(m.z, 1, horizon)
    @test jump1 ≈ repeat(m.y, 1, horizon)

    # No shocks but perturb away from steady state
    state1, jump1 = simulate(m, horizon, 1.01 * m.z)
    state2, jump2 = impulse_responses(m, horizon, 1, 0., 1.01 * m.z; deviations = false)

    @test state1 ≈ state2
    @test jump1 ≈ jump2
    @test !(state1[:, 2] ≈ m.z)
    @test !(jump1[:, 2] ≈ m.y)

    # Now with shocks, from steady state
    shocks = zeros(2, horizon)
    shocks[1] = -3.

    state1, jump1 = impulse_responses(m, horizon, 1, -3.; deviations = false)
    state2, jump2 = impulse_responses(m, horizon, 1, -3., m.z; deviations = false)
    state3, jump3 = simulate(m, horizon, shocks)
    state4, jump4 = impulse_responses(m, horizon, 1, -3.; deviations = true)
    state5, jump5 = impulse_responses(m, horizon, 1, -3., m.z; deviations = true)

    @test state1 ≈ state2
    @test state1 ≈ state3
    @test state1 ≈ state4 .+ m.z
    @test state1 ≈ state5 .+ m.z
    @test jump1 ≈ jump2
    @test jump1 ≈ jump3
    @test jump1 ≈ jump4 .+ m.y
    @test jump1 ≈ jump5 .+ m.y
end
