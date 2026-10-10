# Outputs and estimands

There are 24 main hurdle settings, eight count controls and four sparse stress tests. Production uses 500 seeds per setting, replications 2001–2500. Pilot IDs 1001–1050 and development IDs are excluded. `design.csv` records parameters, task IDs and seeds.

`p`: Pr(Y>0); `m_plus`: E(Y|Y>0), including the first event within the observation window; `expected`: E(Y)=p*m_plus; `recurrent`: Pr(Y>=2); `recurrent_given_positive`: Pr(Y>=2|Y>0); `tail`: Pr(Y>=5). `parent_mu` differs from the truncated positive mean. Machine label `nb` means NB2. `ML` means ordinary estimation; `MAP_sd1` is primary coefficient regularisation and `MAP_sd0.5` is stronger sensitivity.

Each task stores status, design row, true stratum outcomes, predictions, diagnostics and performance metrics. Individuals are generated then compressed using frequency weights, preserving their likelihood. Fitted objects and coefficient/random-effect vectors were not retained.

Eligibility requires appropriate data support, optimiser convergence and a positive-definite Hessian; near-zero variance alone is not failure. Hurdle eligibility is target-specific. `restricted=TRUE` or `diagnostic_restricted=TRUE` means conditional accuracy among eligible fits. All attempts remain in availability denominators. Finite flagged predictions remain in sensitivity summaries; unavailable predictions are never assigned zero error.

Performance tables contain mean dataset-level RMSE, medians, upper errors and signed bias. Paired comparisons use the same datasets for both methods. Primary precision tables retain all 288 contrasts and 39 unmet targets. PCV is descriptive and was not evaluated for estimation accuracy.

Review extensions use projected latent predictors orthogonal to category effects, not raw random effects. Size terciles contain 24 strata each. Targetwise fallback uses hurdle, then NB2, otherwise unavailable; independently selected targets need not form a coherent joint distribution. Extreme-error thresholds are descriptive, not clinical plausibility limits. Extensions were exploratory after production.
