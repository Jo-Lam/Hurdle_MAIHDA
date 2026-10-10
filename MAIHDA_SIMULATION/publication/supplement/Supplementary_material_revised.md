# Supplementary methods and results for rare count MAIHDA

This supplement supports the comparison of Poisson, negative-binomial and hurdle negative-binomial MAIHDA for occurrence, frequency among affected people and the overall average count. It provides the generating assumptions, estimation criteria, complete additional-scenario and sensitivity comparisons, and the exploratory assessment of stratum interaction patterns.

## Contents

- Sections S1–S4: data generation, models, fitting criteria and performance measures.
- Section S5: additional scenarios and sensitivity results.
- Section S6: exploratory recovery of stratum interaction patterns.
- Supplementary Tables S1–S6: design, availability, primary comparison summaries, regularisation comparisons, precision exceptions and residual recovery.
- Supplementary Data D1–D8: complete numerical reports for the analyses retained here.

## S1 Data generation and simulation design

### Outcomes and population structure

Occurrence is p_j = Pr(Y > 0 | stratum j). Frequency among affected people is m_j+ = E(Y | Y > 0, stratum j). The overall mean is mu_j = p_j × m_j+. Counts cover one common observation period and include the first event in that period; they do not identify first-ever events. Individuals have no additional covariates within strata. Differential follow-up, missingness, linkage error and causal intervention effects were not simulated.

Four unnamed categorical dimensions with 2, 3, 3 and 4 levels define 72 strata. Marginal weights are (0.55, 0.45), (0.65, 0.25, 0.10), (0.50, 0.30, 0.20) and (0.35, 0.30, 0.20, 0.15). Their products are multiplied by exp(0.5) where the second and third category indices agree, then normalised to sum to one. These fixed generating probabilities range from 0.159% to 8.106%; their median is 0.806%. Each dataset samples individual stratum memberships from these probabilities.

### Stratum patterns

Category contributions are (-0.25, 0.25), (-0.30, 0, 0.30), (-0.40, 0, 0.40) and (-0.30, -0.10, 0.10, 0.30). Their sum for stratum j is s_j. In settings without stratum interaction effects, u_j = 0. In other settings, u_j is independently drawn from a normal distribution with mean zero and standard deviation 0.35 for each dataset.

The occurrence predictor, before adding its intercept, is s_j + u_j. For the scenario with no stratum interaction effects and for the scenario with occurrence and frequency moving together, the positive-count parent-mean predictor is 0.6s_j + u_j. For opposite-direction settings it is -(s_j + u_j). Thus the generating components share a residual effect in same-direction settings, while the entire predictor reverses in opposite-direction settings. Overall stratum means were not constrained to be equal. The code labels additive, aligned and opposing correspond to these three patterns, respectively.

### Sampling and calibration

For the 24 main settings and four very-sparse settings, a Bernoulli draw determines whether each person has an event. Affected people receive a count from a zero-truncated NB2 distribution with parent mean lambda_j and shape phi = 2. If q_j is the parent NB2 probability of zero, the positive mean is lambda_j/(1-q_j). Occurrence uses a logit link; the positive parent mean uses a log link.

The occurrence intercept is solved so that sum(w_j p_j) equals 0.005 or 0.02. The positive-count intercept is separately solved so that sum(w_j p_j m_j+)/sum(w_j p_j) equals 1.2 or 3. Calibration therefore weights frequency by the distribution of strata among affected people, not by equal stratum weights or population shares alone. Conditional on the stratum parameters, individual outcomes are independently sampled. Event times are not generated.

For conventional Poisson or NB2 generation, counts are drawn directly with a log-mean predictor comprising an intercept plus s_j + u_j. The intercept is calibrated using occurrence = 1 - Pr(Y = 0). NB2 shape remains 2. Positive means then follow from the distribution and are not matched to the main settings. Comparisons across generating families do not isolate distributional shape at a fixed positive mean.

