# Run from this folder: Rscript --vanilla make_information_figures.R
# Reads only the included frozen, filtered results; no model fitting.
a <- commandArgs(trailingOnly=FALSE)
s <- sub('^--file=', '', a[grepl('^--file=', a)])
out <- if(length(s)) dirname(normalizePath(s)) else getwd()
z <- read.csv(file.path(out,'plot_data.csv'))
stopifnot(nrow(z)==72, all(z$attempted==500), all(z$available<=z$attempted), all(is.finite(z$mean_rmse)))
models <- c('poisson','nb','hurdle'); colors <- c('#777777','#0072B2','#D55E00'); shapes <- c(15,17,16)
patterns <- c('additive','aligned','opposing')
pattern_labels <- c('No stratum interaction effects','Interaction effects: same direction','Interaction effects: opposite directions')
cols <- expand.grid(p=c(.005,.02),positive_mean=c(1.2,3))
# Same error scale across the whole figure; intervals describe Monte Carlo precision.
ymax <- max(z$mean_rmse+1.96*z$mcse_mean_rmse)*1.10
fmt <- function(x) format(x,big.mark=',',scientific=FALSE,trim=TRUE)
figure <- function(availability=FALSE){
 par(mfrow=c(3,4),oma=c(5.8,3.3,6.1,1),mar=c(3.4,3.6,3.3,.8),family='sans',las=1,mgp=c(2.1,.65,0),cex=.92)
 for(i in 1:3) for(j in 1:4){
  dat <- z[z$pattern==patterns[i] & z$p==cols$p[j] & z$positive_mean==cols$positive_mean[j],]
  plot(NA,xlim=c(.76,2.24),ylim=if(availability)c(0,104) else c(0,ymax),xaxt='n',xlab='',ylab='',bty='l',yaxs='i')
  abline(h=if(availability)seq(0,100,25) else pretty(c(0,ymax)),col='#E8E8E8',lwd=.7)
  for(k in 1:3){
   d<-dat[dat$model==models[k],];d<-d[order(d$affected),];stopifnot(nrow(d)==2)
   # Small offsets prevent complete overlap at 100%; the x axis is categorical.
   xx<-1:2+(k-2)*.04
   yy<-if(availability)100*d$available/d$attempted else d$mean_rmse
   if(!availability){lo<-pmax(0,yy-1.96*d$mcse_mean_rmse);hi<-yy+1.96*d$mcse_mean_rmse;segments(xx,lo,xx,hi,col=colors[k],lwd=1);segments(xx-.025,lo,xx+.025,lo,col=colors[k]);segments(xx-.025,hi,xx+.025,hi,col=colors[k])}
   lines(xx,yy,col=colors[k],lwd=1.7,lty=k);points(xx,yy,col=colors[k],pch=shapes[k],cex=.95)
  }
  if(!availability){hh<-dat[dat$model=='hurdle',];hh<-hh[order(hh$affected),];text(1:2,rep(ymax*.96,2),labels=paste0('Common fits: ',hh$common_acceptable),cex=.7,col='#444444')}
  ns<-c(100,500)/cols$p[j]
  axis(1,at=1:2,labels=paste0(c('100','500'),' affected\nN = ',fmt(ns)),cex.axis=.9,tick=FALSE)
  mtext(pattern_labels[i],side=3,line=1.3,cex=.74,font=2)
  mtext(sprintf('Occurrence %s%%  |  Frequency %s',100*cols$p[j],cols$positive_mean[j]),side=3,line=.15,cex=.73)
 }
 mtext(if(availability)'Figure 2. Availability of frequency estimates' else 'Figure 3. Accuracy of frequency estimates',side=3,outer=TRUE,line=4.1,cex=1.4,font=2)
 mtext('Frequency = average events among people with at least one event',side=3,outer=TRUE,line=2.5,cex=.95)
 mtext(if(availability)'Acceptable fits (%)' else 'Mean estimation error (RMSE, events per affected person)',side=2,outer=TRUE,line=1.5,las=0,cex=1)
 mtext('Expected number affected; N is the total sample size',side=1,outer=TRUE,line=1,cex=1)
 mtext(if(availability)'All 500 datasets per setting form the denominator. Passing checks does not establish accuracy.' else 'Equal weight per stratum. All three models use the same acceptable datasets within each setting.',side=1,outer=TRUE,line=2.7,cex=.86)
 mtext(if(availability)'Primary regularised additive models; 24 main settings. Lines connect two tested information levels.' else 'Bars: approximate 95% Monte Carlo intervals for mean RMSE, not uncertainty in patient outcomes.',side=1,outer=TRUE,line=4,cex=.82)
 par(fig=c(0,1,0,1),oma=c(0,0,0,0),mar=c(0,0,0,0),new=TRUE);plot.new()
 legend('top',inset=.065,horiz=TRUE,legend=c('Poisson','Negative binomial (NB2)','Hurdle NB2'),col=colors,pch=shapes,lty=1:3,lwd=1.7,bty='n',cex=1.05)
}
for(av in c(FALSE,TRUE)){
 name<-if(av)'Figure_2_frequency_availability' else 'Figure_3_frequency_accuracy'
 png(file.path(out,paste0(name,'.png')),width=16,height=11,units='in',res=200);figure(av);dev.off()
 pdf(file.path(out,paste0(name,'.pdf')),width=16,height=11,useDingbats=FALSE);figure(av);dev.off()
 svg(file.path(out,paste0(name,'.svg')),width=16,height=11);figure(av);dev.off()
}
