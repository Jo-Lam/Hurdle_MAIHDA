# Table 3 Frequency estimation across the 24 main settings

Primary regularised additive MAIHDA models; equal-stratum weighting. All three mean RMSEs in a row use exactly the same acceptable datasets. Poisson and NB2 passed in all 500 datasets per setting, so this common subset equals the acceptable hurdle subset. RMSE is in events per affected person. Negative differences favour hurdle; positive differences favour NB2. Intervals are approximate 95% Monte Carlo intervals for the paired mean RMSE difference, not confidence intervals for health outcomes.

## No stratum interaction effects

| Occurrence | Total N | Frequency | Pairs / 500 | Poisson RMSE | NB2 RMSE | Hurdle RMSE | Hurdle minus NB2 (95% MC interval) |
|---|---:|---:|---:|---:|---:|---:|---|
| 0.5% | 20,000 | 1.2 | 283 | 0.225 | 0.105 | 0.159 | +0.054 (+0.047, +0.061) |
| 0.5% | 100,000 | 1.2 | 447 | 0.225 | 0.073 | 0.076 | +0.003 (+0.001, +0.005) |
| 2% | 5,000 | 1.2 | 295 | 0.211 | 0.098 | 0.162 | +0.064 (+0.057, +0.071) |
| 2% | 25,000 | 1.2 | 435 | 0.210 | 0.070 | 0.074 | +0.005 (+0.002, +0.007) |
| 0.5% | 20,000 | 3 | 499 | 2.312 | 1.124 | 0.811 | -0.314 (-0.353, -0.274) |
| 0.5% | 100,000 | 3 | 500 | 2.311 | 1.057 | 0.358 | -0.699 (-0.724, -0.674) |
| 2% | 5,000 | 3 | 499 | 2.272 | 1.074 | 0.819 | -0.255 (-0.293, -0.218) |
| 2% | 25,000 | 3 | 500 | 2.270 | 1.029 | 0.359 | -0.669 (-0.692, -0.646) |

## Stratum interaction effects with occurrence and frequency moving together

| Occurrence | Total N | Frequency | Pairs / 500 | Poisson RMSE | NB2 RMSE | Hurdle RMSE | Hurdle minus NB2 (95% MC interval) |
|---|---:|---:|---:|---:|---:|---:|---|
| 0.5% | 20,000 | 1.2 | 311 | 0.213 | 0.125 | 0.172 | +0.047 (+0.040, +0.054) |
| 0.5% | 100,000 | 1.2 | 467 | 0.212 | 0.086 | 0.103 | +0.017 (+0.015, +0.019) |
| 2% | 5,000 | 1.2 | 318 | 0.200 | 0.126 | 0.182 | +0.057 (+0.050, +0.063) |
| 2% | 25,000 | 1.2 | 451 | 0.198 | 0.085 | 0.105 | +0.020 (+0.018, +0.022) |
| 0.5% | 20,000 | 3 | 499 | 2.179 | 1.461 | 1.155 | -0.305 (-0.349, -0.262) |
| 0.5% | 100,000 | 3 | 500 | 2.177 | 1.184 | 0.713 | -0.472 (-0.495, -0.448) |
| 2% | 5,000 | 3 | 500 | 2.135 | 1.387 | 1.128 | -0.259 (-0.296, -0.222) |
| 2% | 25,000 | 3 | 500 | 2.133 | 1.140 | 0.724 | -0.416 (-0.438, -0.394) |

## Stratum interaction effects with occurrence and frequency moving in opposite directions

| Occurrence | Total N | Frequency | Pairs / 500 | Poisson RMSE | NB2 RMSE | Hurdle RMSE | Hurdle minus NB2 (95% MC interval) |
|---|---:|---:|---:|---:|---:|---:|---|
| 0.5% | 20,000 | 1.2 | 321 | 0.233 | 0.227 | 0.159 | -0.068 (-0.073, -0.063) |
| 0.5% | 100,000 | 1.2 | 453 | 0.233 | 0.222 | 0.101 | -0.121 (-0.123, -0.119) |
| 2% | 5,000 | 1.2 | 347 | 0.222 | 0.222 | 0.159 | -0.063 (-0.068, -0.057) |
| 2% | 25,000 | 1.2 | 445 | 0.223 | 0.220 | 0.100 | -0.120 (-0.122, -0.117) |
| 0.5% | 20,000 | 3 | 500 | 2.380 | 1.811 | 1.112 | -0.699 (-0.725, -0.674) |
| 0.5% | 100,000 | 3 | 500 | 2.372 | 1.696 | 0.742 | -0.954 (-0.971, -0.937) |
| 2% | 5,000 | 3 | 499 | 2.328 | 1.740 | 1.085 | -0.655 (-0.679, -0.631) |
| 2% | 25,000 | 3 | 500 | 2.336 | 1.662 | 0.738 | -0.924 (-0.942, -0.907) |

## Calculation provenance

Paired comparator means were reconstructed as mean hurdle RMSE minus the saved mean paired difference. This identity applies because the paired dataset count equals the hurdle-acceptable count and the comparator passes for all 500 datasets; those conditions were asserted for every row. Sources: frozen review/performance.csv and review/paired_precision.csv. No refitting or new simulation.