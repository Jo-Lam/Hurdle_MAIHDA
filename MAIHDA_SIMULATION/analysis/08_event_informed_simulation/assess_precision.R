# Decision support only: records evidence; never launches production automatically.
source('R/project_utils.R');set_project_root();args<-parse_named_args()
if(!identical(names(args),'run_id') || !grepl('^[A-Za-z0-9_-]+$',args$run_id))stop('Use --run-id=completed_run_id')
p<-file.path('outputs','07_event_informed_simulation',args$run_id)
if(!file.exists(file.path(p,'review/paired_precision.csv')))stop('Completed paired report required.')
g<-read.csv(file.path(p,'design.csv'));r<-read.csv(file.path(p,'review/paired_precision.csv'))
s<-read.csv(file.path(p,'task_status.csv'))
core<-unique(g$cell[g$role=='core'])
x<-r[r$cell %in% core & r$method_a=='MAP_sd1:hurdle' & r$reference_b %in% c('MAP_sd1:poisson','MAP_sd1:nb') & r$target %in% c('p','m_plus','expected') & r$diagnostic_restricted,]
tolerances<-c(p=.00025,m_plus=.05,expected=.001)
x$target_half_width<-unname(tolerances[x$target])
x$enough_pilot_pairs<-x$paired>=25 & is.finite(x$mcse)
x$projected_attempts<-ifelse(x$enough_pilot_pairs,ceiling(x$attempted*(1.96*x$mcse/x$target_half_width)^2),NA_real_)
write.csv(x,file.path(p,'review/production_precision_projection.csv'),row.names=FALSE)
# Examine every saved truth, not only the first scenario.
checks<-lapply(seq_len(nrow(g)),function(i) {
 z<-readRDS(file.path(p,'tasks',paste0(g$task[i],'.rds')))
 if(z$status!='complete')return(data.frame(task=g$task[i],truth_ok=FALSE,prediction_domain_ok=NA))
 t<-z$truth
 ok<-abs(sum(t$weight*t$p)-g$p[i])<1e-8 && sum(t$n)==g$n[i] &&
      all(abs(t$expected-t$p*t$m_plus)<1e-10) && all(abs(t$recurrent-t$p*t$recurrent_given_positive)<1e-10)
 if(g$family[i]=='hurdle')ok<-ok && abs(sum(t$weight*t$p*t$m_plus)/sum(t$weight*t$p)-g$positive_mean[i])<1e-8
 pred<-z$fitted$MAP_sd1$predictions
 finite_bounds<-function(v,lower,upper)all(v[is.finite(v)]>=lower-1e-8 & v[is.finite(v)]<=upper+1e-8)
 domain<-finite_bounds(pred$p,0,1)&&finite_bounds(pred$recurrent,0,1)&&finite_bounds(pred$tail,0,1)&&finite_bounds(pred$recurrent_given_positive,0,1)&&finite_bounds(pred$m_plus,1,Inf)&&finite_bounds(pred$expected,0,Inf)
 data.frame(task=g$task[i],truth_ok=ok,prediction_domain_ok=domain)
})
checks<-do.call(rbind,checks);write.csv(checks,file.path(p,'review/invariant_audit.csv'),row.names=FALSE)
cat('Dataset failures:',sum(s$status!='complete'),'Truth failures:',sum(!checks$truth_ok),'Prediction domain failures:',sum(!checks$prediction_domain_ok,na.rm=TRUE),'\n')
cat('Primary contrasts:',nrow(x),'At least25 pairs:',sum(x$enough_pilot_pairs),'\n')
for(n in c(250,500,1000))cat('Projected within target at',n,':',sum(x$enough_pilot_pairs & x$projected_attempts<=n,na.rm=TRUE),'/',nrow(x),'\n')
if(any(x$enough_pilot_pairs))cat('Largest supported projection:',max(x$projected_attempts,na.rm=TRUE),'\n')
writeLines(c('Requires scientific adjudication before production; this script does not authorise or launch a run.',
 'Absolute half-width targets: occurrence 0.00025; positive mean 0.05 events; total mean 0.001 events/person.',
 'Targets concern Monte Carlo precision, not clinical importance or model adequacy.',
 'Projections assume stable error variance and joint availability. Inspect extreme errors and inadequate pairs.',
 'Controls and stress tests remain reportable but are not forced to produce estimable positive components.'),file.path(p,'review/production_gate_notes.txt'))
