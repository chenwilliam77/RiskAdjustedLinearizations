# This script actually solves the WachterDisasterRisk model with a risk-adjusted linearization
# and times the methods, if desired
using RiskAdjustedLinearizations, JLD2, LinearAlgebra, MAT, Test
include("nk_with_capital.jl")
out = JLD2.jldopen(joinpath(dirname(@__FILE__), "..", "..", "test", "reference", "nk_with_capital_output.jld2"), "r")

# Settings
autodiff              = false
algorithm             = :relaxation
euler_equation_errors = false
test_price_dispersion = false # check if price dispersion in steady state is always bounded below by 1
plot_irfs             = false

# Set up
m_nk = NKCapital() # create parameters
m = nk_capital(m_nk) # instantiate risk-adjusted linearization
autodiff_method = autodiff ? :forward : :central

# Solve!
solve!(m; algorithm = :deterministic, autodiff = autodiff_method)
@test m.z ≈ out["z_det"]
@test m.y ≈ out["y_det"]
@test m.Ψ ≈ out["Psi_det"]
z_det = copy(m.z)
y_det = copy(m.y)
Ψ_det = copy(m.Ψ)

solve!(m; algorithm = algorithm, autodiff = autodiff_method)
@test m.z ≈ out["z"]
@test m.y ≈ out["y"]
@test m.Ψ ≈ out["Psi"]

if test_price_dispersion
    π̃_ss_vec = log.(range(1 - .005, stop = 1 + .005, length = 10)) # On annualized basis, range from -2% to 2% target inflation
    det_soln = Dict()
    sss_soln = Vector{RiskAdjustedLinearization}(undef, length(π̃_ss_vec))

    for (i, π̃_ss) in enumerate(π̃_ss_vec)
        local m_nk = NKCapital(; π̃_ss = π̃_ss)
        local m = textbook_nk(m_nk)
        solve!(m; algorithm = :deterministic, verbose = :none)
        det_soln[i] = Dict()
        det_soln[i][:z] = copy(m.z)
        det_soln[i][:y] = copy(m.y)
        det_soln[i][:Ψ] = copy(m.Ψ)
        solve!(m; algorithm = algorithm, verbose = :none)
        sss_soln[i] = m
    end

    det_v = exp.([det_soln[i][:z][3] for i in 1:length(det_soln)])
    sss_v = exp.([sss_soln[i].z[3] for i in 1:length(sss_soln)])
    @test all(det_v .> 1.)
    @test all(sss_v .> 1.)
end

if euler_equation_errors
    # Load shocks. Using CRW ones b/c that model also has 2 standard normal random variables
    # shocks = JLD2.jldopen(joinpath(dirname(@__FILE__), "..", "..", "test", "reference", "nk_with_capital_shocks.jld2"), "r")["shocks"]

    # With this simple model, the Euler equation holds exactly
    @test abs(euler_equation_error(m, nk_cₜ, (a, b, c, d) -> nk_logSDFxR(a, b, c, d; β = m_nk.β, σ = m_nk.σ),
                                   nk_𝔼_quadrature, shocks, summary_statistic = x -> norm(x, Inf))) ≈ 0.
end

if plot_irfs
    # Show IRFs of interesting variables (discount rate, labor supply, productivity, and MP shocks)
end

nothing
