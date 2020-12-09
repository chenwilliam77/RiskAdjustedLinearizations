using SafeTestsets

# Start Test Script

@time begin
    @time @safetestset "Utilities" begin
        include("util.jl")
    end

    @time @safetestset "Risk-Adjusted Linearization" begin
        include("risk_adjusted_linearization/constructors.jl")
    end

    @time @safetestset "Numerical algorithms" begin
        include("numerical_algorithms/blanchard_kahn.jl")
        include("numerical_algorithms/compute_psi.jl")
        for i in 1:5
            try
                include("numerical_algorithms/deterministic.jl")
                include("numerical_algorithms/relaxation.jl")
                include("numerical_algorithms/homotopy.jl")
                include("numerical_algorithms/solve.jl")
                break
            catch e
            end
        end
    end

    @time @safetestset "Examples" begin
        for i in 1:5
            try
                include(joinpath(dirname(@__FILE__), "..", "examples", "rbc_cc", "example_rbc_cc.jl"))
                include(joinpath(dirname(@__FILE__), "..", "examples", "wachter_disaster_risk", "example_wachter.jl"))
                include(joinpath(dirname(@__FILE__), "..", "examples", "crw", "example_crw.jl")) # This example tests case of jump-dependent Σ and Λ
                include(joinpath(dirname(@__FILE__), "..", "examples", "textbook_nk", "example_textbook_nk.jl"))
                include("test_rbc_cc.jl")
                break
            catch e
            end
        end
    end

    @time @safetestset "Simulations, Impulse Responses, and Simulation-Based Diagnostics" begin
        for i in 1:5
            try
                include("simulation/simulate_rbc_cc.jl")
                include("simulation/simulate_wachter_disaster_risk.jl")
                include("simulation/simulate_crw.jl")
                include("simulation/impulse_responses_rbc_cc.jl")
                include("simulation/impulse_responses_wachter_disaster_risk.jl")
                include("simulation/impulse_responses_crw.jl")
                include("simulation/gausshermite_expectation.jl")
                include("simulation/euler_equation_error.jl")
                break
            catch e
            end
        end
    end
end