Total sample size N is the expected number affected divided by population occurrence. It is fixed within a setting; realised numbers affected vary. Empty strata and strata with no observed events remain in the truth and prediction grid. Sparse datasets are not replaced.

### Supplementary Table S1 Complete setting grid

Each setting has 500 datasets. A, S and O denote no stratum interaction effects, interaction effects with occurrence and frequency moving together, and interaction effects with the components moving in opposite directions. A dash indicates that frequency is implied by the conventional generating distribution rather than independently set. Settings 1–24 are main, 25–32 conventional-count and 33–36 very-sparse.

| Setting | Generating model | Pattern | Occurrence | Total N | Affected | Frequency |
|---|---|---|---|---|---|---|
| 1 | Hurdle NB2 | A | 0.5% | 20,000 | 100 | 1.2 |
| 2 | Hurdle NB2 | A | 2% | 5,000 | 100 | 1.2 |
| 3 | Hurdle NB2 | A | 0.5% | 100,000 | 500 | 1.2 |
| 4 | Hurdle NB2 | A | 2% | 25,000 | 500 | 1.2 |
| 5 | Hurdle NB2 | A | 0.5% | 20,000 | 100 | 3 |
| 6 | Hurdle NB2 | A | 2% | 5,000 | 100 | 3 |
| 7 | Hurdle NB2 | A | 0.5% | 100,000 | 500 | 3 |
| 8 | Hurdle NB2 | A | 2% | 25,000 | 500 | 3 |
| 9 | Hurdle NB2 | S | 0.5% | 20,000 | 100 | 1.2 |
| 10 | Hurdle NB2 | S | 2% | 5,000 | 100 | 1.2 |
| 11 | Hurdle NB2 | S | 0.5% | 100,000 | 500 | 1.2 |
| 12 | Hurdle NB2 | S | 2% | 25,000 | 500 | 1.2 |
| 13 | Hurdle NB2 | S | 0.5% | 20,000 | 100 | 3 |
| 14 | Hurdle NB2 | S | 2% | 5,000 | 100 | 3 |
| 15 | Hurdle NB2 | S | 0.5% | 100,000 | 500 | 3 |
| 16 | Hurdle NB2 | S | 2% | 25,000 | 500 | 3 |
| 17 | Hurdle NB2 | O | 0.5% | 20,000 | 100 | 1.2 |
| 18 | Hurdle NB2 | O | 2% | 5,000 | 100 | 1.2 |
| 19 | Hurdle NB2 | O | 0.5% | 100,000 | 500 | 1.2 |
| 20 | Hurdle NB2 | O | 2% | 25,000 | 500 | 1.2 |
| 21 | Hurdle NB2 | O | 0.5% | 20,000 | 100 | 3 |
| 22 | Hurdle NB2 | O | 2% | 5,000 | 100 | 3 |
| 23 | Hurdle NB2 | O | 0.5% | 100,000 | 500 | 3 |
| 24 | Hurdle NB2 | O | 2% | 25,000 | 500 | 3 |
| 25 | Poisson | S | 0.5% | 20,000 | 100 | — |
| 26 | Poisson | S | 2% | 5,000 | 100 | — |
| 27 | Poisson | S | 0.5% | 100,000 | 500 | — |
| 28 | Poisson | S | 2% | 25,000 | 500 | — |
| 29 | NB2 | S | 0.5% | 20,000 | 100 | — |
| 30 | NB2 | S | 2% | 5,000 | 100 | — |
| 31 | NB2 | S | 0.5% | 100,000 | 500 | — |
| 32 | NB2 | S | 2% | 25,000 | 500 | — |
| 33 | Hurdle NB2 | S | 0.5% | 2,000 | 10 | 1.2 |
| 34 | Hurdle NB2 | S | 0.5% | 10,000 | 50 | 1.2 |
| 35 | Hurdle NB2 | S | 0.5% | 2,000 | 10 | 3 |
| 36 | Hurdle NB2 | S | 0.5% | 10,000 | 50 | 3 |

