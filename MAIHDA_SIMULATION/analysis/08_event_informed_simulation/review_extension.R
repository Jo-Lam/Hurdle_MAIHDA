source('R/report_paths.R')
# Post-production analyses; reads saved predictions, never refits models.
library(data.table)
setDTthreads(1)
root <- report_run
out <- file.path(root,'review_extension_20260928');dir.create(out,showWarnings=FALSE)
design <- fread(file.path(root,'design.csv'))
source('analysis/08_event_informed_simulation/simulate.R')
s <- v3_strata();X <- model.matrix(~a+b+c+d,s);Q <- qr.Q(qr(X));P <- diag(72)-tcrossprod(Q)
stopifnot(max(abs(P%*%X))<1e-12,max(abs(P%*%P-P))<1e-12)
# Fixed population-size groups, 24 strata each; deterministic index breaks ties.
tercile <- integer(72);tercile[order(s$weight,seq_len(72))] <- rep(c(1,2,3),each=24)
rows <- list();latent <- list();branches <- list();flags <- list();nrowid<-0L;lid<-0L;bid<-0L;fid<-0L
for(cell in 1:36){
 if(file.exists(file.path(out,sprintf("cell%02d.rds",cell)))) {cat("Retained completed setting",cell,"\n");next}
 cell_id <- cell
 tasks <- design[design[['cell']] == cell_id]
 for(ii in seq_len(nrow(tasks))){
  task<-tasks[ii];z<-readRDS(file.path(root,'tasks',paste0(task$task,'.rds')))
  stopifnot(z$status=='complete',identical(as.character(z$truth$stratum),as.character(s$stratum)))
  tr<-z$truth
  for(est in c('ML','MAP_sd1','MAP_sd0.5')){
   d<-z$fitted[[est]]$predictions;d<-d[d$specification=='additive',]
   ds<-z$fitted[[est]]$diagnostics;ds<-ds[ds$specification=='additive',]
   for(target in c('p','m_plus','expected')){
    okcol<-if(target=='p')'occurrence_diagnostic_ok' else if(target=='m_plus')'positive_diagnostic_ok' else 'diagnostic_ok'
    pred<-lapply(c('poisson','nb','hurdle'),function(m)d[d$model==m,][[target]])
    names(pred)<-c('poisson','nb','hurdle')
    ok<-sapply(names(pred),function(m) all(d[d$model==m,][[okcol]])&&all(is.finite(pred[[m]])))
    branch<-if(ok['hurdle'])'hurdle' else if(ok['nb'])'nb' else 'unavailable'
    bid<-bid+1L;branches[[bid]]<-list(cell=cell,task=task$task,role=task$role,estimator=est,target=target,branch=branch)
    pred$fallback<-if(branch=='unavailable')rep(NA_real_,72) else pred[[branch]];ok<-c(ok,fallback=branch!='unavailable')
    y<-tr[[target]]
    for(m in names(pred)){
     x<-pred[[m]];finite<-all(is.finite(x));e<-x-y
     for(g in 0:3){
      ix<-if(g==0)seq_len(72) else which(tercile==g)
      weights<-if(g==0)list(equal_stratum=rep(1/72,72),population=tr$weight) else list(equal_stratum=rep(1/24,24))
      for(wn in names(weights)){
       w<-weights[[wn]];tm<-sum(w*y[ix]);rm<-if(finite)sqrt(sum(w*e[ix]^2)) else NA_real_
       cr<-if(finite)sqrt(sum(w*(e[ix]-sum(w*e[ix]))^2)) else NA_real_
       nrowid<-nrowid+1L;rows[[nrowid]]<-list(cell=cell,task=task$task,role=task$role,pattern=task$pattern,estimator=est,model=m,target=target,tercile=g,weighting=wn,ok=unname(ok[m]),finite=finite,rmse=rm,bias=if(finite)sum(w*e[ix])else NA_real_,true_mean=tm,relative_rmse=rm/tm,contrast_rmse=sqrt(2)*cr,
         spearman=if(finite&&sd(x[ix])>1e-10&&sd(y[ix])>1e-10)cor(x[ix],y[ix],method='spearman')else NA_real_)
      }
     }
     if(target=='m_plus'&&m!='fallback'){
      use<-if(m=='hurdle')'additive_positive' else paste0('additive_',m)
      dg<-ds[ds$component==use,]
      fid<-fid+1L;flags[[fid]]<-list(cell=cell,task=task$task,role=task$role,estimator=est,model=m,ok=unname(ok[m]),finite=finite,relative_rmse=if(finite)sqrt(mean(e^2))/mean(y)else NA_real_,max_prediction=if(finite)max(x)else NA_real_,min_shape=min(d[d$model==m,]$shape,na.rm=TRUE),max_coefficient=dg$max_abs_fixed_coefficient,support=dg$data_support_ok,optimiser=dg$optimiser_ok,hessian=dg$hessian_ok,variance=dg$variance,warning=dg$warnings,error=dg$error)
     }
    }
   }
   # Identifiable category-orthogonal part of the latent hurdle predictors, not raw BLUPs.
   h<-d[d$model=='hurdle',]
   for(comp in c('occurrence','positive')){
    ty<-if(comp=='occurrence')qlogis(tr$p)else log(tr$parent_mu)
    px<-if(comp=='occurrence')qlogis(h$p)else log(h$parent_mu)
    rt<-as.numeric(P%*%ty);rp<-as.numeric(P%*%px)
    good<-if(comp=='occurrence')all(h$occurrence_diagnostic_ok)else all(h$positive_diagnostic_ok)
    lid<-lid+1L;latent[[lid]]<-list(cell=cell,task=task$task,role=task$role,pattern=task$pattern,estimator=est,component=comp,ok=good&&all(is.finite(px)),residual_rmse=if(all(is.finite(px)))sqrt(mean((rp-rt)^2))else NA_real_,true_residual_rms=sqrt(mean(rt^2)),estimated_residual_rms=if(all(is.finite(px)))sqrt(mean(rp^2))else NA_real_,recovery_slope=if(all(is.finite(px))&&sum(rt^2)>1e-12)sum(rt*rp)/sum(rt^2)else NA_real_)
   }
  }
 }
 # Persist per-setting reports to bound memory and permit audit.
 saveRDS(list(metrics=rbindlist(rows),latent=rbindlist(latent),branches=rbindlist(branches),flags=rbindlist(flags)),file.path(out,sprintf('cell%02d.rds',cell)))
 rows<-latent<-branches<-flags<-list();nrowid<-lid<-bid<-fid<-0L
 cat('Completed saved-output analysis',cell,'/36\n');flush.console()
}
all<-lapply(1:36,function(i)readRDS(file.path(out,sprintf('cell%02d.rds',i))))
m<-rbindlist(lapply(all,'[[','metrics'));l<-rbindlist(lapply(all,'[[','latent'));b<-rbindlist(lapply(all,'[[','branches'));f<-rbindlist(lapply(all,'[[','flags'));rm(all);gc()
stopifnot(nrow(b)==18000*3*3,nrow(l)==18000*3*2)
sm<-function(d,keys){rbindlist(lapply(c(FALSE,TRUE),function(restricted){
 d[, {v<-finite & (!restricted|ok);r<-rmse[v];list(restricted=restricted,attempted=.N,available=sum(v),mean_rmse=mean(r),median_rmse=median(r),q90=as.numeric(quantile(r,.9,na.rm=TRUE)),q99=as.numeric(quantile(r,.99,na.rm=TRUE)),mean_bias=mean(bias[v]),mean_contrast_rmse=mean(contrast_rmse[v]),mean_spearman=mean(spearman[v],na.rm=TRUE),extreme2=sum(relative_rmse[v]>2),extreme10=sum(relative_rmse[v]>10))},by=keys]
 }))}
