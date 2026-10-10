# All six model specifications use one backend and its default optimiser.
v3_fit_component <- function(formula,data,family,label,penalty_sd=NA_real_) {
  warnings <- character()
  start <- proc.time()[['elapsed']]
  design_rank <- fixed_coefficients <- NA_integer_
  support_ok <- FALSE
  fit <- tryCatch(withCallingHandlers({
    if(!nrow(data)) stop('No observations for this component.')
    fixed <- as.formula(gsub(' + (1 | stratum)','',paste(deparse(formula),collapse=' '),fixed=TRUE))
    x <- model.matrix(fixed,data=data)
    design_rank <- qr(x)$rank
    fixed_coefficients <- ncol(x)
    if(design_rank < fixed_coefficients) stop('Fixed-effect design is rank deficient; category contrasts cannot all be estimated.')
    response <- model.response(model.frame(fixed,data=data))
    if(all(response==0)) stop('All responses are zero; finite component estimation is unsupported.')
    if(family$family=='binomial' && all(response==1)) stop('All occurrence responses are one.')
    if(family$family=='truncated_nbinom2' && all(response==1)) stop('No recurrent observations; positive-count dispersion is unsupported.')
    support_ok <- TRUE
    component <- if(family$family=='binomial') 'occurrence' else if(family$family=='truncated_nbinom2') 'positive' else 'count'
    priors <- if(is.na(penalty_sd)) NULL else data.frame(
      prior=c(sprintf('normal(%g,%g)',v3_config$intercept_mean[component],v3_config$intercept_sd),
              sprintf('normal(0,%g)',penalty_sd)),class='beta',coef=c('(Intercept)',''))
    # Intercept-only models have no slope coefficients to penalise.
    if(!is.null(priors) && ncol(x)==1) priors <- priors[1,,drop=FALSE]
    glmmTMB::glmmTMB(formula,data=data,family=family,weights=frequency,priors=priors)
  },
    warning=function(w) {warnings <<- c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),
    error=function(e)e)
  failed <- inherits(fit,'error')
  variance <- if(failed) NA_real_ else as.numeric(glmmTMB::VarCorr(fit)$cond$stratum[1,1])
  diagnostic <- data.frame(component=label,n_observations=sum(data$frequency),n_frequency_rows=nrow(data),
    design_rank=design_rank,fixed_coefficients=fixed_coefficients,data_support_ok=support_ok,fit_returned=!failed,
    optimiser_ok=if(failed) FALSE else isTRUE(fit$fit$convergence==0L),
    hessian_ok=if(failed) FALSE else isTRUE(fit$sdr$pdHess),
    variance=variance,boundary=if(failed) NA else variance < 1e-8,
    max_abs_fixed_coefficient=if(failed) NA_real_ else max(abs(glmmTMB::fixef(fit)$cond)),
    seconds=proc.time()[['elapsed']]-start,
    optimiser_message=if(failed) '' else paste(fit$fit$message,collapse=' | '),
    warnings=paste(unique(warnings),collapse=' | '),
    error=if(failed) conditionMessage(fit) else '',stringsAsFactors=FALSE)
  list(fit=if(failed) NULL else fit,diagnostic=diagnostic)
}

v3_count_predictions <- function(fit,grid,family,k) {
  mu <- exp(as.numeric(predict(fit,newdata=grid,type='link',allow.new.levels=TRUE)))
  shape <- if(family=='poisson') Inf else as.numeric(sigma(fit))
  mass <- if(family=='poisson') -expm1(-mu) else v3_positive_mass(mu,shape)
  parent_tail <- function(k) if(family=='poisson') ppois(k-1,mu,lower.tail=FALSE) else
    pnbinom(k-1,mu=mu,size=shape,lower.tail=FALSE)
  data.frame(stratum=grid$stratum,p=mass,m_plus=mu/mass,expected=mu,
             recurrent=parent_tail(2),tail=parent_tail(k),parent_mu=mu,shape=shape)
}

v3_fit <- function(sim,k=v3_config$tail_threshold,penalty_sd=NA_real_) {
  predictions <- list();diagnostics <- list();errors <- list();variances <- list()
  for(spec in c('simple','additive')) {
    rhs <- if(spec=='simple') '1 + (1 | stratum)' else 'a + b + c + d + (1 | stratum)'
    f <- function(response) as.formula(paste(response,'~',rhs))
    pos <- sim$data[sim$data$y>0,,drop=FALSE]
    components <- list(
      poisson=v3_fit_component(f('y'),sim$data,poisson(),paste(spec,'poisson',sep='_'),penalty_sd=penalty_sd),
      nb=v3_fit_component(f('y'),sim$data,glmmTMB::nbinom2(),paste(spec,'nb',sep='_'),penalty_sd=penalty_sd),
      occurrence=v3_fit_component(f('positive'),sim$data,binomial(),paste(spec,'occurrence',sep='_'),penalty_sd=penalty_sd),
      positive=v3_fit_component(f('y'),pos,glmmTMB::truncated_nbinom2(),paste(spec,'positive',sep='_'),penalty_sd=penalty_sd))
    for(name in names(components)) {
      id <- paste(spec,name,sep='_')
      diagnostics[[id]] <- cbind(specification=spec,components[[name]]$diagnostic)
      variances[[id]] <- components[[name]]$diagnostic$variance
    }
    for(model in c('poisson','nb','hurdle')) {
      id <- paste(spec,model,sep='_')
      used <- if(model=='hurdle') c('occurrence','positive') else model
      ok <- all(vapply(components[used],function(z) z$diagnostic$optimiser_ok && z$diagnostic$hessian_ok,logical(1)))
      pred <- tryCatch({
        if(model!='hurdle' && is.null(components[[model]]$fit)) stop('A required component did not fit.')
        if(model!='hurdle') {
          result <- v3_count_predictions(components[[model]]$fit,sim$truth,model,k)
        } else {
          # Each estimand depends only on the component(s) needed to identify it.
          component_errors <- character()
          extract <- function(expr) tryCatch(expr,error=function(e) {
            component_errors <<- c(component_errors,conditionMessage(e)); NULL
          })
          occ <- extract({
            if(is.null(components$occurrence$fit)) stop('Occurrence component did not fit.')
            as.numeric(predict(components$occurrence$fit,newdata=sim$truth,type='response',allow.new.levels=TRUE))
          })
          pos <- extract({
            if(is.null(components$positive$fit)) stop('Positive component did not fit.')
            parent <- v3_count_predictions(components$positive$fit,sim$truth,'nb',k)
            list(parent=parent,mean=as.numeric(predict(components$positive$fit,
                 newdata=sim$truth,type='response',allow.new.levels=TRUE)))
          })
          if(is.null(occ)) occ <- rep(NA_real_,nrow(sim$truth))
          if(is.null(pos)) pos <- list(mean=rep(NA_real_,nrow(sim$truth)),
            parent=data.frame(p=NA_real_,recurrent=NA_real_,tail=NA_real_,parent_mu=NA_real_,shape=NA_real_))
          parent <- pos$parent
          result <- data.frame(stratum=sim$truth$stratum,p=occ,m_plus=pos$mean,
            expected=occ*pos$mean,recurrent=occ*parent$recurrent/parent$p,
            tail=occ*parent$tail/parent$p,parent_mu=parent$parent_mu,shape=parent$shape)
        }
        result
      },error=function(e)e)
      err <- if(inherits(pred,'error')) conditionMessage(pred) else if(model=='hurdle') paste(unique(component_errors),collapse=' | ') else ''
      if(inherits(pred,'error')) pred <- data.frame(stratum=sim$truth$stratum,p=NA_real_,
        m_plus=NA_real_,expected=NA_real_,recurrent=NA_real_,tail=NA_real_,parent_mu=NA_real_,shape=NA_real_)
      component_ok <- function(name) isTRUE(components[[name]]$diagnostic$optimiser_ok) && isTRUE(components[[name]]$diagnostic$hessian_ok)
      predictions[[id]] <- cbind(specification=spec,model=model,diagnostic_ok=ok,
        occurrence_diagnostic_ok=if(model=='hurdle') component_ok('occurrence') else ok,
        positive_diagnostic_ok=if(model=='hurdle') component_ok('positive') else ok,
        prediction_error=err,pred)
    }
  }
  diagnostics <- do.call(rbind,diagnostics)
  pcv <- do.call(rbind,lapply(c('poisson','nb','occurrence','positive'),function(component) {
    a <- variances[[paste('simple',component,sep='_')]]
    b <- variances[[paste('additive',component,sep='_')]]
    ids <- paste(c('simple','additive'),component,sep='_')
    d <- diagnostics[diagnostics$component %in% ids,]
    eligible <- all(d$optimiser_ok & d$hessian_ok) && is.finite(a) && a>1e-8 && is.finite(b)
    data.frame(component=component,simple_variance=a,additive_variance=b,eligible=eligible,
               pcv=if(eligible) 1-b/a else NA_real_)
  }))
  predictions <- do.call(rbind,predictions)
  predictions$recurrent_given_positive <- predictions$recurrent/predictions$p
  # For the hurdle model this conditional target does not require occurrence estimation.
  for(spec in c('simple','additive')) {
    idx <- predictions$specification==spec & predictions$model=='hurdle'
    parent <- predictions$parent_mu[idx];shape <- predictions$shape[idx]
    predictions$recurrent_given_positive[idx] <- pnbinom(1,mu=parent,size=shape,lower.tail=FALSE)/v3_positive_mass(parent,shape)
  }
  list(predictions=predictions,diagnostics=diagnostics,pcv=pcv)
}

v3_evaluate <- function(predictions,truth) {
  result <- list()
  for(id in unique(paste(predictions$specification,predictions$model))) {
    d <- predictions[paste(predictions$specification,predictions$model)==id,]
    t <- truth[match(d$stratum,truth$stratum),]
    for(target in c('p','m_plus','expected','recurrent','tail','recurrent_given_positive')) for(weighting in c('equal_stratum','population')) {
      x <- d[[target]];y <- t[[target]]
      w <- if(weighting=='population') t$weight else rep(1/nrow(t),nrow(t))
      # Do not silently drop an unestimable stratum and change the target population.
      complete <- all(is.finite(x)) && all(is.finite(y))
      cor_safe <- function(method) if(complete && sd(x)>1e-10 && sd(y)>1e-10) cor(x,y,method=method) else NA_real_
      result[[length(result)+1L]] <- data.frame(specification=d$specification[1],model=d$model[1],
        target=target,weighting=weighting,
        diagnostic_ok=if(target=='p' && 'occurrence_diagnostic_ok' %in% names(d)) all(d$occurrence_diagnostic_ok) else
          if(target %in% c('m_plus','recurrent_given_positive') && 'positive_diagnostic_ok' %in% names(d)) all(d$positive_diagnostic_ok) else all(d$diagnostic_ok),
        predictions_complete=complete,n_predictions=sum(is.finite(x)),
        bias=if(complete) sum(w*(x-y)) else NA_real_,
        rmse=if(complete) sqrt(sum(w*(x-y)^2)) else NA_real_,
        pearson_equal=if(weighting=='equal_stratum') cor_safe('pearson') else NA_real_,
        spearman_equal=if(weighting=='equal_stratum') cor_safe('spearman') else NA_real_)
    }
  }
  do.call(rbind,result)
}