## S2 Fitted models and regularisation

Primary fitted models include an intercept, fixed main effects for all four characteristics, and a normally distributed stratum random intercept. Poisson uses a log mean and conditional variance equal to the mean. NB2 uses conditional variance mu + mu²/phi, with a shared estimated shape parameter. Hurdle combines logistic occurrence and zero-truncated NB2 positive counts. Its components are fitted separately; their random-effect correlation is not estimated. These models provide all three target quantities from the same fitted distribution (Brooks et al., 2017; Evans et al., 2024).

For truncated NB2, the response-scale prediction from the installed implementation is already the positive mean; exponentiating the link prediction yields the parent mean. Applying another truncation correction to the response prediction would be incorrect. Prediction-scale checks verified this distinction.

Category coding uses orthonormal contrasts. The primary normal penalties have mean zero and standard deviation 1 for category coefficients. The stronger-penalty sensitivity uses standard deviation 0.5. For a K-level characteristic, the induced zero-sum category effects have covariance sigma²(I-J/K); a pairwise category contrast has standard deviation sqrt(2) × sigma. Coding therefore avoids privileging a reference category.

Intercept penalties have standard deviation 1.5, centred at logit(0.01) for occurrence, log(0.01) for conventional count means and log(0.5) for the positive parent mean. Shape and stratum variance have no additional penalties. Ordinary maximum-likelihood estimation omits the coefficient and intercept penalties but retains partial pooling of stratum random effects. Penalised estimates are point estimates, not posterior means or posterior intervals. The primary penalty was selected during development before the independent pilot and production simulation; stronger penalties were retained as sensitivity rather than selected using the production results. Software labels MAP_sd1, MAP_sd0.5 and ML identify these three approaches.

Models used glmmTMB 1.1.14 in R 4.6.0, with the same default optimisation backend across approaches. Identical (stratum, count) observations were compressed with frequency weights after individual-record generation. This preserves the individual likelihood and does not collapse a stratum to one aggregate event count. Verification reproduced individual-record predictions to below 10⁻⁸ and objective values to below 4 × 10⁻¹⁰ in the tested comparison.

## S3 Data support and numerical availability

Before fitting, a component was classified as unsupported if there were no observations, its fixed-effect design was rank deficient, all responses were zero, its binary occurrence responses were all one, or all positive counts were one. The last condition excludes positive-count samples without recurrence under the prespecified rule; it is not a claim that no alternative estimator could return an estimate.

An acceptable fit required the component to pass these support rules, return a fitted object, report an optimiser convergence code of zero and have a positive-definite Hessian (glmmTMB diagnostic field pdHess). These are operational numerical criteria, not proof of accuracy or a global optimum. Warnings were recorded but were not independently used as an exclusion criterion. A stratum variance below 10⁻⁸ was recorded as a boundary estimate and was not automatically a failure.

Hurdle occurrence requires its occurrence fit; frequency requires its positive-count fit; the overall mean requires both. A failed component does not erase an otherwise available target. All 500 attempted datasets remain in availability denominators. Accuracy additionally requires finite errors and complete target predictions across the 72 strata.

### Supplementary Table S2 Availability of primary hurdle components

Counts out of 500 per setting. Unsupported components are distinguished from numerical failures among supported attempts. Poisson and NB2 target-specific availability, including ordinary and stronger-penalty estimates, is supplied in D2; all component diagnostic counts are supplied in D4.