fwrite(sm(m,c('cell','role','pattern','estimator','model','target','tercile','weighting')),file.path(out,'performance_by_setting.csv'))
fwrite(sm(m,c('role','estimator','model','target','tercile','weighting')),file.path(out,'performance_by_role.csv'))
fwrite(b[,.N,by=.(role,estimator,target,branch)],file.path(out,'fallback_branches.csv'))
fwrite(l[ok==TRUE,.(available=.N,mean_residual_rmse=mean(residual_rmse),median_residual_rmse=median(residual_rmse),mean_true_rms=mean(true_residual_rms),mean_estimated_rms=mean(estimated_residual_rms),mean_recovery_slope=mean(recovery_slope,na.rm=TRUE)),by=.(role,pattern,estimator,component)],file.path(out,'latent_recovery.csv'))
fwrite(f[,.(attempted=.N,finite=sum(finite),eligible=sum(ok),extreme2_all=sum(relative_rmse>2,na.rm=TRUE),extreme10_all=sum(relative_rmse>10,na.rm=TRUE),extreme2_eligible=sum(relative_rmse>2&ok,na.rm=TRUE),extreme10_eligible=sum(relative_rmse>10&ok,na.rm=TRUE)),by=.(role,estimator,model)],file.path(out,'extreme_counts.csv'))
fwrite(f[is.finite(relative_rmse)][order(-relative_rmse)][1:50],file.path(out,'extreme_diagnostics_top50.csv'))
# Within-setting paired comparisons for strategies and estimators; no mismatched subsets.
q<-m[tercile==0]
pairs<-list(c('hurdle','nb'),c('hurdle','poisson'),c('fallback','nb'),c('fallback','hurdle'))
pr<-rbindlist(lapply(pairs,function(pair){a<-q[model==pair[1]];bb<-q[model==pair[2]];zz<-merge(a,bb,by=c('task','cell','role','estimator','target','weighting'));zz[ok.x & ok.y, {de<-rmse.x-rmse.y;se<-sd(de)/sqrt(.N);list(n=.N,difference=mean(de),mc_lower=mean(de)-1.96*se,mc_upper=mean(de)+1.96*se)},by=.(cell,role,estimator,target,weighting)][,`:=`(method=pair[1],reference=pair[2])]}))
fwrite(pr,file.path(out,'paired_comparisons.csv'))
fwrite(pr[,.(lower=sum(difference<0),clear_lower=sum(mc_upper<0,na.rm=TRUE),clear_higher=sum(mc_lower>0,na.rm=TRUE)),by=.(role,estimator,target,weighting,method,reference)],file.path(out,'direction_counts.csv'))
file.copy('analysis/08_event_informed_simulation/review_extension.R',out,overwrite=TRUE)
writeLines('Saved-output analysis complete; no simulations or fits were rerun.',file.path(out,'COMPLETE.txt'))

