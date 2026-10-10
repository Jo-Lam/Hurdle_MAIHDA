source('R/project_utils.R');set_project_root()
args<-parse_named_args()
if(!identical(names(args),'run_id') || !grepl('^[A-Za-z0-9_-]+$',args$run_id))stop('Use --run-id=completed_run_id')
out<-file.path('outputs','07_event_informed_simulation',args$run_id)
if(!file.exists(file.path(out,'RUN_COMPLETE.txt')))stop('Run is not complete.')
design<-read.csv(file.path(out,'design.csv'));m<-read.csv(file.path(out,'metrics.csv'));d<-read.csv(file.path(out,'diagnostics.csv'))
report<-file.path(out,'review');dir.create(report,showWarnings=FALSE)
key<-c('cell','estimator','specification','model','target','weighting')
groups<-split(m,interaction(m[key],drop=TRUE))
summaries<-lapply(groups,function(x)do.call(rbind,lapply(c(FALSE,TRUE),function(restrict) {
 good<-is.finite(x$rmse)&(!restrict|x$diagnostic_ok);r<-x$rmse[good];b<-x$bias[good]
 attempted<-sum(design$cell==x$cell[1])
 cbind(x[1,c('cell','role','family','pattern','p','affected','positive_mean',key[-1])],
  data.frame(diagnostic_restricted=restrict,attempted=attempted,available=sum(good),
   mean_rmse=if(length(r))mean(r) else NA_real_,median_rmse=if(length(r))median(r) else NA_real_,
   q90_rmse=if(length(r))unname(quantile(r,.9)) else NA_real_,max_rmse=if(length(r))max(r) else NA_real_,
   mcse_mean_rmse=if(length(r)>1)sd(r)/sqrt(length(r)) else NA_real_,
   mean_bias=if(length(b))mean(b) else NA_real_,mcse_bias=if(length(b)>1)sd(b)/sqrt(length(b)) else NA_real_))
})))
write.csv(do.call(rbind,summaries),file.path(report,'performance.csv'),row.names=FALSE)
dg<-split(d,interaction(d[c('cell','estimator','component')],drop=TRUE))
ds<-lapply(dg,function(x)cbind(x[1,c('cell','role','estimator','component')],
 data.frame(attempted=sum(design$cell==x$cell[1]),recorded=nrow(x),unsupported=sum(!x$data_support_ok),
 returned=sum(x$fit_returned),diagnostic_ok=sum(x$optimiser_ok & x$hessian_ok),
 boundary=sum(x$boundary,na.rm=TRUE),max_abs_coefficient=if(any(is.finite(x$max_abs_fixed_coefficient))) max(x$max_abs_fixed_coefficient,na.rm=TRUE) else NA_real_)))
write.csv(do.call(rbind,ds),file.path(report,'availability.csv'),row.names=FALSE)
# Pair on the same dataset, never compare different eligible subsets as if paired.
m<-subset(m,specification=='additive');m$method<-paste(m$estimator,m$model,sep=':')
contrasts<-list()
for(e in unique(m$estimator)) for(pair in list(c('hurdle','poisson'),c('hurdle','nb'),c('nb','poisson'))) contrasts[[length(contrasts)+1]]<-paste(e,pair,sep=':')
for(model in c('poisson','nb','hurdle')) for(e in c('MAP_sd0.5','MAP_sd1')) contrasts[[length(contrasts)+1]]<-paste(c(e,'ML'),model,sep=':')
pairs<-list()
for(cell in unique(design$cell)) for(target in unique(m$target)) for(weight in unique(m$weighting)) {
 x<-m[m$cell==cell & m$target==target & m$weighting==weight,]
 for(pair in contrasts) for(restrict in c(FALSE,TRUE)) {
  a<-x[x$method==pair[1],c('task','rmse','diagnostic_ok')];b<-x[x$method==pair[2],c('task','rmse','diagnostic_ok')]
  z<-merge(a,b,by='task');valid<-is.finite(z$rmse.x)&is.finite(z$rmse.y)
  if(restrict) valid<-valid & z$diagnostic_ok.x & z$diagnostic_ok.y
  difference<-z$rmse.x[valid]-z$rmse.y[valid];n<-length(difference)
  delta<-if(n)mean(difference) else NA_real_;se<-if(n>1)sd(difference)/sqrt(n) else NA_real_
  pairs[[length(pairs)+1]]<-data.frame(cell=cell,target=target,weighting=weight,method_a=pair[1],reference_b=pair[2],diagnostic_restricted=restrict,
    attempted=sum(design$cell==cell),paired=n,difference=delta,mcse=se,
    mc_lower=delta-1.96*se,mc_upper=delta+1.96*se)
 }
}
write.csv(do.call(rbind,pairs),file.path(report,'paired_precision.csv'),row.names=FALSE)
file.copy('analysis/08_event_informed_simulation/review.R',report,overwrite=TRUE)
writeLines(c('Interpret these summaries using the run design, replication count, diagnostic availability and Monte Carlo uncertainty.',
 'Intervals quantify Monte Carlo uncertainty in mean dataset-level RMSE contrasts; they are not patient confidence intervals.',
 'Comparisons condition on joint availability; read alongside attempted counts and component failures.',
 'Ordinary normal-approximation MC intervals may be unreliable with few pairs or extreme errors.',
 'The manuscript production design uses 500 replications per setting; other run sizes are exploratory.'),file.path(report,'README.txt'))
cat('Review:',report,'\n')