| Setting | Occurrence acceptable | Positive unsupported | Positive numerical failure | Positive acceptable |
|---|---|---|---|---|
| 1 | 500 | 0 | 217 | 283 |
| 2 | 500 | 0 | 205 | 295 |
| 3 | 500 | 0 | 53 | 447 |
| 4 | 500 | 0 | 65 | 435 |
| 5 | 500 | 0 | 1 | 499 |
| 6 | 500 | 0 | 1 | 499 |
| 7 | 500 | 0 | 0 | 500 |
| 8 | 500 | 0 | 0 | 500 |
| 9 | 500 | 0 | 189 | 311 |
| 10 | 500 | 0 | 182 | 318 |
| 11 | 500 | 0 | 33 | 467 |
| 12 | 500 | 0 | 49 | 451 |
| 13 | 500 | 0 | 1 | 499 |
| 14 | 500 | 0 | 0 | 500 |
| 15 | 500 | 0 | 0 | 500 |
| 16 | 500 | 0 | 0 | 500 |
| 17 | 500 | 0 | 179 | 321 |
| 18 | 500 | 0 | 153 | 347 |
| 19 | 500 | 0 | 47 | 453 |
| 20 | 500 | 0 | 55 | 445 |
| 21 | 500 | 0 | 0 | 500 |
| 22 | 500 | 0 | 1 | 499 |
| 23 | 500 | 0 | 0 | 500 |
| 24 | 500 | 0 | 0 | 500 |
| 25 | 500 | 322 | 75 | 103 |
| 26 | 500 | 114 | 171 | 215 |
| 27 | 500 | 80 | 181 | 239 |
| 28 | 500 | 0 | 247 | 253 |
| 29 | 500 | 290 | 87 | 123 |
| 30 | 500 | 60 | 195 | 245 |
| 31 | 500 | 32 | 219 | 249 |
| 32 | 500 | 0 | 242 | 258 |
| 33 | 500 | 357 | 65 | 78 |
| 34 | 500 | 1 | 226 | 273 |
| 35 | 500 | 326 | 77 | 97 |
| 36 | 500 | 1 | 31 | 468 |

## S4 Accuracy and Monte Carlo precision

Within each dataset, RMSE is the square root of the weighted sum of squared differences between estimated and true stratum outcomes. Weights sum to one and are either 1/72 for every stratum or the generating population shares. Mean RMSE is the average of these dataset-level RMSEs, not the square root of errors pooled across all simulations. Signed bias is the corresponding weighted mean difference and permits positive and negative errors to offset.

Each paired contrast uses the same datasets for both methods, requiring both relevant fits to be acceptable and their errors finite. The reported difference is mean(dataset RMSE for hurdle minus comparator RMSE); negative values favour hurdle. Its Monte Carlo standard error is the standard deviation of the dataset-level paired differences divided by the square root of their number. The approximate 95% interval is the difference plus or minus 1.96 standard errors. These intervals quantify finite-simulation uncertainty, not confidence-interval coverage for estimated health outcomes. Sensitivity contrasts include all finite errors regardless of diagnostics; unavailable errors are not assigned zero.

Main Figure 3 and Table 3 use the same acceptable subset for all three models within each setting. Because primary Poisson and NB2 pass throughout the 24 main frequency settings, these subsets equal those used in each primary hurdle comparison. The figure reports uncertainty for each model mean; inference about a paired difference uses its own paired standard error, not overlap of the separate plotted intervals.

The independent pilot used 50 datasets per setting (replication IDs 1001–1050). Production used IDs 2001–2500, with 500 per setting and no pooling of pilot or development datasets. The seed is 1,937,000 + 10,000 × setting ID + replication ID. All 18,000 production datasets completed. Generating calibration and finite prediction-domain checks were distinct from the fitted-model checks.

The planned 95% Monte Carlo half-widths were 0.00025 for occurrence, 0.05 events for frequency and 0.001 events per person for the overall mean. These are computational precision targets, not thresholds of clinical importance. They apply to 288 primary contrasts: 24 main settings × three targets × two weighting schemes × two hurdle comparators. Targets were met for 249 contrasts: 69/96 occurrence, 96/96 frequency and 84/96 overall-mean comparisons. All 39 exceptions appear in Table S5. They were retained without relaxing targets or selectively adding replications (Morris et al., 2019).

### Supplementary Table S3 Primary accuracy comparisons in the main settings

