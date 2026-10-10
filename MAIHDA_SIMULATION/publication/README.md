# October 2026 publication materials

## Figures and numerical results

`figures/` contains the revised Figure 2 (frequency-fit availability), Figure 3 (frequency RMSE), numerical Table 3, figure data and captions. These supersede the earlier information figures. Accuracy is compared using the same acceptable finite fits for all three models within each setting; availability uses all 500 attempted datasets as its denominator.

To regenerate the figures from the included data, run from the repository root:

```text
Rscript --vanilla publication/figures/make_information_figures.R
```

This requires base R and does not fit models. The script writes figures beside its input data. Monte Carlo intervals on Figure 3 describe individual model means; paired difference intervals are reported in Table 3.

## Supplementary material

`supplement/` contains the revised Word document, its Markdown source and Supplementary Data D1–D8. Supplementary Tables S1–S6 cover design, availability, primary comparison directions, regularisation, simulation precision and exploratory residual recovery, respectively.

The supplement was revised on 1 October against the Methods and Results then available. It has not been checked against subsequent edits to the 5 October manuscript. Removed analyses remain in the original research records and are not presented as part of this submission supplement.

## Provenance

Files were copied from `MAIHDA_figures_and_numerical_results_updated.zip` and `Supplementary_material_revised_package.zip`. The internal manuscript-editing checklist was excluded. No simulations were rerun or results altered. The September analysis scripts remain available for reproducing the underlying study; their original figure stage produces the earlier displays. Use the command above for the October figures.
