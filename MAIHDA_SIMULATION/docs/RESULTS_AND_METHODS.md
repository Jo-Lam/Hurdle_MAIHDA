# Post-production analysis definitions and decisions — 28 September 2026

This extension uses saved truth, fitted predictions and diagnostics from the completed 18,000-dataset experiment. It does not refit models. The new analyses are exploratory and were selected in response to review, after the original overall results were known. They do not replace the primary estimator or eligibility rules.

## Beyond category effects

The original fitted fixed coefficients and stratum random-effect vectors were not retained. We therefore cannot claim direct recovery of the fitted random effects. Instead, for the hurdle occurrence and positive-count components, form the 72-vector of log-odds or log parent-NB means, respectively. Remove its equal-weight least-squares projection onto the intercept and constituent category main effects: r=(I-QQ') eta, where Q is an orthonormal basis for the category design. Apply exactly the same operation to truth and fitted predictions. This yields the component of each latent predictor that cannot be represented by category main effects. Additive generating settings have zero true projected residual, up to rounding.

Report residual RMSE, true and estimated residual root-mean-square magnitude, and slope sum(r_true*r_est)/sum(r_true^2). A slope below one indicates attenuation of this projected residual; it is not clinical calibration. The slope is undefined when true residual variation is zero. This is a scale-specific residual projection, not recovery of raw random effects, a causal interaction, or a test of intersectionality. The parent-NB mean is distinct from the mean among affected people. No such latent comparison is imposed across incompatible model scales.

Total outcome estimation remains important to MAIHDA, including settings in which category main effects describe the truth. Good total-outcome prediction alone does not establish good recovery of residual differences.

## Stratum size and inequality contrasts

Divide the 72 strata into three fixed groups of 24 by their generating population shares, with stratum index breaking ties. These are expected population-size terciles, not realised affected-count terciles. Compute dataset-level equal-stratum RMSE and signed bias within each group. The groups contain the same strata in all datasets. Low population share does not imply identical occurrence risk; do not infer median affected counts as share times overall prevalence.

For each target, also compute root mean squared error of between-stratum differences. With two independent draws from the specified stratum weights, including diagonal pairs, this is sqrt(2)*sqrt(sum(w*(error-weighted_mean_error)^2)). It measures errors in contrasts and is unaffected by a uniform shift of all predictions. Both natural-scale level RMSE and contrast RMSE are reported. Rankings use Spearman correlation, undefined for effectively constant predictions.

## Fallback procedure

For each target separately: use the primary hurdle estimate if every required component meets the original numerical criteria and all stratum predictions are finite; otherwise use NB2 if it meets the same requirements; otherwise report unavailable. Occurrence requires only the hurdle occurrence fit; positive mean requires the positive-count fit; total mean requires both. This target-specific procedure is not a coherent hybrid joint count distribution: three separately selected outputs need not satisfy the product identity. The main applied example therefore reports positive-count performance and its availability; any joint-distribution application should use a single whole-model branch.

Compare strategies on common eligible datasets and separately report all-attempt branch counts. Comparing each method's separate eligible-sample mean is not a paired accuracy comparison. A fallback rule does not guarantee estimates for all datasets. Unavailable is not assigned zero loss.

## Ordinary estimation and large errors

For positive-count estimates, flag equal-stratum RMSE exceeding two and ten times that dataset's equal-stratum true positive mean. These are descriptive relative-error thresholds, not clinical plausibility bounds. Count flags among all finite predictions and among fits meeting numerical checks; keep all attempted datasets as the reported denominator and show unavailable counts. Do not discard extreme errors.

Report ordinary ML and coefficient-regularised estimators separately. Large coefficient magnitudes, shape estimates, warnings and Hessian flags can identify numerical signatures, but cannot prove a unique cause without refitting or likelihood investigation. Distinguish the largest finite errors from typical and upper-quantile behaviour.

## Verification and sources

The first-setting residual-null check is at numerical precision; its 283 eligible primary positive fits matches the prior table. Validation passed: 3,888 whole-stratum summary rows matched the original availability, mean/median RMSE and bias. Four settings were audited for complete branch records, the null projected residual and the explicit all-pair contrast identity. All 36 settings were processed; no models were refitted. See VALIDATION.txt in the output directory. Source code: analysis/08_event_informed_simulation/review_extension.R. Output directory: review_extension_20260928 beneath the production run.
