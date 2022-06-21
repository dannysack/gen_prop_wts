library(tidyverse)
library(rms)
library(mice)


# function to calculate the numerator for orm
orm.num <- function(vec) {
  num <- rep(NA, length(vec))
  for(i in 1:length(vec)){
    num[i] <- sum(vec == vec[i]) / sum(!is.na(vec))
  }
  num
}

# function to calculate the denominator for orm
orm.denom <- function(df, vec, colname) {
  if(nrow(df) != length(vec)) {
    stop("Predicted Probabilities and Exposure Vector Different Lengths")
  }
  
  denom <- rep(NA, nrow(df))
  for(i in 1:nrow(df)){
    denom[i] <- as.numeric(df[i, paste0(colname, "=", vec[i])])
  }
  denom
}

# create orm weights
orm.wt <- function(object, exposure, cov_form){
  #first do some checks
  # make sure exposure is in quotes
  if(is.character(exposure) == FALSE){stop("Please enter the exposure as a character")}
  # make sure the cov_form is in quotes
  if(is.character(cov_form) == FALSE){stop("Please enter the covariate formula as a character
                                   For example: '~ x1 + x2 + x3'")}
  # now make formula
  formula <- formula(paste(exposure, cov_form))
  
  # now determine data type and make list of models
  if(is.data.frame(object) == TRUE){ # if you're using one dataframe
    # first make object into data
    data <- object
    # make list of models
    mods <- list(orm(formula, data = data))
    # finally make list of exposures
    exp <- list(data[[exposure]])
  } else if(mice::is.mids(object) == TRUE){ # if you're using a mice object
    # first make imputation object into data
    data <- complete(as.mids(long), "all")
    # make list of models
    mods <- data %>% map(~ orm(formula, data = .x))
    # finally make list of exposures
    exp <- data %>% map(~ .x[[exposure]])
  } else {
    stop("Please make sure the object is a data.frame or mids object")
  }
  
  # now create a list of dataframes of predicted probabilities for each model
  pp <- mods %>%
    map(~ as_tibble(predict(.x, type = "fitted.ind")))
  # now need to calculate numerator (should be the same across all imputed datasets)
  # now calculate numerator
  nums <- exp %>%
    map(~ orm.num(.x))
  # now calculate the denominator (should be different across all imputed datasets)
  denoms <- map2(pp, exp, ~ orm.denom(df = .x, vec = .y, colname = exposure))
  # now calculate weights
  orm_wts <- map2(nums, denoms, ~ .x / .y)
  orm_wts
}