Counts of settings with lower hurdle RMSE by point estimate, followed by counts whose Monte Carlo interval lies entirely below zero. Each row summarises 24 settings. This table does not count simulation settings as independent samples of real-world applications. Full magnitudes and intervals are in D3 and D5.

| Outcome | Weighting | Hurdle versus Poisson | Hurdle versus NB2 |
|---|---|---|---|
| Occurrence | Equal strata | 24 (24) | 19 (15) |
| Occurrence | Population | 24 (24) | 13 (12) |
| Frequency | Equal strata | 24 (24) | 16 (16) |
| Frequency | Population | 24 (24) | 16 (16) |
| Overall mean | Equal strata | 22 (22) | 12 (11) |
| Overall mean | Population | 22 (22) | 12 (11) |

## S5 Additional scenarios and sensitivity analyses

The four very-sparse settings contain 2,000 or 10,000 people at 0.5% occurrence (10 or 50 expected affected), both frequency levels and the same-direction stratum pattern. Primary hurdle occurrence was acceptable throughout, while frequency was acceptable in 916/2,000 datasets (45.8%). In the eight conventional-count settings, frequency was acceptable in 1,685/4,000 (42.1%); occurrence was acceptable throughout. Under both weighting schemes, NB2 had lower occurrence and frequency RMSE than hurdle in all eight conventional-count settings, and Poisson had lower frequency RMSE throughout. Complete estimates, availability and paired intervals for these additional scenarios are retained in D2–D4.

The following table summarises the regularisation sensitivity reported in the main text. Each estimator is assessed on its own acceptable pairs; these are not necessarily identical datasets across estimation procedures. Including numerically flagged finite errors did not reverse any of the 288 primary contrast directions. This does not recover non-finite estimates or establish equal contrast magnitudes. Full restricted and all-finite comparisons are retained in D3.

### Supplementary Table S4 Sensitivity of frequency comparisons to regularisation

Counts of the 24 main settings with lower hurdle RMSE by point estimate; counts with intervals wholly below zero are in parentheses.

| Estimation | Weighting | Versus Poisson | Versus NB2 |
|---|---|---|---|
| Ordinary estimation | Equal strata | 21 (21) | 16 (16) |
| Ordinary estimation | Population | 22 (22) | 16 (16) |
| Primary penalties | Equal strata | 24 (24) | 16 (16) |
| Primary penalties | Population | 24 (24) | 16 (16) |
| Stronger penalties | Equal strata | 24 (24) | 12 (12) |
| Stronger penalties | Population | 24 (24) | 12 (12) |

### Supplementary Table S5 All unmet simulation precision targets

Differences are primary hurdle minus comparator mean RMSE on common acceptable datasets. A 95% Monte Carlo interval is difference plus or minus the reported half-width. Targets are 0.00025 for occurrence and 0.001 for the overall mean; all frequency comparisons met their 0.05-event target. Failure to meet an absolute precision target does not necessarily mean the direction of a comparison is unresolved.

