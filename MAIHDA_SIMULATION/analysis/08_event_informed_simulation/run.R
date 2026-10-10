source('R/project_utils.R');set_project_root()
module <- 'analysis/08_event_informed_simulation'
for(name in c('config.R','simulate.R','fit_evaluate.R','aggregate.R')) source(file.path(module,name))
assert_packages('glmmTMB');args<-parse_named_args()
if(length(setdiff(names(args),c('replications','start_replication','run_id','resume')))) stop('Unknown argument.')
reps<-arg_value(args,'replications',1L,'integer')
start_rep<-arg_value(args,'start_replication',1L,'integer');design<-v3_design(reps,start_rep)
run_id<-arg_value(args,'run_id','example36')
if(!grepl('^[A-Za-z0-9_-]+$',run_id))stop('Invalid run ID.')
out<-file.path('outputs','07_event_informed_simulation',run_id)
files<-c(file.path(module,c('config.R','simulate.R','fit_evaluate.R','aggregate.R','run.R')), 'R/project_utils.R')
spec<-list(config=v3_config,design=design,hashes=tools::md5sum(files),R=R.version.string,packages=package_versions('glmmTMB'))
if(arg_value(args,'resume',FALSE,'logical')) {
 if(!identical(readRDS(file.path(out,'run_spec.rds')),spec))stop('Resume refused: changed source or design.')
} else {
 write_run_start(out,'event-informed simulation',args,'glmmTMB')
 saveRDS(spec,file.path(out,'run_spec.rds'));write.csv(design,file.path(out,'design.csv'),row.names=FALSE)
 dir.create(file.path(out,'source'));for(f in files)file.copy(f,file.path(out,'source',basename(f)))
}
dir.create(file.path(out,'tasks'),showWarnings=FALSE)
penalties<-c(ML=NA_real_,MAP_sd0.5=.5,MAP_sd1=1)
for(i in seq_len(nrow(design))) {
 task<-design[i,,drop=FALSE];path<-file.path(out,'tasks',paste0(task$task,'.rds'))
 if(file.exists(path)) {
  if(!identical(readRDS(path)$task,task))stop('Checkpoint mismatch.')
  next
 }
 cat(sprintf('[%d/%d] %s\n',i,nrow(design),task$task))
 z<-tryCatch({
  sim<-v3_compress(v3_simulate(task));fitted<-list();metrics<-list()
  for(method in names(penalties)) {
   fitted[[method]]<-v3_fit(sim,penalty_sd=penalties[[method]])
   metrics[[method]]<-cbind(estimator=method,v3_evaluate(fitted[[method]]$predictions,sim$truth))
  }
  list(status='complete',task=task,truth=sim$truth,compressed_rows=nrow(sim$data),fitted=fitted,
       metrics=do.call(rbind,metrics),error='')
 },error=function(e)list(status='failed',task=task,error=conditionMessage(e)))
 saveRDS(z,paste0(path,'.tmp'));if(!file.rename(paste0(path,'.tmp'),path))stop('Checkpoint rename failed.')
}
status<-v3_aggregate(out,design)
write_run_end(out,if(any(status$status=='failed'))'failed' else 'complete','Inspect component diagnostics, prediction errors and paired precision before interpretation.')
cat('Outputs:',out,'\n')
