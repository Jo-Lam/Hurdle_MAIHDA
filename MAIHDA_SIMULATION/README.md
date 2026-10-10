# MAIHDA for rare health outcomes

Reproducibility package for **Who is affected, and how often? Estimating rare health outcomes across intersectional strata**. The study compares Poisson, negative-binomial (NB2) and hurdle NB2 MAIHDA for estimating the proportion of people affected, the average number of events among affected people, and the average across everyone.

## Start here

Open a terminal in this folder. Install R and the required packages, then check the environment:

```r
install.packages(c("glmmTMB", "data.table"))
```

```text
Rscript --vanilla pipeline.R --stage=check
Rscript --vanilla pipeline.R --stage=test
```

The study used R 4.6.0 and glmmTMB 1.1.14; data.table 1.18.4 was used for the review extension. Full production versions are in `reference_results/session_info.txt`. Installing current versions does not guarantee identical optimisation; use the recorded versions for closest reproduction. No package installation or full simulation starts automatically.

## Layout

- `pipeline.R`: entry point for each stage.
- `analysis/08_event_informed_simulation/`: generator, estimators, evaluation, tests and reporting.
- `R/`: project location, argument and provenance helpers.
- `reference_results/`: completed aggregate results and seeds for checking the paper without rerunning fits.
- `docs/`: analysis definitions and reproducibility notes.
- `verification/`: release checks.
- `publication/`: October figures, numerical results and revised supplementary material.
- `outputs/`: created by execution and excluded from Git.

The simulation design and estimation code match the completed study. `SOURCE_MANIFEST.csv` records their checksums; `verification/README.md` describes the checks performed. Large dataset-level outputs are excluded from this repository.

## Small example

```text
Rscript --vanilla pipeline.R --stage=simulate --replications=1 --start-replication=1 --run-id=example36
Rscript --vanilla pipeline.R --stage=review --run-id=example36
Rscript --vanilla pipeline.R --stage=audit --run-id=example36
```

This fits 36 datasets, each with 24 component fits. It tests execution, not scientific performance. The test stage checks selected fits and all generating settings more economically.

## Production reproduction

```text
Rscript --vanilla pipeline.R --stage=simulate --replications=500 --start-replication=2001 --run-id=production500
Rscript --vanilla pipeline.R --stage=review --run-id=production500
Rscript --vanilla pipeline.R --stage=audit --run-id=production500
Rscript --vanilla pipeline.R --stage=consolidate --run-id=production500
Rscript --vanilla pipeline.R --stage=figures --run-id=production500
Rscript --vanilla pipeline.R --stage=conceptual --run-id=production500
Rscript --vanilla pipeline.R --stage=tables --run-id=production500
Rscript --vanilla pipeline.R --stage=extension --run-id=production500
Rscript --vanilla pipeline.R --stage=validate_extension --run-id=production500
Rscript --vanilla pipeline.R --stage=summarise_extension --run-id=production500
```

Production comprises 18,000 datasets and can take days. Consolidation, manuscript displays and extension validation are production-specific and retain 500-per-setting checks. Results go to `outputs/07_event_informed_simulation/production500/`; figures and parallel tables go into its `publication/` subfolder. The extension folder retains its historical label `review_extension_20260928/`.

To resume simulation, repeat its exact command with `--resume=true`. Configuration, source hashes, design and software must match. Do not resume old project runs using this release: the path-helper and entry-point hashes differ. Do not start two writers for one output directory. A failed dataset remains recorded rather than silently retried. The extension reuses per-setting reports; start in a fresh output directory if its analysis code changes. This release has no parallel launcher.

## Existing results

`reference_results/` contains the completed study summaries, not newly fitted release results. Accuracy among eligible fits must be read alongside availability. Monte Carlo intervals quantify simulation precision, not patient or stratum confidence intervals. Individual task RDS files and large metrics/diagnostics tables are excluded; reproduce them from the code and seeds or archive them separately for full saved-output reanalysis. Synthetic data only; no patient records are included.

## Scope and reporting

The study evaluates point estimates and numerical availability. It does not evaluate confidence-interval coverage, causal effects or a diagnostic rule for choosing a model. Exploratory analyses are identified in `docs/RESULTS_AND_METHODS.md`.

October 2026 figures, numerical Table 3 and revised supplementary material are included in `publication/`. See `publication/README.md` for the figure regeneration command and the scope of the supplementary revision. The original pipeline figure stage retains the September displays.

## Licence and citation

A redistribution licence and final manuscript citation have not yet been specified. No open-source licence is implied by making the repository public.


