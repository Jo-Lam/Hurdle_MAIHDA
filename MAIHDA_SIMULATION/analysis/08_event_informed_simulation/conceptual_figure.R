source('R/report_paths.R')
pub<-report_publication
fig<-function(){
 par(mar=c(0,0,0,0));plot.new();plot.window(xlim=c(0,12),ylim=c(0,7),xaxs='i',yaxs='i')
 text(6,6.55,'Same average, different experiences',font=2,cex=1.5)
 text(6,6.08,'Two hypothetical populations, each with 1,000 people observed for the same period',cex=.95)
 xs<-c(2.6,6,9.4);heads<-c('People with any event','Mean among affected people','Total across the population')
 for(k in 1:3)text(xs[k],5.3,heads[k],cex=.91,font=2)
 for(i in 1:2){y<-c(4.2,2.45)[i];cc<-c('#007C91','#A94B82')[i];text(.3,y,paste('Population',c('A','B')[i]),adj=0,srt=90,cex=.95)
  vals<-if(i==1)c('100 people','1 event','100 events') else c('20 people','5 events','100 events')
  sub<-if(i==1)c('10% affected','per affected person','0.10 events per person') else c('2% affected','per affected person','0.10 events per person')
  for(k in 1:3){rect(xs[k]-1.35,y-.57,xs[k]+1.35,y+.57,col=if(k==3)'#F2F2F2' else '#F5FAFB',border=cc,lwd=1.6);text(xs[k],y+.13,vals[k],cex=1.3,font=2,col=cc);text(xs[k],y-.28,sub[k],cex=.86)}
  text(4.3,y,'x',cex=1.4);text(7.7,y,'=',cex=1.4)
 }
 text(6,1.2,'An identical overall average can conceal differences in how many people are affected',cex=.97)
 text(6,.87,'and how often affected people experience events.',cex=.97)
 text(6,.3,'Illustration only: these are not estimates from the simulation or from a real population.',cex=.82,col='#555555')
}
pdf(file.path(pub,'figures/figure1_same_average.pdf'),width=12,height=7,useDingbats=FALSE);fig();dev.off()
png(file.path(pub,'figures/figure1_same_average.png'),width=2160,height=1260,res=180);fig();dev.off()
