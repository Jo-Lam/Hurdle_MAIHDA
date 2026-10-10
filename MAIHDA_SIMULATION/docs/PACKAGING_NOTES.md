# Release scope and provenance

This is a separate publication package; the working repository and its completed production runs are unchanged. Core config, simulation, fitting/evaluation and aggregation files are byte-identical to production. Source checksums are recorded in SOURCE_MANIFEST.csv. The project-root marker is self-contained; report scripts use a run ID and write under that run's publication directory. The launcher defaults to checking dependencies and never starts production implicitly.

Reporting changes: the review extension now explicitly binds the setting identifier rather than retrieving a global variable. Direction counts ignore undefined Monte Carlo bounds (e.g. insufficient paired datasets), so the count of supported directions is available rather than NA. Undefined intervals remain in the underlying paired table; they are not evidence of equality. Statistical estimates and eligibility rules are unchanged. Reference_results preserves the original completed summaries, including original missing summary values.

The model verification suite tests all generating settings, calibration, identities, likelihood-preserving compression, contrast symmetry, category-order invariance and seed separation. It does not reproduce the full 18,000-dataset experiment. Original production used Windows/R 4.6.0; cross-platform numerical optimisation can differ. Large task files and raw aggregated fit tables are not included in the upload package.

Manuscript drafts and supervisor comments are excluded. Licensing and the final manuscript citation remain to be specified.

