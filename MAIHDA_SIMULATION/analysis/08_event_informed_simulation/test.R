source('analysis/08_event_informed_simulation/config.R')
source('analysis/08_event_informed_simulation/simulate.R')
source('analysis/08_event_informed_simulation/fit_evaluate.R')
g <- v3_design(1)
stopifnot(nrow(g)==36,sum(g$role=='core')==24,sum(g$role=='control')==8,sum(g$role=='stress')==4,
          identical(g$seed,v3_design(2)$seed[v3_design(2)$replication==1]))
for(i in seq_len(nrow(g))) {
 sim <- v3_simulate(g[i,]);t <- sim$truth
 stopifnot(nrow(sim$data)==g$n[i],sum(t$n)==g$n[i],abs(sum(t$weight*t$p)-g$p[i])<1e-9,
   abs(sum(t$n_positive)-sum(sim$data$positive))<1e-10,
   all(abs(t$expected-t$p*t$m_plus)<1e-12),
   all(abs(t$recurrent-t$p*t$recurrent_given_positive)<1e-12),
   all(t$tail<=t$recurrent),all(t$recurrent<=t$p),all(sim$data$y>=0),all(sim$data$y==floor(sim$data$y)))
 if(g$family[i]=='hurdle') stopifnot(abs(sum(t$weight*t$p*t$m_plus)/sum(t$weight*t$p)-g$positive_mean[i])<1e-8)
 compressed <- v3_compress(sim)
 stopifnot(sum(compressed$data$frequency)==g$n[i],sum(compressed$data$y*compressed$data$frequency)==sum(sim$data$y))
}
for(k in 2:4) {
 h<-v3_contrast(k)
 stopifnot(max(abs(crossprod(h)-diag(k-1)))<1e-12,
           max(abs(h%*%t(h)-(diag(k)-matrix(1/k,k,k))))<1e-12)
}
case <- subset(g,role=='core' & p==.02 & affected==500 & positive_mean==3 & pattern=='aligned')
sim <- v3_simulate(case); compressed <- v3_compress(sim)
for(component in c('poisson','nb','occurrence','positive')) {
 family <- switch(component,poisson=poisson(),nb=glmmTMB::nbinom2(),occurrence=binomial(),positive=glmmTMB::truncated_nbinom2())
 form <- if(component=='occurrence') positive~a+b+c+d+(1|stratum) else y~a+b+c+d+(1|stratum)
 a <- sim$data;b <- compressed$data
 if(component=='positive') {a<-subset(a,y>0);b<-subset(b,y>0)}
 for(penalty in c(NA_real_,.5)) {
  fit_a <- v3_fit_component(form,a,family,component,penalty)
  fit_b <- v3_fit_component(form,b,family,component,penalty)
  stopifnot(!is.null(fit_a$fit),!is.null(fit_b$fit))
  pa <- predict(fit_a$fit,newdata=sim$truth,type='response',allow.new.levels=TRUE)
  pb <- predict(fit_b$fit,newdata=sim$truth,type='response',allow.new.levels=TRUE)
  relative <- max(abs(pa-pb)/pmax(1,abs(pa)))
  objective_difference <- abs(fit_a$fit$fit$objective-fit_b$fit$fit$objective)
  cat(component,'penalty',penalty,'prediction difference',relative,'objective difference',objective_difference,'\n')
  stopifnot(relative<.002,objective_difference<.01)
 }
}
# Actual reordering check for isotropic penalties on the contrast subspace.
a <- subset(compressed$data,y>0); b <- a; grid <- sim$truth
for(nm in c('a','b','c','d')) {
 b[[nm]]<-factor(b[[nm]],levels=rev(levels(b[[nm]])))
 grid[[nm]]<-factor(grid[[nm]],levels=rev(levels(grid[[nm]])))
}
b<-v3_encode(b);grid<-v3_encode(grid)
fa<-v3_fit_component(y~a+b+c+d+(1|stratum),a,glmmTMB::truncated_nbinom2(),'positive',.5)
fb<-v3_fit_component(y~a+b+c+d+(1|stratum),b,glmmTMB::truncated_nbinom2(),'positive',.5)
pa<-predict(fa$fit,newdata=sim$truth,type='response',allow.new.levels=TRUE)
pb<-predict(fb$fit,newdata=grid,type='response',allow.new.levels=TRUE)
stopifnot(max(abs(pa-pb)/pmax(1,abs(pa)))<.002)
# Verify the end-to-end evaluator retains conditional recurrence.
z<-v3_fit(compressed,penalty_sd=.5)
m<-v3_evaluate(z$predictions,sim$truth)
stopifnot(nrow(m)==72,'recurrent_given_positive' %in% m$target)
cat('V3 tests passed: 36-cell calibration, identities, compression, penalty symmetry and evaluation.\n')

# Reserved replication ranges are disjoint from selection and development data.
a <- v3_design(50,1001);b <- v3_design(250,2001)
stopifnot(!any(a$seed %in% v3_design(103)$seed),!any(a$seed %in% b$seed),
          identical(a$seed[a$replication==1001],v3_design(1,1001)$seed))
cat('Disjoint pilot/production seed ranges and expansion stability passed.\n')
