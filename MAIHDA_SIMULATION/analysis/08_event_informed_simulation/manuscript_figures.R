# Reproducible manuscript figures; reads frozen reports, never refits.
source('R/report_paths.R')
run<-report_run
pub<-report_publication
out<-file.path(pub,'figures');dir.create(out,showWarnings=FALSE)
g<-read.csv(file.path(run,'design.csv'));g<-g[!duplicated(g$cell),];g<-g[order(g$cell),]
a<-read.csv(file.path(run,'review/availability.csv'));r<-read.csv(file.path(run,'review/paired_precision.csv'))
labels<-with(g,sprintf('%02d  %-8s %4s%%  %3d  %s',cell,ifelse(role=='core',pattern,ifelse(role=='stress','stress',family)),100*p,affected,ifelse(is.na(positive_mean),'-',positive_mean)))
colours<-c('#007C91','#D9D9D9','#D88B38')
fig1<-function(){
 par(mfrow=c(1,2),oma=c(6,0,5,0))
 for(k in 1:2){
  par(mar=c(4,if(k==1)13 else 1.5,2,1));comp<-c('additive_occurrence','additive_positive')[k]
  z<-subset(a,estimator=='MAP_sd1' & component==comp);z<-z[match(g$cell,z$cell),]
  stopifnot(nrow(z)==36,all(z$diagnostic_ok+z$unsupported<=500))
  plot(NA,xlim=c(0,500),ylim=c(.3,36.7),yaxt='n',xlab='Datasets (out of 500)',ylab='',bty='n',main=c('A  Occurrence','B  Positive counts')[k],cex.main=1)
  abline(v=seq(0,500,100),col='#EEEEEE');for(i in 1:36){y<-37-i;left<-0;vals<-c(z$diagnostic_ok[i],z$unsupported[i],500-z$diagnostic_ok[i]-z$unsupported[i]);for(j in 1:3){rect(left,y-.33,left+vals[j],y+.33,col=colours[j],border=NA);left<-left+vals[j]}}
  if(k==1)axis(2,at=36:1,labels=labels,las=1,tick=FALSE,cex.axis=.66)
  abline(h=c(12.5,4.5),lty=2,col='#999999')
 }
 mtext('Availability of primary additive hurdle components',outer=TRUE,line=3,cex=1.1,font=2)
 mtext('Row: setting / pattern or control family / occurrence / expected affected / positive mean',outer=TRUE,line=1.7,cex=.72)
 par(fig=c(0,1,0,1),oma=c(0,0,0,0),new=TRUE,mar=c(0,0,0,0));plot.new();legend('bottom',horiz=TRUE,legend=c('Eligible','Unsupported','Numerical failure'),fill=colours,bty='n',cex=.85,inset=.015)
}
fig2<-function(){
 par(mfrow=c(1,3),oma=c(6,0,4,0));par(cex=1);g2<-g[g$cell<=24,]
 for(k in 1:3){
  target_name<-c('p','m_plus','expected')[k];scale<-c(10000,1,10000)[k]
  z<-subset(r,cell<=24 & method_a=='MAP_sd1:hurdle' & reference_b=='MAP_sd1:nb' & diagnostic_restricted & target==target_name);stopifnot(nrow(z)==48,all(is.finite(z$difference)))
  lim<-range(c(z$mc_lower,z$mc_upper,0))*scale;pad<-diff(lim)*.08;xx<-c(lim[1]-pad,lim[2]+pad*3.5)
  par(mar=c(5,if(k==1)11 else 1,2,1))
  plot(NA,xlim=xx,ylim=c(.3,25),yaxt='n',ylab='',xlab=c('Difference in RMSE\n(people per 10,000)','Difference in RMSE\n(events per affected person)','Difference in RMSE\n(events per 10,000 people)')[k],main=c('A  Occurrence','B  Positive mean','C  Total mean')[k],cex.main=.9,bty='n')
  abline(v=0,lty=2,col='#777777');abline(h=c(8.5,16.5),col='#DDDDDD')
  if(k==1)axis(2,at=24:1,labels=labels[1:24],las=1,tick=FALSE,cex.axis=.8)
  for(w in c('equal_stratum','population')){zz<-z[z$weighting==w,];yy<-25-zz$cell+if(w=='equal_stratum') .13 else -.13;cc<-if(w=='equal_stratum') '#007C91' else '#A94B82';segments(zz$mc_lower*scale,yy,zz$mc_upper*scale,yy,col=cc,lwd=1.2);points(zz$difference*scale,yy,pch=if(w=='equal_stratum')16 else 17,col=cc,cex=.65)}
  zz<-z[z$weighting=='equal_stratum',];text(xx[2],25-zz$cell,zz$paired,pos=2,cex=.7,col='#555555');text(xx[2],24.85,'Pairs',pos=2,cex=.8)
 }
 mtext('Hurdle minus negative-binomial error: core settings',outer=TRUE,line=2,cex=1.1,font=2)
 mtext('Negative favours hurdle; positive favours NB. Intervals show Monte Carlo uncertainty.',outer=TRUE,line=.7,cex=.8)
 par(fig=c(0,1,0,1),oma=c(0,0,0,0),new=TRUE,mar=c(0,0,0,0));plot.new();legend('bottom',horiz=TRUE,legend=c('Equal-stratum weights','Population weights'),pch=c(16,17),col=c('#007C91','#A94B82'),bty='n',cex=.85,inset=.005)
}
for(i in 1:2){fn<-if(i==1)fig1 else fig2;name<-c('figure1_availability','figure2_paired_accuracy')[i];width<-if(i==1)11 else 15
 pdf(file.path(out,paste0(name,'.pdf')),width=width,height=10,useDingbats=FALSE);fn();dev.off()
 png(file.path(out,paste0(name,'.png')),width=width,height=10,units='in',res=180);fn();dev.off()
}
file.copy('analysis/08_event_informed_simulation/manuscript_figures.R',out,overwrite=TRUE)



