v3_config <- list(version='event_informed_v3_20260921',seed=1937000L,shape=2,tail_threshold=5L,
  penalty_sd=c(.5,1),intercept_sd=1.5,
  intercept_mean=c(occurrence=qlogis(.01),positive=log(.5),count=log(.01)))
v3_design <- function(replications=1L,start_replication=1L) {
 stopifnot(length(replications)==1,is.finite(replications),replications>=1,
           replications==as.integer(replications),replications<=9999)
 stopifnot(length(start_replication)==1,is.finite(start_replication),start_replication>=1,
           start_replication==as.integer(start_replication),start_replication+replications-1<=9999)
 core <- expand.grid(p=c(.005,.02),affected=c(100,500),positive_mean=c(1.2,3),
                     pattern=c('additive','aligned','opposing'),stringsAsFactors=FALSE)
 core$family <- 'hurdle';core$role <- 'core'
 controls <- expand.grid(p=c(.005,.02),affected=c(100,500),family=c('poisson','nb'),stringsAsFactors=FALSE)
 controls$positive_mean <- NA_real_;controls$pattern <- 'aligned';controls$role <- 'control'
 stress <- expand.grid(p=.005,affected=c(10,50),positive_mean=c(1.2,3),stringsAsFactors=FALSE)
 stress$pattern <- 'aligned';stress$family <- 'hurdle';stress$role <- 'stress'
 cells <- rbind(core,controls[names(core)],stress[names(core)])
 cells$cell <- seq_len(nrow(cells));cells$n <- as.integer(round(cells$affected/cells$p))
 g <- cells[rep(seq_len(nrow(cells)),each=replications),]
 g$replication <- rep(seq.int(start_replication,length.out=replications),nrow(cells))
 g$seed <- as.integer(v3_config$seed+g$cell*10000L+g$replication)
 g$task <- sprintf('cell%02d_r%04d',g$cell,g$replication)
 rownames(g)<-NULL;g
}
