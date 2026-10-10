# Stream task tables to disk; never retain all production predictions in memory.
v3_aggregate <- function(out,design,task_dir=file.path(out,'tasks')) {
 status<-vector('list',nrow(design));first_metrics<-TRUE;first_diagnostics<-TRUE
 for(i in seq_len(nrow(design))) {
  x<-readRDS(file.path(task_dir,paste0(design$task[i],'.rds')))
  stopifnot(identical(x$task$task,design$task[i]))
  status[[i]]<-data.frame(task=x$task$task,status=x$status,error=x$error)
  if(x$status!='complete')next
  m<-cbind(x$task[rep(1,nrow(x$metrics)),],x$metrics)
  write.table(m,file.path(out,'metrics.csv'),sep=',',row.names=FALSE,col.names=first_metrics,append=!first_metrics)
  first_metrics<-FALSE
  d<-do.call(rbind,lapply(names(x$fitted),function(method){
   z<-x$fitted[[method]]$diagnostics;cbind(x$task[rep(1,nrow(z)),],estimator=method,z)
  }))
  write.table(d,file.path(out,'diagnostics.csv'),sep=',',row.names=FALSE,col.names=first_diagnostics,append=!first_diagnostics)
  first_diagnostics<-FALSE
 }
 status<-do.call(rbind,status);write.csv(status,file.path(out,'task_status.csv'),row.names=FALSE)
 status
}
