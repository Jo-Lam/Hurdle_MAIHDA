# Release verification

Passed on 28 September 2026 with R 4.6.0, glmmTMB 1.1.14 and data.table 1.18.4.

- All 18 packaged R scripts parsed.
- Package environment and 18,000-row production seed design checked.
- Existing statistical tests passed: all 36 generating calibrations, outcome identities, individual/frequency-compressed likelihood equivalence, orthonormal penalty symmetry, category-order invariance and disjoint seeds.
- Configuration, generator, fitting/evaluation and aggregation modules match their source bytes.
- Portable consolidation, manuscript figures, conceptual figure and parallel MAIHDA table scripts ran on existing production inputs without refitting.
- Primary precision, precision exceptions, positive-count availability and comparison-direction consolidated CSVs match their reference files exactly.
- The earlier review extension validation matched 3,888 original summaries; see reference_results/review_extension_20260928/VALIDATION.txt. The release did not rerun the full saved-output extension or the 18,000 fits.
- The release source and included reports were scanned for local user paths; none were found.

The startup locale warnings reflect the host configuration and did not prevent these checks. Local test inputs/outputs are under ignored outputs/ and excluded from the distribution archive.
