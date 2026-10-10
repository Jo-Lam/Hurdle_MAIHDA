source('R/report_paths.R')
library(data.table)
root<-report_run;out<-file.path(root,'review_extension_20260928')
a<-fread(file.path(out,'performance_by_setting.csv'))[tercile==0 & model!='fallback']
b<-fread(file.path(root,'review/performance.csv'))[specification=='additive' & target %in% c('p','m_plus','expected')]
setnames(a,'restricted','diagnostic_restricted')
k<-c('cell','estimator','model','target','weighting','diagnostic_restricted')
x<-merge(a,b,by=k)
stopifnot(nrow(x)==nrow(a),all(x$available.x==x$available.y))
for(n in c('mean_rmse','median_rmse','mean_bias')){
 ax<-as.numeric(x[[paste0(n,'.x')]]);bx<-as.numeric(x[[paste0(n,'.y')]]);good<-is.finite(ax)&is.finite(bx)
 stopifnot(all(is.finite(ax)==is.finite(bx)),all(abs(ax[good]-bx[good]) <= 1e-9*pmax(1,abs(bx[good]))))
}
for(i in c(1,9,23,33)){
 z<-readRDS(file.path(out,sprintf('cell%02d.rds',i)))
 stopifnot(uniqueN(z$branches$task)==500,nrow(z$branches)==4500)
 if(i==1)stopifnot(max(z$latent$true_residual_rms)<1e-12)
 # Explicit all-pair contrast check for one saved model/target against compact formula.
 orig<-readRDS(file.path(root,'tasks',paste0(z$branches$task[1],'.rds')))
 d<-orig$fitted$MAP_sd1$predictions;d<-d[d$specification=='additive' & d$model=='hurdle',]
 e<-d$m_plus-orig$truth$m_plus
 if(all(is.finite(e))){ direct<-sqrt(mean(outer(e,e,'-')^2)); r<-z$metrics[task==orig$task$task & estimator=='MAP_sd1' & model=='hurdle' & target=='m_plus' & tercile==0 & weighting=='equal_stratum']$contrast_rmse;stopifnot(abs(direct-r)<1e-10)}
}
writeLines(sprintf('PASS: %d whole-stratum summary rows match original means, medians, bias and eligibility. Four settings audited for complete branch records; additive projected truth is zero; explicit pairwise contrast identity checked.',nrow(x)),file.path(out,'VALIDATION.txt'))
cat(readLines(file.path(out,'VALIDATION.txt')),'\n')

