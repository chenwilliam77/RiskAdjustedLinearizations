using RiskAdjustedLinearizations, Test, LinearAlgebra
include(joinpath(dirname(@__FILE__), "..", "..", "examples", "wachter_disaster_risk", "wachter.jl"))

# Solve model
m_wachter = WachterDisasterRisk()
m = inplace_wachter_disaster_risk(m_wachter)
try
    solve!(m, m.z, m.y; verbose = :none)
catch e
    local sssout = JLD2.jldopen(joinpath(dirname(@__FILE__), "..", "..", "test", "reference", "iterative_sss_output.jld2"), "r")
    update!(m, sssout["z"], sssout["y"], sssout["Psi"])
end

# Verify impulse responses with a zero shock is the same as simulate with no shocks
horizon = 100
@testset "Calculate impulse responses for Wachter (2013)" begin

    # No shocks and start from steady state
    state1, jump1 = simulate(m, horizon)
    state2, jump2 = impulse_responses(m, horizon, 1, 0.; deviations = false)
    state3, jump3 = impulse_responses(m, horizon, 2, 0.; deviations = false)
    state4, jump4 = impulse_responses(m, horizon, 3, 0.; deviations = false)

    @test state1 ≈ state2
    @test state1 ≈ state3
    @test state1 ≈ state4
    @test jump1 ≈ jump2
    @test jump1 ≈ jump3
    @test jump1 ≈ jump4
    @test state1 ≈ repeat(m.z, 1, horizon)
    @test jump1 ≈ repeat(m.y, 1, horizon)

    # No shocks but perturb away from steady state
    state1, jump1 = simulate(m, horizon, 1.01 * m.z)
    state2, jump2 = impulse_responses(m, horizon, 1, 0., 1.01 * m.z; deviations = false)
    state3, jump3 = impulse_responses(m, horizon, 2, 0., 1.01 * m.z; deviations = false)
    state4, jump4 = impulse_responses(m, horizon, 3, 0., 1.01 * m.z; deviations = false)

    @test state1 ≈ state2
    @test state1 ≈ state3
    @test state1 ≈ state4
    @test jump1 ≈ jump2
    @test jump1 ≈ jump3
    @test jump1 ≈ jump4
    @test !(state1[:, 2] ≈ m.z)
    @test !(jump1[:, 2] ≈ m.y)

    # Now with shocks, from steady state
    shocks = zeros(3, horizon)
    shocks[2] = -3.

    state1, jump1 = impulse_responses(m, horizon, 2, -3.; deviations = false)
    state2, jump2 = impulse_responses(m, horizon, 2, -3., m.z; deviations = false)
    state3, jump3 = simulate(m, horizon, shocks)
    state4, jump4 = impulse_responses(m, horizon, 1, -3; deviations = false)

    @test state1 ≈ state2
    @test state1 ≈ state3
    @test !(state1 ≈ state4)
    @test jump1 ≈ jump2
    @test jump1 ≈ jump3
    @test !(jump1 ≈ jump4)
end
