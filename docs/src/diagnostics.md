# [Diagnostics](@id diagnostics)

To assess the quality of a risk-adjusted linearization, diagnostic tests should be run. In particular,
as Lopez et al. (2018) discuss at length, whenever forward difference equations arise
(e.g. the equation for the log wealth-consumption ratio in our implementation of Wachter (2013)),
there are infinitely many ways to write the expectational equations. Assuming computational costs
do not become too significant, users should add as many expectational equations as needed
to maximize the accuracy of the risk-adjusted linearization.

The best accuracy test is comparing the risk-adjusted linearization to the true nonlinear solution,
but this test requires this solution to be available. In many cases (e.g. high dimensions),
neither analytical nor numerical methods can deliver the true
solution. To address this problem, economists have developed a variety of accuracy tests that
only involve the chosen approximation method and quadrature.

The most popular diagnostics revolve around the Euler equation. RiskAdjustedLinearizations.jl implements wrapper functions for
performing two of these Euler equation diagnostics. The first is the so-called "Euler equation errors" test proposed
by [Judd (1992)](https://www.sciencedirect.com/science/article/abs/pii/002205319290061L). The second is
the so-called "dynamic Euler equation errors" test proposed by
[Den Haan (2009)](https://www.sciencedirect.com/science/article/abs/pii/S0165188909001298).
We defer the reader to these articles for explanations of the theory behind these tests.
A good set of slides on accuracy tests are [these ones by Den Haan](http://www.wouterdenhaan.com/numerical/slidesaccuracy.pdf).

The wrapper functions in RiskAdjustedLinearizations.jl are `euler_equation_error` and `dynamic_euler_equation_error`.
See the [Coeurdacier, Rey, and Winant (2011) script](https://github.com/chenwilliam77/RiskAdjustedLinearizations/tree/main/examples/crw/example_crw.jl)
for an example of how to use these functions.

```@docs
RiskAdjustedLinearizations.euler_equation_error
RiskAdjustedLinearizations.dynamic_euler_equation_error
```

To make running diagnostics even easier, we also provide user-friendly functions
for calculating Gauss-Hermite quadrature when shocks are Gaussian. Extensions
of Gauss-Hermite quadrature rules for non-Gaussian shocks (e.g. Poisson disaster risk)
should be straightforward to implement by mirroring the implementation
in RiskAdjustedLinearizations.jl.

```@docs
RiskAdjustedLinearizations.gausshermite_expectation
```