| Setting | Outcome | Weight | Comparator | Pairs | Difference | Half-width |
|---|---|---|---|---|---|---|
| 2 | Occurrence | Strata | Poisson | 500 | -0.0060161 | 0.00045146 |
| 4 | Occurrence | Strata | Poisson | 500 | -0.0060127 | 0.00028198 |
| 5 | Occurrence | Strata | Poisson | 500 | -0.038222 | 0.0011157 |
| 5 | Occurrence | People | Poisson | 500 | -0.020533 | 0.00040427 |
| 5 | Overall mean | Strata | Poisson | 499 | -0.02529 | 0.001237 |
| 6 | Occurrence | Strata | Poisson | 500 | -0.10986 | 0.0023123 |
| 6 | Occurrence | Strata | NB2 | 500 | -0.00055088 | 0.00033737 |
| 6 | Occurrence | People | Poisson | 500 | -0.064493 | 0.0010033 |
| 6 | Overall mean | Strata | Poisson | 499 | -0.098344 | 0.0056139 |
| 6 | Overall mean | Strata | NB2 | 499 | 0.00099991 | 0.0012738 |
| 6 | Overall mean | People | Poisson | 499 | -0.048049 | 0.0019531 |
| 7 | Occurrence | Strata | Poisson | 500 | -0.028785 | 0.00045834 |
| 8 | Occurrence | Strata | Poisson | 500 | -0.09507 | 0.0011982 |
| 8 | Occurrence | People | Poisson | 500 | -0.053642 | 0.0004682 |
| 8 | Overall mean | Strata | Poisson | 500 | -0.041978 | 0.0015368 |
| 10 | Occurrence | Strata | Poisson | 500 | -0.0047676 | 0.00046804 |
| 12 | Occurrence | Strata | Poisson | 500 | -0.0044565 | 0.00030682 |
| 13 | Occurrence | Strata | Poisson | 500 | -0.039475 | 0.0012805 |
| 13 | Occurrence | People | Poisson | 500 | -0.021374 | 0.00048343 |
| 13 | Overall mean | Strata | Poisson | 499 | -0.015471 | 0.0013382 |
| 14 | Occurrence | Strata | Poisson | 500 | -0.10746 | 0.0024197 |
| 14 | Occurrence | Strata | NB2 | 500 | -0.0001631 | 0.00026453 |
| 14 | Occurrence | People | Poisson | 500 | -0.064456 | 0.0010971 |
| 14 | Overall mean | Strata | Poisson | 500 | -0.067979 | 0.0063281 |
| 14 | Overall mean | Strata | NB2 | 500 | -0.003097 | 0.0011798 |
| 14 | Overall mean | People | Poisson | 500 | -0.030513 | 0.002252 |
| 15 | Occurrence | Strata | Poisson | 500 | -0.032312 | 0.000718 |
| 15 | Occurrence | People | Poisson | 500 | -0.017584 | 0.00025487 |
| 16 | Occurrence | Strata | Poisson | 500 | -0.097134 | 0.0015988 |
| 16 | Occurrence | People | Poisson | 500 | -0.056606 | 0.00063494 |
| 16 | Overall mean | Strata | Poisson | 500 | -0.007045 | 0.0023365 |
| 16 | Overall mean | Strata | NB2 | 500 | -0.0092652 | 0.0010616 |
| 21 | Occurrence | Strata | Poisson | 500 | -0.013145 | 0.00032779 |
| 22 | Occurrence | Strata | Poisson | 500 | -0.046181 | 0.0010735 |
| 22 | Occurrence | Strata | NB2 | 500 | -0.0058083 | 0.00027836 |
| 22 | Occurrence | People | Poisson | 500 | -0.046288 | 0.00077606 |
| 22 | Overall mean | Strata | Poisson | 499 | -0.03255 | 0.0011936 |
| 24 | Occurrence | Strata | Poisson | 500 | -0.032461 | 0.00043092 |
| 24 | Occurrence | People | Poisson | 500 | -0.036149 | 0.00033208 |

## S6 Exploratory recovery of stratum interaction patterns

This analysis used saved predictions after the main simulation and did not change the estimator, diagnostic rules or simulation sample. It assessed whether predictions retained stratum differences beyond the category main effects. It did not directly compare fitted random effects with their generating values because the original coefficient and random-effect vectors were not retained.

