v3_strata <- function() {
  s <- expand.grid(a=factor(c('a1','a2')), b=factor(paste0('b',1:3)),
                   c=factor(paste0('c',1:3)), d=factor(paste0('d',1:4)))
  s$stratum <- factor(seq_len(nrow(s)))
  # Unequal joint probabilities, with an explicit b-by-c association.
  w <- c(.55,.45)[s$a] * c(.65,.25,.10)[s$b] *
       c(.50,.30,.20)[s$c] * c(.35,.30,.20,.15)[s$d]
  w <- w * exp(.5 * (as.integer(s$b)==as.integer(s$c)))
  s$weight <- w/sum(w)
  s
}

v3_positive_mass <- function(mu, shape) -expm1(dnbinom(0,mu=mu,size=shape,log=TRUE))


# Orthonormal contrasts give exchangeable zero-sum level effects under IID normal penalties.
v3_contrast <- function(k) {
 h <- contr.helmert(k)
 sweep(h,2,sqrt(colSums(h*h)),'/')
}
v3_encode <- function(d) {
 for(nm in c('a','b','c','d')) contrasts(d[[nm]]) <- v3_contrast(nlevels(d[[nm]]))
 d
}
v3_simulate <- function(task,effect_multiplier=1) {
 stopifnot(length(effect_multiplier)==1,is.finite(effect_multiplier),effect_multiplier>0)
 set.seed(task$seed);s <- v3_encode(v3_strata())
 score <- c(-.25,.25)[s$a]+c(-.3,0,.3)[s$b]+c(-.4,0,.4)[s$c]+c(-.3,-.1,.1,.3)[s$d]
 score <- effect_multiplier*score
 u <- if(task$pattern=='additive') rep(0,nrow(s)) else rnorm(nrow(s),0,.35)
 eta <- score+u
 positive_eta <- if(task$pattern=='opposing') -eta else .6*score+u
 inv <- function(b) {
   if(task$family=='hurdle') return(plogis(b+eta))
   mu <- exp(b+eta)
   if(task$family=='poisson') -expm1(-mu) else v3_positive_mass(mu,v3_config$shape)
 }
 intercept <- uniroot(function(b) sum(s$weight*inv(b))-task$p,c(-30,20),tol=1e-11)$root
 s$p <- inv(intercept)
 if(task$family=='hurdle') {
   case_weights <- s$weight*s$p/sum(s$weight*s$p)
   positive_intercept <- uniroot(function(b) {
     mu <- exp(b+positive_eta)
     sum(case_weights*mu/v3_positive_mass(mu,v3_config$shape))-task$positive_mean
   },c(-25,20),tol=1e-11)$root
   s$parent_mu <- exp(positive_intercept+positive_eta)
 } else s$parent_mu <- exp(intercept+eta)
 s$shape <- if(task$family=='poisson') Inf else v3_config$shape
 mass <- if(task$family=='poisson') -expm1(-s$parent_mu) else v3_positive_mass(s$parent_mu,s$shape)
 s$m_plus <- s$parent_mu/mass;s$expected <- s$p*s$m_plus
 conditional_tail <- function(k) {
   tail <- if(task$family=='poisson') ppois(k-1,s$parent_mu,lower.tail=FALSE) else
     pnbinom(k-1,mu=s$parent_mu,size=s$shape,lower.tail=FALSE)
   tail/mass
 }
 s$recurrent_given_positive <- conditional_tail(2)
 s$recurrent <- s$p*s$recurrent_given_positive
 s$tail <- s$p*conditional_tail(v3_config$tail_threshold)
 membership <- sample.int(nrow(s),task$n,replace=TRUE,prob=s$weight)
 dat <- s[membership,c('a','b','c','d','stratum')];rownames(dat)<-NULL
 mu <- s$parent_mu[membership]
 if(task$family=='poisson') y <- rpois(task$n,mu)
 if(task$family=='nb') y <- rnbinom(task$n,mu=mu,size=v3_config$shape)
 if(task$family=='hurdle') {
   y <- integer(task$n);ind <- which(rbinom(task$n,1,s$p[membership])==1)
   if(length(ind)) {
     p0 <- dnbinom(0,mu=mu[ind],size=v3_config$shape)
     y[ind] <- qnbinom(p0+runif(length(ind))*(1-p0),mu=mu[ind],size=v3_config$shape)
   }
 }
 dat$y <- y;dat$positive <- as.integer(y>0);dat$frequency <- 1L
 s$n <- tabulate(membership,nbins=72)
 s$n_positive <- tabulate(membership[y>0],nbins=72)
 s$n_recurrent <- tabulate(membership[y>=2],nbins=72)
 s$n_tail <- tabulate(membership[y>=v3_config$tail_threshold],nbins=72)
 s$frequency <- 1L # Prediction rows represent one individual each.
 list(data=dat,truth=s,task=task)
}
v3_compress <- function(sim) {
 d <- sim$data
 # Frequency weighting of identical individual observations preserves the likelihood.
 f <- aggregate(d$frequency,list(stratum=as.integer(d$stratum),y=d$y),sum)
 z <- sim$truth[f$stratum,c('a','b','c','d','stratum')]
 z$y <- f$y;z$positive <- as.integer(z$y>0);z$frequency <- f$x
 sim$data <- v3_encode(z);sim
}

