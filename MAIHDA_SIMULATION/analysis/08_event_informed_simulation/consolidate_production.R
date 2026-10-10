# Final reporting only: does not generate or refit any dataset.
source('R/report_paths.R')
p<-report_run
out<-file.path(p,'consolidated');dir.create(out,showWarnings=FALSE)
q<-read.csv(file.path(p,'review/performance.csv'));r<-read.csv(file.path(p,'review/paired_precision.csv'));v<-read.csv(file.path(p,'review/availability.csv'));x<-read.csv(file.path(p,'review/production_precision_projection.csv'))
s<-read.csv(file.path(p,'task_status.csv'));a<-read.csv(file.path(p,'review/invariant_audit.csv'));g<-read.csv(file.path(p,'design.csv'))
stopifnot(nrow(s)==18000L,!anyDuplicated(s$task),all(s$status=='complete'),nrow(a)==18000L,all(a$truth_ok),all(a$prediction_domain_ok),nrow(g)==18000L)
x$achieved_half_width<-1.96*x$mcse;x$precision_met<-x$achieved_half_width<=x$target_half_width
write.csv(x,file.path(out,'primary_precision.csv'),row.names=FALSE)
write.csv(subset(x,!precision_met),file.path(out,'precision_exceptions.csv'),row.names=FALSE)
h<-subset(q,estimator=='MAP_sd1' & specification=='additive' & model=='hurdle' & weighting=='equal_stratum' & diagnostic_restricted & target %in% c('p','m_plus','expected'))
av<-aggregate(cbind(attempted,available)~role+target,h,sum)
# Wilson intervals describe the pooled, equally represented scenario mixture, not any one setting.
ph<-av$available/av$attempted;den<-1+1.96^2/av$attempted
av$proportion<-ph;av$lower<-(ph+1.96^2/(2*av$attempted)-1.96*sqrt(ph*(1-ph)/av$attempted+1.96^2/(4*av$attempted^2)))/den
av$upper<-(ph+1.96^2/(2*av$attempted)+1.96*sqrt(ph*(1-ph)/av$attempted+1.96^2/(4*av$attempted^2)))/den
write.csv(av,file.path(out,'hurdle_availability.csv'),row.names=FALSE)
burden<-aggregate(cbind(attempted,available)~affected+positive_mean,subset(h,role=='core' & target=='m_plus'),sum);write.csv(burden,file.path(out,'positive_availability_by_burden.csv'),row.names=FALSE)
y<-subset(r,method_a %in% c('MAP_sd1:hurdle','MAP_sd0.5:hurdle') & reference_b %in% c('MAP_sd1:nb','MAP_sd1:poisson','MAP_sd0.5:nb','MAP_sd0.5:poisson') & target %in% c('p','m_plus','expected'))
y$role<-ifelse(y$cell<=24,'core',ifelse(y$cell<=32,'control','stress'));y$lower<-y$difference<0;y$clear_lower<-y$mc_upper<0;y$clear_higher<-y$mc_lower>0
counts<-aggregate(cbind(lower,clear_lower,clear_higher)~role+target+weighting+method_a+reference_b+diagnostic_restricted,y,sum);write.csv(counts,file.path(out,'comparison_direction_counts.csv'),row.names=FALSE)
sel<-subset(q,estimator=='MAP_sd1' & specification=='additive');write.csv(sel,file.path(out,'selected_performance.csv'),row.names=FALSE)
write.csv(subset(v,estimator=='MAP_sd1'),file.path(out,'selected_component_diagnostics.csv'),row.names=FALSE)
cat('Integrity passed. Precision:',sum(x$precision_met),'/',nrow(x),'\n');print(av);print(burden)
cat('Penalty .5 core directions\n');print(subset(counts,role=='core' & method_a=='MAP_sd0.5:hurdle' & diagnostic_restricted))
# Preserve the reporting implementation independently of frozen simulation sources.
file.copy('analysis/08_event_informed_simulation/consolidate_production.R',out,overwrite=TRUE)
