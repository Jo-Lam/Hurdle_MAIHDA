# Run from this folder with Rscript --vanilla pipeline.R --stage=...
source('R/project_utils.R')
set_project_root()
a <- parse_named_args()
if (length(setdiff(names(a),c('stage','run_id','replications','start_replication','resume')))) stop('Unknown argument')
stage <- arg_value(a,'stage','check')
module <- 'analysis/08_event_informed_simulation'
scripts <- c(test='test.R', simulate='run.R', review='review.R', audit='assess_precision.R', consolidate='consolidate_production.R', figures='manuscript_figures.R', conceptual='conceptual_figure.R', tables='maihda_parallel_table.R', extension='review_extension.R', validate_extension='validate_review_extension.R', summarise_extension='summarise_review_extension.R')
if (stage=='check') {
 assert_packages(c('glmmTMB','data.table'))
 print(package_versions(c('glmmTMB','data.table')))
 source(file.path(module,'config.R'))
 g <- v3_design(500,2001)
 stopifnot(nrow(g)==18000L,!anyDuplicated(g$seed))
 cat('Environment and production design checks passed. No models fitted.\n')
} else {
 if (!stage %in% names(scripts)) stop('Unknown stage: ',stage)
 if (stage!='simulate' && any(c('replications','start_replication','resume') %in% names(a))) stop('Replication and resume options apply only to simulate')
 if (stage=='test' && 'run_id' %in% names(a)) stop('Test does not take a run ID')
 forwarded <- a[setdiff(names(a),'stage')]
 cli <- if(length(forwarded)) paste0('--',gsub('_','-',names(forwarded)), '=',unlist(forwarded)) else character()
 status <- system2(file.path(R.home('bin'),'Rscript'), c('--vanilla',shQuote(file.path(module,scripts[[stage]])),shQuote(cli)))
 if(status!=0L) stop('Stage failed: ',stage,' (exit ',status,')')
}
