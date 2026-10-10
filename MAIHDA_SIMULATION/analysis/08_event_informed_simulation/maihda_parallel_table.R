# Parallel MAIHDA summaries from saved diagnostics; no refitting.
source('R/report_paths.R')
run<-report_run
pub<-report_publication
d<-read.csv(file.path(run,'diagnostics.csv'));d<-d[d$estimator=='MAP_sd1',]
g<-read.csv(file.path(run,'design.csv'));g<-g[!duplicated(g$cell),]
stat<-function(x){x<-x[is.finite(x)];if(!length(x))return(c(median=NA,q25=NA,q75=NA));setNames(c(median(x),quantile(x,c(.25,.75),names=FALSE)),c('median','q25','q75'))}
rows<-list()
for(cell in g$cell)for(comp in c('poisson','nb','occurrence','positive')){
 # Explicit column selection avoids ambiguous scenario identifiers in subset expressions.
 a<-d[d$cell==cell & d$component==paste0('simple_',comp),];b<-d[d$cell==cell & d$component==paste0('additive_',comp),]
 stopifnot(nrow(a)==500,nrow(b)==500,!anyDuplicated(a$task),!anyDuplicated(b$task))
 a<-a[order(a$task),];b<-b[order(b$task),];stopifnot(identical(a$task,b$task))
 ga<-a$optimiser_ok&a$hessian_ok&is.finite(a$variance);gb<-b$optimiser_ok&b$hessian_ok&is.finite(b$variance)
 pair<-ga&gb&a$variance>1e-8;pcv<-100*(1-b$variance[pair]/a$variance[pair])
 av<-stat(a$variance[ga]);bv<-stat(b$variance[gb]);pv<-stat(pcv)
 rows[[length(rows)+1]]<-data.frame(cell=cell,component=comp,attempted=500,simple_pass=sum(ga),additive_pass=sum(gb),simple_median=av[1],simple_q25=av[2],simple_q75=av[3],additive_median=bv[1],additive_q25=bv[2],additive_q75=bv[3],pcv_n=sum(pair),pcv_median=pv[1],pcv_q25=pv[2],pcv_q75=pv[3],pcv_negative=sum(pcv<0),simple_boundary=sum(ga&a$variance<=1e-8),additive_boundary=sum(gb&b$variance<=1e-8),observations_median=median(a$n_observations))
}
z<-do.call(rbind,rows);rownames(z)<-NULL
write.csv(z,file.path(pub,'supplementary_tables/maihda_parallel_all_settings.csv'),row.names=FALSE)
fmt<-function(v,digits=3){out<-ifelse(is.finite(v),formatC(v,format='f',digits=digits),'NA');small<-is.finite(v)&v!=0&abs(v)<10^(-digits);out[small]<-formatC(v[small],format='e',digits=1);out}
render<-function(cell){
 x<-z[z$cell==cell,];s<-g[g$cell==cell,]
 title<-sprintf('### Setting %d: %s; generating family %s; occurrence %.1f%%; %d expected affected; positive mean %s',cell,s$pattern,s$family,100*s$p,s$affected,ifelse(is.na(s$positive_mean),'determined by count distribution',s$positive_mean))
 vals<-function(prefix,digits=3)paste0(fmt(x[[paste0(prefix,'_median')]],digits),' [',fmt(x[[paste0(prefix,'_q25')]],digits),', ',fmt(x[[paste0(prefix,'_q75')]],digits),']')
 rr<-function(label,values)paste0('| ',label,' | ',paste(values,collapse=' | '),' |')
 c(title,'', '| Summary | Poisson | NB2 | Hurdle NB2: occurrence | Hurdle NB2: positive counts |','|---|---:|---:|---:|---:|',rr('People informing component, median',fmt(x$observations_median,0)),rr('Simple model: passed / 500',x$simple_pass),rr('Simple model: stratum variance, median [IQR]',vals('simple')),rr('Additive model: passed / 500',x$additive_pass),rr('Additive model: stratum variance, median [IQR]',vals('additive')),rr('PCV (%), median [IQR]',vals('pcv',1)),rr('Paired datasets contributing to PCV',x$pcv_n),rr('Paired PCVs below zero',x$pcv_negative),rr('Additive boundary variance, among passes',x$additive_boundary),'')
}
notes<-c('## How to read this table','', 'All columns use the prespecified regularised analysis (category-penalty SD 1). Each setting contains 500 independently simulated datasets and 72 possible strata. Simple models contain an intercept and stratum random intercept; additive models also include all constituent category main effects. Hurdle NB2 is one two-part approach, displayed in two component columns.','', 'Variances are on different model scales: log count mean for Poisson/NB2, log odds for occurrence, and log parent mean for zero-truncated NB2 positive counts. Their magnitudes must not be ranked across columns as if they measured the same quantity. Positive-count modelling uses only affected people. All strata remain in the prediction grid.','', 'Variance rows summarise fits passing optimiser and Hessian checks separately for each specification. IQR means the 25th–75th percentiles across replications, not a confidence interval. PCV is calculated within each replication as 100 × (1 − additive variance / simple variance), then summarised. It is not calculated from the displayed median variances. PCV requires both fits to pass and simple variance > 1e-8; its paired denominator is shown. Negative PCVs are retained. Boundary counts use variance <= 1e-8, matching the PCV denominator exclusion.','', 'PCV describes a change in model-scale variance after adding category effects. It does not measure the proportion of health inequality caused by those categories. These are supporting descriptive model summaries, not validation of PCV recovery or a method-ranking criterion. The main accuracy comparisons and conditional-availability caveats still apply.','', 'Fixed-effect estimates and standard errors were not retained in the completed run; the saved maximum coefficient cannot reconstruct them. VPC, AUC and comparable fitted-model uncertainty intervals were not validated in this experiment, so they are not invented or substituted. No new models were fitted.','')
all<-c('# Parallel MAIHDA results: all 36 settings','',notes,unlist(lapply(g$cell,render)))
writeLines(all,file.path(pub,'24_MAIHDA_tables_all_settings.md'),useBytes=TRUE)
main<-c('# Proposed parallel MAIHDA results table','', 'The two panels below cover the contrasting settings already used as examples in the article. They do not represent the whole design; the same table for every setting is in `24_MAIHDA_tables_all_settings.md`. These are simulation summaries, not results from an observed health population.','',render(1),render(23),notes,'## Suggested manuscript text','', '“Table 3 presents conventional MAIHDA summaries for the three count approaches, with separate occurrence and positive-count components for hurdle NB2. It shows how adding category effects changes estimated between-stratum variance in two contrasting settings. The corresponding summaries for all settings are provided in the supplement. These model-scale summaries complement the accuracy results; they do not identify which approach most accurately describes the health outcome.”','', 'For a journal table, use a merged Hurdle NB2 column heading above its two components. Keep the fit and paired-PCV denominators visible. Insert this as a draft Table 3 only after trimming other material to preserve the 4,000-word ceiling. The current manuscript is preserved unchanged pending that layout decision.')
writeLines(main,file.path(pub,'23_parallel_MAIHDA_results_table.md'),useBytes=TRUE)
print(z[z$cell %in% c(1,23),c('cell','component','simple_pass','additive_pass','simple_median','additive_median','pcv_n','pcv_median')])

cat("\nImportant: in setting 23, the NB2 simple-model variance is near zero; its PCV must not be interpreted as evidence of accurate recovery.\n",file=file.path(pub,"23_parallel_MAIHDA_results_table.md"),append=TRUE)