For each hurdle component, we formed a 72-vector eta of log-odds for occurrence or log parent-NB means for positive counts. Let Q be an orthonormal basis for the design containing the intercept and all category main effects. The residual pattern is r = (I - QQ') eta, the part of the predictor not represented by those main effects under equal-stratum projection. The same projection was applied to true and fitted predictors. The positive parent mean is distinct from frequency among affected people.

Recovery slope is sum(r_true × r_estimated) / sum(r_true²). A value of one corresponds to the correct average amplitude along the true residual pattern; a value near zero indicates little recovery in that direction. A slope of one does not by itself establish perfect recovery, because other residual errors can remain. We therefore also report residual RMSE and true and estimated root-mean-square (RMS) magnitudes. These are scale-specific summaries, not percentages of inequality explained or tests of intersectionality. Slopes are undefined where the true residual is zero, including the scenario without stratum interaction effects.

### Supplementary Table S6 Residual pattern recovery

Primary hurdle models in the same-direction and opposite-direction main settings, combining both occurrence levels. Each row has 2,000 attempted datasets and uses acceptable fits for its component. Occurrence is on the log-odds scale; positive counts are on the log parent-NB-mean scale. RMS denotes root mean square magnitude. Sample sizes corresponding to 100 affected are 20,000 at 0.5% and 5,000 at 2%; for 500 affected they are 100,000 and 25,000, respectively.

| Affected | Frequency | Component | Acceptable | Slope | RMSE | True RMS | Fitted RMS |
|---|---|---|---|---|---|---|---|
| 100 | 1.2 | Occurrence | 2000 | 0.068 | 0.317 | 0.325 | 0.057 |
| 100 | 1.2 | Positive counts | 1297 | 0.010 | 0.328 | 0.326 | 0.019 |
| 500 | 1.2 | Occurrence | 2000 | 0.322 | 0.261 | 0.327 | 0.165 |
| 500 | 1.2 | Positive counts | 1816 | 0.048 | 0.321 | 0.327 | 0.044 |
| 100 | 3 | Occurrence | 2000 | 0.063 | 0.319 | 0.326 | 0.054 |
| 100 | 3 | Positive counts | 1998 | 0.039 | 0.322 | 0.326 | 0.038 |
| 500 | 3 | Occurrence | 2000 | 0.317 | 0.262 | 0.326 | 0.163 |
| 500 | 3 | Positive counts | 2000 | 0.246 | 0.277 | 0.326 | 0.138 |

## Supplementary data index

All accompanying files are restricted to the outcomes and analyses described here. Code labels retain their original spelling for reproducibility; p, m_plus and expected denote occurrence, frequency among affected people and the overall mean. Diagnostic restriction TRUE denotes acceptable finite fits; FALSE denotes all finite errors. Counts and model means remain conditional on the specified restriction.

| File | Contents |
|---|---|
| D1_design.csv | Parameters of all 36 settings; 500 datasets per setting |
| D2_performance.csv | Model-specific accuracy and availability for all three outcomes, additive models and three estimators |
| D3_paired_comparisons.csv | Paired model and estimator differences, both weighting schemes and diagnostic restrictions |
| D4_availability.csv | Data-support and numerical diagnostics for additive components |
| D5_primary_precision.csv | All 288 planned primary contrasts and precision targets |
| D6_precision_exceptions.csv | All 39 unmet targets |
| D7_residual_summary.csv | Values underlying Supplementary Table S6 |
| D8_residual_by_setting.csv | Detailed exploratory residual-pattern recovery by setting |

## References

Brooks, M.E., et al. (2017). glmmTMB balances speed and flexibility among packages for zero-inflated generalized linear mixed modeling. The R Journal, 9, 378–400. https://doi.org/10.32614/RJ-2017-066

Evans, C.R., Leckie, G., Subramanian, S.V., Bell, A., and Merlo, J. (2024). A tutorial for conducting intersectional multilevel analysis of individual heterogeneity and discriminatory accuracy (MAIHDA). SSM – Population Health, 26, 101664. https://doi.org/10.1016/j.ssmph.2024.101664

Morris, T.P., White, I.R., and Crowther, M.J. (2019). Using simulation studies to evaluate statistical methods. Statistics in Medicine, 38, 2074–2102. https://doi.org/10.1002/sim.8086

R Core Team (2026). R: A language and environment for statistical computing. R Foundation for Statistical Computing. Version 4.6.0. https://www.R-project.org/
